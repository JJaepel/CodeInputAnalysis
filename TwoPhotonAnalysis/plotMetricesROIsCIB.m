function plotMetricesROIsCIB(ce, info)
% Plots the distribution of OSI and DSI as well as the distribution of the
% pref ori and pref dir
%
% Inputs:
% - ce: structure containing information about ROI, each row is one roi,
% containing anatomical information as well as functional
% - info: structure containing all information about an experiment,
% including the template and the saveDir
%
% Output:
% - Figure 30: Orientation metrices for each eye
% - Figure 31: Direction metrices for each eye
% - Figure 32: OD measurements: ODI, ODIsum, Congruency
% - Figure 33: pie chart

%% Step 0: Set the color palette

colors = struct;
colors.ipsi = [.9 .1 .1];
colors.contra = [.1 .1 .9];

%% Step 1: Select the ROIs that are relevant: responsive for that eye or 
% generally responsive to at least one eye for OD
goodROIs{1} = find([ce.usec] == 1); %responsive for contra
goodROIs{2} = find([ce.usei] == 1); %responsive for ipsi
goodROIs{3} = find(~isnan([ce.OD])); %responsive in general
goodROIs{4} = find([ce.OD] == 0); %responsive to both

%% Step 2:  Plot orientation metrices
figure(30)
sgtitle('Orientation measurements');

%prefDir
subplot(1,4,1)
plot(1,[ce(goodROIs{1}).prefOriContra],'.', 'MarkerSize',20, 'Color',colors.contra)
hold on
boxplot([ce(goodROIs{1}).prefOriContra],'Color', colors.contra)  
ylabel('preferred Orientation')
ylim([0 180])
xticklabels({'contra'})
box off

subplot(1,4,2)
plot(1,[ce(goodROIs{2}).prefOriIpsi],'.', 'MarkerSize',20, 'Color',colors.ipsi)
hold on
boxplot([ce(goodROIs{2}).prefOriIpsi], 'Color', colors.ipsi)  
ylim([0 180])
xticklabels({'ipsi'})
box off
set(gca, 'YColor', 'none', 'YTick', []); 

%OSI
subplot(1,4,3)
plot(1,[ce(goodROIs{1}).OSIContra],'.', 'MarkerSize',20, 'Color',colors.contra)
hold on
boxplot([ce(goodROIs{1}).OSIContra],'Color', colors.contra)  
ylabel('Orientation selectivity')
ylim([0 1])
xticklabels({'contra'})
box off

subplot(1,4,4)
plot(1,[ce(goodROIs{2}).OSIIpsi],'.', 'MarkerSize',20, 'Color',colors.ipsi)
hold on
boxplot([ce(goodROIs{2}).OSIIpsi], 'Color', colors.ipsi)  
ylim([0 1])
xticklabels({'ipsi'})
box off
set(gca, 'YColor', 'none', 'YTick', []); 

%save
set(gcf, 'color', 'w');
saveas(gcf, fullfile(info.saveDir, strcat('30_Orientation.png')))

%% Step 3:  Plot direction metrices
%pref dir
figure(31)
sgtitle('Direction measurements');
subplot(1,4,1)
plot(1,[ce(goodROIs{1}).prefDirContra],'.', 'MarkerSize',20, 'Color',colors.contra)
hold on
boxplot([ce(goodROIs{1}).prefDirContra],'Color', colors.contra)  
ylabel('preferred Direction')
ylim([0 360])
xticklabels({'contra'})
box off

subplot(1,4,2)
plot(1,[ce(goodROIs{2}).prefDirIpsi],'.', 'MarkerSize',20, 'Color',colors.ipsi)
hold on
boxplot([ce(goodROIs{2}).prefDirIpsi], 'Color', colors.ipsi)  
ylim([0 360])
xticklabels({'ipsi'})
box off
set(gca, 'YColor', 'none', 'YTick', []); 

%DSI
subplot(1,4,3)
plot(1,[ce(goodROIs{1}).DSIContra],'.', 'MarkerSize',20, 'Color',colors.contra)
hold on
boxplot([ce(goodROIs{1}).DSIContra],'Color', colors.contra)  
ylabel('Direction selectivity')
ylim([0 1])
xticklabels({'contra'})
box off

subplot(1,4,4)
plot(1,[ce(goodROIs{2}).DSIIpsi],'.', 'MarkerSize',20, 'Color',colors.ipsi)
hold on
boxplot([ce(goodROIs{2}).DSIIpsi], 'Color', colors.ipsi)  
ylim([0 1])
xticklabels({'ipsi'})
box off
set(gca, 'YColor', 'none', 'YTick', []); 

%save
set(gcf, 'color', 'w');
saveas(gcf, fullfile(info.saveDir, strcat('31_Direction.png')))

%% Step 4:  Plot OD metrices

figure(32)
sgtitle('Binocularity measurements');

%ODI based on peak
subplot(1,4,1)
plot(1,[ce(goodROIs{3}).ODI],'.', 'MarkerSize',20)
hold on
boxplot([ce(goodROIs{3}).ODI])  
ylabel('ODI (peak)')
ylim([-1 1])
xticklabels({'All'})
box off

%ODI based on sum
subplot(1,4,2)
plot(1,[ce(goodROIs{3}).ODIsum],'.', 'MarkerSize',20)
hold on
boxplot([ce(goodROIs{3}).ODIsum])  
ylim([-1 1])
ylabel('ODI (sum)')
xticklabels({'All'})
box off

%Congruency of binos
subplot(1,4,3)
plot(1,[ce(goodROIs{4}).congruency],'.', 'MarkerSize',20)
hold on
boxplot([ce(goodROIs{4}).congruency])  
ylim([-1 1])
ylabel('Congruency')
xticklabels({'Binos'})
box off

%Mismatch of binos
subplot(1,4,4)
plot(1,[ce(goodROIs{4}).mismatch],'.', 'MarkerSize',20)
hold on
boxplot([ce(goodROIs{4}).mismatch])  
ylim([0 180])
ylabel('Mismatch')
xticklabels({'Binos'})
box off

set(gcf, 'color', 'w');
saveas(gcf, fullfile(info.saveDir, strcat('32_Binocularity.png')))
