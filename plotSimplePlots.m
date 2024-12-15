
function plotSimplePlots(glob, depos)

        % Set global variables that need to have specific values in the plotting routines
        glob.sedimentSupplyFreq = 1.0 / glob.flowSedVolOscillationPeriod; % Define this here because not defined in glob in currently saved versions of the two model runs loaded in the lines above
        glob.thicknessThreshold = 0.001; % Thickness threshold used for various post-run analysis e.g. strat completeness, runs analysis
        glob.modelName = "BigFan";
        
        % Plotting parameters to use in the function calls below e.g. calls
        % to plot cross sections
        newFigure = 1; % Control whether plots appear as a new figure (1) or plot on existing axis (0)
        lobeOrFlowColourCoding = 0; % Control colour coding, either by individual flow (0) or by lobe (1)
        transparency = 0.75; % Control transparency of flow areas in 3D plot, from totally opaque (0) to totally transparent (1)
        xCross = 250; % Position of the dip-oriented section on the x-axis
        yCross = 260;  % Position of the strike-oriented section on the y-axis
        lowerLimitX = 0; % limits on x, y and z coords for cross-section plotting, or 0 if want cross-section to auto-calculate plot limits
        upperLimitX = 0;
        maxZ = 0;
        
        fprintf("Plot flow apices positions, xy iteration ...")
        plot3DView(glob, depos, newFigure, lobeOrFlowColourCoding, transparency);
        plotFlowApecesXYZ(glob, 0)
        fprintf("Done\n")

%         fprintf('Plot cross sections...');
        plotCrossSectionStrikeDirection(glob, depos, yCross, lowerLimitX, upperLimitX, maxZ, lobeOrFlowColourCoding, glob.modelName); % Add more calls to cross section routines with different paramters if required
        plotCrossSectionDipDirection(glob, depos, xCross, lowerLimitX, upperLimitX, maxZ, lobeOrFlowColourCoding, glob.modelName);
%         fprintf('Done\n');

        fprintf('Plot vertical section...');
        plotVerticalSection(glob, depos, xCross, yCross, glob.modelName); % Add more calls to vertical section routines with different paramters if required
      
        fprintf('Done\n');
end