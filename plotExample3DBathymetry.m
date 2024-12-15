function plotExample3DBathymetry(glob, depos, leftX, rightX, bottY, topY, modelName)
% Plot bathymetry across the subset of the grid, flat top grid cells, with white opaque side columns

    ff = figure;
    time = glob.totalIterations - 1;
    
    minBathym = min(min(depos.elevation(bottY:topY, leftX:rightX, time)));
    maxBathym = max(max(depos.elevation(bottY:topY, leftX:rightX, time)));
    
    for x = leftX:rightX
        for y = bottY:topY
          
           bathyColour = [0 0 0.25 + (0.75 * ((depos.elevation(y,x,time) - minBathym)/maxBathym))]; % Bathymetry, cyan at min depth, dark blue at max depth
           
           yco = [(y-0.5)*glob.dy (y-0.5)*glob.dy (y+0.5)*glob.dy (y+0.5)*glob.dy];  
           xco = [(x-0.5)*glob.dx (x+0.5)*glob.dx (x+0.5)*glob.dx (x-0.5)*glob.dx];
           zco = [depos.elevation(y,x,time), depos.elevation(y,x,time), depos.elevation(y,x,time), depos.elevation(y,x,time)];
           patch(yco, xco, zco, bathyColour); % top surface patch
           
           zco = [minBathym, depos.elevation(y,x,time), depos.elevation(y,x,time), minBathym];
           xco = [(x-0.5)*glob.dx, (x-0.5)*glob.dx, (x-0.5)*glob.dx, (x-0.5)*glob.dx];
           yco = [(y-0.5)*glob.dy, (y-0.5)*glob.dy, (y+0.5)*glob.dy, (y+0.5)*glob.dy];
           patch(yco, xco, zco, [0.9 0.9 0.9]); % x-0.5 left column
           
           xco = [(x+0.5)*glob.dx,(x+0.5)*glob.dx,(x+0.5)*glob.dx, (x+0.5)*glob.dx];
           yco = [(y-0.5)*glob.dy (y-0.5)*glob.dy,(y+0.5)*glob.dy, (y+0.5)*glob.dy];
           patch(yco, xco, zco, [ 0.9 0.9 0.9]); % x+0.5 right column
           
           xco = [(x-0.5)*glob.dx, (x-0.5)*glob.dx, (x+0.5)*glob.dx, (x+0.5)*glob.dx];
           yco = [(y-0.5)*glob.dy, (y-0.5)*glob.dy, (y-0.5)*glob.dy, (y-0.5)*glob.dy];
           patch(yco, xco, zco, [0.9 0.9 0.9]); % x-0.5 left column
           
           xco = [(x-0.5)*glob.dx, (x-0.5)*glob.dx, (x+0.5)*glob.dx, (x+0.5)*glob.dx];
           yco = [(y+0.5)*glob.dy, (y+0.5)*glob.dy, (y+0.5)*glob.dy, (y+0.5)*glob.dy];
           patch(yco, xco, zco, [0.9 0.9 0.9]); % x+0.5 right column
           
        end
    end
    
    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    grid on
    axis tight
    
    xlabel('Strike distance (km)');
    ylabel('Dip distance (km)');
    zlabel('Elevation (m)');
    
%     view([110, 45]);
%     export_fig(sprintf('lobyte3D%s_LimitedAreaPlot', modelName), '-png', '-transparent', '-r600');
end