function plotSingleFlowMapsAnimated(glob, depos, startChron, endChron, lobeOrFlowColourCoding)

    if startChron > 0 && endChron <= glob.totalIterations
        
        scrsz = get(0,'ScreenSize'); % screen dimensions vector
        figHandle = figure('Visible','on','Position',[1 1 (scrsz(3)*0.9) (scrsz(4)*0.9)]);
        fName = strcat('modelOutput\animations\', glob.modelName,'flowimation.avi');
        vid = VideoWriter(fName);
        vid.FrameRate = 5;
        open(vid);
        
        fprintf('Drawing flow %5d', startChron)
       
        for t = startChron: endChron 
            
            plotDx = glob.dx / 1000.0;
            plotDy = glob.dy / 1000.0;
            minX = 180;
            maxX = 300;
            minY = 50;
            maxY = 250; 
            line([minX * plotDx, maxX * plotDx],[minY * plotDy, maxY * plotDy], 'color', [1,1,1]); % Draw line to force xy size of grid, so that it does not change during animation
            line([minX,minX],[minY,minY],[0,20], 'color', [1,1,1]); % Draw line at xy=0,0 to fix z height of the axes

            ax = gca;
            xlabel('X Distance (km)');
            ylabel('Y Distance (km)');
            zlabel('Elevation (m)')
            ax.LineWidth = 0.5;
            ax.FontSize = 12;
            axis tight
            grid on
            view([220 60]);
            
            [xco, yco] = meshgrid(minX:maxX, minY:maxY);
            z = depos.elevation(minY:maxY, minX:maxX, 1);
            col = ones((maxY - minY) + 1, (maxX - minX) + 1, 3) / 2.0;
            surface(xco, yco, z, col);

            for x = minX:maxX
                for y = minY:maxY
                    
                    tTop = t;
                    topFlowFound = false;
                    while tTop > 1 && ~topFlowFound% Loop from top chron back through older layers
                        
                        if depos.transThickness(y,x,tTop) > glob.thicknessThreshold
                            yco = [y*plotDy, y*plotDy, (y+1)*plotDy, (y+1)*plotDy, y*plotDy];  
                            xco = [x*plotDx, (x+1)*plotDx, (x+1)*plotDx, x*plotDx, x*plotDx];
                            zco = [depos.elevation(y,x,t), depos.elevation(y,x+1,t), depos.elevation(y+1, x+1,t), depos.elevation(y+1,x,t), depos.elevation(y,x,t)];
                            lobeNumber = depos.flowLobeNumber(tTop);
                            if lobeOrFlowColourCoding ~= 1
                                patch(xco, yco, zco, depos.flowColours(tTop,:), 'EdgeColor','none');
                            else
                                patch(xco, yco, zco, depos.lobeColours(lobeNumber,:), 'EdgeColor','none');
                            end
                            topFlowFound = true;
                        end
                        
                        tTop = tTop - 1;
                    end
                    
%                     if ~topFlowFound
%                         yco = [y*plotDy, y*plotDy, (y+1)*plotDy, (y+1)*plotDy, y*plotDy];  
%                         xco = [x*plotDx, (x+1)*plotDx, (x+1)*plotDx, x*plotDx, x*plotDx];
%                         zco = [depos.elevation(y,x,1), depos.elevation(y,x+1,1), depos.elevation(y+1, x+1,1), depos.elevation(y+1,x,1), depos.elevation(y,x,1)];
%                         patch(xco, yco, zco, [0.5, 0.5, 0.5], 'EdgeColor','none');
%                     end
                end
            end

            oneApexXco = glob.apexCoords(t,2) * plotDx;
            oneApexYco = glob.apexCoords(t,3) * plotDy;
            oneApexZco = depos.elevation(glob.apexCoords(t,3),glob.apexCoords(t,2),t);
            blobSize =  plotDx;
            
            xco = [oneApexXco - blobSize, oneApexXco - blobSize, oneApexXco + blobSize, oneApexXco + blobSize];
            yco = [oneApexYco - blobSize, oneApexYco + blobSize, oneApexYco + blobSize, oneApexYco - blobSize];
            zco = [oneApexZco, oneApexZco, oneApexZco, oneApexZco];
            if lobeOrFlowColourCoding ~= 1
                patch(xco, yco, zco, depos.flowColours(t,:), 'EdgeColor','none');
            else
%                 patch(xco, yco, zco, depos.flowColoursByLobe(t,:), 'EdgeColor','none');
                patch(xco, yco, zco, [0,0.6,0.9], 'EdgeColor','none');
            end
            
            drawnow;

           oneFrame = getframe;
           writeVideo(vid, oneFrame);
           fprintf('\b\b\b\b\b%5d', t);
           cla
           
           % close(figHandle);
           
        end

        fprintf('Done\n');
        close(vid);
    end
end