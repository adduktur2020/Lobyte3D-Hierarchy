function plotSelectedModelOutput(glob, depos, trans, topog)

        % Define two cross-section positions, to calculate stats through the model
        xCross = 250; % Position of the dip-oriented section on the x-axis
        yCross1 = 77;  % Position of the strike-oriented section on the y-axis
        glob.sedimentSupplyFreq = 1.0 / glob.flowSedVolOscillationPeriod; % Define this here because not defined in glob in currently saved versions of the two model runs loaded in the lines above
        glob.thicknessThreshold = 0.001; % Thickness threshold used for various post-run analysis e.g. strat completeness, runs analysis

        glob.modelName = "BigFan";
        
        plotFlowApecesTimeseries(glob);
        
        fprintf("Plot flow apices positions, xy iteration ...")
        plot3DView(glob, depos, 1)
        plotFlowApecesXYZ(glob, 0)
        fprintf("Done\n")

        fprintf('Plot cross sections...');
        plotCrossSectionStrikeDirection(glob, depos, 125, glob.modelName);
        plotCrossSectionStrikeDirection(glob, depos, 150, glob.modelName);
        plotCrossSectionDipDirection(glob, depos, 250, glob.modelName);
        fprintf('Done\n');

%         fprintf('Plot vertical sections...');
%         plotVerticalSection(glob, depos, 250, 50, glob.modelName);
%         plotVerticalSection(glob, depos, 250, 75, glob.modelName);
%         plotVerticalSection(glob, depos, 250, 100, glob.modelName);
%         fprintf('Done\n');

%         fprintf('Plot vertical section and correlative chronostrat');
%         plotVerticalSectionAndChronostratsTriangles(glob, depos, xCross, yCross, glob.modelName);
%         fprintf('Done\n');

%         
%         fprintf("Plot 3D view of flow history ...")
%         plotSingleFlowMaps(glob, depos, 2, glob.it-1);
%         fprintf("Done\n")
%         

%           fprintf('Plot flow centroids...');
%           plotCentroids(glob, depos, glob.modelName);
%           fprintf('Done\n');
%           
%           fprintf('Plot chronostrat diagrams slices through model animation...');
%           plotChronostratTraverseAnimation(glob, depos);
%           fprintf('Done\n');

%           fprintf('Plot maps, P value, strat completeness and maximum power spectra frequencies etc...');
%           plotStatsMaps(glob, depos, glob.modelName);
%           fprintf('Done\n');
          
%           fprintf('Plot significant spectral peaks count bar chart...');     
%           plotSpectralPeakCounts(glob.significantPeakCount, glob.sedimentSupplyPeriod, glob.modelName); % Note updated on 25.7 to send just sigPeakCount rather than all of glob structure, and then sediment supply period added too
%           fprintf('Done\n');
% 
%           fprintf('Plot bed thickness distribution etc...');
%           plotBedThicknessDistribution(glob, depos);
%           fprintf('Done\n');

%           fprintf('Calculate and plot power spectra at X=97, Y=50 ...');
%           glob = powerSpectraAnalysis(glob, depos.transThickness, xCross, yCross, 500, 1,1);
%    
% 
%         plotPvsCompleteness(glob, depos);
%         
%         fprintf('Analysing flow overlap time series...');
%         analyseFlowOverlapTimeseries(glob);
%         fprintf('Done\n');

end