function checkSupplyCurveParameterFile
    
    clear;
    
    filePath = 'E:/LobyteOutput/signalBumpOutputV66/'; % look here for the Lobyte and post-processing output files.
    fileName = strcat(filePath, 'supplyCurveParameters');
    load(fileName,'supply');
    
    fprintf('Loaded supply parameter file %s with supply variables as follows...\n', fileName);
    
    supply
    
    fprintf('Mean sediment supply volume in all model runs will be %3.2f\n', supply.ampMidPoint);
    fprintf('Supply curve amplitude will range from %d to %d with increment %3.2f\n', supply.ampStart,  supply.ampEnd, supply.ampInc);
    fprintf('Supply curve period will range from %d to %d with increment %3.2f\n', supply.periodStart, supply.periodEnd, supply.periodInc);
    fprintf('Requires a total of %d model runs to complete\n', length(supply.ampVector) * length(supply.periodVector));
end