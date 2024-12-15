function fanMovie = plotOneFlowIn2D(glob, depos, chronNumber, fanMovie, plotWindowHandle)

    indexStart = find(glob.transRouteXYZRecord(:,2,chronNumber) >= glob.mapViewLimits(3), 1, 'first'); % Find the index for the first y coordinate greater than minimum y coord in specified map view
    indexEnd = find(glob.transRouteXYZRecord(:,2,chronNumber) > 0, 1, 'last'); % Find the index for the first y coordinate greater than minimum y coord in specified map view
    transRoutePlot = glob.transRouteXYZRecord(indexStart : indexEnd, :, chronNumber); % Extract only the transport route points where y > map view y min
    transRoutePlot(:,1) = (transRoutePlot(:,1) - glob.mapViewLimits(1)) + 1; % Subtract map view minimum xco, and make minimum 1 for correct array subscript format
    transRoutePlot(:,2) = (transRoutePlot(:,2) - glob.mapViewLimits(3)) + 1; % Subtract map view minimum yco, and make minimum 1 for correct array subscript format
    erosionPlotMap = depos.erosion(glob.mapViewLimits(3):glob.mapViewLimits(4), glob.mapViewLimits(1):glob.mapViewLimits(2), chronNumber);

    hold on

    % Plot the flow route
    j = 1;
    maxJ = size(transRoutePlot,1); % How many points in the transport coordinates record for this chron?
    while j <= maxJ
        xco = transRoutePlot(j, 1);
        yco = transRoutePlot(j, 2); 
        xVect = [(xco - 0.5) *  glob.dx, (xco + 0.5) * glob.dx, (xco + 0.5) * glob.dx, (xco - 0.5) * glob.dx];
        yVect = [(yco - 0.5) *  glob.dy, (yco - 0.5) * glob.dy, (yco + 0.5) * glob.dy, (yco + 0.5) * glob.dy];
        
        if erosionPlotMap(yco, xco) > 0
            colourCode = [0.580, 0.000, 0.827];
        else
            colourCode = [0.424, 0.565, 0.843];
        end
        
        patch(xVect, yVect, colourCode, 'EdgeColor','none');
        j = j + 1;
    end
    
    hold on

    % Plot the area of deposition from the flows in chronNumber
    for y = 1:glob.ySize-1
       for x = 1:glob.xSize-1 
 
           if depos.transThickness(y,x, chronNumber) > glob.thicknessThreshold
               yco = [(y - 0.5 - glob.mapViewLimits(3)) * glob.dy, (y - 0.5 - glob.mapViewLimits(3)) * glob.dy, (y + 0.5 - glob.mapViewLimits(3)) * glob.dy, (y + 0.5 - glob.mapViewLimits(3)) * glob.dy];  
               xco = [(x - 0.5 - glob.mapViewLimits(1)) * glob.dx, (x + 0.5 - glob.mapViewLimits(1)) * glob.dx, (x + 0.5 - glob.mapViewLimits(1)) * glob.dx, (x - 0.5 - glob.mapViewLimits(1)) * glob.dx];
               patch(xco, yco, depos.flowColours(chronNumber,:), 'EdgeColor','none');
           end
       end
    end
    
    % Plot the flow apex
    xco = (glob.apexCoords(chronNumber, 2)  - glob.mapViewLimits(1)) .* glob.dx;
    yco = (glob.apexCoords(chronNumber, 3) - glob.mapViewLimits(3)) .* glob.dy;
    plot(xco, yco, 'o', 'MarkerFaceColor',[0.424,0.565,0.843]);
    
    
    fanMovieFrame = getframe(plotWindowHandle);
    writeVideo(fanMovie, fanMovieFrame);
end