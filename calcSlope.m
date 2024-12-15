function [slope] = calcSlope(glob, topog, y1, x1, y2, x2, cellIndex)

    % Calculate slope and azimuth between two point in the 3D space, assuming glob.dx and glob.dy in meters
    dz = topog(y2,x2) - topog(y1,x1); % the slope is negative for outflow

    if mod(cellIndex,2) == 0
        slope = dz/(sqrt(glob.dy^2 + glob.dx^2));    
    else
        slope = dz/glob.dx; 
    end  
end