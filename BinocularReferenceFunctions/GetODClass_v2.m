function OD = GetODClass_v2(ce,indx)
% Defines ocular class based on monocular responeses. If evalCIB has been
% used to classify C and I as responsive yet, use that.
% If not, run it and use ce.usec and ce.usei to classify Ocular class

% Input: 
% - ce: structure containing all data of the ROIs
% - inx: indices of rows (= spines/soma) of ce struct to compute Ocular 
% class for.

% Steps:
%   1.) Define which indexes are to be run and predefine OD
%   2.) If not already calculated, get monocular responsiveness
%   3.) Classify based on monocular responses

% Output: 
% - OD: array (length(indx),1) with OD class labels:
%         -1 = contra   monocular
%          0 = binocular
%          1 = ipsi     monocular

% Clara Tepohl & Juliane Jaepel, modified from Ben Scholl
% Max Planck Florida Institute for Neuroscience
% May 2024

%% Step 1.) Define which indexes are to be run and predefine OD
if nargin<1
    indx = 1:length(ce);
end

OD = nan(length(indx),1);

%% Step 2.) If not already calculated, get monocular responsiveness

if ~isempty(indx)
    if ~isfield(ce,'usec')
        ce = evalCIB(ce, indx);
    end
    
    % 3.) Classify based on monocular responses
    for ii = 1:length(indx)
        j = indx(ii);
        
        if ce(j).usec==1 && ce(j).usei==0
            OD(ii) = -1;                        % contra
        elseif ce(j).usec==1 && ce(j).usei==1
            OD(ii) = 0;                         % binocular
        elseif ce(j).usec==0 && ce(j).usei==1
            OD(ii) = 1;                         % ipsi
        else
            OD(ii) = nan;                       % not responsive
        end
 
    end
else
    OD = [];
    disp('indx is empty')
end