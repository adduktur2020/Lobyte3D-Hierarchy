function [glob, depos] = calculateStatistics (glob, depos)

    [glob, totalDeposArea] = calculateFanSummaryStatistics(glob, depos);
    
    [glob, depos, numberOfLobes] = calculateFanLobesFromFlowCentroids(glob, depos);
%     [glob, depos, numberOfLobes] = calculateFanLobesFromFlowApices(glob, depos); 
    depos = calculateFanLobeVolumes(glob, depos, numberOfLobes);
    depos = calculateFanLobeColours(glob, depos, numberOfLobes); 
    
    
    
    % Compensation time scale - time necessary to produce a deposit with a mean thickness equal to the maximum relief of the depositional surface
    % calculate and plot mean thickness and maximum relief of the Lobyte3D surface through time

    
    
%     calculateSectionLengthsAllGrid(glob, depos);
%     
%     glob = calculateStratigraphicCompletenessSimple(glob, depos);
%     glob = calculateCentroidsAndOverlap(glob, depos);
%     glob = calculatePValueMaps(glob, depos, totalDeposArea);
%     glob = calculateStratigraphicCompensationMetrics(glob, depos);
% 
%     MCIterations = 100;
%     minSectLength = 500;
% 
%     tic
%     glob = calculatePowerSpectra(glob, depos, totalDeposArea, MCIterations, minSectLength); 
%     toc
end

function [glob, totalDeposArea] = calculateFanSummaryStatistics(glob, depos)
% Calculate the proportion of areal coverage for each time step and the mean thickness of layer at each time t

    glob.meanThickness = zeros(1,glob.totalIterations);
    glob.deposArea = zeros(1,glob.totalIterations);
    glob.deposAreaProportion = zeros(1,glob.totalIterations);
    
    meanThicknessAll = mean(mean(mean(nonzeros(depos.transThickness(:,:,:)))));
    minThicknessAll = min(min(min(nonzeros(depos.transThickness(:,:,:)))));
    maxThicknessAll = max(max(max(nonzeros(depos.transThickness(:,:,:)))));
    
    % Calculate the maximum fan area, the total number of points on the x y grid that have recorded some deposition
    totalDeposArea = 0;
    for x = 2:glob.xSize-1
        for y = 1:glob.ySize-1
            totalFlowThick = sum(depos.transThickness(y,x,:));
            if totalFlowThick > glob.thicknessThreshold 
                totalDeposArea = totalDeposArea + 1;
            end
        end
    end
    
    % Calculate areas and mean thickness of flow deposition for each iteration
     for t = 2:glob.totalIterations       
        glob.deposArea(t) = nnz(depos.transThickness(:,:,t)); % Counts non-zero elements, so number of points covered by thickness > 0 is depositional area
        glob.deposAreaProportion(t) = nnz(depos.transThickness(:,:,t)) / totalDeposArea; 
        glob.meanThickness(t) = mean(mean(nonzeros(depos.transThickness(:,:,t))));
     end
    
     % Calculate hiatus lengths - INCOMPLETE
     for x = 1:glob.xSize
        for y = 1:glob.ySize
    
            % The ideal homogenous thickness is the flow volume at time t / maximum fan area. We can then calcuate through a vertical succession the proportional thickness of
            % each layer relative to that idea homogenous thickness
