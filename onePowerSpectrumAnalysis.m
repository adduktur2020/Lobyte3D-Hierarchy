function [glob] = onePowerSpectrumAnalysis(glob, transThickness, xco, yco, standardSectLength, windowSize, iterationsMC, minSectLength)
% Calculates fft of thickness succession at all grid points, and test for significance of spectra peaks using an MC method
% For each xy coord in the model grid, we calculate a power spectrum. These are stored in powerSpectra
% We need to know though if the powers in this spectrum are significant.
% We can determine this using Monte Carlo analysis in which we run n iterations (e.g. n=1000), for each iterations shuffle the strata, then calculate a power spectrum
% for the shuffled strata. A data structure to store all these would be  big (e.g. 200*200*100*1000) so we do not want to store these. Instead calculate for each
% point, calculate a p value from the MC distribution and store this, since this is the final result we are interested in.
% We do want to be able to plot some examples though, so give the x-y coords of cases to plot, and when we come to them in the loop, plot them
    
    oneSection = nonzeros(reshape(transThickness(yco,xco,:),[],1)); % select column of thickness data, excluding zero values
    sectLength = length(oneSection);
    if sectLength > minSectLength
        
        % subtract mean so that mean is zero and data varies around mean - avoids nasty low-freq artefacts in power spectrum
        oneSection = oneSection - mean(oneSection); 
        
        if sectLength < standardSectLength && sectLength > 0
            oneSection(sectLength:standardSectLength) = 0; % Pad the section with zeros to a total length of 2048, closest ^2 to the maximum model section length 2000
            sectLength = standardSectLength;
        end
        
        spectrumLength = standardSectLength / 2.0;

        % The dashed green line should be the p=0.001 line marking the edge of the PDF 
        % Peaks above this line have a very low (less than 1/100) probability of occurring by chance, and are therefore significant.
        significanceLimit = 0.01;

        % Set the various parameters and arrays required for the Monte Carlo analysis of the power spectra significance
        n = size(transThickness);
        ySize = n(1);
        xSize = n(2);
        zSize = n(3);
        freqVects = NaN(ySize, xSize, zSize);
        powerSpectra = NaN(ySize, xSize, zSize);
        maxPowerSpectraLength = zSize + 2; % +2 to allow some wriggle room for rounding etc when the FFT calculates spectrum length
        maxBins = 50; % The number of frequencies to be checked in power spectra
        powerSpectraMC = zeros(maxPowerSpectraLength, iterationsMC); % size the power spectra arrays assuming a maximum power spectra length
        freqCountsMC = zeros(maxPowerSpectraLength, maxBins);
        relativeFreqsMC  = zeros(maxPowerSpectraLength, maxBins);
        binEdges = zeros(maxPowerSpectraLength, maxBins);
        MCPDFBelowSpectrumPoint = zeros(1,maxBins);
        pValue = NaN(ySize, xSize, zSize);

      %  [oneFreqVect, onePowerSpectrum, cl99(yco,xco)] = PSDeda(oneSection, 1, 0.99); % calculate PSD, duration of time series is 1 - why?
        [onePowerSpectrum, oneFreqVect] = pmtm(oneSection, 4, sectLength, 1);
        freqVects(yco,xco,1:spectrumLength) = oneFreqVect(1:spectrumLength); % the frequency points at which data points are recorded
        powerSpectra(yco,xco,1:spectrumLength) = onePowerSpectrum(1:spectrumLength);

        % For point x,y get Monte Carlo iterations of the power spectra for shuffled sections, to make a random model PDF
        powerSpectraMC(1:spectrumLength, 1:iterationsMC) = calculateShuffledMCPowerSpectra(oneSection, standardSectLength, iterationsMC);

        freqCountsMC = zeros(maxPowerSpectraLength, maxBins);

        % Loop through frequencies and calculate the frequencies of significant peaks at that frequency, and the p=0 point in the MC distribution of peaks
        for j = 1:spectrumLength
            % Need to put all MC realization values at each signal frequency j into a vector to calculate stats relative frequency distribution of those powers
            [tempFreqCounts, tempBinEdges] = histcounts(powerSpectraMC(j,1:iterationsMC), maxBins); % define constant number of bins for all frequencies - can then plot easily
            freqCountsMC(j,1:length(tempFreqCounts)) = tempFreqCounts;
            binEdges(j,1:length(tempBinEdges)) = tempBinEdges;
            relativeFreqsMC(j, :) = freqCountsMC(j, :) / sum(freqCountsMC(j,:)); % Convert frequency to relative frequency

            MCPDFBelowSpectrumPoint = (binEdges(j,1:length(tempBinEdges)-1) < powerSpectra(yco,xco,j)); % Should return a vector of 1s for bin edge values < jth spectrum peak
            pValue(yco,xco,j) = 1 - sum(MCPDFBelowSpectrumPoint .* relativeFreqsMC(j,:));
        end

        % Now loop again to check pValues and count significant peaks etc
        maxPower = 0.0;
        glob.maxPowerFrequency(yco, xco) = 0.0; % in case there are no significant peaks, which would otherwise leave these variables unassigned and cause a function return value error
        glob.signalFrequencyPresent(yco, xco) = 0;

        for j = 1:spectrumLength

            % Is the spectrum at this frequency a significant peak?
            if pValue(yco,xco,j) < significanceLimit
                glob.significantPeakCount(j) = glob.significantPeakCount(j) + 1;
            end

            if freqVects(yco,xco,j) == glob.sedimentSupplyFreq  % is this the input signal frequency?

               % Given windowSize, calculate the j value for the start of the window
               winStart = j - floor(windowSize /2);
               if winStart < 1 % Check it's within array size limits
                   winStart = 1;
               end

               % Given windowSize, calculate the j value for the end of the window
               winEnd = winStart + (windowSize - 1);
               if winEnd > spectrumLength % Check it's within array size limits
                   winEnd = spectrumLength;
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
        
