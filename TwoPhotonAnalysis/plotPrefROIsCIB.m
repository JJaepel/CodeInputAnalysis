function plotPrefROIsCIB(ce,info)

% Plots the prefered orientation or direction of spines or cells on top of
% the template as a quick way to see the distribution of preferences. 
%
% Inputs:
% - ce: structure containing information about ROI, each row is one roi,
% containing anatomical information as well as functional
% - info: structure containing all information about an experiment,
% including the template and the saveDir
%
% Output:
% - Figure 20: orientation preference for each eye on top of template
% - Figure 21: direction preference for each eye on top of template
% - Figure 22: ODIsum

%% Step 1: Select the ROIs that are relevant: responsive for that eye and 
% ori- or dir-selective or generally responsive to at least one eye for OD

goodROIs{1} = intersect(find([ce.OSIIpsi] > 0.15),find([ce.usei] == 1));
goodROIs{2} = intersect(find([ce.DSIIpsi] > 0.15),find([ce.usei] == 1));
goodROIs{3} = intersect(find([ce.OSIContra] > 0.15),find([ce.usec] == 1));
goodROIs{4} = intersect(find([ce.DSIContra] > 0.15),find([ce.usec] == 1));
goodROIs{5} = find(~isnan([ce.OD]));

%% Step 2: Plot ori-selectivity
figure(20)
sgtitle('Orientation preference map')
stims = {'Contra', 'Ipsi'};
for stim = 1:length(stims)
    prefOrientation = strcat('prefOri',stims{stim});
    
    %get template
    subplot(1,2,stim)
    imshow(cat(3,info.template,info.template,info.template)/prctile(info.template(:),99));
    colormap(hsv)
    LUT = hsv(180);
    title(strcat(stims{stim},' eye'))
    caxis([0 180]); colorbar('Location', 'southoutside');

    axis image
    hold on

    % Plot ROIs and their prefOri on top
    if ~isempty(goodROIs{stim})
        for r = 1:length(goodROIs{stim})
            cc = goodROIs{stim}(r);
            xpos=ce(cc).xPos;
            ypos= ce(cc).yPos;
            plot(xpos,ypos,'ok','MarkerSize',10','MarkerFaceColor',LUT(1+floor(ce(cc).(prefOrientation)),:));
        end
    end
    
    %remove box, set background to white and save
    set(gca,'Box','off');
    set(gcf, 'color', 'w');
end
saveas(gcf, fullfile(info.saveDir, strcat('20_OriPref.png')))

%% Step 3: Plot ori-selectivity
figure(21)
sgtitle('Direction preference map')
stims = {'Contra', 'Ipsi'};
for stim = 1:length(stims)
    prefDirection = strcat('prefDir',stims{stim});
    
    %get template
    subplot(1,2,stim)
    imshow(cat(3,info.template,info.template,info.template)/prctile(info.template(:),99));
    colormap(hsv)
    LUT = hsv(360);
    title(strcat(stims{stim},' eye'))
    caxis([0 360]); colorbar('Location', 'southoutside');

    axis image
    hold on

    % Plot ROIs and their prefOri on top
    if ~isempty(goodROIs{2+stim})
        for r = 1:length(goodROIs{2+stim})
            cc = goodROIs{2+stim}(r);
            xpos=ce(cc).xPos;
            ypos= ce(cc).yPos;
            plot(xpos,ypos,'ok','MarkerSize',10','MarkerFaceColor',LUT(1+floor(ce(cc).(prefDirection)),:));
        end
    end
    
    %remove box, set background to white and save
    set(gca,'Box','off');
    set(gcf, 'color', 'w');
end
saveas(gcf, fullfile(info.saveDir, strcat('21_DirPref.png')))


%% Step 4: Plot ODI Sum on top of template
%Define a custom colormap from red to blue
nColors = 200;  % Number of colors in the colormap
LUT = cbrewer('div', 'RdBu', nColors);
LUT(LUT<0)=0;

%plot ODIsum
figure(22)
colormap(LUT);
imshow(cat(3, info.template, info.template, info.template) / prctile(info.template(:), 99)); 
caxis([-1 1]); 
colorbar('Location', 'southoutside');

axis image;
hold on;

if ~isempty(goodROIs{5})
    for r = 1:length(goodROIs{5})
        cc = goodROIs{5}(r);
        xpos = ce(cc).xPos;
        ypos = ce(cc).yPos;
        
        ODISum = ce(cc).ODIsum+1;
        plot(xpos,ypos,'ok','MarkerSize',10','MarkerFaceColor',LUT(ceil(ODISum*100),:));
      
    end
end
 saveas(gcf, fullfile(info.saveDir, '23_ODISum.png'))

%plot ODI
figure(23)
colormap(LUT);
imshow(cat(3, info.template, info.template, info.template) / prctile(info.template(:), 99)); 
caxis([-1 1]); 
colorbar('Location', 'southoutside');

axis image;
hold on;

if ~isempty(goodROIs{5})
    for r = 1:length(goodROIs{5})
        cc = goodROIs{5}(r);
        xpos = ce(cc).xPos;
        ypos = ce(cc).yPos;
        
        ODI = ce(cc).ODI+1;
        plot(xpos,ypos,'ok','MarkerSize',10','MarkerFaceColor',LUT(ceil(ODI*100),:));
      
    end
end
 saveas(gcf, fullfile(info.saveDir, '24_ODI.png'))

