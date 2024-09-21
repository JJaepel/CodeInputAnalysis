function ce = calcOriParamsCIB(ce, metadata,info,verbose)

% Based on the cyc or cycRes, it calculates all the relevanted parameters
% for a drifting ori stimulus, like OSI, prefDir, ...
%
% Inputs:
% - ce: structure containing information about ROI, each row is one roi,
% containing anatomical information, raw & dff traces, chopped stimulus
% traces and cyc traces
% - metadata: structure containing information about the stimulus that was
% run, such as how many different stims
% - info: all information about the experiment, such as whether it was a
% cell and where to save things
% - verbose: do you want to plot the ROIs?
%
% Outputs:
% - ce: updated with meanResp, OSI, DSI, prefDir, prefOri, Bandwidth, ...
% - ROIsAna.mat: File with the store ce

%% Step 0: Set parameters

if nargin<3
    verbose = 0;
end

%set parameters
opts = optimset('Display','off');

%fit orientation
numOri = (length(metadata(1).uniqStims)-1)/4;
n = (length(metadata(1).uniqStims)-1)/2;
xs =   0:0.1:(2*pi);

% boundaries
ub = [2*pi pi     5  5  1];
lb = [0    pi/n  0  0  0]; %% change lb(5) to -1?###########

%% Step 1: Go through all ROIs
for cc = 1:length(ce)
    % starting parameter for fit
    angs = 0:pi/numOri:2*pi-(pi/numOri);
    p(1) = 0;
    p(2) = pi/numOri; 
    p(3) = 1; 
    p(4) = 1; 
    p(5) = 0;
    
    f = @(p,x) p(3).*exp(-(angdiffVNew(x-p(1)).^2)./p(2)) +...
           p(4).*exp(-(angdiffVNew(x-p(1)-pi).^2)./p(2)) + p(5); 
       
    % get the trace, depending on whether it is cell, spine or dendrite
    if info.isCell  %this is where I take data in  - 8x33x25 - 8 would be trails, 33 would be stims and 25 is frames 
        cyc = ce(cc).cyc;
    else 
        if ce(cc).spine
            cyc = ce(cc).cycRes; %this creates a struct named cyc. Why is it cycRes when it all becomes cyc?
        else
            cyc = ce(cc).cyc;
        end
    end
    % find the peaks for each dir and trial
    for ii = 1:size(cyc,1) 
        for jj = 1:size(cyc,2)
            r = squeeze(cyc(ii,jj,:));
            ff = fft(r)./length(r);
            peak(ii,jj) = ff(1)+2*abs(ff(2));
            if ii==size(cyc,1)
                peak(ii,jj) = ff(1);
            end
        end
    end
    
    for i = 1:2 %gong through two eyes
        %first get the blank for the spont data
        spont = median(peak(end,:));

        if i == 1
            eyeStart = 1;
            eyeEnd = 16;
        else
            eyeStart = 17;
            eyeEnd = 32;
        end
        
        %get the part of the data that is for that eye
        eyePeak = peak(eyeStart:eyeEnd,:);

        %remove spontaneous data
        eyePeak = eyePeak - spont;
        eyePeak(isnan(eyePeak)) = 0;
        eyePeak(eyePeak<0) = 0;
    
        %mean over trials
        meanResp = mean(eyePeak(1:n,:),2)'; 
        errResp = std(eyePeak(1:n,:),0,2)/sqrt(size(eyePeak(1:n,:),2)); %SEM
        meanResp(meanResp<0 )=0;
    
        %fit to make it circular
        angs2 = [angs angs(1)]; 
        angs2 = (ones(size(cyc,2),1)*angs2)';
        peak2 = [eyePeak(1:n,:); eyePeak(1,:);];
    
        %find max Response
        [~,ind] = max(meanResp); 
        angs(ind);
        p(1) = angs(ind);

        if isnan(p(1))
           p(1) = pi;
        end
        p(3) = max(nanmean(eyePeak));

        xo = p;
        err = 0;
        if isnan(xo(3))~= 0 % if nan in peak
            err  = 1;
        else
            % fit the data
            [phat,resnorm] = lsqcurvefit(f,xo,angs2,peak2,lb,ub,opts); %fit over all directions

            %compute OSI & DSI
            OSI= sqrt(sum(sin(2*angs).*meanResp).^2 + sum(cos(2*angs).*meanResp).^2)/sum(meanResp);
            DSIvect = sqrt(sum(sin(angs).*meanResp).^2 + sum(cos(angs).*meanResp).^2)/sum(meanResp); 
            pref = phat(1); %prefDir
            pref(pref<0) = pi + pref;

            [b,~] = hist(pref,angs);
            pref = find(b);
            if pref<=n/2
                null = pref+n/2;
            else
                 null = pref-n/2;
            end
            DSI = abs(meanResp(pref)-meanResp(null))./sum(meanResp([pref null]));

            %compute bandwith
            [bandwidth] = computeBandWidth(meanResp);

             pref = phat(1);
             peakFit = f(phat,xs);
        end
        
        %% STEP 3: Store data
        if i == 1
            eye = 'Contra';
        else
            if i == 2
                eye = 'Ipsi';
            end
        end
        ce(cc).(strcat('peak',eye)) = eyePeak;
        ce(cc).(strcat('phat',eye)) = phat;
        ce(cc).(strcat('rsq',eye)) = resnorm;
        ce(cc).(strcat('meanResp',eye)) = meanResp; 
        ce(cc).(strcat('mpeakErr',eye)) = errResp;
        ce(cc).(strcat('pref',eye)) = pref;
        ce(cc).(strcat('prefDir',eye)) = rad2deg(pref);
        if ce(cc).(strcat('prefDir',eye)) >= 180
            ce(cc).(strcat('prefOri',eye)) = ce(cc).(strcat('prefDir',eye))-180;
        else
            ce(cc).(strcat('prefOri',eye)) = ce(cc).(strcat('prefDir',eye));
        end
        ce(cc).(strcat('OSI',eye)) = OSI;
        ce(cc).(strcat('DSIvect',eye)) = DSIvect;
        ce(cc).(strcat('DSI',eye)) = DSI;
        ce(cc).(strcat('peakFit',eye)) = peakFit;
        ce(cc).(strcat('bandwidth',eye)) = bandwidth;
        
        if err == 1
            fns = {'peak','phat','rsq','meanResp','mpeakErr','pref','OSI','DSIvect', 'DSI','peakfit'};
            for f = 1:length(fns)
                ce(cc).(strcat(fns{f}, eye)) = 0;
            end
        end
    end
    %% STEP 4: ODI sum, congruency and mismatch
    %calculate ODI, congruency and mismatch
    ce(cc).ODI = -(max(ce(cc).meanRespContra) - max(ce(cc).meanRespIpsi))./(max(ce(cc).meanRespContra) + max(ce(cc).meanRespIpsi));
    ce(cc).ODIsum = -(sum(ce(cc).meanRespContra) - sum(ce(cc).meanRespIpsi))./(sum(ce(cc).meanRespContra) + sum(ce(cc).meanRespIpsi));
    ce(cc).congruency = ComputeCongruency(ce(cc).meanRespContra, ce(cc).meanRespIpsi);
    ce(cc).mismatch = OrientationMismatch(ce(cc).prefContra,ce(cc).prefIpsi);

    %% STEP 5: Plot if applicable
	if verbose
        plotSpineTraceAndFit(ce, cc)
        saveas(gcf, fullfile(info.saveDirROI, ['StimResp_ROI_Nr_' num2str(cc) '.png']))
        close gcf
    end
end

%% Step 6: Save data 
save([info.saveDir 'ROIsAna.mat'], 'ce', '-mat') 