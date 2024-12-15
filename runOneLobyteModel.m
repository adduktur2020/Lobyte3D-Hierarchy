function [glob, depos, trans, topog] = runOneLobyteModel(glob, depos, trans, topog, verbose)
% Verbose flag controls text output 0=only notification of final output file writing 1=output about each iteration plus final output

    % Set up the main model loop variables ready to start
    glob.it = 2; % Because subscript 1 in the arrays stores the initial conditions
    glob.maxIt = glob.totalIterations;
    glob.apexCoords = zeros(glob.totalIterations,4); % 4 dimensions are 1=x,2=y,3=z, 4= termination value, so 1=free to deposit, 2=trapped, 3=grid edge
    glob.transRouteXYZRecord = zeros(glob.ySize, 3, glob.totalIterations);

    flowHistory = zeros(1000,4,glob.maxIt);
    
    while glob.it <= glob.maxIt
        
        if glob.animation && glob.it == glob.animationStartChron
            movieFileName = sprintf("%s/animations/%sMovieChron%dto%d.avi", glob.outputDir, glob.modelName, glob.animationStartChron, glob.animationEndChron);
            fanMovie = VideoWriter(movieFileName); % Note only called once because of if statement above
            fanMovie.FrameRate = 5;
            open(fanMovie);
            [fanMovie, plotWindowHandle] = plotInitialBathymetry2D(glob, topog, fanMovie);
        end

        if verbose fprintf('It#%d Event#',glob.it); end

        % Set up variables before doing eventNum flows for this iteration   
        depos.elevation(:,:,glob.it) = depos.elevation(:,:,glob.it-1); % copy the previous layer into the current one
        eventNum = 1; % number of events per iteration
        glob.maxDescentGradient(glob.it) = -99999; % Set to low initial value so can be set to max value found in steepestDescentTransport
        totalDeposVolumeOneIt = 0.0;

        for i = 1 : eventNum

            % Initialise specific flow variables for one flow
            flow.yco = glob.sedEntryPointYco; % Set flowXco and flowYco to the start coordinates for the flow
            flow.xco = glob.sedEntryPointXco;   
            flow.sedVolume = glob.flowSedVolHistory(glob.it); % Sediment volume at start of deposition 
            flow.sedConcentration = glob.flowVolumConcentration;
            flow.totalVolume = flow.sedVolume / flow.sedConcentration;
            flow.velocity = 0;
            flow.shearVelocity = 0;
            flow.viscWater = 1.787 * 10^-06; % kinematic viscosity of water (constant)
            flow.ReP = sqrt(1.6 * glob.gravity * (glob.medianGrainDiameter ^ 3/2)) / flow.viscWater; % particle reynolds number (dimensionless) 1.787 * 10^-06 is kinematic viscosity of water
            flow.settlingVelocity = 1/18 * ((1.6 * glob.gravity)/ flow.viscWater) * glob.medianGrainDiameter ^ 2; % (m/s) settling velocity
            flow.lostOffGrid = 0;
            flow.trapped = 0;
            flow.stopped = 0;
            
            if verbose fprintf('%d %1.0f ',i, flow.sedVolume); end

            % Calculate sediment channel-type transport route from the point of sediment input to the point where deposition should begin  
            [depos, erosionMap, deposMap, flow, flowXco, flowYco, transRouteXYZ, velocity_data, Xco_data, Yco_data, elevation_data] = calcSteepestDescentTransportAndErosion(glob, depos, flow, topog);
            
            depos.facies(:,:,glob.it) = deposMap > 0; % Record as facies 1 all the points where steepest-descent deposition occurred
            glob.apexCoords(glob.it, :) = flow.apexCoords;
            glob.transRouteXYZRecord(:, :, glob.it) = transRouteXYZ; % Record the route this particular flow took
            oneFlowErodedVolume = sum(erosionMap,'all') * glob.dx * glob.dy;
            if verbose fprintf("%d pts erod %1.0f (%3.2f m) ", nnz(transRouteXYZ(:,1)), oneFlowErodedVolume, max(erosionMap,[],'all')); end

            if flow.lostOffGrid == false % Deposit the transported sediment if it is still on the grid
                % Calculate fan-lobe deposition. Flow thick is the thickness of the flow, depos thick the thickness of the deposit from the flow
                [~, deposMap] = calcFanLobeDeposition(glob, topog, deposMap, flowXco, flowYco, flow.sedVolume);
                depos.facies(:,:,glob.it) = depos.facies(:,:,glob.it) + uint8((deposMap > depos.facies(:,:,glob.it)) * 2);
            end
            
%             erosionMap = calcDiffusionErosion(erosionMap, glob.xSize, glob.ySize, glob.dx, glob.deltaT, glob.erosionKappa);

            topog = topog - erosionMap + deposMap; % Update topography with flow erosion and deposition, so that the next flow will interact with the results of the current flow
            totalDeposVolumeOneEvent = sum(sum(deposMap .* glob.gridCellArea)); % Volume for one event
            totalDeposVolumeOneIt = totalDeposVolumeOneIt + totalDeposVolumeOneEvent; % Volume for whole iteration
            
            if verbose 
                fprintf('vol %1.0f (%5.4f input+erod & %5.4f input) ', ...
                    totalDeposVolumeOneIt, totalDeposVolumeOneIt / (glob.flowSedVolHistory(glob.it) + oneFlowErodedVolume) , totalDeposVolumeOneIt / glob.flowSedVolHistory(glob.it)); 
            end
        end

        % Update depositional record variables and matrices with the results from all flow events in this iteration
        depos.erosion(:,:,glob.it) = erosionMap; % Record the magnitude of erosion
        depos.transThickness(:,:,glob.it) = deposMap; % total transported sediment thickness for this time step, adds each flow at each xy coord
        depos.hpThickness(:,:,glob.it) = depos.hpThickness(:,:,glob.it) + glob.hpThickPerTimestep; % total hemipelagic sediment thickness for this time step,
        depos.elevation(:,:,glob.it) = depos.elevation(:,:,glob.it) +  depos.transThickness(:,:,glob.it) + depos.hpThickness(:,:,glob.it);
        depos.flowColours(glob.it,1:3) = [0.5+(rand/2), rand, 0.0]; % Set a partially random colour for current flow
        
        if glob.animation && glob.it >= glob.animationStartChron && glob.it <= glob.animationEndChron
            fanMovie = plotOneFlowIn2D(glob, depos, glob.it, fanMovie, plotWindowHandle);
        end

        % Update the flow history
        flowHistory(:,1,glob.it) = velocity_data;
        flowHistory(:,2,glob.it) = Yco_data;
        flowHistory(:,3,glob.it) = Xco_data;
        flowHistory(:,4,glob.it) = elevation_data;

        glob.it = glob.it + 1; 
        if verbose fprintf('\n'); end
    end

    % Save the recorded movie, if there is one
    if glob.animation
        close(fanMovie)
    end
    
%     % Save the main model data, so variable structures glob, depos, trans and topog
%     fileName = strcat(glob.outputDir, glob.modelName, '.mat');
%     fprintf('Writing model data to %s ...', fileName);
%     save(fileName,'glob','depos', 'trans','topog','-v7.3');


    fileName3 = strcat(glob.outputDir, 'flowDataRaw.mat');
    save(fileName3,'flowHistory');
    
    fprintf('Run done hon\n');
end