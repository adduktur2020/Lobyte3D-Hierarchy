function plotSingleFlowRouteAndTopogMapIb(glob, topog, depos, chron, xStart, xStop, yStart, yStop)

    rng(150)

    startVid = 2;
    stopVid = 189;

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    figure('Visible','on','Position',[1 1 (scrsz(3)*0.6) (scrsz(4)*0.9)]);
    transparency = 0.75;

    xSize = (xStop - xStart) + 1;
    ySize = (yStop - yStart) + 1;
    plotDx = glob.dx / 1000.0;
    plotDy = glob.dy / 1000.0;
   
    
    xcoGridVect = (xStart:xStop) * plotDx ;
    ycoGridVect = (yStart:yStop) * plotDy;
    colMap = ones(glob.ySize, glob.xSize, 3);
    
    glob1 = calculateCentroidsAndFlowOverlapsIB(glob, depos);
  
    
    % Extract the flow route with the grid AOI from the whole flow route record for this iteration
    flowXcos = glob.transRouteXYZRecord(:, 1, chron) .* plotDx; % Assumes that element 1 to n are > 0, then elements n+1 to numel are zero
    flowYcos = glob.transRouteXYZRecord(:, 2, chron) .* plotDy;
    flowZcos = glob.transRouteXYZRecord(1:numel(flowXcos), 3, chron); % because some zco values might be zero, use the length of xco to select the equivalent zco vector
    indexes = (flowXcos > xStart) & (flowXcos < xStop) & (flowYcos > yStart) & (flowYcos < yStop);
    flowXcos = flowXcos(indexes);
    flowYcos = flowYcos(indexes);
    flowZcos = flowZcos(indexes);
    flowZcos = flowZcos + 1.5;


    


    topChron = zeros(glob.ySize, glob.xSize);
    deposThickness = zeros(glob.ySize, glob.xSize);
    colArr = [1,3,2,4,5];

    for y = 1:glob.ySize % Loop across the xy grid
       for x = 1:glob.xSize
            for j = 1:glob.totalIterations
                if depos.transThickness(y,x,j) > 0
                    topChron(y,x) = j; % Loop through all the chrons at point xy and record the youngest >0 thickness chron number
                end
            end
       end
    end

for a = startVid:stopVid
    colRand = randsrc(1,1,colArr);
    colR = rand(2);
    for p = 1:glob.ySize
        for q = 1:glob.xSize
%             colRand = randsrc(1,1,colArr);
%             for a = startVid:stopVid
                
%                 colRand = randsrc(1,1,colArr);
                if topChron(p,q) == a
                    if (glob1.centroidX(1,a) >= 250 | glob1.centroidX(1,a) <=252) & (glob1.centroidY(1,a) >= 135 | glob1.centroidY(1,a) <= 270)
%                     if isbetween(glob1.centroidX(1,a),250,252) && isbetween(glob1.centroidY(1,a),135,270)
                        colMap(p,q,1) = 128/255;
                        colMap(p,q,2) = 128/255;
                        colMap(p,q,3) = 0/255;
                    elseif (glob1.centroidX(1,a) >= 245 | glob1.centroidX(1,a) <=274) & (glob1.centroidY(1,a) >= 137 | glob1.centroidY(1,a) <= 284)
%                     elseif isbetween(glob1.centroidX(1,a),245,274) && isbetween(glob1.centroidY(1,a),137,284)
                        colMap(p,q,1) = 128/255;
                        colMap(p,q,2) = 0/255;
                        colMap(p,q,3) = 128/255;
                    elseif (glob1.centroidX(1,a) >= 257 | glob1.centroidX(1,a) <=296) & (glob1.centroidY(1,a) >= 143 | glob1.centroidY(1,a) <= 267)
%                     elseif isbetween(glob1.centroidX(1,a),257,296) && isbetween(glob1.centroidY(1,a),143,267)

                        colMap(p,q,1) = 255/255;
                        colMap(p,q,2) = 255/255;
                        colMap(p,q,3) = 0/255;
                    else
                        colMap(p,q,1) = 0/255;
                        colMap(p,q,2) = 255/255;
                        colMap(p,q,3) = 255/255;
                    end
                end
%             end
        end
    end
end
    colMap = colMap(yStart:yStop,xStart:xStop,:);
    plotTopog = topog(yStart:yStop, xStart:xStop);
    surface(xcoGridVect, ycoGridVect, plotTopog,colMap); % , 'EdgeColor','none')

hold on


    % Draw flow routes in cornflower blue
    line(flowXcos, flowYcos, flowZcos,'Color', 'blue', 'LineWidth', 3);

    
    ax = gca;
    xlabel('X Distance (km)')
    ylabel('Y Distance (km)')
    zlabel('Elevation (m)')
    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    axis tight
    grid on
    view([220 60]);
    drawnow
    
    view(120, 85);
    saveas(gcf, 'flowVid139-173',"tif")
%     fileName8 = strcat(glob.outputDir, 'SteepexIndex_Historyacc02.mat');
%     save(fileName8,'steepestHistory');
%     
%     fprintf("Topography lowest gradient %9.8f highest gradient %9.8f\n", minSteepestGrad, maxSteepestGrad);
end