%             allFanLayerThickness = zeros(1, glob.totalIterations);
%             for t = 2:glob.totalIterations
%                 allFanLayerThickness(t) = glob.supplyHistory(t) / totalDeposArea;
%                 depos.proportionThickness(t) = (depos.elevation(y,x,t) - depos.elevation(y,x,t-1)) ./ allFanLayerThickness(t);
%             end
% 
%             % calculate the frequency versus duration of the hiatuses at coordinates x y
%             for t = 2:glob.totalIterations      
%                 if depos.transThickness(y,x,t) > 0.0 % glob.thicknessThreshold
% 
%                     % code in here to calculate hiatus lengths
% 
%                 end
%             end
        end
     end

    % Calculate the number of event beds at each location on the grid
    glob.eventBedCountMap = nnz(depos.transThickness(:,:));
    
    maxBedStrikeLengths = zeros(1,glob.totalIterations);
    minBedStrikeLengths = ones(1,glob.totalIterations) * 10E10; % Ensure starting values are very big, so will definitely be over-written by actual smaller values
    meanBedStrikeLengths = zeros(1,glob.totalIterations);
    
    % Calculate all flow minimum, mean and maximum strike-direction lengths
    for t = 2:glob.totalIterations
        
        sectionsCount = 0; % Used to count the number of sections with > o strike length beds
        
        for y = 1:glob.ySize % Loop across the grid in the depositional dip direction
            
            % put all the non-zero bed thicknesses along profile at y into vector
            oneFlowStrikeThicknessProfile = depos.transThickness(y,:,t);
            oneFlowStrikeThicknessProfile = oneFlowStrikeThicknessProfile(oneFlowStrikeThicknessProfile > glob.thicknessThreshold);
            bedStrikeLength = numel(oneFlowStrikeThicknessProfile); % Bed strike legnth is the number of non-zero elements, but NOT allowing for continuous extent
            
            if bedStrikeLength > 0
                meanBedStrikeLengths(t) = meanBedStrikeLengths(t) + bedStrikeLength;
                if bedStrikeLength < minBedStrikeLengths(t)
                    minBedStrikeLengths(t) = bedStrikeLength;
                end

                if bedStrikeLength > maxBedStrikeLengths(t)
                    maxBedStrikeLengths(t) = bedStrikeLength;
                end
                
                sectionsCount = sectionsCount + 1;
            end
        end
        
        if sectionsCount > 0
            meanBedStrikeLengths(t) = meanBedStrikeLengths(t) / sectionsCount; % Calculate the mean strike bed length for the bed deposited time t
        else
            meanBedStrikeLengths(t) = 0;
        end
    end
    
    glob.meanBedStrikeLength = mean(meanBedStrikeLengths); % Calculate the mean strike bed length for all beds deposited from iteration 2 to total iterations
    glob.maxBedStrikeLength = max(maxBedStrikeLengths); % Calculate the maximum of the strike bed length for all beds deposited from iteration 2 to total iterations

    fprintf('Done\n');
    fprintf('Summary statistics, across fan with total area %d\n', totalDeposArea);
    fprintf('Minimum unit thickness %4.3f m Mean %4.3f m Maximum %4.3f m\n', minThicknessAll, meanThicknessAll, maxThicknessAll);
    fprintf('Minimum unit area %d Mean %d Maximum %d\n', min(glob.deposArea), mean(glob.deposArea), max(glob.deposArea));
    fprintf('Bed strike lengths: min %4.3fkm mean %4.3fkm max %4.3fkm\n', min(minBedStrikeLengths) * glob.dx, mean(meanBedStrikeLengths) * glob.dx, max(maxBedStrikeLengths * glob.dx));
end

function calculateSectionLengthsAllGrid(glob, depos)
% calculate the distribution of the vertical section lengths across the fan strata, shortest, longest, mean length etc
    
    fName = sprintf('%s%s_SectionLengthGrid.mat',glob.outputDir, glob.modelName);
    if exist(fName, 'file')
        load(fName, 'sectionLengthGrid','sectionLengthCounts');
    else
        sectionLengthGrid = zeros(glob.ySize, glob.xSize);
        for x = 1:glob.xSize
            for y = 1:glob.ySize
                sectionLengthGrid(y,x) = sum(depos.transThickness(y,x,:) > 0); % Number of layers in the section is the sum of number of non-zero thickness layers
            end
        end
        
        bins = 1:20:length(depos.transThickness(1,1,:));
        sectionLengthCounts = histcounts(sectionLengthGrid, numel(bins));
        save(fName, 'sectionLengthGrid','sectionLengthCounts');
    end
    
    nonZeroSections = sectionLengthGrid(sectionLengthGrid > 0);
    minSectLength = min(nonZeroSections);
    meanSectLength = mean(nonZeroSections);
    modalSectLength = mode(nonZeroSections);
    maxSectLength = max(nonZeroSections);
    
    fprintf('Shortest non-zero section %d units, non-zero mean %3.2f, non-zero mode %d, maximum %d\n', minSectLength, meanSectLength, modalSectLength, maxSectLength);
