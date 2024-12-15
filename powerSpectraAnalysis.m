function [glob] = powerSpectraAnalysis(glob, transThickness, xco, yco, spectrumLength, plotFlag, windowSize, iterationsMC)
    % Calculates fft of thickness succession at all grid points, and test for significance of spectra peaks using an MC method
    % For each xy coord in the model grid, we calculate a power spectrum. These are stored in powerSpectra
    % We need to know though if the powers in this spectrum are significant.
    % We can determine this using Monte Carlo analysis in which we run n iterations (e.g. n=1000), for each iterations shuffle the strata, then calculate a power spectrum
    % for the shuffled strata. A data structure to store all these would be  big (e.g. 200*200*100*1000) so we do not want to store these. Instead calculate for each
    % point, calculate a p value from the MC distribution and store this, since this is the final result we are interested in.
    % We do want to be able to plot some examples though, so give the x-y coords of cases to plot, and when we come to them in the loop, plot them
    
    % Number of iterations in the Monte Carlo sampling method. 1000 is the norm NB this is the key control on computation time
%     iterationsMC = 200; 
    
    oneSection = nonzeros(reshape(transThickness(yco,xco,:),[],1)); % select column of thickness data, excluding zero values
    
    % Length of section needs to be integer multiple of frequency of sediment supply signal, if there is one
    % So, for now, do PS analysis on a timeseries 500 elements long, so 25 iterations signal with 
    % frequency 1/25=0.04 should fall directly on one datapoint in the frequency vector
    if length(oneSection) > spectrumLength
        dummy = oneSection(1:spectrumLength);
        oneSection = dummy;
    end
    
