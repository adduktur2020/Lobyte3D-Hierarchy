function plotSpectralPeakCounts(significantPeakCount, signalPeriod,  modelName)

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    ffNew = figure('Visible','on','Position',[100, 0, scrsz(3)*0.5, scrsz(4)*0.95]);
    
    % SignificantPeakCount is the count of the statistically significant peaks at each frequency
    % Frequency vector needs to be calculated then to plot value labels on the x axis
    N = 500; % Length of vertical section sample we use in this analysys
    Dt = 1; % Time axis frequency increment?
    fmax = 1 / (2 * Dt); % Nyquist frequency
    Df = fmax / (N / 2); % frequency interval
    freqVect = Df * [0:N/2, -N/2+1:-1]'; % frequency vector
    
    plotSeries = significantPeakCount(2:100); % Just plot the first 100 because number near zero after this
    plotFreqValues = freqVect(2:100);
    zLimit = max(plotSeries) * 1.1;
    
    bar(plotFreqValues, plotSeries);
    
    fprintf('Peak count in j=15 f=0.05 to j=30 f=0.03 signal bulge is %d\n', sum(significantPeakCount(15:28)));
    
    axMinMaxVect = axis; % Get the current axis limits
    axMinMaxVect(4) = zLimit; % Reset the y axis max to a specific values required to compare two model scenarios on the same scale
    axis(axMinMaxVect);
    grid on;
    xlabel('Frequency 1/layers');
    ylabel('Number of peaks p<0.01');
    title(modelName);
    ax = gca;
    ax.LineWidth = 0.5;
    ax.FontSize = 24;
   
    line([1/signalPeriod, 1/signalPeriod],[0 zLimit],'color',[0 0.6 1.0], 'LineWidth', 1.0); % Draw a line that marks the input signal frequency

    %% Save image using save_fig

%     fName = strcat(modelName, '_SpectralPeakCount');
%     export_fig(fName, '-png', '-transparent', '-r600');
end