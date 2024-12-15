function calculateCompensationIndex(stratSectionThicknesses, sectLabel) 
    
    maxLayers = size(stratSectionThicknesses, 2);
    
    intervalWindowLoopSmallest = 10;
    intervalWindowLoopIncrement = 10;
    maxWindows = fix(maxLayers / intervalWindowLoopIncrement); % the integer result of the division
    cv = zeros(1, maxWindows-1); 
    xPlotVect = zeros(1, maxWindows-1);
    counter = 1;
    x = 1:size(stratSectionThicknesses, 1); % So calculate integral/sum accross the length of the whole cross-section
    
    
    for intervalWindowSize = intervalWindowLoopSmallest:intervalWindowLoopIncrement:maxLayers-1
        
        for windowPosition = 1: intervalWindowSize: maxLayers - intervalWindowSize
            
            stratSurfaceStart = windowPosition;
            stratSurfaceEnd = windowPosition + intervalWindowSize; % and for the current window/interval size
  
            localThickness = sum(sum(stratSectionThicknesses(x, stratSurfaceStart:stratSurfaceEnd)));
        end
        
        meanThickness = mean(mean(stratSectionThicknesses(x, stratSurfaceStart:stratSurfaceEnd)));     
        if meanThickness > 0 % Only want to sum non-zero mean thickness points, or else results will just be NaN
            cv(counter) = cv(counter) + (((localThickness / meanThickness) - 1.0) * ((localThickness / meanThickness) - 1.0));
        end
        
%         xPlotVect(counter) = meanThickness;
        xPlotVect(counter) = intervalWindowSize;
        cv(counter) = sqrt(cv(counter));
        counter = counter + 1;
    end
    
    figure
    
    size(xPlotVect)
    
    scatter(xPlotVect, cv, 'filled');
    set(gca, 'yscale', 'log');
    set(gca, 'xscale', 'log');
    ylabel('CV');
    xlabel('Mean interval thickness (m)');
    title(sectLabel);
    grid on;
%     hold on;
    
    % best fit line equation constants, calculate line and plot
    const = polyfit(xPlotVect, cv, 1);
    m = const(1);
    k = const(2);
    YBL = m * cv + k;
%     line(xPlotVect, YBL); % , 'r-', 'LineWidth', 3);
    
    hold off;
end