function plotLobeVolumeTimeseries(glob, depos)

    figure
    
    timeValues = (1:glob.totalIterations) *  glob.deltaT;
    numberOfLobes = size(depos.lobeCentroidXY, 1);
    
    for lobeNumber = 1:numberOfLobes
        
        plot(timeValues, depos.fanLobeVolumes(:, lobeNumber), 'color', depos.lobeColours(lobeNumber, :), 'LineWidth',3)
        hold on
    
    end
  
    grid on   
    xlabel("Elapsed model time (My)")
    ylabel("Lobe volume")
    hold off
end