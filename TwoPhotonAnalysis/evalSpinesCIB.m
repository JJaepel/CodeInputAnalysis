function ce = evalSpinesCIB(ce,info, id,thresh_resp)
% Checks for each input/spine if responses to each eye (C / I) pass 3
% criteria :
% (1) SNR > 1 
% (2) resp. Ampl > 0.1
% (3) residual correlation to dendrite <0.4
% 
% Inputs:
%   - ce: structure containing the data of the ROIs
%   (- id: indices of rows (= spines/soma) of ce struct to compute 
%   responsiveness for (default: whole ce struct gets analyzed))
%   (- thresh_SNR: threshold for signal to noise ratio (default: 1))
%   (- thresh_resp: threshold for responsiveness (default: 0.2 dF/F))

% Steps:
%   1.) Get responses and format input correctly depending on how many 
%   stims were run
%   2.) Get spontaneous activity & SNR
%   3.) Get residual correlation for spines
%   4.) Check, if in general all criteria are fullfilled
%   5.) Check, for each eye if all criteria are fullfilled

% Output: 
%  - ce: updated to include responsiveness

% Clara Tepohl & Juliane Jaepel, modified from Ben Scholl
% Max Planck Florida Institute for Neuroscience
% May 2024


if nargin<5  %changed from 4 to 5 coz "info" added
    thresh_resp = 0.2;
    id = 1:length(ce);
end
if nargin==1
    id = 1:length(ce);
end

%% Step 1.) Get responses and format input correctly depending on how many stims were run
for cc = id 
    %%%This step is already done in calcOri
    %spine or soma -> use cycRes or cyc
    if info.isCell
        cyc = ce(cc).cyc;
    else
        if ce(cc).spine
            cyc = ce(cc).cycRes;
        else
            cyc = ce(cc).cyc;
        end
    end
    %%%%%%%%%%%%%
    
    spontind = size(cyc,1); %ones(size(ce,1),1)*size(cyc,1);
        
    % grab correct mpeak for various eye/stim conditions:
    if size(cyc,1)==17 && ~isfield(ce,'meanRespContra') && ~isfield(ce,'meanRespIpsi')% just one eye condition
        respC = [ce(cc).mpeak];
        respI = respC*0;
        respB = respC*0;

        resperrC = [ce(cc).mpeakerr'];
        resperrI = resperrC*0;
        resperrB = resperrC*0;
    elseif size(cyc,1)==33 %&& ~isfield(ce,'mpeakB')% C and I, one blank at the end
        respC = [ce(cc).meanRespContra];
        respI = [ce(cc).meanRespContra];
        respB = respI*0;

        resperrC = [ce(cc).mpeakErrContra'];
        resperrI = [ce(cc).mpeakErrIpsi'];
        resperrB = resperrI*0;
    end

    % reshape    
    resp = [respC respI respB];
    resperr = [resperrC resperrI resperrB];
    
    %% Step 2.) Get spontaneous activity & SNR
    % get blank activity -> spontaneous mean & error
    blank = squeeze(cyc(spontind,:,:));

    spont = mean(blank(:));
    spont(spont < 0) = 0;
    sponterr = std(mean(blank,2))./sqrt(size(cyc,2));

    %SNR
    snr = (resp - spont) ./ (resperr + sponterr);

    %% Step 3.) Get residual correlation for spines
    if info.isCell
        residualcorr = 0;
    else
        if ce(cc).spine
            residualcorr = computeStimCorrSpDend(cc,ce);
        else
            residualcorr = 0;
        end
    end
    
    %% Step 4.) Check, if in general all criteria are fullfilled
    if (residualcorr<.4) && sum((resp>0.1) & (snr>1))>0
        ce(cc).good = 1;
    else
        ce(cc).good = 0;
    end
    
    %% Step 5.) Check, for each eye if all criteria are fullfilled
    % a) Get eye-specific SNR  
    snrC = (respC - spont) ./ (resperrC + sponterr);
    snrI = (respI - spont) ./ (resperrI + sponterr);
    snrB = (respB - spont) ./ (resperrB + sponterr);

    ce(cc).snrC = snrC;
    ce(cc).snrI = snrI;
    ce(cc).snrB = snrB;
        
    % b) contra responsive
    if residualcorr<.4 && sum((respC>0.1) & (snrC>1))>0
        ce(cc).usec = 1;
    else
        ce(cc).usec = 0;
    end
    
    % c) ipsi responsive
    if residualcorr<.4 && sum((respI>0.1) & (snrI>1))>0
        ce(cc).usei = 1;
    else
        ce(cc).usei = 0;
    end
    
    % d) bino responsive
    if residualcorr<.4 && sum((respB>0.1) & (snrB>1))>0
        ce(cc).useb = 1;
    else
        ce(cc).useb = 0;
    end
    
end

%% Step 6: Save in mat file
save([info.saveDir 'ROIsAna.mat'], 'ce', '-mat') 