end
    
    
function glob = calculateStratigraphicCompletenessSimple(glob, depos)

    fprintf('Calculating stratigraphic completeness map...');
    fprintf('NB depositional threshold is %6.5f\n', glob.thicknessThreshold);

    fName = sprintf('%s%s_StratCompletenessRecord.mat', glob.outputDir, glob.modelName);
    if exist(fName, 'file')
        load(fName, 'stratCompleteness','stratCompletenessContig','contiguousUnitsMap');
        depos.stratCompleteness = stratCompleteness;
        depos.stratCompletenessContig =  stratCompletenessContig;
        glob.contiguousUnitsMap = contiguousUnitsMap;
        glob.contiguousUnitsSizes = contiguousUnitsMap(contiguousUnitsMap~=0); % Remove all remaining zeros values before stats are calculated and store in glob
    else
        % Calculate stratigraphic completeness for each point on the grid
        fprintf('X: ');
        maxContigUnits = round((glob.totalIterations / 3) + 0.5); % This is the probably just slightly more than the maximum possible number of contiguous units in the strata since minimum unit is 2 flows then no flow, right?
        contiguousUnitsMap = zeros(glob.ySize, glob.xSize, maxContigUnits);
        for x = 1:glob.xSize
            fprintf('%3d', x);
            for y = 1:glob.ySize
                deposCountOnePoint = 0;
                deposCountContigOnePoint = 0;

                % Loop through time to calculate total and contiguous stratigraphic completeness
                for t = 2:glob.totalIterations 
                   if depos.transThickness(y,x,t) > 0.0 % So thickness of deposited flow/s at x,y,t is > 0
                       deposCountOnePoint = deposCountOnePoint + 1; % So this is an iteration that records some deposition, so add to count for total strat completeness
                   end

                   if depos.transThickness(y,x,t) > 0.0 && depos.transThickness(y,x,t-1) > 0.0 % Count all >0 thickness units with a similar unit contiguous i.e. in contact below
                       deposCountContigOnePoint = deposCountContigOnePoint + 1;
                   end
                end
                depos.stratCompleteness(y,x) = deposCountOnePoint / glob.totalIterations; % Divide deposition record count at x,y by total iterations to get completeness
                depos.stratCompletenessContig(y,x) = deposCountContigOnePoint / glob.totalIterations;

                % Loop through time again and calculate the proportion of all contiguous thickness units
                maxContigCountOnePoint = 0; % Maximum length of contiguous units for one point on the gridd
                t = 2;
                contigCountPtr = 1; % Pointer for where in the matrix 3rd dimension the latest contiguous unit length should be stored

                while t <= glob.totalIterations 

                    contigCount = 0;

                    while  t <= glob.totalIterations && depos.transThickness(y,x,t) > 0.0 && depos.transThickness(y,x,t-1) > 0.0 % So two vertically adjacent non-zero thickness units
                        contigCount = contigCount + 1;
                        t = t + 1;
                    end

                    if contigCount > 0 % Because previous loop found at least two contiguous units
                        contiguousUnitsMap(y,x,contigCountPtr) = contigCount + 1; % Store the count in the map, and plus one to count the first unit from t-1 in the total
                        contigCountPtr = contigCountPtr + 1; % Update the pointer so next stored unit is stored in next element in the matrix 3rd dimension
                        if contigCount > maxContigCountOnePoint % so if the number of contiguous points is the longest so far, record it as the max
                            maxContigCountOnePoint = contigCount;
                        end
                    end

                    t = t + 1;
                end

%                 depos.stratCompletenessContig(y,x) = sum(contiguousUnitsMap(y,x, :)) / glob.totalIterations; % So this the sum of all contiguous units as a proportion of the total time steps
            end
            fprintf('\b\b\b');
        end
        
        % Ensure results of calculation are in appropiate bits of global data structures
        glob.contiguousUnitsSizes = contiguousUnitsMap(contiguousUnitsMap~=0); % Remove all remaining zeros values before stats are calculated and store in glob
        glob.contiguousUnitsMap = contiguousUnitsMap; % Put it in the glob structure so that it is available for plotting elsewhere
        stratCompleteness = depos.stratCompleteness;
        stratCompletenessContig = depos.stratCompletenessContig;
        save(fName, 'stratCompleteness','stratCompletenessContig','contiguousUnitsMap');
    end
    % So from the code about the contiguousUnitsMap is now an xy array containing a list of the lengths of all the sections of contiguous strata at each grid cell point
    
    fprintf('Done\n');
    fprintf('Stratigraphic completeness: Minimum %4.3f Mean %4.3f Maximum %4.3f\n', min(min(depos.stratCompleteness)), mean(mean(depos.stratCompleteness)), max(max(depos.stratCompleteness)));
    fprintf('Stratigraphic completeness (contiguous): Minimum %4.3f Mean %4.3f Maximum %4.3f\n', min(min(depos.stratCompletenessContig)), mean(mean(depos.stratCompletenessContig)), max(max(depos.stratCompletenessContig)));
    fprintf('Analysis of contiguous units shows: minimum length %d, mean length %4.3f, model length %d, maximum length %d, maximum contiguous completeness %5.4f\n', ...
        min(min(min(glob.contiguousUnitsSizes))), mean(mean(mean(glob.contiguousUnitsSizes))), mode(mode(mode(glob.contiguousUnitsSizes))), max(max(max(glob.contiguousUnitsSizes))), max(max(depos.stratCompletenessContig)));
