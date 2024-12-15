function flowOverlapRecord = calculateFlowOverlapRecord(glob, depos)

    flowOverlapRecord = zeros(1, glob.totalIterations);
    
%     flow1 = zeros(glob.ySize, glob.xSize);
%     flow2 = zeros(glob.ySize, glob.xSize);
    
    fprintf('Mapping overlapping flow deposits...');
    for t = 2:glob.totalIterations - 1;
        [flow1Row, flow1Col, ~] = find(depos.transThickness(:,:,t) > 0);
        [flow2Row, flow2Col, ~] = find(depos.transThickness(:,:,t+1) > 0);

        % Find the smallest of the two flows for time step t
        % Will use this below to calculate the proportion of flow areas that overlap
        % NB this means overlap area is proportional to size of each pair of flows - not an absolute flow overlap area. Maybe important to calculations at some point??
        minLobeArea = min(length(flow1Row), length(flow2Row));

        % Now combine flow1Row and flow1Col into two matrices of xy coords 
        lobe1XY = horzcat(flow1Row(:), flow1Col(:));
        lobe2XY = horzcat(flow2Row(:), flow2Col(:));
        
        % use intersect to find those common rows, and length to give the area of the overlap,
        % then normalise against maximum possible overlap which is area of the smaller flow...
        flowOverlapRecord(t) = length(intersect(lobe1XY, lobe2XY, 'rows')) / minLobeArea; % intersect with 'rows' option outputs all rows with common values
    end
    
    fprintf('Done\n');
end