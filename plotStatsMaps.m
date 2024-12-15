function plotStatsMaps(glob, depos, modelName)

%% Draw maps showing stratigraphic completeness at each xy location, plus other properties

scrsz = get(0,'ScreenSize'); % screen dimensions vector
ffSix = figure('Visible','on','Position',[1, 0, scrsz(3)*0.5, scrsz(4)*0.95]);

subplot(2,2,1);
% Plot a patch that covers and therefore sets the whole map size, because individual patches might only be subarea
xco = [0* glob.dx, 0* glob.dx, glob.xSize* glob.dx, glob.xSize* glob.dx];
yco = [0* glob.dy, glob.ySize* glob.dy, glob.ySize* glob.dy, 0* glob.dy];
patch(xco, yco, [1 1 1], 'EdgeColor','none', 'FaceVertexAlphaData', 0.2, 'FaceAlpha','flat'); 

if isfield(depos,'stratCompleteness')
    maxStratCompleteness = max(max( depos.stratCompleteness));
    maxStratCompletenessContig = max(max( depos.stratCompletenessContig));
    % maxStratCompleteness = max(max( depos.stratCompleteness));

    % Stratigraphic completeness map
    for x = 1:glob.xSize
         for y = 1:glob.ySize
            yco = [y-0.5 y-0.5 y+0.5 y+0.5] * glob.dy;  % 4 vertices coordinates clockwise 
            xco = [x-0.5 x+0.5 x+0.5 x-0.5] * glob.dx;
            if sum(depos.transThickness(y,x,:)) > 0.01
                colour = [1-( depos.stratCompletenessContig(y,x)/maxStratCompletenessContig)  depos.stratCompletenessContig(y,x)/maxStratCompletenessContig 0];
    %             colour = [1-( depos.stratCompleteness(y,x)/maxStratCompleteness)  depos.stratCompleteness(y,x)/maxStratCompleteness 0];
                patch(xco, yco, colour, 'EdgeColor','none');
            end
         end
    end

    ax = gca;
    xlabel('Strike Distance (km)');
    ylabel('Dip distance (km)');
    ax.LineWidth = 0.5;
    ax.FontSize = 14;
    axis tight
    grid on
end



%% Plot a map showing the p values from the runs analysis
subplot(2,2,2);

% Plot a patch that covers and therefore sets the whole map size, because individual patches might only be subarea
xco = [0* glob.dx, 0* glob.dx, glob.xSize* glob.dx, glob.xSize* glob.dx];
yco = [0* glob.dy, glob.ySize* glob.dy, glob.ySize* glob.dy, 0* glob.dy];
patch(xco, yco, [1 1 1], 'EdgeColor','none', 'FaceVertexAlphaData', 0.2, 'FaceAlpha','flat'); 

if isfield(glob,'runsPValueMap')
    for x = 1:glob.xSize
         for y = 1:glob.ySize
            yco = [y-0.5 y-0.5 y+0.5 y+0.5] * glob.dy;  % 4 vertices coordinates clockwise 
            xco = [x-0.5 x+0.5 x+0.5 x-0.5] * glob.dx;
            if glob.runsPValueMap(y,x) >= 0.0 && glob.runsPValueMap(y,x) <= 1.0
                if glob.runsPValueMap(y,x) < 0.01
                    colour = [0 1 0];
                else
    %                 colour = [glob.runsPValueMap(y,x)*2 0.8-(glob.runsPValueMap(y,x)*1.6) 0]; % *2 because correct p value should range from 0 to 0.5, so *2 multiplication needed for range 0-1
                    colour = [1 0.8-(glob.runsPValueMap(y,x)*1.6) 0]; 
                end
                patch(xco, yco, colour, 'EdgeColor','none');
            end
         end
    end

    ax = gca;
    xlabel('Strike Distance (km)');
    ylabel('Dip distance (km)');
    ax.LineWidth = 0.75;
    ax.FontSize = 14;
    axis tight
    grid on
end
%% Plot a map showing frequency of maximum power from power spectra

subplot(2,2,3);
% Plot a patch that covers and therefore sets the whole map size, because individual patches might only be subarea
xco = [0* glob.dx, 0* glob.dx, glob.xSize* glob.dx, glob.xSize* glob.dx];
yco = [0* glob.dy, glob.ySize* glob.dy, glob.ySize* glob.dy, 0* glob.dy];
patch(xco, yco, [1 1 1], 'EdgeColor','none', 'FaceVertexAlphaData', 0.2, 'FaceAlpha','flat'); 