end
  
function glob = calculateCentroidsAndOverlap(glob ,depos)
% calculate the centroid locations and degree of overlap of successive fan lobes

    fprintf('Centroid and flow overlap calculations...');
    fName = sprintf('%s%s_CentroidAndFlowOverlapRecord.mat', glob.outputDir, glob.modelName);
    if exist(fName, 'file')
        fprintf('\nFound file %s so loading that...', fName);
        load(fName,'-mat','centroidX','centroidY','centroidSeparation','flowOverlapRecord');
        glob.flowOverlapRecord = flowOverlapRecord;
        glob.centroidSeparation = centroidSeparation;
        glob.centroidX = centroidX;
        glob.centroidY = centroidY;
        fprintf('Done\n');
    else
        fprintf('\nNo previous file found so calculating and saving as %s...',fName);
        glob = calculateCentroidsAndFlowOverlaps(glob, depos, fName);
        fprintf('Done\n');
    end
end

function glob = calculatePValueMaps(glob, depos, totalDeposArea)
%% Calculate P value maps for runs analysis

    fprintf('Calculating runs analysis p values with depositional threshold is %6.5f\n', glob.thicknessThreshold);
    
    glob.runsMetricMap = zeros(glob.ySize, glob.xSize) - 1; % Set array to a dummy value to ID elements not assigned values because zero is a valid value
    glob.runsPValueMap = zeros(glob.ySize, glob.xSize) - 1; 
    rValuesList = zeros(1, glob.ySize * glob.xSize) - 1; % Vector to record all r values calculated, to calculate summary stats
    pValuesList = zeros(1, glob.ySize * glob.xSize) - 1; % Vector to record all p values calculated, to calculate summary stats
    
    fName = sprintf('%s%s_pValueMapsCutOff%7.6f.mat',glob.outputDir, glob.modelName, glob.thicknessThreshold);
    if exist(fName, 'file')
        load(fName,'-mat','runsMetricMap', 'runsPValueMap'); 
        glob.runsMetricMap = runsMetricMap;
        glob.runsPValueMap = runsPValueMap;
        fprintf('Found previously saved file %s so no need to recalculate\n', fName);
    else
        pValuesCount = 0; % Also functions as count for rValues
        fprintf('X: ');
        for x = 1:glob.xSize
            fprintf('%3d', x);
            for y = 1:glob.ySize
                if sum(depos.transThickness(y,x,:)) > glob.thicknessThreshold
                    [glob.runsMetricMap(y,x), glob.runsPValueMap(y,x)] = oneSectionRunsAnalysis(depos.transThickness(y,x,:),glob.thicknessThreshold,0); % Zero is the flag value for no graphics plotting
                    pValuesCount = pValuesCount + 1;
                    rValuesList(pValuesCount) = glob.runsMetricMap(y,x); % pValueCount works here because for each r value there is a pValue so same count
                    pValuesList(pValuesCount) = glob.runsPValueMap(y,x);
                end

                runsMetricMap = glob.runsMetricMap;
                runsPValueMap = glob.runsPValueMap;
                fname = sprintf('%s%s_pValueMapsCutOff%7.6f.mat',glob.outputDir, glob.modelName, glob.thicknessThreshold);
                save(fname, 'runsMetricMap', 'runsPValueMap');
            end
            fprintf('\b\b\b');
        end
    end
    
    rValuesList(rValuesList==-1) = []; % Remove dummy values from the pValues list
    pValuesList(pValuesList==-1) = []; % Remove dummy values from the pValues list
    
    if sum(depos.transThickness(50,100,:)) > glob.thicknessThreshold
        dummy = oneSectionRunsAnalysis(depos.transThickness(50,100,:),glob.thicknessThreshold,0); 
    end
    if sum(depos.transThickness(70,100,:)) > glob.thicknessThreshold
        dummy = oneSectionRunsAnalysis(depos.transThickness(65,100,:),glob.thicknessThreshold, 0);
    end
    
    % Null array elements are value -1 so for a count of map values between 0.10 and 0.0 need to remove -1 values
    % glob.runsPValueMap <= 0.10 returns a matrix with 1 in elements where condition met, so
    % do this with a < 0.10 conditional statement then element-wise matrix multiplication to remove all values less than 0 
    fanPointsP10 = sum(sum((glob.runsPValueMap <= 0.10) .* (glob.runsPValueMap >= 0.0)));
    fanAreaP10 = fanPointsP10 / totalDeposArea;
    fanPointsP01 = sum(sum((glob.runsPValueMap <= 0.01) .* (glob.runsPValueMap >= 0.0)));
    fanAreaP01 = fanPointsP01 / totalDeposArea;
    
    fprintf('Runs analysis R values. Minimum: %5.4f Mean %5.4f Mode %5.4f Maximum %5.4f\n', min(rValuesList), mean(rValuesList), mode(rValuesList), max(rValuesList));
    fprintf('Runs analysis P values. Minimum: %5.4f Mean %5.4f Mode %5.4f Maximum %5.4f\n', min(pValuesList), mean(pValuesList), mode(pValuesList), max(pValuesList));
    fprintf('Fan depositional area with P<0.1 %5.4f (%d points from total %d), P<0.01 %5.4f (%d points from total %d)\n', fanAreaP10,fanPointsP10,totalDeposArea, fanAreaP01,fanPointsP01,totalDeposArea);
