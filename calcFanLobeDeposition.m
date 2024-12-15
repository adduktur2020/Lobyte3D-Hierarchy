function [flowVolumeMap, deposThickMap] = calcFanLobeDeposition(glob, topog, deposThickMap, flowXco, flowYco, flowSedVolume) 
    
    fprintf("Apex %d,%d ", flowXco, flowYco);
    
    % Define key flow volume variables
    flowVolumeMap = zeros(glob.ySize, glob.xSize); % flowVolumeMap records the sediment thickness flow at every step 
    flowRecordMap = zeros(glob.ySize, glob.xSize);
    flowVolumeMap(flowYco, flowXco) = flowSedVolume; % Total sediment volume in the flow at start of deposition at apex point xco, yco
    flowVolumeThreshold = glob.minFlowThick * glob.gridCellArea; % Very important because flow volume dropping below this threshold is what will end most flows
    
    % initialise various variables to control and monitor the flow loop
    maxIterations = 10000; % Just in case of bugs, this iteration limit will terminate the flow loop if it is not self-terminating
    its = 0;
    gCount = 0; % Number of points deposited in free flow gradient descent
    pCount = 0; % Number of points deposited in ponded grid cells
    deposDone = false; % Set the end of flow flag so that the flow can start
    gridEdgeReached = 0;
    
    while deposDone == false && ~gridEdgeReached && its <= maxIterations
        
        [flowVolumeMap, flowRecordMap, deposThickMap, gCount, pCount, gridEdgeReached] = calcFanLobeDepositionOneStep(glob, topog, its, flowVolumeMap, flowRecordMap, deposThickMap, gCount, pCount, flowVolumeThreshold);
       
        [volCheck, volDiff] = calcCheckSumSedVol(glob, flowVolumeMap, deposThickMap);
        if ~volCheck
            fprintf("Conservation-of-mass warning %9.8f at %d %d\n", volDiff, flowXco, flowYco);
        end
       
       % maxFlowVolume is the maximum volume in any cell
       maxflowVolume = max(max(flowVolumeMap));
       if maxflowVolume < flowVolumeThreshold % Stop flow if max volume in any cell would deposit < thickness threshold input parameter
          deposDone = true;
       else
            its = its + 1;
       end
    end

    if its >= maxIterations fprintf("Warning: Reached max %d its in fanLobeDeposition ",its); end
    
    fprintf("Disp%d Pond%d ", gCount, pCount);
end

function [flowVolumeMap, flowRecordMap, deposThickMap, gCount, pCount, gridEdgeReached] = calcFanLobeDepositionOneStep(glob, topog, its, flowVolumeMap, flowRecordMap, deposThickMap, gCount, pCount, flowVolumeThreshold)
% Calculates, for every cell occupied by the flow, the thickness of sediment to be deposited
% and the amount of sediment that keep flowing (flow front) proportionally to the gradient.
% flowVolumeMap is a 2D matrix starting with the flow front thickness at the current step that calculates the next position of the flow front and its thickness.
% deposThickMap is a 2D matrix recording the sediment thickness deposited ad every step.

    % flowYCoords & flowXCoords are two column vectors containing the x,y coordinates of cells that contain the flow - where sediment flow volume exceeds minimum threshold for transport.
    [flowYCoords, flowXCoords] = find(flowVolumeMap > flowVolumeThreshold); % Is glob.minFlowThick correct here? Should be volume?
    flowCanGoMap = flowVolumeMap <= 0; % Flow can go where the flow is not already located, so cell value is TRUE if flow volume <= 0
    flowCanGoMap(deposThickMap > 0) = 0;  % Make sure that the flow cannot go back into cells where deposition has already occurred
    flowSize = size(flowYCoords,1); % the size of the flow in terms of the number of cells it currently covers
    flowCOGHeight = glob.totalFlowThickness * glob.COGFlowThicknessProportion;
    gridEdgeReached = 0;
    
    % For every cell(y,x) into which sediment flows the for loop calculates thickness of sediment to be deposited and stores this in deposThickMap matrix. 
    % Remaining sediment is moved to neighbouring lower cells, with flow volume moved into each cell proportionally to the topographic gradient. 
    % Every cell is treated independently and the resulting updated flow-front is stored in newFlowVolumeMap
    k = 1;
    while k <= flowSize && ~gridEdgeReached
        
        % So take the kth coordinate pair specifying a grid cell occupied by the flow ...
        y = flowYCoords(k);
        x = flowXCoords(k);
        flowRecordMap(y,x) = 1;      
        glob.depStep = size(flowYCoords,1); 
        
        % if the specified xy coords are still on the grid ...
        if y < size(flowVolumeMap,1) && y > 1 && x < size(flowVolumeMap,2) && x > 1

            % Find cells adjacent to flow cells that have lower elevation but have not yet had sediment deposited in them from this flow
            
            % Extract the record of previous deposition for 3 down-dip target cels, from flowCanGoCells
            flowCanGoCells = flowCanGoMap(y+1, x-1:x+1);

            % nbrGrads is a vector containing the gradient between cell(y,x) and its neighbours, for cells x-1,y+1; x,y+1; x+1,y+1 
            [~, nbrGrads] = calcNeighbourMaxGrad(glob, topog, y, x, flowCOGHeight);
            nbrGrads = nbrGrads .* flowCanGoCells; % set gradient to zero into cells already containing deposition from this iteration

            if ~isempty(find(nbrGrads, 1)) % current cell has at least one lower adjacent cell to flow into
                [deposThickMap, flowVolumeMap] = calcDepoStepGradient(glob, y, x, its+1, flowVolumeMap, deposThickMap, nbrGrads); % +1 because its count starts at zero but we want to use it as a vector index for the deposited flow thickness
                gCount = gCount + 1;
            else
                [deposThickMap, flowVolumeMap, topog] = calcDepoStepPondFillAndSpill(glob, topog, y, x, flowVolumeMap, deposThickMap);
                pCount = pCount + 1;
            end  
        else
            if y == glob.ySize
                gridEdgeReached = true;
            end
        end 
        
        k = k + 1;
    end
    
    excessVolume = (sum(sum(deposThickMap)) * glob.gridCellArea) - (glob.flowSedVolHistory(glob.it) * 1.01);
