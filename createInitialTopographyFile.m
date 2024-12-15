function createInitialTopographyFile
% Create initial topography and save as matlab variables to be loaded by Lobyte3D

    xSize = 500;
    ySize = 500;
    topog = zeros (ySize, xSize);
    
    maxElev = 500; % so the elevation of the top of the slope, in m
%     lengthOfSlope = 50; % length of the slope topography, in grid cells
%     slopeGradient = maxElev / lengthOfSlope; % Specify the slope gradient, as 2% of the maxElev per grid cell
%     basinFloorGradient = 0.01; % Specify the basin-floor gradient, per grid cell, in meters.
    randNoiseRelief = 0.01; % Random noise in topography has amplitude/relief of 0.001m, so 1mm - not physically significant, but important to avoid numerical artifacts selecting lowest neighbour cells etc
    
    topog = createConcaveSlopeTopog(topog, xSize, ySize, randNoiseRelief, maxElev);
%     topog = createSlopeFlatBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev, slopeGradient, basinFloorGradient);
%     topog = createPondedBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev);

%     % Create a channel leading on to a barrier, to test flow trapping
%     % behind obstacle etc
%     topog(50,:) = topog(50,:) + 100;
%     topog(1:49,249) = topog(1:49,249) + 100;
%     topog(1:49,251) = topog(1:49,251) + 100;
%     topog(50,250) = 50;

    figure;
    handle = surface(topog);
    set(handle,'edgecolor','none');
    
    xco = 1:xSize;
    sectTopog = topog(round(ySize/2),:);
    figure;
    plot(xco, sectTopog);
    
    save('modelInputParameters/initialTopographyFiles/concaveBasinFloorInitTopogSmoothFilterW3.txt','topog','-ascii');
end 
    
function topog = createSlopeFlatBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev, slopeGradient, basinFloorGradient)

    topog(1,:) = maxElev; % set top edge of grid to this initial elevation value  
    
    % Create a marine slope from maxElev to elevation = 0 on the basin floor
    i=2;
    while topog(i-1,1) > 0                         
        topog(i,:) = topog(i-1,:) - slopeGradient;
        i = i + 1;
    end

    % Fill the remaining part of the grid with the basin floor elevation, effectively from row i-1 coming out of the previous loop
    % Gradient on the basin floor is basinFloorSlope
    for j =i:ySize                         
        topog(j,:) = topog(j-1,:) - basinFloorGradient; 
    end    
    
    % Now to make sure the floor is never completely flat, which would be unrealistic and may cause artifacts in the flow calculations, add some
    % low amplitude random noise to that topography
    topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize);

    % Finally, make sure that the lowest topography value on the grid is zero, not a minus number, to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
end 
 
function topog = createPondedBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev)

    topog(1,:) = maxElev; % set top edge of grid to this initial elevation value  
    slopeDecayRate = maxElev * 0.02; % Specify the slope gradient, as 2% of the maxElev per grid cell
    
    % Create a marine slope from maxElev to elevation = 0 on the basin floor
    i=2;
    while topog(i-1,1) > 0                         
        topog(i,:) = topog(i-1,:) - slopeDecayRate;
        i = i + 1;
    end

    % Fill the remaining part of the grid with a slope of the same gradient in the opposite direction
    for j =i:ySize                         
        topog(j,:) = topog(j-1,:) + slopeDecayRate;
    end    
    
    % Now to make sure the floor is never completely flat, which would be unrealistic and may cause artifacts in the flow calculations, add some
    % low amplitude random noise to that topography
    topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize);

    % Finally, make sure that the lowest topography value on the grid is zero, not a minus number, to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
end 
 
function topog = createConcaveSlopeTopog(topog, xSize, ySize, randNoiseRelief, maxElev)

    topog(1,:) = maxElev; % set top edge of grid to this initial elevation value  
    slopeDecayRate = 0.9; % Specify the slope gradient, as 2% of the maxElev per grid cell

    for j = 2:ySize
        topog(j,:) = topog(j - 1,:) .* slopeDecayRate;
    end
    
    topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize);

    % Finally, make sure that the lowest topography value on the grid is zero, not a minus number, to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
end

function topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize)

    % Add some smoothed random noise to that topography
    noise = rand(ySize, xSize) .* randNoiseRelief;
    for j = 1:50
        noise = imgaussfilt(noise,'FilterSize',5); % Repeatedly smooth with a filter size 5 to create longer-wavelength topog noise
    end
    noise = noise * 10.0; % increase the amplitude to compensate for reduction in amplitude from the averaging
    topog = topog + noise;
end




