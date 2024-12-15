function plotSingleFlowMaps(glob, depos, startChron, endChron)

    if startChron > 0 && endChron <= glob.totalIterations

        scrsz = get(0,'ScreenSize'); % screen dimensions vector
        ffOne = figure('Visible','on','Position',[1 1 (scrsz(3)*0.9) (scrsz(4)*0.9)]);

        plotDx = glob.dx / 1000.0;
        plotDy = glob.dy / 1000.0;
        plotThicknessCutoff = glob.thicknessThreshold * 10;
        xStart = 1;
        xStop = glob.xSize;
        xSize = (xStop - xStart) + 1;
        yStart = 1;
        yStop = glob.ySize;
        ySize = (yStop - yStart) + 1;
        fprintf("Plotting flow maps for iterations %d to %d with thickness cutoff %5.4f for sub-area x%d:%d y%d:%d m\n", startChron, endChron, plotThicknessCutoff, xStart, xStop, yStart,yStop);
        
        totalAllFlowThickness = sum(depos.transThickness,3); % Sum of all flow thickness is what we want to plot to show fan flow depositional structure
        transThickEnoughToPlot = depos.transThickness > plotThicknessCutoff;
        topFanSurface = depos.elevation(:,:,1) + totalAllFlowThickness;
        topFanSurface = topFanSurface(yStart:yStop, xStart:xStop);
        
        xcoGridVect = (xStart:xStop) * plotDx ;
        ycoGridVect = (yStart:yStop) * plotDy;
        colMap = zeros(ySize, xSize, 3);
        
        for x = 1 : xSize
            for y = 1 : ySize
                
                xco = xStart - 1 + x; % because we are plotting a xStart-xStop, yStart-yStop sub grid, need to calc equivalent coords to get thickness values from the full model grid
                yco = yStart - 1 + y;
                
                [~, topChron] = find(transThickEnoughToPlot(yco,xco,startChron:endChron),1,'last');
                if ~isempty(topChron)
                    colMap(y,x,:) = depos.flowColours(topChron+1,:);
                else
                    colMap(y,x,:) = [0.5,0.5,0.5];
                end
            end
        end
        
        surface(xcoGridVect, ycoGridVect, topFanSurface, colMap, 'EdgeColor','none')
        
        ax = gca;
        xlabel('X Distance (km)')
        ylabel('Y Distance (km)')
        zlabel('Elevation (m)')
        ax.LineWidth = 0.5;
        ax.FontSize = 12;
        axis tight
        grid on
        view([220 60]);
        drawnow
    end
end