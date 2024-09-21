function plotSpineTraceAndFit(ce, spineID, figNum)

%Plots the contra and ipsi traces of a specific spine on top of each other
%for all directions

%Input:
%   - ce: structure containing the spine data
%   - spineID: what is the spineID?
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
f.Position = [7 8 30.5 4];

%define the colors
colors = struct;
colors.ipsi = [.9 .1 .1];
colors.contra = [.1 .1 .9];

%% Step 2.) Plot the traces
ax(1) = axes('Position',[0.25 1.5 15.5 2.5]);
    
%get the traces
try
    if ce(spineIDs).spine == 1
        cyc = ce(spineID).cycRes;
    else
        cyc = ce(spineID).cyc;
    end
catch
    cyc = ce(spineID).cyc;
end

%define the size for plotting
[~,nt,nl] = size(cyc); %stims, trials, frames
inds = [1:nt];

%get the ylim for all
stDev = nanstd(squeeze(cyc),1)/sqrt(nt);
mean = nanmean(squeeze(cyc),2);
ylimTrace = [-0.2 max(stDev(:))+max(mean(:))];

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
set(ax(1), 'ylim', [0, max(stDev(:))+max(mean(:))])
set(ax(1), 'XColor', 'none', 'XTick', [], 'XColor', 'none');
set(gca,'YColor', 'none', 'YTick', [], 'YColor', 'none');

%plot a time bar
rectangle('Position', [xt(1), -0.2, xt(end)-xt(1), 0.1], 'FaceColor', 'k')

%% Step 3.) Add the arrow legend
ax(2) = axes('Position',[0.25 0 15.25 1.5]);
xStart = linspace(1,35, 17);
plotArrows(22.5, xStart, .9)

%% Step 4.) Add the tuning curves
ax(3) = axes('Position',[16.5 1.5 4 2]);
angs = 0:pi/8:pi-(pi/8);

mpeakC = ce(spineID).meanRespContra;
mpeakI = ce(spineID).meanRespIpsi;
mpeakCerr = ce(spineID).mpeakErrContra;
mpeakIerr = ce(spineID).mpeakErrIpsi;

%only use the better side
[~, prefCInd] =  max(mpeakC);
if prefCInd < 9
    mpeakC = mpeakC(1:8);
    mpeakCerr = mpeakCerr(1:8);
else
    mpeakC = mpeakC(9:16);
    mpeakCerr = mpeakCerr(9:16);
end

[~, prefIInd] =  max(mpeakI);
if prefIInd < 9
    mpeakI = mpeakI(1:8);
    mpeakIerr = mpeakIerr(1:8);
else
    mpeakI = mpeakI(9:16);
    mpeakIerr = mpeakIerr(9:16);
end

yMax = ceil(max(max(mpeakC)+max(mpeakCerr), max(mpeakI)+max(mpeakIerr))*10)/10;

%plot the curves
hold on
errorbar(rad2deg(angs),mpeakC, mpeakCerr, '-o', 'MarkerSize', 4, 'MarkerFaceColor', colors.contra, 'CapSize', 0);
errorbar(rad2deg(angs),mpeakI, mpeakIerr, '-o', 'MarkerSize', 4, 'MarkerFaceColor', colors.ipsi, 'CapSize', 0);

 %format
box off
set(gca,'TickDir','out')
ylim([0 yMax])
xlim([0 180]) 
offsetAxes(ax(3))
ax(3).XTickLabel = [0:45:180];
ax(3).YTick = [0, yMax];
ax(3).YTickLabel = {'0', num2str(yMax)};
xlabel('Orientation (deg)')

%% Step 5.) Add in the fit
mpeakC = ce(spineID).meanRespContra;
mpeakI = ce(spineID).meanRespIpsi;
peakFitC = ce(spineID).peakFitContra;
peakFitI = ce(spineID).peakFitIpsi;
xs =   0:0.1:(2*pi);
angs = 0:pi/8:2*pi-(pi/8);
maxY = max(max(max(mpeakC), max(peakFitC)),max(max(mpeakI), max(peakFitI)));

ax(4) = axes('Position',[21 1.5 4 2]);
plot(rad2deg(angs),mpeakC,'o',rad2deg(xs),peakFitC,'-','MarkerSize', 4, 'MarkerFaceColor', colors.contra,'Color', colors.contra)

box off
set(gca,'TickDir','out')
ylim([0 maxY])
xlim([0 360])
xlabel('Direction in deg (contra)')

ax(5) = axes('Position',[26 1.5 4 2]);
plot(rad2deg(angs),mpeakI,'o',rad2deg(xs),peakFitI,'-','MarkerSize', 4, 'MarkerFaceColor', colors.ipsi,'Color', colors.ipsi)

box off
set(gca,'TickDir','out')
ylim([0 maxY])
xlim([0 360])
xlabel('Direction in deg (ipsi)')