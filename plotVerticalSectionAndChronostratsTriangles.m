function plotVerticalSectionAndChronostratsTriangles(glob, depos, x, y, modelName)
% Draw a single vertical section at point x,y on the grid. Colour code units a random shade red-to-yellow and assign a random grainsize


    %% runs up and down are plotted with the chronostrat section
    % So calculate runs up and down at point x,y first, before doing any plotting
    [runsUp, runsDown] = calculateRunsUpAndDownForPlotting(depos, x,y);

    %% now plot the vertical section, chronostrat with correlation lines, and the external forcing signal, if any
    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    ffFive = figure('Visible','on','Position',[1 1 (scrsz(3)*0.8) (scrsz(4)*0.95)]);

    timelineInterval = glob.maxIt / 20;

    % chronoStartXco = max(depos.proportionThickness) + 50;
    vertSectWidth = 1;
    chronoStartXco = 1.5;
    chronoWidth = 2;
    runsPlotStartXco = 3.5;
    runsPlotWidth = 0.5;
    lobeShiftPlotWidth = 2;
    lobeShiftPlotWidthStartXco = 4.0;
    sedSupplyStartXco = 6;
    sedSupplyWidth = 2;

    totalSectThickness = depos.elevation(y,x,glob.totalIterations) - depos.elevation(y,x,1);
    baseOfSect = depos.elevation(y,x,1);
    thicknessScaleFactor = glob.totalIterations / totalSectThickness;
    maxSupply = max(glob.supplyHistory);
%     lobeShiftScaleFactor = lobeShiftPlotWidth / max(glob.centroidSeperation);
    lobeShiftScaleFactor = 2;
    
    % Find the 25 smallest flow overlaps to plot as markers
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
    
    % Plot the runs as a series of trinagles, red widening-up for thickening, blue tapering-up for thinning
    i = 1;
    while i < glob.totalIterations % nz is the number of thickness values recorded in depos.transThickness(y,x,:);
        if runsUp(i) > 0
            j = i;
            while runsUp(j) > 0
                j = j + 1;
            end
            xco = [runsPlotStartXco, runsPlotStartXco+(runsPlotWidth), runsPlotStartXco+(runsPlotWidth / 2.0)];
            yco = [j, j, i];
            patch(xco, yco, [1,0,0], 'EdgeColor','none');
            i = j;
        elseif runsDown(i) > 0
                j = i;
                while runsDown(j) > 0
                    j = j + 1;
                end
                xco = [runsPlotStartXco, runsPlotStartXco+(runsPlotWidth), runsPlotStartXco+(runsPlotWidth /2.0)];
                yco = [i,i, j];
                patch(xco, yco, [0,0,1], 'EdgeColor','none');
                i = j;
        else
            i = i + 1;
        end
    end
    
    % Now plot the timeseries curves as one line and one polygon each, so outside of the time loop used above to plot per-iteration elements
    t = 1:glob.totalIterations; % Create an implicit loop on t
    
    % Plot the lobe shift history
%     xco = lobeShiftPlotWidthStartXco + (glob.flowOverlapRecord(t) * lobeShiftScaleFactor);
%     zco = t;
%     line(xco, zco, 'color', [0.0 0.0 0.5]);
    
    % Draw the sediment supply history. We want a solid curve so need to define start and end points at base and top on the xco=0 line
    xco = sedSupplyStartXco + ((glob.supplyHistory(t)/maxSupply) * sedSupplyWidth);
    xco(1) = sedSupplyStartXco;
    xco(glob.totalIterations) = sedSupplyStartXco;
    zco = t;
    zco(1) = 0;
    zco(glob.totalIterations) = glob.totalIterations;
    patch(xco, zco, [0 0.8 0.4], 'EdgeColor','none');

    ax = gca;
    ylabel('Thickness (m)','FontSize',14);
    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    axis tight
    grid on
    
%     fName = strcat(modelName, '_vSectChronostrat');
%     export_fig(fName, '-png', '-transparent', '-r600');

%     scrsz = get(0,'ScreenSize'); % screen dimensions vector
%     ffX = figure('Visible','on','Position',[1 1 (scrsz(3)*0.4) (scrsz(4)*0.4)]);
%     
%     ax = gca;
%     histogram(glob.contiguousUnitsSizes);
%     grid on;
%     axis tight;
%     ax.LineWidth = 0.5;
%     ax.FontSize = 14;
%     ylabel('Frequency');
%     xlabel('Length of contiguous strata');
%     set(ax, 'YScale', 'log')
    
end




