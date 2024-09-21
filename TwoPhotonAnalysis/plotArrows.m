function plotArrows(degreeIncrement, xStart, arrowLength)
% Function to plot arrows in specified degree increments and starting x-coordinate.
%
% Inputs:
%   - degree_increment: The angular increment for each arrow (in degrees)
%   - x_start_point: The x-coordinate from which the first arrow starts (array of x-values)
%
% Steps:
% 1.) Define the arrows
% 2.) Get the position
% 3.) Plot

% Output:
%   (-plotted arrows)

% Juliane Jaepel
% Max Planck Florida Institute for Neuroscience
% September 2024

if nargin < 3
    arrowLength = 1;  
end

%% Step 1.) Define the arrows

% Define angles based on the specified degree increment
anglesDeg = 0:degreeIncrement:360;  % Array of angles in degrees

% Ensure that the number of x_start values matches the number of arrows (wrap angles if needed)
numArrows = length(xStart);
anglesDeg = anglesDeg(1:numArrows);  % Limit to match the number of arrows


%% Step 2.) Get the position
% Convert angles to radians
anglesRad = deg2rad(anglesDeg);

% Calculate u and v components of the arrows
u = arrowLength * cos(anglesRad);  % X components (cosine)
v = arrowLength * sin(anglesRad);  % Y components (sine)

% To ensure vertical centering, adjust the y_start such that arrows are centered
yCenter = 0;  % Center the arrows along the y-axis
yStart = yCenter - v / 2;  % Center the vertical component of each arrow

%% Step 3.) Plot
% plot the arrows using quiver
quiver(xStart, yStart, u, v, 0, 'k');  % 0 scaling, 'k' for black arrows

% Adjust the axis limits to view all arrows properly
axis equal;
xlim([min(xStart), max(xStart)]);
ylim([-arrowLength, arrowLength]);  % Set y-axis limits to keep arrows centered vertically
set(gca,'XColor', 'none', 'XTick', [], 'XColor', 'none');
set(gca,'YColor', 'none', 'YTick', [], 'YColor', 'none');
