function plotBedThicknessAndHiatusDistribution(glob, depos, xco, yco)

%% Draw maps showing stratigraphic completeness at each xy location, plus other properties

scrsz = get(0,'ScreenSize'); % screen dimensions vector
ffSix = figure('Visible','on','Position',[100, 0, scrsz(3)*0.5, scrsz(4)*0.95]);

subplot(2,1,1);

% Calculate the bed thickness frequency distribution for the whole fan
bedThicknessData = reshape(depos.transThickness, numel(depos.transThickness), 1); % Reshape 3D matrix into vector
bedThicknessData(bedThicknessData == 0) = []; % Remove zero thickness units, if there are any
totalBedsAndLaminae = numel(bedThicknessData);
fprintf('%d beds and laminations recorded on the fan\n', totalBedsAndLaminae);
thinBedsBooleanMask = bedThicknessData >= 0.1; % Create a boolean mask to remove bed thicknesses < 1cm
bedThicknessData = bedThicknessData .* thinBedsBooleanMask;
bedThicknessData(bedThicknessData == 0) = []; % Remove zero thickness units created by the mask
totalBedsOnFan = numel(bedThicknessData);
totalLaminaeOnFan = totalBedsAndLaminae - totalBedsOnFan;
fprintf('%d laminae on the fan thickness <1cm\n', totalLaminaeOnFan);
fprintf('%d beds on the fan thickness >=1cm\n', totalBedsOnFan);
histfit(bedThicknessData, 20, 'exponential');

ax = gca;
xlabel('Bed thickness (m)');
ylabel('Frequency');
ax.LineWidth = 0.5;
ax.FontSize = 14;
axis tight
grid on

subplot(2,1,2);
%% calculate the frequency versus duration of the hiatuses at coordinates x y
    j = 1;
    k = 1;
    oneHiatusDuration = 0;
    oneLobeDuration = 0;
    for t = 2:glob.totalIterations - 1
        
        if depos.transThickness(yco,xco,t) == 0.0 
            
            oneHiatusDuration = oneHiatusDuration + 1; % layer t has zero event deposit thickness, so add one to hiatus length
            
            if depos.transThickness(yco,xco,t+1) > 0.0 % if layer t+1 has some event thickness, layer t is the end of the hiatus, so record its length
                hiatusLengthRecord(j) = oneHiatusDuration;
                j = j + 1;
                oneHiatusDuration = 0;
            end
        else
            
            oneLobeDuration = oneLobeDuration + 1; % layer t has > 0 event deposit thickness, so add one to lobe stack length
            
            if depos.transThickness(yco,xco,t+1) == 0.0 % if layer t+1 has no event thickness, layer t is the end of the continuous deposition, so record its length
                lobeLengthRecord(k) = oneLobeDuration;
                k = k + 1;
                oneLobeDuration = 0;
            end
        end
    end
    
    hiatusLengthRecord = hiatusLengthRecord .* glob.deltaT; % convert from length in iterations to length in my
    histogram(hiatusLengthRecord);
    hold on;
    lobeLengthRecord = lobeLengthRecord .* glob.deltaT; % convert from length in iterations to length in my
    histogram(lobeLengthRecord);
    
    ax = gca;
    xlabel('Lobe/hiatus duration (My)');
    ylabel('Frequency');
    ax.LineWidth = 0.5;
    ax.FontSize = 14;
    axis tight
    grid on
    
%% Save image using save_fig
% set(ffOne,'Color','none'); % set transparent background
% set(gca,'Color','none');

% export_fig( sprintf('OrpheusCrossSection %d',iteration),...
%    '-png', '-transparent', '-m12', '-q101');
% export_fig(sprintf('lobyteMaps%d',glob.totalIterations), '-png', '-transparent', '-r600');
end



