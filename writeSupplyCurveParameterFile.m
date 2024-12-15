function writeSupplyCurveParameterFile
    
clear;
    
    filePath = 'E:/LobyteOutput/signalBumpOutputV9/'; % look here for the Lobyte and post-processing output files.
    fileName = strcat(filePath, 'supplyCurveParameters');
    % Need to ensure that the supply range parameters match with the files in the filePath folder above...
    % The parameters below define supply oscillations with amplitudes ranging from 0 to 25, centered on a flow size of 30
    
     % Parameters for the V1 folder
%     supply.ampMidPoint = 25.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 5;
%     supply.ampEnd = 25.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 100;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;
    
  % Parameters for the V5 folder
%     supply.ampMidPoint = 30.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 2.5;
%     supply.ampEnd = 25.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 100;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;


    % Parameters for the V6 folder
%     supply.ampMidPoint = 25.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 2.5;
%     supply.ampEnd = 20.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 100;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;

  
 % Parameters for the V7 folder
%     supply.ampMidPoint = 60.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 5.0;
%     supply.ampEnd = 60.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 100;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;
    
     % Parameters for the V8 folder
%     supply.ampMidPoint = 25.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 2.5;
%     supply.ampEnd = 25.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 100;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;

    % Parameters for the V9 folder
    supply.ampMidPoint = 25.0; 
    supply.ampStart = 0.0;
    supply.ampInc = 2.5;
    supply.ampEnd = 25.0;
    supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
    
    supply.periodStart = 20;
    supply.periodInc = 5;
    supply.periodEnd = 120;
    supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;
    
    % Parameters for the V10 and V11 folder
%     supply.ampMidPoint = 10.0; 
%     supply.ampStart = 0.0;
%     supply.ampInc = 1.0;
%     supply.ampEnd = 10.0;
%     supply.ampVector = supply.ampStart:supply.ampInc:supply.ampEnd;
%     
%     supply.periodStart = 20;
%     supply.periodInc = 5;
%     supply.periodEnd = 120;
%     supply.periodVector = supply.periodStart:supply.periodInc:supply.periodEnd;

    save(fileName,'supply');
    
    fprintf('Created supply parameter file in %s with supply variables as follows...\n', fileName);
    fprintf('Will require %d model runs to complete\n', length(supply.ampVector) * length(supply.periodVector));
    supply
end