%     if glob.it == 5
%        fprintf("Pause"); 
%     end
end

function [deposThickMap, flowVolumeMap] = calcDepoStepGradient(glob, y, x, its, flowVolumeMap, deposThickMap, nbrGrads)
% Deposit a defined amount of sediment and move the remainder into suitable neighbour cells

    if its < numel(glob.fracDepos)
        oneFracDepos = glob.fracDepos(its); 
    else
        oneFracDepos = glob.fracDepos(numel(glob.fracDepos));
    end

    deposVol = flowVolumeMap(y,x) .* oneFracDepos; % calculate the specified fraction of volume to deposit
    deposThickMap(y,x) = deposThickMap(y,x) + (deposVol / glob.gridCellArea); % record the thickness of deposVol across grid cell area
    flowVolumeMap(y,x) = flowVolumeMap(y,x) - deposVol;  % amount of sediment that keep flowing
       
    % Calculate the sediment fraction received by each lower cell from the current cell(y,x)
    % glob.flowRadiationFactor is a flow-volume weighting factor hgiher values of glob.flowRadiationFactor concentrate the flow in cell with higher gradient                      
    nbrGrads = nbrGrads .^ glob.flowRadiationFactor; 
    sedFrac = nbrGrads / sum(nbrGrads);   
    
    flowVolumeMap(y+1, x-1:x+1) = flowVolumeMap(y+1, x-1:x+1) + (flowVolumeMap(y,x) .* sedFrac(1:3));
    flowVolumeMap(y,x) = 0;
end                      

function [deposThickMap, flowVolumeMap, topog] = calcDepoStepPondFillAndSpill(glob, topog, y, x, flowVolumeMap, deposThickMap)
% Fill a topographic low that is ponding and blocking the flow to glob.pondFillProportion of the updip topographic relief 
% and move the flow past the pond to the next lowest cell beyond the pond rim

    % Find the lowest y+1 point around the ponded cell, and it's relief above cell x,y
    nbrTopog = topog(y+1,x-1:x+1); % Make 1x3 matrix of neighbouring topography
    nbrTopog(1,2) = 5000000; % The grid center point is point xy which is the local low flow is trapped in, so need to add height to make sure we find the next lowest cell
    minNbrTopog = min(min(nbrTopog)); % Find the elevation of the lowest adjacent point
    [lowY, lowX] = find(nbrTopog==minNbrTopog); % get the x,y coordinates in the minnbrTopog matrix of that lowest grid point 
    topoBlockingRelief = nbrTopog(lowY(1), lowX(1)) - topog(y,x); % Calculate the relief between xy cell and lowest neighbour cell - this is the relief of the rim of the pond
    if topoBlockingRelief < 0
        topoBlockingRelief = 0;
    end
    
    % Now fill the pond with some deposition and move the flow to the lowest neighbour cell
    deposThicknessToFillPond = topoBlockingRelief * glob.pondFillProportion; % Calculate how much thickness to put in the pond 
    deposVolumeToFillPond = deposThicknessToFillPond * glob.gridCellArea; % Calculate the volume of that deposited thickness
    newX = x + (lowX - 2); % Convert the lowest cell coords from 1x3 to whole grid size coordinates
    newY = y + 1;
    
    % Check if there is enough sediment in the flow at x,y to fill the pond and reduce fill thickness according to available volume if not ...
    if  flowVolumeMap(y,x) < deposVolumeToFillPond 
        deposVolumeToFillPond = flowVolumeMap(y,x); % Calculate the volume of that deposited thickness#
        deposThicknessToFillPond = deposVolumeToFillPond / glob.gridCellArea;
    end
        
    % Now do the deposition in the pond, move the flow volume to the lowest cell beyond pond
    topog(y,x) = topog(y,x) + deposThicknessToFillPond; % Fill the pond behind the blocking relief with sediment to the rim + 1%
    deposThickMap(y,x) = deposThickMap(y,x) + deposThicknessToFillPond; % Record that deposition as a thickness
    flowVolumeMap(newY, newX) = flowVolumeMap(newY, newX) + (flowVolumeMap(y,x) - deposVolumeToFillPond); % Add the remaining sediment volume to the flow in the new cell beyond the topo barrier
    flowVolumeMap(y,x) = 0; % Set the flow volume at the ponded point to zero - it's all moved to newX,new
end

function [volCheckOK, volDiff] = calcCheckSumSedVol(glob, flowVolumeMap, deposThickMap)

    volCheckOK = 1;
    checkSumSedVol = sum(sum(flowVolumeMap)) + sum(sum(deposThickMap .* glob.gridCellArea));
    volDiff = glob.flowSedVolHistory(glob.it) - checkSumSedVol; % So positive if some sediment has been lost - neither in flow or deposited
    if volDiff > 0.0001 % Arbitrary threshold for volume difference indicating mass loss from flow not deposited
        volCheckOK = 0;
    end
end
