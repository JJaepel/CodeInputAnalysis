function plotSpineTrace(ce, spineIDs, figNum)

%Plots the contra and ipsi traces of a specific spine on top of each other
%for all directions

%Input:
%   - ce: structure containing the spine data
%   - spineIDs: which IDs should we plot
%   (- figNum: what numbeer should the figure have)

% Steps:
%   1.) Define figure and colors
%   2.) Plot the traces

% Output:
%   (- plotted figure)

% Juliane Jaepel, modified from Clara Tepohl
% Max Planck Florida Institute for Neuroscience
% September 2024

%% Step 1.) Define figure and colors

if nargin < 3
    figNum = 100;
end

%define the size of the plot based on how big it is
f = figure(figNum); 
f.Units = 'centimeters'; 
f.Position = [7 8 16 4.25+(length(spineIDs)-1)*2.75];

%define the colors
colors = struct;
colors.ipsi = [.9 .1 .1];
colors.contra = [.1 .1 .9];

%% Step 2.) Plot the traces
%go through all spines
for i = 1:length(spineIDs)
    ax(i) = axes('Position',[0.25 (4.25+(length(spineIDs)-1)*2.75)-2.75*i 15.5 2.5]);
    axes(ax(i))
    
    %get the traces
    try
        if ce(spineIDs(i)).spine == 1
            cyc = ce(spineIDs(i)).cycRes;
        else
            cyc = ce(spineIDs(i)).cyc;
        end
    catch
        cyc = ce(spineIDs(i)).cyc;
    end
    
    %define the size for plotting
    [~,nt,nl] = size(cyc); %stims, trials, frames
    inds = [1:nt];
    
    %get the ylim for all
    stDev = nanstd(squeeze(cyc),1)/sqrt(nt);
    mean = nanmean(squeeze(cyc),2);
    ylim = [0 max(stDev(:))+max(mean(:))];
    
    %now first plot the contra traces
    for ii = [1:16]
        xt = (1:nl) + (5+nl)*(ii-1); %move the start of the trace
        if ii==1
            hold off
        end
        y = smooth(nanmean(squeeze(cyc(ii,:,:)),1));
        errBar = smooth(nanstd(squeeze(cyc(ii,:,:)),1)./sqrt(nt)); %%%
        shadedErrorBar(xt,y,errBar,'lineprops', {'-','Color', colors.contra})
        hold on
    end
    
    %now plot the ipsi trace on top
    for ii = [17:32]
        xt = (1:nl) + (5+nl)*(ii-17);
        if ii==17
            hold off
        end
        y = smooth(nanmean(squeeze(cyc(ii,:,:)),1));
        errBar = smooth(nanstd(squeeze(cyc(ii,:,:)),1)./sqrt(nt)); %%%
        shadedErrorBar(xt,y,errBar,'lineprops', {'-','Color', colors.ipsi})
        hold on
    end
    
    %plot a dff bar
    rectangle('Position', [xt(end)+5, 0, 1, 0.25], 'FaceColor', 'k')
    
    %set scaling and remove axes
    set(ax(i), 'ylim', [0, max(stDev(:))+max(mean(:))])
    set(ax(i), 'XColor', 'none', 'XTick', [], 'XColor', 'none');
    set(gca,'YColor', 'none', 'YTick', [], 'YColor', 'none');
end

%plot a time bar
rectangle('Position', [xt(1), -0.1, xt(end)-xt(1), 0.1], 'FaceColor', 'k')

%% Step 3.) Add the arrow legend
ax(i+1) = axes('Position',[0.25 0 15.25 1.5]);
xStart = linspace(1,35, 17);
plotArrows(22.5, xStart, .9)