%         fprintf('%d %d Found %d significant spectral peaks for section length %d\n', xco, yco, sum(glob.significantPeakCount(:)), sectLength);
    else     
        glob.maxPowerFrequency(yco, xco) = 0; % If the section is too short to analyse, record zero result to flag this
        glob.signalFrequencyPresent(yco, xco) = 0;
    end
end

function  powerSpectraMC = calculateShuffledMCPowerSpectra(section, standardSectLength, iterationsMC)
% Calculate power spectra for iterationsMC shuffled versions for the vertical section passed to this function
% This is then a Monte Carlo model of the power spectra, useful as a random model to indicate which peaks are significant in the spectrum

    spectrumLength = standardSectLength / 2.0;
    powerSpectraMC = zeros(1, iterationsMC);
    for m = 1:iterationsMC
        section = section(section~=0); % Remove all the zero values, including padding zeros used to increase the section length to the standard length
        nThicknesses = length(section); %number of datapoints in series
        if nThicknesses > 0 % ensure shortest section are ecluded - check threshold length is same as calling functions
            shuffledSection = shuffleSection(section, standardSectLength); % note section passed with zero-thickness values removed, variable legnth and no padding
            [onePowerSpectrum, ~] = pmtm(shuffledSection, 4, length(shuffledSection), 1);
            powerSpectraMC(1:spectrumLength, m) = onePowerSpectrum(1:spectrumLength);
        else
            powerSpectraMC(1:spectrumLength, m) = 0;
        end
    end
end

function shuffledSection = shuffleSection(section, standardSectLength)
% Shuffle the facies succession to ensure a random configuration, and pad
% with zeros after shuflling (because we don't want to shuffle a padded
% section because it would introduce lots of zeros into the section

    % Shuffle the section using randperm - ~ one order of magnitude faster than individual element swaps in a for loop!
    shuffledSection = section(randperm(numel(section)));
    shuffledSection = reshape(shuffledSection, [1,length(section)]);
    
    zeroPadding = zeros(1,(standardSectLength - length(shuffledSection)));
    shuffledSection = horzcat(shuffledSection, zeroPadding);
end
