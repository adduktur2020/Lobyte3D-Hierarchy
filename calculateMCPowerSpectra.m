function  powerSpectraMC = calculateMCPowerSpectra(section, iterationsMC)
% Calculate power spectra for n=mcIterations shuffled versions for the vertical section passed to this function
% This is then a Monte Carlo model of the power spectra, useful as a random model to indicate which peaks are significant in the spectrum

    powerSpectraMC = zeros(1, iterationsMC);
    for m = 1:iterationsMC
        nThicknesses = length(section); %number of datapoints in series
        if nThicknesses > 20 % exclude very short thickness successsions - why?
            
            shuffledSection = shuffleSection(nonzeros(section), nThicknesses); % note section passed with zero-thickness values removed
            [~, onePowerSpectrum, ~] = PSDeda(shuffledSection, 1, 0.99); % oneFreqVect and CI99 are not used here so ~ instead
            powerSpectraMC(1:length(onePowerSpectrum), m) = onePowerSpectrum;
        end
    end
end