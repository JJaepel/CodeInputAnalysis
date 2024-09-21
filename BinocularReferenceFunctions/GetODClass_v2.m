function ce = GetODClass_v2(ce)
% Defines ocular class based on monocular responeses. If evalCIB has been
% used to classify C and I as responsive yet, use that.
% If not, run it and use ce.usec and ce.usei to classify Ocular class

% Input: 
% - ce: structure containing all data of the ROIs

% Steps:

%   1.) If not already calculated, get monocular responsiveness
%   2.) Classify based on monocular responses

% Output: 
% - ce(cc).OD: with OD class labels:
%         -1 = contra   monocular
%          0 = binocular
%          1 = ipsi     monocular

% Clara Tepohl & Juliane Jaepel, modified from Ben Scholl
% Max Planck Florida Institute for Neuroscience
% May 2024

%% Step 1.) If not already calculated, get monocular responsiveness
if ~isfield(ce,'usec')
    ce = evalCIB(ce, indx);
end

%% Step 3.) Classify based on monocular responses

for cc = 1:length(ce)
    if ce(cc).usec==1 && ce(cc).usei==0
        ce(cc).OD = -1;                        % contra
    elseif ce(cc).usec==1 && ce(cc).usei==1
        ce(cc).OD = 0;                         % binocular
    elseif ce(cc).usec==0 && ce(cc).usei==1
        ce(cc).OD = 1;                         % ipsi
    else
        ce(cc).OD = nan;                       % not responsive
    end
end