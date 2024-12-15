function plotFlowApecesXYZ(glob, newFigure)

    if newFigure
        figure
    end
    
    coordData = glob.apexCoords(2:glob.totalIterations,:);
    
    xco = coordData(coordData(1:glob.totalIterations-1,1) == 1, 2) .* glob.dx;
    yco = coordData(coordData(1:glob.totalIterations-1,1) == 1, 3) .* glob.dy;
    zco = coordData(coordData(1:glob.totalIterations-1,1) == 1, 4);
    plot3(xco, yco, zco, '+')            
    
    hold on;
    
    xco = coordData(coordData(1:glob.totalIterations-1,1) == 2, 2) .* glob.dx;
    yco = coordData(coordData(1:glob.totalIterations-1,1) == 2, 3) .* glob.dy;
    zco = coordData(coordData(1:glob.totalIterations-1,1) == 2, 4);
    plot3(xco, yco, zco, 'o', 'MarkerFaceColor',[0.424,0.565,0.843])  
    
    for j = 1:glob.totalIterations
        xco =  glob.transRouteXYZRecord(:, 1, j) .* glob.dx; % Assumes that element 1 to n are > 0, then elements n+1 to numel are zero
        xco = xco(xco > 0);
        yco = glob.transRouteXYZRecord(:, 2, j) .* glob.dy;
        yco = yco(yco > 0);
        zco = glob.transRouteXYZRecord(1:numel(xco), 3, j); % because some zco values might be zero, use the length of xco to select the equivalent zco vector
        
        line(xco, yco, zco,'Color', [0.424,0.565,0.843]); % Draw flow routes in cornflower blue
    end
    
    view(135,45);
    grid on   
    xlabel("Xco (m)");
    ylabel("Yco (m)");
    zlabel("Zco (m)");
end