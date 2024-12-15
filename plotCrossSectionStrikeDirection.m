
function figHandle = plotCrossSectionStrikeDirection(glob, depos, yCross, lowerLimitX, upperLimitX, maxZ, lobeOrFlowColourCoding, modelName)
% Draw a strike-oriented cross section of the deposit at y = xCross
% Code assumes that glob.dx and glob.dy the grid cell size variables are in meters

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    figHandle = figure('Visible','on','Position',[10, 20, (scrsz(3)*0.8), (scrsz(4)*0.8)]);
    
    y = yCross; % y coord of the cell from which start deposition
    plotDx  = glob.dx / 1000.0; % Create local plotting grid cell size variables in km
    
    if lowerLimitX > 0 && upperLimitX > 0
        xStart = lowerLimitX;
        xEnd = upperLimitX;
    else
        [xStart, xEnd] = findStrikeLimitsTransportedSediment(depos.transThickness, glob.thicknessThreshold, yCross, glob.xSize, glob.maxIt);
    end
    
    if xStart < xEnd

        % Draw the strike-oriented cross-section diagram
        subplot(2,1,1);
        %axis tight
        
        
        % Draw the hemipelagic strata first, as background
        hpStart = xStart - 1;
        if hpStart < 1 hpStart = 1; end
        hpEnd = xEnd + 1;
        if hpEnd > glob.xSize hpEnd = glob.xSize; end
        minStratElevation = min(depos.elevation(yCross, hpStart:hpEnd, 1));
        minStratElevation = minStratElevation - abs(0.1 * minStratElevation);
        zco1 = ones(1,(hpEnd-hpStart)+1) * minStratElevation; % Define points along the base of the hemipelagic background polygon
        zco2 = depos.elevation(y, hpEnd:-1:hpStart, glob.maxIt); % Define the points along the top of the hemipelagic background polygon
        zco = [zco1, zco2]; % Merge bottom and top coordinates
        xco = [(hpStart:hpEnd) * plotDx, (hpEnd:-1:hpStart) * plotDx]; % Create an equivalent length vector of the xcoordinates for each point
        patch(xco, zco, [0.7 0.7 0.7], 'EdgeColor','none');
        
        % Draw the transported strata
        for t = 2:glob.maxIt
            x = xStart;
            
            while x < xEnd
                
                  % Find the first x>0 xcoordinate where the transported layer is greater than threshold thickness
                  while x < xEnd && depos.transThickness(y, x, t) < glob.thicknessThreshold 
                      x = x + 1;
                  end
                  
                  if x < xEnd
                      % Check if left lateral boundary is pinchout or erosional, and set thickness coords accordingly
                      if depos.facies(y, x-1, t) == 10 % So eroded boundary at x-1
                          xco = x;
                          transUnitBase = depos.elevation(y, x, t-1);
                          transUnitTop = depos.elevation(y, x, t-1) + depos.transThickness(y, x, t);

                      else % Pinchout boundary at x-1
                          xco = x-1;
                          transUnitBase = depos.elevation(y, x-1, t-1);
                          transUnitTop = depos.elevation(y, x-1, t-1);
                      end

                      % Loop on x through the coordinates where transported layer thickness is greater than threshold thickness and add coords to the xco, base and top vectors
                      while x <= xEnd && depos.transThickness(y, x, t) >= glob.thicknessThreshold
                          xco(numel(xco)+1) = x;
                          transUnitBase(numel(transUnitBase)+1) = depos.elevation(y, x, t-1);
                          transUnitTop(numel(transUnitTop)+1) = depos.elevation(y, x, t-1) + depos.transThickness(y, x, t);
                          x = x + 1;
                      end

                      % Check if right lateral boundary is pinchout or erosional, and set thickness coords accordingly
                      if depos.facies(y, x, t) ~= 10 % So no erosion (facies = 10) recorded therefore pinchout boundary at x
                          xco(numel(xco)+1) = x;
                          transUnitBase(numel(transUnitBase)+1) = depos.elevation(y, x, t-1);
                          transUnitTop(numel(transUnitTop)+1) = depos.elevation(y, x, t-1);
                      end

                      xco = [xco,xco(numel(xco):-1:1)] .* plotDx; % Repeat xcoordinates twice, once for base of layer, once for top, with second set in reverse order to close the patch circle
                      zco = [transUnitBase, transUnitTop(numel(transUnitTop):-1:1)];
                      if lobeOrFlowColourCoding == 1
                          patch(xco, zco, depos.flowColoursByLobe(t,:), 'EdgeColor','none');
                      else
                          patch(xco, zco, depos.flowColours(t,:), 'EdgeColor','none');
                      end
                  end
             end
        end
        
        if maxZ > 0
            line([xStart, xEnd], [0, maxZ], 'LineStyle','none');
        end

        ax = gca;
        xlabel('Strike Distance (km)','FontSize',16);
        ylabel('Elevation (m)','FontSize',16);

        ax.LineWidth = 0.5;
        ax.FontSize = 14;
        axis tight
        grid on
        xlim1 = xlim(subplot(2,1,1));

        plotTitle = sprintf('%s strike section y=%3.2f km', modelName, yCross * plotDx);
        title(plotTitle);

        % Export-fig outputs high resolution bitmap image of the window contents
        % export_fig(sprintf('modelOutput/lobyte3D_%s_StrikeSection', modelName), '-png', '-transparent', '-r600');

        subplot(2,1,2);
        xlim(xlim1);
        %axis tight

        colMap = zeros(10,3);
        colMap(1:3,:) = [0.41,0.465,0.475; 0.82,0.93,0.95; 0.615,0.6975,0.7125;];
        colMap(10,:) = [1.000,0.800,0.796];

        n = glob.deltaT * 1000000;  % added by IT
        n = n/1000; % added by IT - make the yaaxxis a funtion of selected timestep.

        % Draw the strike-oriented chronostrat diagram
        for t = 2:glob.maxIt

             zco = [t t t-1 t-1] * n; % added by IT
            % for x = x:glob.xSize-1
            for x = xStart:xEnd
                 if lobeOrFlowColourCoding == 1
                     if depos.erosion(y,x,t) > 0
                        xco = [x, x+1, x+1, x] * plotDx;  % 4 vertices coordinates clockwise 
                        patch(xco, zco, [1.000,0.800,0.796], 'EdgeColor','none'); % Pale red marks erosion
                     end
                     if depos.transThickness(y,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                        xco = [x, x+1, x+1, x] * plotDx;  % 4 vertices coordinates clockwise 
                        patch(xco, zco, depos.flowColoursByLobe(t,:), 'EdgeColor','none'); % Draw deposition colour coded by lobe number
                     end
                 else % if not lobe colour scheme, draw erosion and deposition in different colours
                     if depos.erosion(y,x,t) > 0
                        xco = [x, x+1, x+1, x] * plotDx;  % 4 vertices coordinates clockwise 
                        patch(xco, zco, [1.000,0.800,0.796], 'EdgeColor','none'); % Pale red marks erosion
                     end

                     if depos.transThickness(y,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                        xco = [x, x+1, x+1, x] * plotDx;  % 4 vertices coordinates clockwise       
                        patch(xco, zco, colMap(depos.facies(y,x,t),:), 'EdgeColor','none');
                     end
                 end
             end
        end
        
        line([xStart, xEnd], [glob.maxIt, glob.maxIt], 'LineStyle','none'); % Force the chronostrat section to scale to the full xStart to xEnd length

        ax = gca;
        xlabel('X Distance (km)','FontSize',16);
        ylabel('Geological time (ky)','FontSize',16);

        ax.LineWidth = 0.5;
        ax.FontSize = 14;
        axis tight
        grid on
        
        xlim(xlim1);
        % making the yaxis a function of the timestep for the model.
%         currentTicks = get(gca, 'YTick'); % Get current y-axis tick positions added by IT
%         newTick1 = glob.deltaT * 1000000;
%         newTick2 = newTick1/1000;
%         newTick3 = currentTicks * newTick2;
%         set(gca, 'YTick', currentTicks);
%         set(gca, 'YTickLabel', newTick3); % Set the labels for new ticks to old ticks values


        drawnow

    else
        fprintf('Cannot plot strike section at x=%d because strata thickness indicates section start %d and end %d\n', yCross, xStart, xEnd);
    end
end

function [xStart, xEnd] = findStrikeLimitsTransportedSediment(transThickness, thicknessThreshold, yPos, xSize, maxIterations) % added gridSize by IB
% Find the x coordinate limits of deposition of transported sediment

    xStart = xSize; % Set to max and min possible values
    xEnd = 0;

    for x = 1:xSize
        for t = 2:maxIterations 
            if transThickness(yPos, x, t) > thicknessThreshold && x < xStart
                xStart = x;
            end
            if transThickness(yPos, x, t) > thicknessThreshold && x > xEnd
                xEnd = x;
            end
        end
    end
end
