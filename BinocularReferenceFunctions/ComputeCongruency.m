function congruency = ComputeCongruency(contraresp, ipsiresp)
% Calculates congruency of contra and ipsi responses.

% Input: 
%   - contraresp: response to contra eye, expected size n x 16 or 8 (dir or
%   orispace)
%   - ipsiresp: response to ispi eye stimulation, same size as contra resp

% Steps:
%   1) Check if both responses are there and wheter it is ori or dir space
%   2) Format responses so they are in ori space
%   3) Calculate congruency as pairwise correlation between the two
%   responses

% Output:
%   - congruency: pairwise correlation between response to ipsi and
%   contralateral stimulation

% Clara Tepohl & Juliane Jaepel, modified from Ben Scholl
% Max Planck Florida Institute for Neuroscience
% May 2024

%% Step 1.) Check if both responses are there and wheter it is ori or dir space

if ~isempty(contraresp) && ~isempty(ipsiresp)
    if size(contraresp,2)==16
        dirspace =1;
    else
        dirspace = 0;
    end
    
    %initialize variable
    congruency = nan(size(contraresp,1),1); 
    
    % Step 2) Format responses so they are in ori space
    for n = 1:size(contraresp,1)
        if sum(isnan(contraresp(n,:)))<16 || sum(isnan(ipsiresp(n,:)))<16
            
            % fold response if it is dirspace
            if dirspace
                respC = contraresp(n,1:8) + contraresp(n,9:16);
                respI = ipsiresp(n,1:8) + ipsiresp(n,9:16);
            else
                respC = contraresp(n,1:8);
                respI = ipsiresp(n,1:8);
            end
            % Step 3.) Calculate congruency as pairwise correlation between the two responses
            congruency(n) = corr(respC',respI','rows','pairwise');
        end
    end

else
    congruency = nan;
end
