function plotVerticalSectionAndChronostratsAndFlowOverlaps(glob, depos, x, y, modelName)
% Draw a single vertical section at point x,y on the grid. Colour code units a random shade red-to-yellow and assign a random grainsize


    %% runs up and down are plotted with the chronostrat section
    % So calculate runs up and down first, before doing any plotting
    thicknesses = depos.transThickness(y,x,:);
    nz = max(size(thicknesses));
    deltaThick = zeros(1,nz);
    runsUp = zeros(1,nz);
    runsDown = zeros(1,nz);

    % Calculate the change in thickness between successive units
    i = 1:nz-1;
    j = 2:nz; % so j = i + 1 therefore thickness change is thickness(j) - thickness(i)
    deltaThick(i) = thicknesses(j) - thicknesses(i);

    if deltaThick(1) > 0 runsUp(1) = 1; end
    if deltaThick(1) < 0 runsDown(1) = 1; end

    for i=2:nz
        if deltaThick(i) > 0 runsUp(i) = runsUp(i-1)+1; end
        if deltaThick(i) < 0 runsDown(i) = runsDown(i-1)+1; end
    end
    
    maxRunsUp = max(runsUp);
    maxRunsDown = max(runsDown);
    maxRuns = max(maxRunsUp, maxRunsDown);

    %% now plot the vertical section, chronostrat with correlation lines, and the external forcing signal, if any
    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    ffFive = figure('Visible','on','Position',[1 1 (scrsz(3)*0.8) (scrsz(4)*0.95)]);

    timelineInterval = glob.maxIt / 20;

    % chronoStartXco = max(depos.proportionThickness) + 50;
    vertSectWidth = 1;
    chronoStartXco = 1.5;
    chronoWidth = 2;
    runsPlotStartXco = 3.5;
    runsPlotWidth = 2.5;
    lobeShiftPlotWidth = 2;
    lobeShiftPlotWidthStartXco = 6.0;
    sedSupplyStartXco = 8;
    sedSupplyWidth = 2;

    totalSectThickness = depos.elevation(y,x,glob.totalIterations) - depos.elevation(y,x,1);
    baseOfSect = depos.elevation(y,x,1);
    thicknessScaleFactor = glob.totalIterations / totalSectThickness;
    maxSupply = max(glob.supplyHistory);
    lobeShiftScaleFactor = 2.0; % lobeShiftPlotWidth / max(glob.centroidSeperation);
    
    % Find the 25 biggest centroid position shifts to plot as markers
%     sortCentroidSeparations = sort(glob.centroidSeparation, 'descend');
%     centroidSeparationCutoff = sortCentroidSeparations(25);
%     sortFlowOverlaps = sort(glob.flowOverlapRecord, 'ascend');
%     flowOverlapCutoff = sortFlowOverlaps(25);

    % Plot the  vertical section, chronostrat, and supply curve
    for t = 2:glob.totalIterations 

        % Calculate unit elevations
        baseOfUnit = (depos.elevation(y,x,t-1) - baseOfSect) * thicknessScaleFactor; % top of the unit below
        topOfTransported = baseOfUnit + (depos.transThickness(y,x,t) * thicknessScaleFactor);
        topOfUnit = (depos.elevation(y,x,t) - baseOfSect) * thicknessScaleFactor;

        % Draw the vertical section transported fraction first
        xco = [0 vertSectWidth vertSectWidth 0];  
        zco = [baseOfUnit baseOfUnit topOfTransported topOfTransported];
        patch(xco, zco, depos.flowColours(t,:), 'EdgeColor','none');

        % Draw the vertical section hemipelagic fraction
        xco = [0 vertSectWidth*0.5 vertSectWidth*0.5 0];  
        zco = [topOfTransported topOfTransported topOfUnit topOfUnit];
        patch(xco, zco, [0.7 0.7 0.7], 'EdgeColor','none');

        % Draw the correlative chronostrat axis
        if depos.transThickness(y,x,t) > 0.0 % glob.thicknessThreshold
             xco = [chronoStartXco chronoStartXco chronoStartXco+chronoWidth chronoStartXco+chronoWidth];
             zco = [t-1 t t t-1];
             patch(xco, zco, depos.flowColours(t,:), 'EdgeColor','none');
        end
        
        if runsUp(t) > 0
            leftEdge = runsPlotStartXco+(runsPlotWidth * (runsUp(t-1)/maxRuns));
            rightEdge = runsPlotStartXco+(runsPlotWidth * (runsUp(t)/maxRuns));
            xco = [runsPlotStartXco, rightEdge, rightEdge, runsPlotStartXco];
            zco = [t-1 t-1 t t];
            patch(xco, zco, [1 0 0], 'EdgeColor','none');
        end
        
        if runsDown(t) > 0
            leftEdge = runsPlotStartXco+(runsPlotWidth * (runsDown(t-1)/maxRuns));
            rightEdge = runsPlotStartXco+(runsPlotWidth * (runsDown(t)/maxRuns));
            xco = [runsPlotStartXco rightEdge rightEdge runsPlotStartXco];
            zco = [t-1 t-1 t t];
            patch(xco, zco, [0 0 1], 'EdgeColor','none');
        end
        
