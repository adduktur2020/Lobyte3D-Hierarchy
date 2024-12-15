function fanMovie = plotOneFlowIn3D(glob, depos, chronNumber, fanMovie, plotWindowHandle)

    % Plot the flow apex
    xco = glob.apexCoords(chronNumber, 2) .* glob.dx;
    yco = glob.apexCoords(chronNumber, 3) .* glob.dy;
    zco = glob.apexCoords(chronNumber, 4);
    plot3(xco, yco, zco, 'o', 'MarkerFaceColor',[0.424,0.565,0.843]);
    
    hold on;
    
    % Plot the flow route
    xco = glob.transRouteXYZRecord(:, 1, chronNumber) .* glob.dx; % Assumes that element 1 to n are > 0, then elements n+1 to numel are zero
    xco = xco(xco > 0);
    yco = glob.transRouteXYZRecord(:, 2, chronNumber) .* glob.dy;
    yco = yco(yco > 0);
    zco = glob.transRouteXYZRecord(1:numel(xco), 3, chronNumber); % because some zco values might be zero, use the length of xco to select the equivalent zco vector
    line(xco, yco, zco, 'Color', [0.424,0.565,0.843]); % Draw flow routes in cornflower blue
    
     % Plot the area of deposition from the flows in chronNumber
    for y = 1:glob.ySize-1
       for x = 1:glob.xSize-1 
 
           if depos.transThickness(y,x, chronNumber) > glob.thicknessThreshold
               yco = [y*glob.dy y*glob.dy (y+1)*glob.dy (y+1)*glob.dy];  
               xco = [x*glob.dx (x+1)*glob.dx (x+1)*glob.dx x*glob.dx];
               zco = [depos.elevation(y,x,chronNumber), depos.elevation(y,x+1,chronNumber), depos.elevation(y+1, x+1,chronNumber), depos.elevation(y+1,x,chronNumber)];
               patch(xco, yco, zco, depos.flowColours(chronNumber,:), 'EdgeColor','none');
           end
       end
    end

%     waitforbuttonpress;
    
    fanMovieFrame = getframe(plotWindowHandle);
    writeVideo(fanMovie, fanMovieFrame);
end