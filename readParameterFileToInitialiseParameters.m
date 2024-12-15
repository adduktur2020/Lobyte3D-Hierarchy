function [glob, initialisedFromParamFile, savedModelFound] = readParameterFileToInitialiseParameters(glob)

    fileIn = fopen(glob.inputParametersFileNameAndPath, 'r');
    
    if (fileIn < 0)
        fprintf('WARNING: parameter input file %s not found\n', glob.inputParametersFileNameAndPath);
        initialisedFromParamFile = 0; % Boolean flag to show if data loaded or not
        savedModelFound = 0;
    else
        fprintf('Reading parameters from filename %s\n', glob.inputParametersFileNameAndPath);
       
        savedModelFound = 0;
        glob.modelName = fscanf(fileIn,'%s', 1);
        fgetl(fileIn); % Read to the end of the line to skip any label text
          
        if isfile(strcat("modelOutput\", glob.modelName, ".mat")) % Load the model if a saved file with correct name already exists
            
            savedModelFound = 1;
            initialisedFromParamFile = 0;
            
        else % Otherwise, continue to read the parameter file
        
            glob.outputDir = fscanf(fileIn,'%s', 1);
            fgetl(fileIn); % Read to the end of the line to skip any label text

            glob.totalIterations = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % total model iterations (number of transport events)

            glob.deltaT = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % timestep in My, so this is the interval between turbidity current events

            glob.xSize = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % Grid x dimension (km)

            glob.ySize = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % Grid y dimension (km)

            glob.dx = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % grid cell x size in km

            glob.dy = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % grid cell y size in km

            glob.initTopogFilename = fscanf(fileIn,'%s', 1);
            fgetl(fileIn); % filename for the initial topography input file
            
            glob.initTopogErosionRateLimiter = ones(glob.ySize, glob.xSize);
            glob.initTopogErosionRateLimiter(1:50,:) = 0.0;

            glob.sedEntryPointXco = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % x-coordinate for the sediment entry point for each flow 

            glob.sedEntryPointYco = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % y-coordinate for the sediment entry point for each flow 

            glob.flowSedVolMax = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % maximum sediment supply volume during model run, meters cubed

            glob.flowSedVolMin = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % minimum sediment supply volume during model run, meters cubed

            glob.flowSedVolOscillationPeriod = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % sediment supply oscillation period
            
            glob.hpThickPerTimestep = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); %Rate of hemipelagic depos per time step 
            
            glob.erosionKappa = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % diffusion coefficient kappa m2 per my, for smoothing each time step of erosion by flows. Sensitive to time step and grid size - will warn in run if unstable value used
            
            glob.gravity  = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % acceleration due to gravity m squared per second

            glob.rhoAmbient = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % density (kg/m^3) of the ambient fluid 
            
            glob.erosionRateConstant = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % Erosion rate constant, value from original equation 1.3E-7
            
            glob.basalFrictCoeff = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % basal friction factor to use in flow velocity calculation
            
            glob.medianGrainDiameter = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % d50 (m) median grain diameter (medium/fine sand)
            
            glob.rhoSolid = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % grain density is quartz density in kg/m3 (mass density)
            
            glob.deposVelocity = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % depositional velocity threshold (m/s) to stop transport and commence deposition 
            
            glob.flowAccelProportion = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % Flow acceleration/deceleration coefficient - 1.0 is instant acceleration or deceleratio to new v per flow time step, 0.5 halfway accel/decel etc
            
            glob.totalFlowThickness = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % total thicknes of the flow in meters
            
            glob.COGFlowThicknessProportion = fscanf(fileIn,'%f', 1); % NNED TO CHNAGE NAME
            fgetl(fileIn); % Proportion of the total flow height to use in the gradient and flow velocity calculation 0 - slower & very sensitive to topography, 1 - faster & much less sensitive to topography

            glob.flowVolumConcentration = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % volumetric sediment concentration Cv of a suspension Cv = VolSed./VolTot
            
            glob.minFlowThick = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % minimum flow thickness to keep flow moving

            glob.pondFillProportion = fscanf(fileIn,'%f', 1);
            fgetl(fileIn); % Proportion of the height of ponding topographic lows to fill when flow is trapped during fan lobe deposition

            glob.flowRadiationFactor = fscanf(fileIn,'%f', 1); 
            fgetl(fileIn); % concentrate the flow in the direction of max velocity gradient
            
            deposFracIncrements = fscanf(fileIn,'%d', 1); 
            fgetl(fileIn); % How many increments are to be used in the proportion of flow volume deposited - typical aim is for a smooth increase, not a sudden dump
            glob.fracDepos = fscanf(fileIn,'%f,', deposFracIncrements); 
            fgetl(fileIn); % Read deposFracIncrements values, comma-delimited

            glob.animation = fscanf(fileIn,'%d', 1);
            fgetl(fileIn); % Animation flag, 1 to record an animation during the model run, 0 to not
            
            glob.animationStartChron = fscanf(fileIn,'%d', 1);	
            fgetl(fileIn); % Start chron for the animation
            
            glob.animationEndChron = fscanf(fileIn,'%d', 1);	
            fgetl(fileIn); % End chron for the animation
            
            glob.mapViewLimits = fscanf(fileIn,'%d,', 4);
            fgetl(fileIn); % x and y limits of the map animation, in grid cell indices units
            
            initialisedFromParamFile = 1; % Boolean flag to show data loaded successfully. Will be reset below to zero if anything goes wrong
        end
    end
end