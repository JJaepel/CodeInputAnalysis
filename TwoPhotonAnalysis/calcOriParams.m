function ce = calcOriParams(ce, metadata,info,verbose)

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
numOri = (length(metadata(1).uniqStims)-1)/2;
n = length(metadata(1).uniqStims)-1;
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
    if info.isCell
        cyc = ce(cc).cyc;
    else 
        if ce(cc).spine
            cyc = ce(cc).cycRes;
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
    
    %remove spontaneous component
    spont = mean(peak(end,:)); 
    peak = peak - spont;
    peak(isnan(peak)) = 0;
    peak(peak<0) = 0;
    
    %mean over trials
    meanResp = mean(peak(1:n,:),2)'; 
    errResp = std(peak(1:n,:),0,2)/sqrt(size(peak(1:n,:),2)); %SEM
    meanResp(meanResp<0 )=0;
    
    %fit to make it circular
    angs2 = [angs angs(1)]; 
    angs2 = (ones(size(cyc,2),1)*angs2)';
    peak2 = [peak(1:n,:); peak(1,:);];
    
    %find max Response
    [~,ind] = max(meanResp); 
    angs(ind);
    p(1) = angs(ind);

    if isnan(p(1))
        p(1) = pi;
    end
    p(3) = max(nanmean(peak));

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
        
        %% STEP 3: Plot if applicable
        if verbose
            figure(cc)
            subplot(2,1,1)
            plotcycRes2(cyc,1:n)
            box off
            set(gca,'TickDir','out')
            set(gca,'Xtick',[])
            ylabel 'NormResp'

            subplot(2,1,2)
            plot(rad2deg(angs),meanResp,'ok',rad2deg(xs),peakFit,'--k')
            box off
            ylabel 'Peak'
            set(gca,'TickDir','out')
            ylim([0 max(max(meanResp), max(peakFit))])
            xlim([0 360])
            xlabel 'Direction in deg'
            set(gcf, 'Color', 'w')
            saveas(gcf, fullfile(info.saveDirROI, ['StimResp_ROI_Nr_' num2str(cc) '.png']))
            close gcf
        end

        %% STEP 4: Store data
        ce(cc).peak = peak;
        ce(cc).phat = phat;
        ce(cc).rsq = resnorm;
        ce(cc).meanResp = meanResp; 
        ce(cc).mpeakErr = errResp;
        ce(cc).pref = pref;
        ce(cc).prefDir = rad2deg(pref);
        if ce(cc).prefDir >= 180
            ce(cc).prefOri = ce(cc).prefDir-180;
        else
            ce(cc).prefOri = ce(cc).prefDir;
        end
        ce(cc).OSI = OSI;
        ce(cc).DSIvect = DSIvect;
        ce(cc).DSI = DSI;
        ce(cc).peakFit = peakFit;
        ce(cc).bandwidth = bandwidth;
    end
    if err == 1
        fns = {'peak','phat','rsq','meanResp','mpeakErr','pref','OSI','DSIvect', 'DSI','peakfit'};
        for f = 1:length(fns)
            ce(cc).(fns{f}) = 0;
        end
    end
end

%% Step 5: Save data 
save([info.saveDir 'ROIsAna.mat'], 'ce', '-mat') 