function plotFlowApecesTimeseries(glob, depos)

    figure
    
    % Calculate the separation distance of all the flow apices
    separationsX = (glob.apexCoords(3:glob.totalIterations,2) - glob.apexCoords(2:glob.totalIterations-1,2)) * glob.dx;
    separationsY = (glob.apexCoords(3:glob.totalIterations,3) - glob.apexCoords(2:glob.totalIterations-1,3))  * glob.dy;
    separationsXY = sqrt((separationsX .* separationsX) + (separationsY .* separationsY));
    iterationNumber = 3:glob.totalIterations;
    plot(iterationNumber .* glob.deltaT, separationsXY, 'linestyle','-', 'color', [0.5, 0.5, 0.5])
    hold on

    for lobeNumber = 1:size(depos.lobeApexXY, 1)
        timeStepsOneLobe = (iterationNumber(depos.flowLobeNumber(3:glob.totalIterations) == lobeNumber)) * glob.deltaT;
        separationsOneLobe = separationsXY(depos.flowLobeNumber(3:glob.totalIterations) == lobeNumber);
        plot(timeStepsOneLobe, separationsOneLobe, 'marker','o', 'linestyle','none', 'color',depos.lobeColours(lobeNumber,:))
    end
    
    line([1, numel(separationsXY)] * glob.deltaT, [glob.meanBedStrikeLength * glob.dx, glob.meanBedStrikeLength * glob.dx], 'Color', [204/255, 85/255, 0], 'LineStyle', '--')
    line([1, numel(separationsXY)] * glob.deltaT, [glob.maxBedStrikeLength * glob.dx, glob.maxBedStrikeLength * glob.dx], 'Color', 'red', 'LineStyle', '--')
    
    grid on   
    xlabel("Elapsed model time (iterations)")
    ylabel("Flow apex seperation (m)")
    hold off
end