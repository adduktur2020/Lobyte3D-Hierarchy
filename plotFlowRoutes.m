function plotFlowRoutes

    load('modelOutput/oneFanHistory.mat','xco','yco','flowRoutes', 'deposThickness');
    
    xco = xco .* 10;
    yco = yco .* 10;

    figHandle = figure;
    
    set(figHandle,'RendererMode','manual','Renderer','zbuffer');
    
    totalFlows = size(flowRoutes,3);
    totalThickness = deposThickness(:,:,1);
    
    for t = 2: totalFlows
        
        totalThickness = totalThickness + deposThickness(:,:,t-1);
        gca = pcolor(xco, yco, totalThickness);
        gca.LineStyle = 'none';
        hold on;
        
        drawFlow(xco, yco, flowRoutes, deposThickness, t);
          
        xlabel('X Distance (m)');
        ylabel('Y Distance (m)');
        titleString = sprintf('Flow #%d of %d', t, totalFlows);
        title(titleString);
%         w = waitforbuttonpress;

        fanimationMovie(t-1) = getframe(figHandle);
    end
    
%     movie(fanimationMovie);

    vid = VideoWriter('fanimation.avi','Motion JPEG AVI');
    vid.FrameRate = 30;
    open(vid);
    writeVideo(vid, fanimationMovie);
    close(vid);
end

function drawFlow(xGrid, yGrid, flowRoutes, deposThickness, t)
    
    dx = xGrid(2) - xGrid(1);
    dy = yGrid(2) - yGrid(1);

    for x = 1:length(xGrid)
        for y = 1:length(yGrid)
            
             xco = [x * dx, x * dx, (x+1) * dx, (x+1) * dx];
             yco = [y * dy, (y+1) * dy, (y+1) * dy, y * dy];
            
            if flowRoutes(y,x,t) > 0
               patch(xco, yco, [1,0.1,0.8], 'EdgeColor', 'none');
            end
            
            if deposThickness(y,x,t) > 0.0
                patch(xco, yco, [1,0.9,0.0], 'EdgeColor', 'none', 'facealpha', 0.5);
            end
        end
    end
end