%     paddedSection = zeros(round(length(oneSection)*3),1);
%     midPos = round(length(paddedSection)/3);
%     paddedSection(midPos:midPos + length(oneSection) - 1) = oneSection;
%     oneSection = paddedSection;
%     

    if length(oneSection) > 20
    
        % The dashed green line should be the p=0.000 line marking the edge of the PDF
        % peaks above this line have a very low (less than 1/1000) probability of occurring by chance, and are therefore significant.
        % One could draw other lines of course e.g. p=0.010. 

        significanceLimit = 0.01;

        % The dimensions of the strata data structure
        n = size(transThickness);
        ySize = n(1);
        xSize = n(2);
        zSize = n(3);

        % initialise arrays for output from the power spectral analysis
        freqVects = NaN(ySize, xSize, zSize);
        powerSpectra = NaN(ySize, xSize, zSize);
        cl99 = NaN(ySize, xSize);

        % Set the various parameters and arrays required for the Monte Carlo analysis of the power spectra significance
        
        maxPowerSpectraLength = zSize + 2; % +2 to allow some wriggle room for rounding etc when the FFT calculates spectrum length
        maxBins = 50;
        powerSpectraMC = zeros(maxPowerSpectraLength, iterationsMC); % size the power spectra arrays assuming a maximum power spectra length
        freqCountsMC = zeros(maxPowerSpectraLength, maxBins);
        relativeFreqsMC  = zeros(maxPowerSpectraLength, maxBins);
        binEdges = zeros(maxPowerSpectraLength, maxBins);
        MCPDFBelowSpectrumPoint = zeros(1,maxBins);
        pValue = NaN(ySize, xSize, zSize);

        [oneFreqVect, onePowerSpectrum, cl99(yco,xco)] = PSDeda(oneSection, 1, 0.99); % calculate PSD, duration of time series is 1 - why?
        freqVects(yco,xco,1:length(oneFreqVect)) = oneFreqVect(1:length(oneFreqVect)); % the frequency points at which data points are recorded
        powerSpectra(yco,xco,1:length(onePowerSpectrum)) = onePowerSpectrum(1:length(onePowerSpectrum));

        % For point x,y get Monte Carlo iterations of the power spectra for shuffled sections, to make a random model PDF
        powerSpectraMC(1:length(onePowerSpectrum), 1:iterationsMC) = calculateMCPowerSpectra(oneSection, iterationsMC);
        
        freqCountsMC = zeros(maxPowerSpectraLength, maxBins);
        PEqualsZeroPoint = zeros(1,length(freqVects(yco,xco,:))); % Will be used to record the upper edge of the MC power PDF for each spectrum frequency
        
        for j = 1:length(freqVects(yco,xco,:))
            % Need to put all MC realization values at signal frequency j into a vector to calculate stats relative frequency distribution of those powers
            [tempFreqCounts, tempBinEdges] = histcounts(powerSpectraMC(j,1:iterationsMC), maxBins); % define constant number of bins for all frequencies - can then plot easily
            freqCountsMC(j,1:length(tempFreqCounts)) = tempFreqCounts;
            binEdges(j,1:length(tempBinEdges)) = tempBinEdges;
            relativeFreqsMC(j, :) = freqCountsMC(j, :) / sum(freqCountsMC(j,:)); % Convert frequency to relative frequency

            MCPDFBelowSpectrumPoint = (binEdges(j,1:length(tempBinEdges)-1) < powerSpectra(yco,xco,j)); % Should return a vector of 1s for bin edge values < jth spectrum peak
            pValue(yco,xco,j) = 1 - sum(MCPDFBelowSpectrumPoint .* relativeFreqsMC(j,:));

            % Find the point in the MC frequency value bins where the first frequency>0 occurs
            % this marks the upper limit of the PDF, the point beyond which p=0.0
            k = length(tempBinEdges) - 1; % Because bin edges go to length+1 of the relativeFreqsMC array
            relativeFreqSum = 0.0;
            while relativeFreqSum < significanceLimit && k > 1
                relativeFreqSum = relativeFreqSum + relativeFreqsMC(j,k);
                k = k - 1; 
            end
            PEqualsZeroPoint(j) = (tempBinEdges(k) + tempBinEdges(k+1)) / 2.0; % plot p=zero line at midpoint in highest-P non-zero-frequency bin
        end
        
        % Now loop again to check pValues and count significant peaks etc
        maxPower = 0.0;
        glob.maxPowerFrequency(yco, xco) = 0.0; % in case there are no significant peaks, which would otherwise leave these variables unassigned and cause a function return value error
        glob.signalFrequencyPresent(yco, xco) = 0;
        
        for j = 1:length(freqVects(yco,xco,:))
            
            % Is the spectrum at this frequency a significant peak?
            if pValue(yco,xco,j) < 0.01
                glob.significantPeakCount(j) = glob.significantPeakCount(j) + 1;
            end
            
            if freqVects(yco,xco,j) == glob.sedimentSupplyFreq  % if this the input signal frequency?
               
               % Given windowSize, calculate the j value for the start of the window
               winStart = j - floor(windowSize /2);
               if winStart < 1 % Check it's within array size limits
                   winStart = 1;
               end
               
               % Given windowSize, calculate the j value for the end of the window
               winEnd = winStart + (windowSize - 1);
               if winEnd > length(freqVects(yco,xco,:)) % Check it's within array size limits
                   winEnd = length(freqVects(yco,xco,:));
               end
               
               pValuesInWindow = pValue(yco, xco, winStart:winEnd); % Extract the pvalues for that window range
               
               if nnz(pValuesInWindow < 0.01) > 0 % So at least one p in the wWindow range < 0.01
                    glob.signalFrequencyPresent(yco, xco) = 1;
               end
            end
 
            if powerSpectra(yco,xco,j) > maxPower && pValue(yco,xco,j) < 0.01 % if the jth point on the power spectra has the highest power yet and is significant, then record
                maxPower = powerSpectra(yco,xco,j);
                glob.maxPowerFrequency(yco, xco) = freqVects(yco,xco,j);
            end
        end
        
        if plotFlag % Because if this function is called to make a whole grid map, we don't want to plot each spectrum
            plotPowerSpectrumAndMCAnalysis(xco,yco);
        end
    else
        
        glob.maxPowerFrequency(yco, xco) = 0; % If the section is too short to analyse, record zero result to flag this
        glob.signalFrequencyPresent(yco, xco) = 0;
        if plotFlag % plotFlag true enables plotting and verbose out 
            fprintf('Section at x=%d, y=%d was too short to analyse - try another model grid location that received more flow deposits\n',xco,yco);
        end
    end

    
   
    %% Plot routine needs to be here as part of the same function to avoid having to save and/or pass data - obvs could be rewritten but this was quicker
        
    function plotPowerSpectrumAndMCAnalysis(x,y)

        scrsz = get(0,'ScreenSize'); % screen dimensions vector
        ffPSpect = figure('Visible','on','Position',[100, 0, scrsz(3)*0.5, scrsz(4)*0.95]);
        hold on
      
        maxRelFreqMC = 0.1;
        plotLimitFreq = 0.5; % Most of the power is in the lower frequencies so limit the plot to this section

        % Take a sub-sample of the frequencies in the power spectra - lower end of the frequencies < plotLimitFreq only
        j=1;
        while j <= length(onePowerSpectrum) && oneFreqVect(j) <= plotLimitFreq
            oneFreqVectPlot(j) = oneFreqVect(j);
            onePowerSpectrumPlot(j) = onePowerSpectrum(j);
            j=j+1;
        end

        halfXBinSize = (oneFreqVectPlot(2) - oneFreqVectPlot(1)) / 2.0;
       
        % Now plot the relative frequencies of powers for each frequency produced by the MC analysis of the random shuffled strata
        for j = 1: length(oneFreqVectPlot) % Loop through all frequencies included in the power spectrum, so the x axis of the power spectrum plot
            freqDimsMC = size(freqCountsMC(:,:));
            
            for k = 1: freqDimsMC(2) % - 1 % Loop through the bins created for the PDF, from the size of the 2nd dimension of freqDimsMC
                xcoPlot = [oneFreqVectPlot(j) - halfXBinSize, oneFreqVectPlot(j) - halfXBinSize, oneFreqVectPlot(j) + halfXBinSize, oneFreqVectPlot(j) + halfXBinSize];
                ycoPlot = [binEdges(j,k), binEdges(j,k+1), binEdges(j,k+1), binEdges(j,k)];
               
                if freqCountsMC(j,k) > 0
                    if relativeFreqsMC(j,k) > maxRelFreqMC
                        redPinkScale = 0;
                    else
                        redPinkScale = 1-(relativeFreqsMC(j,k)/maxRelFreqMC);
                    end
                    patch(xcoPlot, ycoPlot, [1 redPinkScale, redPinkScale*0.6] , 'EdgeColor','none');
                 end
            end
        end
        
        for j = 1: length(oneFreqVectPlot)
            % Now plot the freqeuncy spectrum line segments
            if j < length(oneFreqVectPlot) 
                xcoPlot = [oneFreqVectPlot(j), oneFreqVectPlot(j+1)];
                
                % plot the power spectrum
                ycoPlot = [onePowerSpectrumPlot(j), onePowerSpectrumPlot(j+1)];
                line(xcoPlot, ycoPlot, 'Color', [0, 0, 0], 'LineWidth',2); 
                
                % plot the p=0 significance line but only j=2 and greater because j=1 value causes scaling issues on the plot
                if j > 1 && j < length(oneFreqVectPlot)-1
                    ycoPlot = [PEqualsZeroPoint(j), PEqualsZeroPoint(j+1)];
                    line(xcoPlot, ycoPlot, 'Color', [0 1 0.2], 'LineWidth', 2, 'LineStyle','-.');
                end
            end
        end
        
        ax = gca;
        ax.FontSize = 16;
        axis([0,0.2,0,inf]);
%         titleString = sprintf('Power spectrum and CL95 x=%d y=%d',x, y);
%         title(titleString);
        xlabel('Frequency (1/layers)');
        ylabel('Power');
        grid on;
        hold off
        titleStr =  sprintf('X:%d Y:%d', x,y);
        title(titleStr);

%         export_fig(sprintf('modelOutput/lobytePowerSpectrumX%dY%dT%d',x,y,glob.totalIterations), '-png', '-transparent', '-r600');
        
%       plot the MC significance colour levels in a colour bar for a key         
%
%         ffkey = figure;
%         increment = 0.01;
%         for k = 0:increment:1
%             xcoPlot = [k - increment, k - increment, k + increment, k + increment];
%             ycoPlot = [0, .1, .1, 0];
%             redPinkScale = 1-k;
%             patch(xcoPlot, ycoPlot, [1 redPinkScale, redPinkScale*0.6] , 'EdgeColor','none');
%         end
%         
%         line([0.01 0.01], [0 0.1], 'Color', [0 1 0.2], 'LineWidth', 2, 'LineStyle','-.');
%         
%         export_fig(sprintf('modelOutput/lobytePowerSpectrumColBar',x,y,glob.totalIterations), '-png', '-transparent', '-r600');
    end
end



    

    


