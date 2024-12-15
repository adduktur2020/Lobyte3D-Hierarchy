function plotCrossSectionAlongTransportPath(glob, depos, modelName, sectIteration)

% Code assumes transport is down-dip in the direction of increasing y coordinate values
% Code also assumes that glob.dx and glob.dy the grid cell size variables are in meters

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    figure('Visible','on','Position',[10, 10, (scrsz(3)*0.8), (scrsz(4)*0.8)]);

    plotDy  = glob.dy / 1000.0; % Create local plotting grid cell size variables in km
    
    % Define the xy coordinate vectors for the cross section
    
    sectLen = find( glob.transRouteXYZRecord(:,1,sectIteration),1,'last');
    xSect = glob.transRouteXYZRecord(1:sectLen,1,sectIteration); % extract the steepest descent xy coords
    ySect = glob.transRouteXYZRecord(1:sectLen,2,sectIteration);
    maxY = max(ySect); % Assuming that y is the down dip direction in the model, find the most down-dip y coord
    
    % Extend the coords down dip 100 points from the last steepest descent route coords
    xSect(sectLen+1:sectLen + 100) = ones(1,100) * xSect(sectLen); 
    ySect(sectLen+1:sectLen + 100) = maxY + (1:100);
    
    % Matrix can be indexed with one number, counting through columns, the rows etc, so create a vector to do this...
    sectIndices = sub2ind([glob.ySize,glob.xSize],ySect,xSect); 

    subplot(2,1,1); % Draw the cross section first
 
    % Draw the hemipelagic strata first, as background to transported elements, one polygon per grid cell along the section
    baseLayer = depos.elevation(:,:, 1);
    zco1 = baseLayer(sectIndices); % Define points along the base of the hemipelagic background polygon
    minElevation = min(zco1) - abs(0.1 * min(zco1));
    zco1 = ones(1,numel(zco1)) * minElevation;
    topLayer = depos.elevation(:,:, glob.maxIt);
    zco2 = topLayer(flip(sectIndices)); % Define points along the top of the hemipelagic background polygon
    zco = [reshape(zco1, [1,length(zco1)]), reshape(zco2, [1,length(zco2)])];
    yco = [(1:(sectLen+100)) * plotDy, ((sectLen+100):-1:1) * plotDy];
    patch(yco, zco, [0.7 0.7 0.7], 'EdgeColor','none');
    
    % Now draw the transported strata for each iteration
    for t = 2:glob.maxIt
        oneDeposElevation = depos.elevation(:,:,t-1);
        oneDeposElevation = oneDeposElevation(sectIndices);
        oneTransThickness = depos.transThickness(:,:, t);
        oneTransThickness = oneTransThickness(sectIndices);

        for y = 2:numel(sectIndices)-1
            
             unitBaseMid = oneDeposElevation(y);
             unitBaseRight = oneDeposElevation(y+1);
             transUnitTopLeft = oneDeposElevation(y-1); + oneTransThickness(y-1);
             transUnitTopMid = oneDeposElevation(y) + oneTransThickness(y);
             transUnitTopRight = oneDeposElevation(y+1) + oneTransThickness(y+1);
              
             if oneTransThickness(y) > glob.thicknessThreshold % so thickness threshold to plot depos is 1mm  

                  % So a pinchout to below threshold thickness in point to the left 
                  if oneTransThickness(y-1) < glob.thicknessThreshold 
                        yco = [y-1 y y] * plotDy;
                        zco = [transUnitTopLeft transUnitTopMid, unitBaseMid];
                        patch(yco, zco, depos.flowColours(t,:), 'EdgeColor','none');
                  end

                  yco = [y y+1 y+1 y]* plotDy;  % 4 vertices coordinates clockwise 
                  zco = [transUnitTopMid transUnitTopRight, unitBaseRight unitBaseMid];
                  patch(yco, zco, depos.flowColours(t,:), 'EdgeColor','none');
              end
         end
    end

    ax = gca;
    xlabel('Dip Distance (km)','FontSize',16);
    ylabel('Elevation (m)','FontSize',16);
    ax.LineWidth = 0.5;
    ax.FontSize = 14;
    axis tight
    grid on
    plotTitle = sprintf('%s dip cross section along transport pathway iteration %d', modelName, sectIteration);
    title(plotTitle);
    % export_fig(sprintf('modelOutput/lobyte3D_%s_DipSection', modelName), '-png', '-transparent', '-r600');

    subplot(2,1,2); % Draw the dip-oriented chronostratigraphic diagram

%     colMap = [0.41,0.465,0.475; 0.82,0.93,0.95; 0.615,0.6975,0.7125;];
    
    colMap = zeros(10,3);
    colMap(1:3,:) = [0.41,0.465,0.475; 0.82,0.93,0.95; 0.615,0.6975,0.7125;];
    colMap(10,:) = [1.000,0.800,0.796];
    
    for t = 2:glob.maxIt
        
        zco = [t t t-1 t-1];
        for y = 2:numel(sectIndices)-1
            
            oneTransThickness = depos.transThickness(:,:, t);   % Extract the whole layer of trans thickness from iteration t
            oneTransThickness = oneTransThickness(sectIndices); % extract the trans thickness along the section defined by the points in sectIncdices
            oneErosionLayer = depos.erosion(:,:,t);             % Same for erosion
            oneErosionLayer = oneErosionLayer(sectIndices);
            oneFacies = depos.facies(:,:,t);                    % Same for facies code
            oneFacies = oneFacies(sectIndices);
            
            if oneErosionLayer(y) > 0
                yco = [y y+1 y+1 y] * plotDy;  % 4 vertices coordinates clockwise 
                patch(yco, zco, [1.000,0.800,0.796], 'EdgeColor','none'); % Pale red marks erosion
            end
            
            if oneTransThickness(y) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                yco = [y y+1 y+1 y] * plotDy;  % 4 vertices coordinates clockwise 
                patch(yco, zco, colMap(oneFacies(y)), 'EdgeColor','none');
            end
        end
    end
    
%     % Draw an invisble line to force the correct updip and downdip limits of the plot
%     line([plotLimits.upDipLimit, plotLimits.downDipLimit], [t,t], 'LineStyle','none');
%     hold on;
    
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
    ylabel('Geological time (it #)','FontSize',16);
    ax.LineWidth = 0.5;
    ax.FontSize = 14;
    axis tight
    grid on
    plotTitle = sprintf('%s dip chronostrat diagram along transport pathway iteration %d', modelName, sectIteration);
    title(plotTitle);
    
    drawnow

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


