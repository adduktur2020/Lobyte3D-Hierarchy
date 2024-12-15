function [fanMovie,  plotWindowHandle] = plotInitialBathymetry2D(glob, topog, fanMovie)

% Plot bathymetry across the subset of the grid, flat top grid cells, with white opaque side columns

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    plotWindowHandle = figure('Visible','on','Position',[10, 10, (scrsz(3)*0.8), (scrsz(4)*0.8)]);
    
    minX = min(glob.mapViewLimits(1:2));
    minY = min(glob.mapViewLimits(3:4));
      
    xco = ((glob.mapViewLimits(1):glob.mapViewLimits(2)) - minX) * glob.dx;
    yco = ((glob.mapViewLimits(3):glob.mapViewLimits(4)) - minY) * glob.dy;

%     xco = (glob.mapViewLimits(1):glob.mapViewLimits(2)) * glob.dx;
%     yco = (glob.mapViewLimits(3):glob.mapViewLimits(4))  * glob.dy;

    plotTopog = topog(glob.mapViewLimits(3):glob.mapViewLimits(4), glob.mapViewLimits(1):glob.mapViewLimits(2));
    imagesc(xco, yco, plotTopog);
    hold on;

    grid on
    axis tight
    xlabel('Strike distance (m)');
    ylabel('Dip distance (m)');
  
    fanMovieFrame = getframe(plotWindowHandle);
    writeVideo(fanMovie, fanMovieFrame);
end