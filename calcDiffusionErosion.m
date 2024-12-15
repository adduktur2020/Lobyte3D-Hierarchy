function smoothedErosion = calcDiffusionErosion(erosionMap, maxX, maxY, dx, dt, kappa)
% Apply a simple 4-neighbour finite difference solution of the diffusion equation to smooth the erosion map
% Size of kappa determines degree of smoothing, limited by +-1 size of smoothing grid
% Units of kappa should be m2 per My, matching time step dt units of my
% Note the cells on the grid margin eg x=1,y=1 are not smoothed, but otherwise, no grid boundary condition is defined

    grdSpaceSquared = dx * dx; % Calculate first because used in loop below but in stability check first

    % Check the finite difference solution stability
    fdGradient = kappa * ( dt / (grdSpaceSquared));
    if fdGradient > 0.5
        fprintf('WARNING: diffusion FD gradients is %5.4f  Solutions not stable for > 0.5 so smoothing not applied\n', fdGradient);
        smoothedErosion = erosionMap; % Return unchanged erosion map
    else

        smoothingMap = zeros(maxY, maxX);

        for x = 2:maxX-1 % Loop across the whole grid, but avoiding edges where x-1, x+1 etc will be a problem
            for y = 2:maxY-1
                elevSum = erosionMap(y,x-1) + erosionMap(y,x+1) + erosionMap(y-1,x) + erosionMap(y+1,x); % Sum the surrounding four erosion values
                smoothingMap(y,x) = kappa * dt * (elevSum - (4 * erosionMap(y,x))) / grdSpaceSquared; % 2d forward finite difference solution for diffusion
            end
        end

        smoothedErosion = erosionMap + smoothingMap; % Update the erosion map with the result of the smoothing calculation
    end
end