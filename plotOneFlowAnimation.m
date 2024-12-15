function plotSingleFlowMaps(glob, depos, showChron)

    scrsz = get(0,'ScreenSize'); % screen dimensions vector
    ffOne = figure('Visible','on','Position',[1 1 (scrsz(3)*0.9) (scrsz(4)*0.9)]);
    
    minBathym = min(min(depos.elevation(:,:,1)));
    maxBathym = max(max(depos.elevation(:,:,1)));
    
    for y = 1:glob.ySize-1
       for x = 1:glob.xSize-1 
 
           yco = [y*glob.dy y*glob.dy (y+1)*glob.dy (y+1)*glob.dy];  
           xco = [x*glob.dx (x+1)*glob.dx (x+1)*glob.dx x*glob.dx];
           
           %Plot bathymetry
           zco = [depos.elevation(y,x,showChron-1), depos.elevation(y,x+1,showChron-1), depos.elevation(y+1, x+1,showChron-1), depos.elevation(y+1,x,showChron-1)];
           bathyColour = [0 0 0.25 + (0.75*((depos.elevation(y,x,1) - minBathym)/maxBathym))]; % Bathymetry, cyan at min depth, dark blue at max depth
           patch(xco, yco, zco, bathyColour, 'EdgeColor',[0.3 0.3 0.3]);
           
       end
    end

    %% General
    view([220 60]);
   
    ax = gca;
    xlabel('X Distance (km)');
    ylabel('Y Distance (km)');
    zlabel('Elevation (m)')
    
    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    
    axis tight
    grid on
    
    frameCount = 1;
    
%     fName = strcat('graphicsOutput\', glob.modelName,'.avi');
%     vid = VideoWriter(fName);
%     vid.FrameRate = 5;
%     open(vid)
%     movieFrames(frameCount) = getframe;
    
    totalIterations = max(glob.flowRoutes(showChron, :, 1)); % Because matrix subset :,1 in 3d array contains iteration values
    iteration = 1;
    j = 1;
    
    while  iteration < totalIterations
 
        if glob.flowRoutes(showChron, j, 1) == iteration
            
            x = glob.flowRoutes(showChron, j, 2);
            y = glob.flowRoutes(showChron, j, 3);
            if depos.transThickness(y,x,showChron) > 0
                flowCol = [1 1 0];
            else
                flowCol = [1 0 0];
            end
            
            yco = [y*glob.dy y*glob.dy (y+1)*glob.dy (y+1)*glob.dy];  
            xco = [x*glob.dx (x+1)*glob.dx (x+1)*glob.dx x*glob.dx];
            zco = [depos.elevation(y,x,showChron-1), depos.elevation(y,x+1,showChron-1), depos.elevation(y+1, x+1,showChron-1), depos.elevation(y+1,x,showChron-1)];
            patch(xco, yco, zco, flowCol, 'EdgeColor','none');
            
            j = j + 1;
        end
        
%         w = waitforbuttonpress;
%         oneFrame = getframe;
%         writeVideo(vid, oneFrame);
        fprintf('\b\b\b\b\b%d', iteration);
        
        iteration = iteration + 1;
    end
    
    fprintf('Done\n');
%     close(vid);
end