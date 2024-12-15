function plotVerticalSection(glob, depos, x, y, modelName)
% Draw a single vertical section at point x,y on the grid. Colour code units a random shade red-to-yellow and assign a random grainsize

% runs up and down are plotted with the chronostrat section
% So calculate runs up and down at point x,y first, before doing any plotting
[runsUp, runsDown] = calculateRunsUpAndDownForPlotting(depos, x,y);

scrsz = get(0,'ScreenSize'); % screen dimensions vector
ffFour = figure('Visible','on','Position',[1 1 (scrsz(3)*0.15) (scrsz(4)*0.95)]);

% line([0,2],[0,depos.elevation(y,x,glob.maxIt)]);
% grid on

timelineInterval = glob.maxIt / 20;
minTriangleWidth = 0.1;

% fileName = sprintf('vertSect%d%d.txt',x,y);
% out = fopen(fileName, 'w');
% fprintf(out,'x:%d y:%d\n', x,y);

for t = 2:glob.maxIt
    
     % Calculate unit elevations
     baseOfUnit = depos.elevation(y,x,t-1); % top of the unit below
     topOfTransported = baseOfUnit + depos.transThickness(y,x,t);
     topOfUnit = depos.elevation(y,x,t);
    
      % Draw the transported fraction first  
      xco = [0 1 1 0];  
      zco = [baseOfUnit baseOfUnit topOfTransported topOfTransported];
      patch(xco, zco, depos.flowColours(t,:), 'EdgeColor','none');
      
      % Draw the hemipelagic fraction
      xco = [0 0.2 0.2 0];  
      zco = [topOfTransported topOfTransported topOfUnit topOfUnit];
      patch(xco, zco, [0.7 0.7 0.7], 'EdgeColor','none');
      
      if mod(t, timelineInterval) == 0 % Draw a marker line for every tenth iteration when t/10 has remainder 0
            line([0 1],[depos.elevation(y,x,t) depos.elevation(y,x,t)], 'color', [0 0 0]);
      end
   
end

% Plot the runs as a series of trinagles, red widening-up for thickening, blue tapering-up for thinning
i = 1;
while i < glob.totalIterations % nz is the number of thickness values recorded in depos.transThickness(y,x,:);
    if runsUp(i) > 0
        j = i;
        while runsUp(j) > 0
            j = j + 1;
        end
        runLength = j-i;
%         xco = [1.5-((runLength * minTriangleWidth)/2.0), 1.5+((runLength * minTriangleWidth)/2.0), 1.5];
        xco = [1.0, 2.0, 1.5];
        baseOfTriangle = depos.elevation(y,x,i); 
        topOfTriangle = baseOfTriangle + sum(depos.transThickness(y,x,i+1:j));
        yco = [topOfTriangle, topOfTriangle, baseOfTriangle];
        patch(xco, yco, [1,0,0], 'EdgeColor','none');
        i = j;
    elseif runsDown(i) > 0
            j = i;
            while runsDown(j) > 0
                j = j + 1;
            end
            runLength = j-i;
%             xco = [1.5-((runLength * minTriangleWidth)/2.0), 1.5+((runLength * minTriangleWidth)/2.0), 1.5];
            xco = [1.0, 2.0, 1.5];
            baseOfTriangle = depos.elevation(y,x,i); 
            topOfTriangle = baseOfTriangle + sum(depos.transThickness(y,x,i+1:j));
            yco = [baseOfTriangle, baseOfTriangle, topOfTriangle];
            patch(xco, yco, [0,0,1], 'EdgeColor','none');
            i = j;
    else
        i = i + 1;
    end
end

% Calculate and print the number of runs, longest run, etc
runsUpCount = sum(runsUp == 1);
longestRunUp = max(runsUp);
runsDownCount = sum(runsDown ==1);
longestRunDown = max(runsDown);
fprintf('Runs up: total count %d Longest %d\nRuns down: total count %d Longest %d\n',runsUpCount, longestRunUp, runsDownCount, longestRunDown);

% Calculate bed thickness stats for the heading text
bedCount = sum(depos.transThickness(y,x,:) > 0.0);
meanBedThickness = mean(depos.transThickness(y,x,:));
maxBedThickness = max(depos.transThickness(y,x,:));

ax = gca;
ylabel('Thickness (m)')
ax.LineWidth = 0.5;
ax.FontSize = 12;
axis tight
grid on
titleStr = sprintf('%s\nx:%2.1f km y:%2.1f km\n%d beds, mean %4.3fm max %4.3fm', modelName, x, y, bedCount, meanBedThickness, maxBedThickness);
title(titleStr)
drawnow

% fclose(out);

% export_fig( sprintf('OrpheusCrossSection %d',iteration),...
%    '-png', '-transparent', '-m12', '-q101');
end



