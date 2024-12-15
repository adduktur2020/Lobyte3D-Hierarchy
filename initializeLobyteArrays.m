function [depos, trans] = initializeLobyteArrays(glob, topog)

    %transport recording matrices 
    trans.xCoord  = cell(1, glob.totalIterations);
    %trans.xCoord{glob.it-1} = cell(1,glob.transEvent);
    trans.yCoord  = cell(1, glob.totalIterations);
    % trans.yCoord{glob.it-1} = cell(1,glob.transEvent);
    trans.topog  = cell(1, glob.totalIterations);
    % trans.topog{glob.it-1} = cell(1,glob.transEvent);
    trans.velocity  = cell(1, glob.totalIterations);
    % trans.velocity{glob.it-1} = cell(1,glob.transEvent);
    trans.runUpHeight  = cell(1, glob.totalIterations);
    % trans.runUpHeight{glob.it-1} = cell(1,glob.transEvent);
    % trans.flowType  = cell(1, glob.totalIterations);
    % trans.flowType{glob.it-1} = cell(1,glob.transEvent);
    trans.seaLevel  = cell(1, glob.totalIterations);
    % trans.seaLevel{glob.it-1} = cell(1,glob.transEvent);
    trans.maxStep  = cell(1, glob.totalIterations);
    % trans.maxStep{glob.it-1} = zeros(1,glob.transEvent);

    % recording strata 
    depos.elevation = zeros(glob.ySize,glob.xSize,glob.totalIterations); % elevation for the strata layers
    depos.elevation(:,:,1) = topog;    % set base elevation in strata equal to initial topog elevation
    depos.erosion = zeros(glob.ySize,glob.xSize,glob.totalIterations); % record of all the erosion that occurs in the model
    depos.facies = uint8(zeros(glob.ySize, glob.xSize, glob.totalIterations)); % Record a facies code for each point in strat, short integer to save memory
    depos.transThickness =  zeros(glob.ySize, glob.xSize, glob.totalIterations); % thickness of transported material for each strata layer
    depos.transFaciesColour = zeros(glob.totalIterations, 3);
    depos.hpThickness = zeros(glob.ySize,glob.xSize,glob.totalIterations); % thickness of hemipelagic material for each strata layer
end
