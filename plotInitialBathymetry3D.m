function [fanMovie,  plotWindowHandle] = plotInitialBathymetry3D(glob, topog, fanMovie)

% Plot bathymetry across the subset of the grid, flat top grid cells, with white opaque side columns

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    plotWindowHandle = figure('Visible','on','Position',[10, 10, (scrsz(3)*0.8), (scrsz(4)*0.8)]);
      
    [xco,yco] = meshgrid(1:glob.dx:glob.xSize * glob.dx, 1:glob.dy:glob.ySize * glob.dy);
    surface(xco, yco, topog, 'edgecolor','none');
    hold on;

    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    grid on
    axis tight
    colormap(gray);
    xlabel('Strike distance (km)');
    ylabel('Dip distance (km)');
    zlabel('Elevation (m)');
    
    view([220 60]); 
%     waitforbuttonpress;
    
    
    fanMovieFrame = getframe(plotWindowHandle);
    writeVideo(fanMovie, fanMovieFrame);
end