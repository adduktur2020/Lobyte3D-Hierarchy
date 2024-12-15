function plotBedThicknessDistribution(glob, depos)

%% Draw maps showing stratigraphic completeness at each xy location, plus other properties

scrsz = get(0,'ScreenSize'); % screen dimensions vector
ffSix = figure('Visible','on','Position',[100, 0, scrsz(3)*0.5, scrsz(4)*0.95]);

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


%% Save image using save_fig
% set(ffOne,'Color','none'); % set transparent background
% set(gca,'Color','none');

% export_fig( sprintf('OrpheusCrossSection %d',iteration),...
%    '-png', '-transparent', '-m12', '-q101');
% export_fig(sprintf('lobyteMaps%d',glob.totalIterations), '-png', '-transparent', '-r600');
end



