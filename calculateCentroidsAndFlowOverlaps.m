function glob = calculateCentroidsAndFlowOverlaps(glob, depos)
% Calculate the centroid of transported sediment deposition at each time step
% multiply this by the inverse of the normalised flow overlap area to give a final flow separation metric

    centroidX = zeros(1, glob.totalIterations);
    centroidY = zeros(1, glob.totalIterations);
    centroidSeparation = zeros(1, glob.totalIterations);
    
    for t = 1:glob.totalIterations
        pointCount = 0;
        for x = 2:glob.xSize-1
            for y = 1:glob.ySize-1
                if depos.transThickness(y,x,t) > glob.thicknessThreshold
                    % Add x & y coordinates of a point where there has been deposition, to form vectors of x and y coordinates for the time step t deposition
                    centroidX(t) = centroidX(t) + x; 
                    centroidY(t) = centroidY(t) + y;
                    pointCount = pointCount + 1;
                end
            end
        end
        % Dividing the x and y list of deposition coordinates by the total number of depositional points gives the average depos coordinate, 
        % which is the xy centroid for time step t
        if pointCount > 0
            centroidX(t) = centroidX(t) / pointCount;
            centroidY(t) = centroidY(t) / pointCount;
        end
    end
    
    % Now calculate the separation distance of the centroids, specifically centroid(t) from centroid(t-1)
    for t = 2:glob.totalIterations
        if centroidX(t) > 0 && centroidX(t-1) > 0 && centroidY(t) > 0 && centroidY(t-1) > 0
            deltaX = centroidX(t) - centroidX(t-1);
            deltaY = centroidY(t) - centroidY(t-1);
            centroidSeparation(t) = sqrt((deltaX * deltaX) + (deltaY * deltaY));
        end
    end
    
    flowOverlapRecord = calculateFlowOverlapRecord(glob, depos);   
    glob.flowOverlapRecord = flowOverlapRecord;
    glob.centroidSeparation = centroidSeparation;
    glob.centroidX = centroidX;
    glob.centroidY = centroidY;
end