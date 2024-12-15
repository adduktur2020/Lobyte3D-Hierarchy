function [runsUp, runsDown, maxRunsUp, maxRunsDown, maxRuns] = calculateRunsUpAndDownForPlotting(depos, x,y)
% Calculate runs up and down at point x,y and record in runsUp and runsDown vectors, to return to calling function for plotting

    thicknesses = depos.transThickness(y,x,:);
    nz = max(size(thicknesses));
    deltaThick = zeros(1,nz);
    runsUp = zeros(1,nz);
    runsDown = zeros(1,nz);

    % Calculate the change in thickness between successive units
    i = 1:nz-1;
    j = 2:nz; % so j = i + 1 therefore thickness change is thickness(j) - thickness(i)
    deltaThick(i) = thicknesses(j) - thicknesses(i); % So deltaThick positive for thickening-up, negative for thinning-up, zero for same

    if deltaThick(1) > 0 runsUp(1) = 1; end % Set the initial value at the base of the succession to start either type of run if thickening/thinning
    if deltaThick(1) < 0 runsDown(1) = 1; end

    for i=2:nz
        if deltaThick(i) > 0 runsUp(i) = runsUp(i-1)+1; end % upper unit thicker, so increment runs up length
        if deltaThick(i) < 0 runsDown(i) = runsDown(i-1)+1; end % upper unit thinner, so increment runs down length
    end
    
    % record some summary stats on the longest runs up and down, and return if required 
    maxRunsUp = max(runsUp);
    maxRunsDown = max(runsDown);
    maxRuns = max(maxRunsUp, maxRunsDown);
end

