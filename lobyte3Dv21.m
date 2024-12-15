function lobyte3Dv21(inputParamsFileNameAndPath)

    verbose = 1; % Control volume of text output as the model runs
    advanced = 1; % Control the complexity of post-processing analysis and plotting
    glob.inputParametersFileNameAndPath = inputParamsFileNameAndPath;
   
    % Initialise the model, either just by reading the parameter file and
    % setting up all variables ready to run, or, if a saved .mat file with
    % the defined model name already exists in folder modelOutput,
    % initialise the model by reading that saved file
    [glob, topog, depos, trans, initialisedFromParamFile, savedModelFound] = initialiseLobyte(glob); 
    
    if initialisedFromParamFile && ~savedModelFound
        lobyteRunFileNameAndPath = strcat(glob.outputDir, glob.modelName, '.mat');
        fprintf('Running model to save to %s\n', lobyteRunFileNameAndPath);
        [glob, depos, ~, ~] = runOneLobyteModel(glob, depos, trans, topog, verbose);
        
        if advanced == 1
            [glob, depos] = calculateStatistics (glob, depos);
            plotAdvancedPlots(glob, depos);
        else  
            plotSimplePlots(glob, depos);
        end
        
    elseif savedModelFound

        if advanced == 1
            [glob, depos] = calculateStatistics (glob, depos);
            plotAdvancedPlots(glob, depos);
        else  
            plotSimplePlots(glob, depos);
        end
    else
        fprintf('Lobyte model failed to initialise. Check file path and name and param file details\n');
    end
end

    



