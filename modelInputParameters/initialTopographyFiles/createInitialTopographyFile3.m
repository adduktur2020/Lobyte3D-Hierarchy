function createInitialTopographyFile3(topogType, noiseType, smoothingFactor, fileName)
% Create initial topography and save as matlab variables to be loaded by Lobyte3D

    xSize = 50;
    ySize = 50;
    topog = zeros(ySize, xSize);
    
    maxElev = 500; % so the elevation of the top of the slope, in m
    slopeDecayRate = 0.05; % Specify the slope rate of elevation decay per grid cell
    lengthOfSlope = 50; % length of the slope topography, in grid cells
    slopeGradient = maxElev / lengthOfSlope; % Specify the slope gradient, as 2% of the maxElev per grid cell
    basinFloorGradient = 0.01; % Specify the basin-floor gradient, per grid cell, in meters.
    randNoiseRelief = 0.01; % Random noise in topography has amplitude/relief of 0.1m, so 1cm - not physically significant, but important to avoid numerical artifacts selecting lowest neighbour cells etc
    
%    topogType = "FlatFloor";
%    noiseType = "RawNoise";

    switch(topogType)
        case "FlatFloor"
            topog = createSlopeFlatBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev, slopeGradient, basinFloorGradient);
            
        case "ConcaveSlope"
            topog = createConcaveSlopeTopog(topog, xSize, ySize, randNoiseRelief, maxElev, slopeDecayRate);
            
        case "Ponded"
            topog = createPondedBasinFloorTopog(topog, xSize, ySize, randNoiseRelief, maxElev);
    end
    
    switch(noiseType)
        case "RawNoise"
            topog = addRawNoise(topog, randNoiseRelief, ySize, xSize);
            
        case "SmoothedNoise"
            topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize, smoothingFactor);
    end

    figure;
    handle = surface(topog);
    set(handle,'edgecolor','none');
    xlabel("X distance (cells)");
    ylabel("Y distance (cells)");
    zlabel("Elevation (m)");
    
    figure;
    xco = 1:xSize;
    sectTopog = topog(round(ySize/2),:);
    plot(xco, sectTopog);
    xlabel("X distance (cells)");
    ylabel("Elevation (m)");
    titleStr = sprintf("Initial topography strike-oriented cross section at y=%d", ySize/2);
    title(titleStr);
    
    figure;
    yco = 1:ySize;
    sectTopog = topog(round(xSize/2),:);
    plot(yco, sectTopog);
    xlabel("Y distance (cells)");
    ylabel("Elevation (m)");
    titleStr = sprintf("Initial topography dip-oriented cross section at x=%d", ySize/2);
    title(titleStr);
    
    filePath = "modelInputParameters/initialTopographyFiles/";
    fullFileName = strcat(filePath, fileName);
    save(fullFileName,'topog','-ascii');
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
    
    
    topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize);

    % Finally, make sure that the lowest topography value on the grid is zero, not a minus number, to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
end 
 
function topog = createConcaveSlopeTopog(topog, xSize, ySize, randNoiseRelief, maxElev, slopeDecayRate)

    topog(1,:) = maxElev; % set top edge of grid to this initial elevation value  
    slopeDecayRate = 1 - slopeDecayRate;

    for j = 2:ySize
        topog(j,:) = topog(j - 1,:) .* slopeDecayRate;
    end

    % Ensure lowest topography value on the grid is zero, not a minus number, to avoid issues with complex number results in flow algorithms
    minTopogValue = min(min(topog));
    topog = topog + abs(minTopogValue); % So find minimum value in the topography and add it backt to the topography to ensure min=zero
end

function topog = addRawNoise(topog, randNoiseRelief, ySize, xSize)
% Now to make sure the floor is never completely flat, which would be unrealistic and may cause artifacts in the flow calculations, add some
% low amplitude random noise to that topography
   
    noise = rand(ySize, xSize) .* randNoiseRelief;
    topog = topog + noise;
end

function topog = addSmoothedNoise(topog, randNoiseRelief, ySize, xSize, smoothingFactor)
% Now to make sure the floor is never completely flat, which would be unrealistic and may cause artifacts in the flow calculations, add some
% low amplitude random noise to that topography
   
    noise = rand(ySize, xSize) .* randNoiseRelief;
    minNoise = min(min(noise)); 
    maxNoise = max(max(noise));
    fprintf("Raw noise range from %5.4f m to %5.4fm\n", minNoise, maxNoise);
    
    for j = 1:smoothingFactor
        noise = imgaussfilt(noise,'FilterSize',5); % Repeatedly smooth with a filter size 5 to create longer-wavelength topog noise
    end
    
    minNoise = min(min(noise)); 
    maxNoise = max(max(noise));
    rescale = randNoiseRelief / (maxNoise - minNoise);
    fprintf("Rescale noise range from %5.4f m to %5.4fm with factor %5.4f\n", minNoise, maxNoise, rescale);
    
    noise = (noise - minNoise) .* rescale; % increase the amplitude to compensate for reduction in amplitude from the averaging
    minNoise = min(min(noise)); 
    maxNoise = max(max(noise));
    fprintf("Rescaled noise range from %5.4f m to %5.4fm\n", minNoise, maxNoise);
    
    topog = topog + noise;
end




