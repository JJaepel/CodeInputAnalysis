function mismatch = OrientationMismatch(prefC,prefI)
% Gives the smaller absolute angle difference of two directions (in rad) 
% in orientation space(0-180 degree)

% Input:
% - prefC: one preference in degree (e. g. contra eye or soma)
% - prefI: other preference in degree (e. g. ipsi eye or spine)

% Steps:
%   1.) Convert preferences to radiance
%   2.) Calculate difference in radiance
%   3.) Convert mismatch to angle

% Clara Tepohl & Juliane Jaepel, modified from Ben Scholl
% Max Planck Florida Institute for Neuroscience
% May 2024

%% Step 1: Convert preferences to radiance
z_c = cos(prefC*2) + 1i*sin(prefC*2);
z_i = cos(prefI*2) + 1i*sin(prefI*2);

%% Step 2: Calculate difference in radiance
delta_z = z_c./z_i;

%% Step 3: Convert mismatch to angle
mismatch = abs(rad2deg(angle(delta_z))/2);