%         
%         if glob.centroidSeperation(t) >= centroidSeparationCutoff % One of the top 20 separations, so draw a marker on the end of the line segment to indicate this
%             markerXcoCenter = lobeShiftPlotWidthStartXco + (lobeShiftScaleFactor * glob.centroidSeperation(t));
%             xco = [markerXcoCenter - (lobeShiftPlotWidth / 50), markerXcoCenter - (lobeShiftPlotWidth / 50), markerXcoCenter + (lobeShiftPlotWidth / 50), markerXcoCenter + (lobeShiftPlotWidth / 50)];
%             yco = [t - 5, t + 5, t + 5, t - 5];
%             patch(xco, yco, [0.768 0.580 0.109], 'EdgeColor','none');
%         end

%         if glob.flowOverlapRecord(t) <= flowOverlapCutoff % One of the top 20 separations, so draw a marker on the end of the line segment to indicate this
%             markerXcoCenter = lobeShiftPlotWidthStartXco + (lobeShiftScaleFactor * glob.flowOverlapRecord(t));
%             xco = [markerXcoCenter - (lobeShiftPlotWidth / 50), markerXcoCenter - (lobeShiftPlotWidth / 50), markerXcoCenter + (lobeShiftPlotWidth / 50), markerXcoCenter + (lobeShiftPlotWidth / 50)];
%             yco = [t - 5, t + 5, t + 5, t - 5];
%             patch(xco, yco, [0.768 0.580 0.109], 'EdgeColor','none');
%         end

        if mod(t, timelineInterval) == 0 % Draw a marker line for every tenth iteration when t/10 has remainder 0
             xco = [0, vertSectWidth, chronoStartXco, sedSupplyStartXco+sedSupplyWidth];
             zco = [(depos.elevation(y,x,t) - baseOfSect) * thicknessScaleFactor, (depos.elevation(y,x,t) - baseOfSect) * thicknessScaleFactor, t, t];
             line(xco, zco, 'color', [0 0 0]);
        end
    end
    
    % Now plot the timeseries curves as one line and one polygon each, so outside of the time loop used above to plot per-iteration elements
    t = 1:glob.totalIterations; % Create an implicit loop on t

    % Draw the sediment supply history. We want a solid curve so need to define start and end points at base and top on the xco=0 line
    xco = sedSupplyStartXco + ((glob.supplyHistory(t)/maxSupply) * sedSupplyWidth);
    xco(1) = sedSupplyStartXco;
    xco(glob.totalIterations) = sedSupplyStartXco;
    zco = t;
    zco(1) = 0;
    zco(glob.totalIterations) = glob.totalIterations;
    patch(xco, zco, [0 0.8 0.4], 'EdgeColor','none');
    
    % Draw the lobe overlap history
%     xco = lobeShiftPlotWidthStartXco + (glob.flowOverlapRecord(t) * lobeShiftScaleFactor);
%     zco = t;
%     line(xco, zco, 'color', [0.0 0.0 0.5]);
    
    % Draw the lobe overlap history 80% and 20% lines
    line([lobeShiftPlotWidthStartXco + (0.2 * lobeShiftScaleFactor), lobeShiftPlotWidthStartXco + (0.2 * lobeShiftScaleFactor)], [0,glob.totalIterations], ...
        'color', [1.0 0.0 0.0], 'lineStyle','-', 'lineWidth',1);
    line([lobeShiftPlotWidthStartXco + (0.8 * lobeShiftScaleFactor), lobeShiftPlotWidthStartXco + (0.8 * lobeShiftScaleFactor)], [0,glob.totalIterations], ...
        'color', [0.0 1.0 0.0], 'lineStyle','-', 'lineWidth',1);

    ax = gca;
    ylabel('Thickness (m)','FontSize',14);
    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    axis tight
    grid on
    title(modelName);
    
%     fName = sprintf('modelOutput/signalBumpOutputV5/vSectChronoSupplyCurve%s.png', modelName);
%     if exist(fName, 'file') ~= 2
%         fprintf('Creating graphics output file %s ...', fName);
%         export_fig(fName, '-png', '-transparent', '-r600');
%         fprintf('Done\n');
%     end
end



