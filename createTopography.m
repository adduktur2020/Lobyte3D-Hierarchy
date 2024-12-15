function [topog, glob] = createTopography(glob)
% Create initial topography, with a basin margin slope down to a flat or very gently inclined basin floor
% Basin margin ranges from maxElev, which is taken as the relief of the slope above the basin floor, to the basin floor at elevation 0m
% Note that all elevations are assumed in this case to be below sea-level, representing a marine basin slope and basin floor

    topog = zeros (glob.ySize, glob.xSize);
    maxElev = 100; % so the elevation of the top of the slope, in m
    topog(1,:) = maxElev; % set top edge of grid to this initial elevation value  
    slopeDecayRate = maxElev * 0.02; % Specify the slope gradient, as 2% of the maxElev per grid cell
    basinFloorSlope = 0.00; % Specify the basin-floor gradient, per grid cell, in meters. Zero for these model runs
    
    % Create a marine slope from maxElev to elevation = 0 on the basin floor
    i=2;
    while topog(i-1,1) > 0                         
        topog(i,:) = topog(i-1,:) - slopeDecayRate;
        i = i + 1;
    end

    % Fill the remaining part of the grid with the basin floor elevation, effectively from row i-1 coming out of the previous loop
    % Gradient on the basin floor is basinFloorSlope
    for j =i:glob.ySize                         
        topog(j,:) = topog(j-1,:) - basinFloorSlope; 
    end    
    
    % Now to make sure the floor is never completely flat, which would be unrealistic and may cause artifacts in the flow calculations, add some
    % low amplitude random noise to that topography
    noise = rand(glob.ySize,glob.xSize).*0.0006;
    topog = topog + noise;

    % Finally, make sure that the lowest topography value on the grid is zero, not a minus number,
    % to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
 end 


