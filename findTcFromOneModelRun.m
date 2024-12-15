function findTcFromOneModelRun

    inputDir = 'E:/LobyteOutput/signalBumpOutputV9/'; % look here for the Lobyte saved files
    
    sedimentSupplyMin = 0;
    sedimentSupplyMax = 50;
    sedimentSupplyPeriod = 20;
    
    previousLobyteRunFName = sprintf('%slobyteRunSignalBumpRunsSupA%2.1f-%2.1fP%d.mat', inputDir, sedimentSupplyMin, sedimentSupplyMax, sedimentSupplyPeriod);
    if exist(previousLobyteRunFName, 'file')
        fprintf('Reading previously saved Lobyte model in %s%s ...', inputDir, previousLobyteRunFName);
        load(previousLobyteRunFName,'-mat','glob','depos','trans','topog');
        fprintf(' read successfully\n');
        fileRead = 1;
        
        glob.deltaT = 0.001; % Reset to 1ky because wrongly set to 10ky in signal bump runs input files
    else
        fprintf("Can't find file %s to read, sorry\n", previousLobyteRunFName);
        fileRead = 0;
    end
    
    if fileRead == 1
        
        [depositionalRelief, Tc] = calculateTc(glob, depos, 0);
        kappa = calcStdDevSedSub(glob, depos, 0);


    end
end

function [depositionalRelief, Tc] = calculateTc(glob, depos, plotsOn)

        depositionalRelief = zeros(1,glob.totalIterations);
        % Code to calculate Tc per time step across the whole fan surface

        sumThickness = depos.elevation(:,:,glob.totalIterations) - depos.elevation(:,:,1);
        % Mean of all deposition divided by total model duration in My
        % gives long-term sedimentation rate in m/My
        longTermAggradationRate = mean(mean(sumThickness)) / (glob.totalIterations * glob.deltaT); 

        for iteration = 2 : glob.totalIterations
            % Get all the elevation points on the model for current
            % iteration and subtract the initial bathymetry to get
            % depositional relief
            elevationsOneTimestep = squeeze(depos.elevation(:,:,iteration)) - squeeze(depos.elevation(:,:,1));

            if elevationsOneTimestep > 0 % Will be zero if sediment supply was zero, which it might be if oscillating...
                depositionalRelief(iteration) = max(max(elevationsOneTimestep)) - min(min(elevationsOneTimestep));
                Tc(iteration) = depositionalRelief(iteration) / longTermAggradationRate;
            else
                Tc(iteration) = 0;
            end
        end

        TcMax = max(depositionalRelief) / longTermAggradationRate;
        fprintf("Maximum fan relief %3.2f m and long-term aggradation rate %5.4f m/My gives maximum Tc %5.4f\n", max(depositionalRelief), longTermAggradationRate, TcMax);
        
        if plotsOn
            
            figure
            plot(depositionalRelief); 
            xlabel('Geological time, iteration #');
            ylabel('Depositional relief (m)');
            
            figure
            plot(Tc);
            xlabel('Geological time, iteration #');
            ylabel('Tc (My)');
        end
end

function kappa = calcStdDevSedSub(glob, depos, plotsOn)

    % calculate the total thickness of transported sediment that makes up
    % the fan, across the whole model grid for all the time steps, as a 2D matrix
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

        sedRateStdDev(tIndex) = std2(sedRateRatios);
        fprintf('T %d: sed rate stdDev %5.4f\n', tWin(j), sedRateStdDev(tIndex));
        tIndex = tIndex + 1;
    end
    
    tWin = tWin .* glob.deltaT; % Added but not tested 2.11.19

    expFit = fit(tWin, sedRateStdDev,'exp1');
    expFitCoeffs = coeffvalues(expFit);
    expBestFitY = expFitCoeffs(1) * exp(expFitCoeffs(2) * tWin);
    
    powFit = fit(tWin, sedRateStdDev,'power1');
    powFitCoeffs = coeffvalues(powFit);
    powBestFitY = powFitCoeffs(1) .* tWin .^ powFitCoeffs(2); % insert powerlaw code here
    
    kappa = powFitCoeffs(2);
    
    fprintf('For %d time windows from %5.4f My to %5.4f My, power law kappa value is %5.4f\n', length(tWin), min(tWin), max(tWin), kappa);
    
    if plotsOn
        figure
        semilogy(tWin, sedRateStdDev, 'LineStyle','none', 'Marker','o');
        hold on;
        semilogy(tWin, powBestFitY, 'LineStyle','-.', 'Color','m');
        grid on;
        xlabel('Time window (My)');
        ylabel('Phi ss');
        title(sprintf('Best fit lines:\nExp kappa=%5.4f\nPow kappa=%5.4f', expFitCoeffs(2), powFitCoeffs(2)));

        figure
        plot(tWin, sedRateStdDev, 'LineStyle','none', 'Marker','o');
        hold on;
        plot(tWin, powBestFitY, 'LineStyle','-.', 'Color','m');
        grid on;
        xlabel('Time window (My)');
        ylabel('Phi ss');
        title(sprintf('Best fit lines:\nExp kappa=%5.4f\nPow kappa=%5.4f', expFitCoeffs(2), powFitCoeffs(2)));
    end
end
    