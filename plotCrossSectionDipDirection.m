function figHandle = plotCrossSectionDipDirection(glob, depos, x, upDipLimitY, downDipLimitY, maxZ, lobeOrFlowColourCoding, modelName)
% Draw a dip-oriented cross section of the deposit along line xcoordinate = x
% Code assumes transport is down-dip in the direction of increasing y coordinate values
% Code also assumes that glob.dx and glob.dy the grid cell size variables are in meters

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    figHandle = figure('Visible','on','Position',[10, 10, (scrsz(3)*0.8), (scrsz(4)*0.8)]);
    
    if upDipLimitY > 0 && downDipLimitY > 0
        plotLimits.upDipLimit = upDipLimitY;
        plotLimits.downDipLimit = downDipLimitY;
    else

        % Find limits of deposition of transported sediment
        plotLimits = findDipLimitsTransportedSediment(depos.transThickness, glob.thicknessThreshold, x, glob.ySize, glob.maxIt);
        plotLimits.upDipLimit = round(plotLimits.upDipLimit * 0.7); % Want to see the section up-dip of the pinchout, so extend section up dip a little bit...
        if plotLimits.upDipLimit < 2 % So reset if 0 or 1, because there is a y-1 in the code below which we don't want to generate a 0 array index
            plotLimits.upDipLimit = 2;
        end
    end
    plotDy  = glob.dy / 1000.0; % Create local plotting grid cell size variables in km
    
    % Check to see the plot limits are OK to plot. For dip sections where
    % there is no deposition or deposition below prescribed thickness limit
    % plot limits might return unset. Also, function could be called with
    % similarly unsuitable plot limits, so important to check to avoid
    % crash on length of zxo and yco vectors
    if plotLimits.upDipLimit < plotLimits.downDipLimit 

        subplot(2,1,1); % Draw the cross section first

        % Draw the hemipelagic strata first, as background to transported elements, one polygon per grid cell along the section
        hpStart = plotLimits.upDipLimit - 1;
        if hpStart < 1 hpStart = 1; end
        hpEnd = plotLimits.downDipLimit + 1;
        if hpEnd > glob.xSize hpEnd = glob.xSize; end
        minStratElevation = min(depos.elevation(hpStart:hpEnd, x, 1));
        minStratElevation = minStratElevation - abs(0.1 * minStratElevation);
        zco1 = ones(1,(hpEnd-hpStart)+1) * minStratElevation; % Define points along the base of the hemipelagic background polygon
        zco2 = depos.elevation(hpEnd:-1:hpStart, x, glob.maxIt);
        zco = [reshape(zco1, [1,length(zco1)]), reshape(zco2, [1,length(zco2)])];
        yco = [(hpStart:hpEnd) * plotDy, (hpEnd:-1:hpStart) * plotDy];
        patch(yco, zco, [0.7 0.7 0.7], 'EdgeColor','none');

        % Now draw the transported strata for each iteration
        for t = 2:glob.maxIt
            for y = plotLimits.upDipLimit: plotLimits.downDipLimit

                  unitBaseMid = depos.elevation(y, x,t-1);
                  unitBaseRight = depos.elevation(y+1, x, t-1);
                  transUnitTopLeft = depos.elevation(y-1,x, t-1) + depos.transThickness(y-1, x, t);
                  transUnitTopMid = depos.elevation(y, x, t-1) + depos.transThickness(y, x, t);
                  transUnitTopRight = depos.elevation(y+1,x, t-1) + depos.transThickness(y+1, x, t);

                  if depos.transThickness(y,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos is 1mm  

                      % So a pinchout to below threshold thickness in point to the left 
                      if depos.transThickness(y-1,x,t) < glob.thicknessThreshold 
                            yco = [y-1 y y] * plotDy;
                            zco = [transUnitTopLeft transUnitTopMid, unitBaseMid];
                            patch(yco, zco, depos.flowColours(t,:), 'EdgeColor','none');
                      end

                      yco = [y y+1 y+1 y]* plotDy;  % 4 vertices coordinates clockwise 
                      zco = [transUnitTopMid transUnitTopRight, unitBaseRight unitBaseMid];
                      
                      if lobeOrFlowColourCoding == 1
                          patch(yco, zco, depos.flowColoursByLobe(t,:), 'EdgeColor','none');
                      else
                          patch(yco, zco, depos.flowColours(t,:), 'EdgeColor','none');
                      end
                  end
             end
        end

        % Draw an invisble line to force the correct updip and downdip limits of the plot using one of the last z-coords used in the section
        line([plotLimits.upDipLimit, plotLimits.downDipLimit], [unitBaseMid, unitBaseMid], 'LineStyle','none');
        
        if maxZ > 0
            line([plotLimits.upDipLimit, plotLimits.upDipLimit], [0, maxZ], 'LineStyle','none');
        end

        ax = gca;
        xlabel('Dip Distance (km)','FontSize',16);
        ylabel('Elevation (m)','FontSize',16);
        ax.LineWidth = 0.5;
        ax.FontSize = 14;
        axis tight
        grid on
        plotTitle = sprintf('%s dip cross section x=%3.2f km', modelName, x*plotDy);
        title(plotTitle);
        xlim2 = xlim(subplot(2,1,1));
        xlim3 = xlim2(2);
        xlim([xlim2(1) (xlim3/10)]);  % added by IB
        
        % export_fig(sprintf('modelOutput/lobyte3D_%s_DipSection', modelName), '-png', '-transparent', '-r600');

        subplot(2,1,2); % Draw the dip-oriented chronostratigraphic diagram

        colMap = zeros(10,3);
        colMap(1:3,:) = [0.41,0.465,0.475; 0.82,0.93,0.95; 0.615,0.6975,0.7125;];
        colMap(10,:) = [1.000,0.800,0.796];

        n = glob.deltaT * 1000000;  % added by IT
        n = n/1000; % added by IT - make the yaaxxis a funtion of selected timestep.

        for t = 2:glob.maxIt

            zco = [t t t-1 t-1] * n;
            for y = plotLimits.upDipLimit: plotLimits.downDipLimit
             
                if lobeOrFlowColourCoding == 1
                    if depos.transThickness(y,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                        yco = [y, y+1, y+1, y] * plotDy;  % 4 vertices coordinates clockwise 
                        patch(yco, zco, depos.flowColoursByLobe(t,:), 'EdgeColor','none'); % Draw deposition colour coded by lobe number
                    end
                    if depos.erosion(y,x,t) > 0
                        yco = [y y+1 y+1 y] * plotDy;  % 4 vertices coordinates clockwise 
                        patch(yco, zco, [1.000,0.800,0.796], 'EdgeColor','none'); % Pale red marks erosion
                    end

                else % if not lobe colour scheme, draw erosion and deposition in different colours
                    if depos.erosion(y,x,t) > 0
                        yco = [y y+1 y+1 y] * plotDy;  % 4 vertices coordinates clockwise 
                        patch(yco, zco, [1.000,0.800,0.796], 'EdgeColor','none'); % Pale red marks erosion
                    end

                    if depos.transThickness(y,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                        yco = [y y+1 y+1 y] * plotDy;  % 4 vertices coordinates clockwise 
                        patch(yco, zco, colMap(depos.facies(y,x,t),:), 'EdgeColor','none');
                    end
                end
            end
        end

        % Draw an invisble line to force the correct updip and downdip limits of the plot
        line([plotLimits.upDipLimit, plotLimits.downDipLimit], [t,t], 'LineStyle','none');
        hold on;

        % Plot the updip onlap curve
    %     onlapHistoryYco = plotLimits.onlapHistory .* plotDy;
    %     downlapHistoryYco  = plotLimits.downlapHistory .* plotDy;
    %     plot(onlapHistoryYco, 1:glob.maxIt, 'LineStyle','none');
    %     for t = 1:glob.maxIt
    %         if plotLimits.onlapHistory(t) > 0
    %             plot(onlapHistoryYco(t), t, 'r*');      
    %         end
    %         if plotLimits.downlapHistory(t) > 0
    %             plot(downlapHistoryYco(t), t, 'b*');
    %         end
    %     end

        % Plot a line showing contiguous stratigraphic completeness along the line of section - helps interpret lobe stacking on the chronostrat diagram
        % yco = (upDipLimit:downDipLimit) * plotDy;
        % zco = depos.stratCompletenessContig(leftStart:rightEnd, xCross) * glob.maxIt; % Scale completeness as a proportion of the total iterations
        % line(yco, zco, 'color','blue','LineWidth',1.0);

        ax = gca;
        xlabel('Dip Distance (km)','FontSize',16);
        ylabel('Geological time (ky)','FontSize',16);
        ax.LineWidth = 0.5;
        ax.FontSize = 14;
        axis tight
        grid on
        plotTitle = sprintf('%s dip chronostrat diagram x=%3.2f km', modelName, x * plotDy);
        title(plotTitle);
        xlim([xlim2(1) (xlim3/10)]);  % added by IB

        % making the yaxis a function of the timestep for the model.
%         currentTicks = get(gca, 'YTick'); % Get current y-axis tick positions added by IT
%         newTick1 = glob.deltaT * 1000000;
%         newTick2 = newTick1/1000;
%         newTick3 = currentTicks * newTick2;
%         set(gca, 'YTick', currentTicks);
%         set(gca, 'YTickLabel', newTick3); % Set the labels for new ticks to old ticks values

        drawnow
    end

    % export_fig(sprintf('modelOutput/lobyte3D_%s_DipChrono', modelName), '-png', '-transparent', '-r600');
end

function plotLimits = findDipLimitsTransportedSediment(transThickness, thicknessThreshold, xPos, ySize, maxIterations)

    % Set to maximum and mimumum values possible, so that they will most likely change
    plotLimits.upDipLimit = ySize;
    plotLimits.downDipLimit = 0;
  
    plotLimits.onlapHistory = zeros(1, maxIterations);
    plotLimits.downlapHistory = zeros(1, maxIterations);

    for t = 2:maxIterations
        
        if isempty(find(transThickness(1:ySize, xPos, t) > thicknessThreshold, 1)) ~= 1 % If there are values in this iteration of transThickness
            plotLimits.onlapHistory(t) = find(transThickness(1:ySize, xPos, t) > thicknessThreshold, 1); % Find the most proximal transThickness > threshold - onlap point
        end
        if isempty(find(transThickness(ySize:-1:1, xPos, t) > thicknessThreshold, 1)) ~= 1
            plotLimits.downlapHistory(t) = ySize - find(transThickness(ySize:-1:1, xPos, t) > thicknessThreshold, 1); % Find the most distal transThickness > threshold - downlap point
        end
        
        if plotLimits.onlapHistory(t) > 0 && plotLimits.onlapHistory(t) < plotLimits.upDipLimit
            plotLimits.upDipLimit = plotLimits.onlapHistory(t);
        end
        
        if plotLimits.downlapHistory(t) < ySize && plotLimits.downlapHistory(t) > plotLimits.downDipLimit
            plotLimits.downDipLimit = plotLimits.downlapHistory(t);
        end
    end
end


