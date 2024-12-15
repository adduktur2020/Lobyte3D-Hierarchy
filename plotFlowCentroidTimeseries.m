function plotFlowCentroidTimeseries(glob, depos)

    figure
    
    % Calculate the separation distance of each flow centroid from the t-1 previous flow centroid
    separationsX = (glob.centroidX(3:glob.totalIterations) - glob.centroidX(2:glob.totalIterations-1)) * glob.dx;
    separationsY = (glob.centroidY(3:glob.totalIterations) - glob.centroidY(2:glob.totalIterations-1)) * glob.dy;
    separationsXY = sqrt((separationsX .* separationsX) + (separationsY .* separationsY));
    iterationNumber = 3:glob.totalIterations;
    plot(iterationNumber .* glob.deltaT, separationsXY, 'linestyle','-', 'color', [0.5, 0.5, 0.5])
    hold on

    for lobeNumber = 1:size(depos.lobeCentroidXY, 1)
        timeOneLobe = iterationNumber(depos.flowLobeNumber(3:glob.totalIterations) == lobeNumber) .* glob.deltaT;
        separationsOneLobe = separationsXY(depos.flowLobeNumber(3:glob.totalIterations) == lobeNumber);
        plot(timeOneLobe, separationsOneLobe, 'marker','o', 'linestyle','none', 'color',depos.lobeColours(lobeNumber,:))
    end
    
    line([1, numel(separationsXY)] .* glob.deltaT, [glob.meanBedStrikeLength * glob.dx, glob.meanBedStrikeLength * glob.dx], 'Color', [204/255, 85/255, 0], 'LineStyle', '--')
    line([1, numel(separationsXY)] .* glob.deltaT, [glob.maxBedStrikeLength * glob.dx, glob.maxBedStrikeLength * glob.dx], 'Color', 'red', 'LineStyle', '--')
    
    grid on   
    xlabel("Elapsed model time (My)")
    ylabel("Flow centroid seperation (m)")
    hold off
end