if isfield(glob,'signalFrequencyPresent')

    for x = 1:glob.xSize
         for y = 1:glob.ySize
            yco = [y-0.5 y-0.5 y+0.5 y+0.5]* glob.dy;  % 4 vertices coordinates clockwise 
            xco = [x-0.5 x+0.5 x+0.5 x-0.5]* glob.dx;
    %         if depos.stratCompleteness(y,x) > 0 && glob.runsPValueMap(y,x) >= 0.0
    %             colour = [1 abs(depos.stratCompleteness(y,x) - glob.runsPValueMap(y,x)) 0];
    %             patch(xco, yco, colour, 'EdgeColor','none');
    %         end

            if glob.signalFrequencyPresent(y,x) == 1
                colour = [0.6 1 0.6]; % pale green for the exact signal frequency present
                patch(xco, yco, colour, 'EdgeColor','none');
            else
                if glob.maxPowerFrequency(y, x) > 0.04
                    colour = [0.576 0.439 0.859]; % Medium purple for higher-frequency elements
                    patch(xco, yco, colour, 'EdgeColor','none');
                elseif glob.maxPowerFrequency(y, x) > 0.0 && glob.maxPowerFrequency(y, x) < 0.04
                    colour = [0.859 0.439 0.576]; % pale violet red for lower-frequency elements
                    patch(xco, yco, colour, 'EdgeColor','none');
                end
            end
         end
    end

    ax = gca;
    xlabel('Strike Distance (km)');
    ylabel('Dip distance (km)');
    ax.LineWidth = 0.5;
    ax.FontSize = 14;
    axis tight
    grid on
end
%% Plot the colour bar for stratigraphic completeness

subplot(2,2,4);

% % Plot the colour bar for stratigraphic completeness
% yco = 0;
% yIncrement = 0.1;
% %for col = 0:0.001:maxStratCompleteness
% for col = 0:0.001:maxStratCompletenessContig
% %     patch([0 0 1 1], [yco yco + yIncrement yco + yIncrement yco], [1-(col/maxStratCompleteness) col/maxStratCompleteness 0], 'EdgeColor','none');
%     patch([0 0 1 1], [yco yco + yIncrement yco + yIncrement yco], [1-(col/maxStratCompletenessContig) col/maxStratCompletenessContig 0], 'EdgeColor','none');
%     yco = yco + yIncrement;
% end
% fprintf('Stratigraphic completeness bar plotted to maximum value %5.4f\n', maxStratCompletenessContig);
% 
% % plot the colour bar for p value maps
% yco = 0;
% for col = 0:0.01:0.5
%     if col < 0.01
%         colour = [0 1 0];
%     else
%         colour = [1 0.8-(col*1.6) 0]; % *2 because correct p value should range from 0 to 0.5, so *2 multiplication needed for range 0-1
%     end
%     patch([2 2 3 3], [yco yco + yIncrement yco + yIncrement yco], colour, 'EdgeColor','none');
%     yco = yco + yIncrement;
% end
% 
% % plot the colour bar for the power spectra frequency map
% xco = [4 4 5 5];
% colour = [0.859 0.439 0.576]; % pale violet red for lower-frequency elements
% patch(xco, [0 0.4 0.4 0], colour, 'EdgeColor','none');
% 
% colour = [0.6 1 0.6]; % pale green for the exact signal frequency present
% patch(xco, [0.4 0.6 0.6 0.4], colour, 'EdgeColor','none');
%         
% colour = [0.576 0.439 0.859]; % Medium purple for higher-frequency elements
% patch(xco, [0.6 1.0 1.0 0.6], colour, 'EdgeColor','none');

% dumpOut = fopen('correlTest.dat','w');
% for x = 1:glob.xSize
%      for y = 1:glob.ySize
%          fprintf(dumpOut,'%f %f\n', depos.stratCompletenessContig(y,x), glob.runsAnalysisPValueMap(y,x));
%      end
% end
% fclose(dumpOut);


%% Save image using save_fig

%     fName = strcat(modelName, '_CompletenessAndPValueMaps');
%     export_fig(fName, '-png', '-transparent', '-r600');

end



