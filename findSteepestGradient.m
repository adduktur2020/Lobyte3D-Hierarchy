function [newY, newX, steepestGrad, flowLostOffGrid, flowBehindObstacle, obstacleRelief, randomRouting] = findSteepestGradient(topog, y, x, neighbYXIncs, neighbYXDists)

    flowLostOffGrid = false;
    flowBehindObstacle = false;
    randomRouting = false; % Flag to test if random routing was used - need to know models are determinisitc or not
    obstacleRelief = 0;
    
    [gradDestinationCells, negGradients] = calcSingleDestinationCellGradients(x, y, topog, neighbYXDists, neighbYXIncs); % calc gradient to each single neighbour cell, no averaging
    
    [steepestGrad, steepestIndex] = max(gradDestinationCells); % Find the maximum, positive down-slope gradients (n.b. there might be more than one...)
    
    if negGradients(steepestIndex)
        flowBehindObstacle = true;
        newY = y + neighbYXIncs(steepestIndex,1); % steepestIndex xy increments should move the flow over the lowest relief exit from the low-point current cell
        newX = x + neighbYXIncs(steepestIndex,2);
        % Calculate the height difference to top of the obstacle using minimum gradient which should be to steepest adjacent cell, which should be the obstacle
        % gradients going up are negative, so abs required to ensure obstacleRelief is not also negative
        obstacleRelief = abs(steepestGrad) * neighbYXDists(steepestIndex); 
    else
    
        if numel(steepestIndex) == 1 % one unique steepest-gradient destination found, so set next xy coords to this cell
            newY = y + neighbYXIncs(steepestIndex,1);
            newX = x + neighbYXIncs(steepestIndex,2);
            
        else % so numel > 1, meaning the the lowest/steepest destination cell is non-unique, more than one cell with this elevation

           % shuffle coord and take a random cell between the lowest (in y direction?????)
           nOfSteepestCells = numel(steepestIndex);
           randIndex = round((rand * (nOfSteepestCells - 1)) + 0.50);
           randCellInd = steepestIndex(randIndex);
           newY = y + neighbYXIncs(randCellInd,1);
           newX = x + neighbYXIncs(randCellInd,2);
           randomRouting = 1; % Set a flag to show stochastic element in flow routing
        end
    end

    % finally, check if the new flow location has reached the edge of the model grid ...
    if newY==1 || newY==size(topog,1) || newX==1 || newX==size(topog,2)
        flowLostOffGrid = true; % Set flag to indicate the flow is lost off the grid, no deposition etc
    end   
end
