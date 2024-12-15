function [glob, topog, depos, trans, initialisedFromParamFile, savedModelFound] = initialiseLobyte(glob)

    rng(84); % Seed the random number generator so that the sequence of random numbers is the same for each model run
    
    [glob, initialisedFromParamFile, savedModelFound] = readParameterFileToInitialiseParameters(glob);
    
    if savedModelFound
        
        savedFileName = strcat("modelOutput\", glob.modelName, ".mat");
        fprintf("Loaded model from previously saved file %s\n", savedFileName);
        load(savedFileName,'glob','depos', 'trans','topog');
        initialiseSuccess = 1;
        
    else
        if initialisedFromParamFile
            % Define general model variables and parameters
            glob.maxIts = glob.totalIterations + 2; % max number of iterations/events = used for calculating the SL curve (probably redundant)
            glob.thicknessThreshold = 0.01; % Thickness threshold used for various post-run analysis e.g. strat completeness, runs analysis
            glob.dx = glob.dx * 1000; % Convert grid cell dimensions to m from km, because m used in all the calculations
            glob.dy = glob.dy * 1000;
            glob.gridCellArea = glob.dx * glob.dy; % Calculate grid area in m2 from grid cell xy sizes in m

            % Create initialize topography
            [topog, glob, topogReadSuccessfully] = readInitTopography(glob); % this function create a faulted/non-faulted ramp topography 

            if topogReadSuccessfully % If topog file not read, or wrong dimensions, topog == 0
                % Initialize water level and sediment supply oscillation curves
                [glob] = waterLevelCurve(glob);
                [glob] = initializeSedimentSupplyParams(glob);

                % Initialize Lobyte parameters and arrays
                [glob] = initializeLobyteParameters(glob);
                [depos, trans] = initializeLobyteArrays(glob, topog);
                
                initialisedFromParamFile = 1;
            else
                % Initial topog file not read successfully, so return all variables as zero and set flag as fail 
                % but do not set glob to zero because that will disrupt possible further model runs
                topog = 0; 
                depos = 0;
                trans = 0;
                initialisedFromParamFile = 0;
            end
        end
    end
        
    if ~savedModelFound && ~initialisedFromParamFile
        
        % vars are returned so need to assign with dummy values, but do not set glob to zero because that will disrupt possible further model runs
        topog = 0;
        depos = 0;
        trans = 0;
        initialiseSuccess = 0;
        fprintf("Coult not initialise model, either from parameter file or from previously saved model. Check parameter file carefully for correct format, check for location of saved file etc\n");
    end
end