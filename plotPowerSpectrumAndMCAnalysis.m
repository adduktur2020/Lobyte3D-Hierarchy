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
    xlabel('Frequency (1/layers)');
    ylabel('Power');
    grid on;
    hold off
    titleStr =  sprintf('X:%d Y:%d', x,y);
    title(titleStr);
end