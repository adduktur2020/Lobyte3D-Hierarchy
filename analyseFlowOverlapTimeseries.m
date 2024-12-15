function analyseFlowOverlapTimeseries(glob)

    cutOffProportion = 0.25;
    % Find the 25 smallest flow overlaps to plot as markers
    sortFlowOverlaps = sort(glob.flowOverlapRecord, 'ascend');
%     flowOverlapCutoff = sortFlowOverlaps(50);
    flowOverlapCutoff = cutOffProportion;
    
    separateFlows = (glob.flowOverlapRecord < flowOverlapCutoff);
    
    j = 1;
    m = 1;
    while j < length(separateFlows)
        k = 0;
        while j < length(separateFlows) && separateFlows(j) == 0
            j = j + 1;
            k = k + 1;
        end
        
        if j > 1 % Because if the first element is a no overlap event, we don't want to record a zero duration
            duration(m) = k;
        end
        j = j + 1; % To get past the =1 value
        m = m + 1;
    end
    
    n = length(duration);
    histogram(duration);
    ylabel('Frequency');
    xlabel('Proportional overlap of consecutive flows');
    titleString = sprintf('Time interval between low-overlap flows\nn=%d cutoff=%3.2f mean %4.3f mode %4.3f', n, cutOffProportion, mean(duration), mode(duration));
    title(titleString);
end