end

function glob = calculateStratigraphicCompensationMetrics(glob, depos)
% Calculate Tc and Kappa to understand stratigraphic compensation
    
    fName = sprintf('%s%s_KappaTcRecordAndMax.mat', glob.outputDir, glob.modelName);
    if exist(fName, 'file')
        load(fName,'-mat','temp1','temp2','temp3'); 
        fprintf('Found previously saved file %s so no need to recalculate\n', fName);
    else
        fprintf('Calculating fan topography and compensation\n');
    
        depositionalRelief = zeros(1,glob.totalIterations);
        sumThickness = depos.elevation(:,:,glob.totalIterations) - depos.elevation(:,:,1);

        % Mean of all deposition divided by total model duration in My
        % gives long-term sedimentation rate in m/My
        longTermAggradationRate = mean(mean(sumThickness)) / (glob.totalIterations * glob.deltaT); 

        for iteration = 2 : glob.totalIterations
            % Get all the elevation points on the model for current iteration and subtract the initial bathymetry to get depositional relief
            elevationsOneTimestep = squeeze(depos.elevation(:,:,iteration)) - squeeze(depos.elevation(:,:,1));

            if elevationsOneTimestep > 0 % Will be zero if sediment supply was zero, which it might be if oscillating...
                depositionalRelief(iteration) = max(max(elevationsOneTimestep)) - min(min(elevationsOneTimestep));
                Tc(iteration) = depositionalRelief(iteration) / longTermAggradationRate;
            else
                Tc(iteration) = 0;
            end
        end

        TcMax = max(depositionalRelief) / longTermAggradationRate;

        fprintf('Maximum fan relief %3.2fm and long-term aggradation rate %5.4fm/My gives maximum Tc %5.4fMy\n', max(depositionalRelief), longTermAggradationRate, TcMax);

        % Now calculate kappa
        % calculate the total thickness of transported sediment that makes up the fan, across the whole model grid for all the time steps, as a 2D matrix
        totalFanThick = sum(depos.transThickness, 3);
        maxTWin = glob.totalIterations / 2;
        tWin = [10:10:maxTWin];
        tWin = tWin(mod(glob.totalIterations, tWin) == 0);
        tWin = reshape(tWin',[],1);
        sedRateStdDev = zeros(length(tWin),1);

        tIndex = 1;
        for j = 1:length(tWin)

            sedRateRatios = zeros(glob.ySize, glob.xSize, (glob.totalIterations / tWin(1)));
            for x = 1:glob.xSize
                for y = 1:glob.ySize

                    % if the fan strata at this point is more than 1cm thick
                    if totalFanThick(y,x) > 0.01

                        % Calculate long-term average sedimentation rate
                        avSedRateLongTerm = totalFanThick(y,x) / (glob.totalIterations * glob.deltaT);

                        k = 1;
                        for tWinStart = 1:tWin(j):(glob.totalIterations - maxTWin)
                            oneSedRateShortTerm = sum(depos.transThickness(y,x, tWinStart:(tWinStart + tWin(j)))) / (tWin(j) * glob.deltaT);
                            sedRateRatios(y,x,k) = oneSedRateShortTerm / avSedRateLongTerm;
                            k = k + 1;
                        end
                    end
                end
            end

%             sedRateStdDev(tIndex) = std2(sedRateRatios);
%             fprintf('T %d: sed rate stdDev %5.4f\n', tWin(j), sedRateStdDev(tIndex));
%             tIndex = tIndex + 1;
        end

        tWin = tWin .* glob.deltaT; % Added but not tested 2.11.19
% 
%         expFit = fit(tWin, sedRateStdDev,'exp1');
%         expFitCoeffs = coeffvalues(expFit);
%         expBestFitY = expFitCoeffs(1) * exp(expFitCoeffs(2) * tWin);
% 
%         powFit = fit(tWin, sedRateStdDev,'power1');
%         powFitCoeffs = coeffvalues(powFit);
%         powBestFitY = powFitCoeffs(1) .* tWin .^ powFitCoeffs(2); % insert powerlaw code here
% 
%         kappa = powFitCoeffs(2);
% 
%         fprintf('For %d time windows from %5.4f My to %5.4f My, power law kappa value is %5.4f\n', length(tWin), min(tWin), max(tWin), kappa);
%         save(fName,'-mat','kappa', 'Tc','TcMax');
    end
end

function glob = calculatePowerSpectra(glob, depos, totalDeposArea, MCIterations, minSectLength)
% Calculate the power spectra and from that the frequency with the most power for the whole model grid
    
    
    windowSize = 3; % Controls size of window for signal frequency search in power spectra. size 3 means frequency plus one unit below and above
    glob.maxPowerFrequency = zeros(glob.ySize, glob.xSize); % records the most powerful significant frequency from the power spectrum at each model grid point
    glob.signalFrequencyPresent = zeros(glob.ySize, glob.xSize);
    
    fName = sprintf('%s%s_PSMaxPowerFrequencies_Wind%d.mat', glob.outputDir, glob.modelName, windowSize);
    if exist(fName, 'file')
        load(fName,'-mat','temp1','temp2','temp3'); 
        glob.significantPeakCount = temp1;
        glob.maxPowerFrequency = temp2;
        glob.signalFrequencyPresent = temp3;
        fprintf('Found previously saved file %s so no need to recalculate\n', fName);
    else
        fprintf('Calculating power spectra and most powerful frequency over model map grid for window size %d\n', windowSize);
        fprintf('X: ');
        
        spectrumLength = 500;
        glob.significantPeakCount = zeros(spectrumLength,1);
        for x = 1:glob.xSize
            fprintf('%3d', x);
            for y = 1:glob.ySize
                % Call the power spectrum analysis code, with a section and so frequency sepctrum length of 500 - because sed supply oscillations in variable sed Lobyte3D run is 25 beds
                % The function returns modifed versions of glob.significantPeakCount, glob.maxPowerFrequency(y, x), glob.signalFrequencyPresent(y,x)
                glob = onePowerSpectrumAnalysis(glob, depos.transThickness, x, y, spectrumLength, windowSize, MCIterations, minSectLength);
                
                % Note the old code that uses the bugget Stephan code
                %                 [glob] = powerSpectraAnalysis(glob, depos.transThickness, x, y, spectrumLength, 0, windowSize, MCIterations); % Zero is the plot flag - don't plot each spectrum in this case
            end
            fprintf('\b\b\b');
        end

        temp1 = glob.significantPeakCount;
        temp2 = glob.maxPowerFrequency;
        temp3 = glob.signalFrequencyPresent;
        save(fName,'-mat','temp1','temp2','temp3'); % Expensive calculation, so save the results, then can check in future if already calculated
    end

    fprintf('Power spectra map shows:\n%d significant peaks in power spectra from all map points\n%d (%5.4f%% of fan area) point that record a signal at the input frequency\n', ...
        sum(glob.significantPeakCount), sum(sum(glob.signalFrequencyPresent)), sum(sum(glob.signalFrequencyPresent))/totalDeposArea);
end

