function plotChronostratTraverseAnimation(glob, depos)

scrsz = get(0,'ScreenSize'); % screen dimensions vector
ffTwo = figure('Visible','on','Position',[1 1 (scrsz(3)*0.8) (scrsz(4)*0.8)]);

leftStart = 0;
rightEnd = (glob.ySize - 1) * glob.dy;
glob.deltaT = 0.001;

% now loop through the model grid plotting a strike-oriented chronostrat at
% each yCo location specified

for ycoTraverseLoop = 30:5:100 % So loop from proximal to distal down dip drawing a strike-oriented chronostrat diagram for each location

    fprintf('Drawing chronostrat y=%d\n', ycoTraverseLoop);
    
    clf; % clear anything plotted on previous iterations
    line([leftStart, rightEnd], [0, (glob.maxIt-1)*glob.deltaT], 'Color','white'); % Ensure plot axis are across whole strike section length

    for t = 2:glob.maxIt-1

         zco = [t * glob.deltaT, t * glob.deltaT, (t-1) * glob.deltaT, (t-1) * glob.deltaT]; % Set zcoords in plot to time for current chron in t loop
         for x = 1:glob.xSize-1
              if depos.transThickness(ycoTraverseLoop,x,t) > glob.thicknessThreshold % so thickness threshold to plot depos on chronostrat is 1mm
                    xco = [x x+1 x+1 x] * glob.dx;  % 4 vertices coordinates clockwise       
                    patch(xco, zco, depos.flowColours(t,:), 'EdgeColor','none');
              end
         end
    end

    % Plot a line showing contiguous stratigraphic completeness along the line of section - helps interpret lobe stacking on the chronostrat diagram
    % xco = (leftStart:rightEnd) * glob.dx;
    % zco = depos.stratCompletenessContig(yCross, leftStart:rightEnd) * glob.maxIt; % Scale completeness as a proportion of the total iterations
    % line(xco, zco, 'color','blue','LineWidth',1.0);

    ax = gca;
    grid on;
    xlabel('X Distance (km)','FontSize',16);
    ylabel('Geological time (My)','FontSize',16);
    titleStr = sprintf('Distance down dip = %2.1fkm', ycoTraverseLoop * glob.dy);
    title(titleStr);
    
%     disp('Press a key...');
%     waitforbuttonpress;
%     
%     fName = sprintf('graphicsOutput/lobyte3D_%s_vSectChronostratAnimation%d',  glob.modelName, ycoTraverseLoop);
%     export_fig(fName, '-png', '-transparent', '-r600');
end