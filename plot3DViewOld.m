function plot3DView(depos, glob, xCross, yCross, plotTitle)

    ff = figure;


    %% Draw the top basement using surface (plot initial topography)
    % mymapcoast;  
%     plotInitialSurface = depos.elevation(:,:,1);
%     pp = surface(plotInitialSurface);  
%     shading('flat'); 
%     set(pp,'LineStyle','none');

%     pp = figure;

    % %set(pp,'FaceAlpha',0.5);
    % set(pp,'specularexponent',100.,'specularstrength',0.0); 
    % set(pp,'diffusestrength',[0.9],'Ambientstrength',0.3); 
    % colormap(cc);
    % %put light and shading 
    % camlight(18,5); 
    % colormap(cc); 
    % set(gcf,'PaperUnits','centimeters'); 
    % set(gcf,'PaperPosition',[0. 0. 9. 9.]);

    %% Draw basement
%     l = min(min(plotLastSurface)) - 20;
%     for x = glob.xSize
%         for y = 1:glob.ySize-1
%             xc = [x x x x] * glob.dx;
%             yc = [y y+1 y+1 y] * glob.dy;
%             zc = [l l plotLastSurface(y,x) plotLastSurface(y,x)];
%             patch(xc,yc,zc,[177  179  179]./255,'EdgeColor','none');
%         end
%     end
% 
%     for x = 1:glob.xSize-1
%         for y = glob.ySize
%             xc = [x x+1 x+1 x] * glob.dx;
%             yc = [y y y y] * glob.dy;
%             zc = [l l plotLastSurface(y,x) plotLastSurface(y,x)];
%             patch(xc,yc,zc,[177  179  179]./255,'EdgeColor','none');
%         end
%     end
% 
%     for x = 1
%         for y =1:glob.ySize-1
%             xc = [x x x x] * glob.dx;
%             yc = [y y+1 y+1 y] * glob.dy;
%             zc = [l l plotLastSurface(y,x) plotLastSurface(y,x)];
%             patch(xc,yc,zc,[177  179  179]./255,'EdgeColor','none');
%         end
%     end
% 
%     for x = 1:glob.xSize-1
%         for y = 1
%             xc = [x x+1 x+1 x] * glob.dx;
%             yc = [y y y y]* glob.dy;
%             zc = [l l plotLastSurface(y,x) plotLastSurface(y,x)];
%             patch(xc,yc,zc,[177  179  179]./255,'EdgeColor','none');
%         end
%     end

    % %% Draw Sea Level
    % SL = 70; %% not in agreement with the real topography
    % z = SL;
    % x = 1:glob.xSize;
    % y = 1:glob.ySize;
    % zco = [z z z z];
    % xco = [x(1) x(end) x(end) x(1)];
    % yco = [y(1) y(1) y(end) y(end)];
    % patch(xco,yco,zco,[0  1  1],'FaceAlpha',0.15,'EdgeColor','none');

    %% Draw the sediment deposit using patch 
    fr = 1;
    
    for y = 1:glob.ySize
       for x = 1:glob.xSize
            deposThickness(y,x) = sum(depos.transThickness(y,x,1:glob.totalIterations));
       end
    end
    maxDeposThickness = max(max(deposThickness));
    minBathym = min(min(depos.elevation(:,:,1)));
    maxBathym = max(max(depos.elevation(:,:,1)));

    for y = 1:glob.ySize-1
       for x = 1:glob.xSize-1 
           
%            yco = [y y (y+1) (y+1)];  % 4 vertices coordinates clockwise 
%            xco = [x (x+1) (x+1) x];
           
           yco = [y*glob.dy y*glob.dy (y+1)*glob.dy (y+1)*glob.dy];  
           xco = [x*glob.dx (x+1)*glob.dx (x+1)*glob.dx x*glob.dx];
           
           %Plot bathymetry
           zco = [depos.elevation(y,x,1), depos.elevation(y,x+1,1), depos.elevation(y+1, x+1,1), depos.elevation(y+1,x,1)];
           bathyColour = [0 0 0.25 + (0.75*((depos.elevation(y,x,1) - minBathym)/maxBathym))]; % Bathymetry, cyan at min depth, dark blue at max depth
           patch(xco, yco, zco, bathyColour, 'EdgeColor','none');
    
            if  deposThickness(y,x) > 0.00
%                 if  deposThickness(y,x) > 0.01
%                 yco = [y*glob.dy y*glob.dy (y+1)*glob.dy (y+1)*glob.dy];  % 4 vertices coordinates clockwise 
%                 xco = [x*glob.dx (x+1)*glob.dx (x+1)*glob.dx x*glob.dx];
%                 xco = [x-0.5 x+0.5 x+0.5 x-0.5];
%                 yco = [y+0.5 y+0.5 y-0.5 y-0.5];
%                 
%                 centralZco = plotInitialSurface(y,x)+deposThickness(y,x);
%                 zcoXplusYplus = (centralZco + ((plotInitialSurface(y+1,x+1)+deposThickness(y+1,x+1)) / 2 ));
%                 zcoXplusYminus = (centralZco + ((plotInitialSurface(y-1,x+1)+deposThickness(y-1,x+1)) / 2));
%                 zcoXminusYplus = (centralZco + ((plotInitialSurface(y+1,x-1)+deposThickness(y+1,x-1)) / 2));
%                 zcoXminusYminus = (centralZco + ((plotInitialSurface(y-1,x-1)+deposThickness(y-1,x-1)) / 2));
% %                 zco = [centralZco, centralZco, centralZco, centralZco];
%                 zco = [zcoXminusYplus, zcoXplusYplus, zcoXplusYminus, zcoXminusYminus];
%                  thicknessColour = [0.8549 * (deposThickness(y,x)/maxDeposThickness), 0.7568, 0.1255];
                thicknessColour = [1 1 0.70 * (1-(deposThickness(y,x)/maxDeposThickness))];
                zco = [deposThickness(y,x), deposThickness(y,x+1), deposThickness(y+1, x+1), deposThickness(y+1,x)];
%                 thicknessColour = [0.8549 0.7568 0.1255];
                patch(xco,yco,zco, thicknessColour,'EdgeColor','none');
            end
        end 
    end

    % Draw planes of cross section
    xco = [xCross* glob.dy xCross* glob.dy xCross* glob.dy xCross* glob.dy];
    yco = [0 0 glob.ySize * glob.dy glob.ySize * glob.dy];
    zco = [minBathym maxBathym maxBathym minBathym];
    patch(xco, yco, zco, [1 1 1], 'FaceVertexAlphaData', 0.2, 'FaceAlpha', 'flat');
    
    xco = [0 0 glob.xSize * glob.dy glob.xSize * glob.dy];
    yco = [yCross* glob.dy yCross* glob.dy yCross* glob.dy yCross* glob.dy];
    zco = [minBathym maxBathym maxBathym minBathym];
    patch(xco, yco, zco, [1 1 1], 'FaceVertexAlphaData', 0.2, 'FaceAlpha', 'flat');
    
    
    %         myMovie(fr) = getframe;
    %        fr = fr + 1; 
    %% General
    view([220 60]);
%     view([-50 80]);
    
    ax = gca;
%     xlabel('Strike distance (km)');
%     ylabel('Dip distance (km)');
%     zlabel('Elevation (m)')

    ax.LineWidth = 0.5;
    ax.FontSize = 12;
    axis tight
    grid off
    title(plotTitle);

    % % shading flat
    % lightangle(250,30)
    % pp.FaceLighting = 'gouraud'; % 'flat';
    % pp.AmbientStrength = 0.9;
    % pp.DiffuseStrength = 0.8;
    % pp.SpecularStrength = 0.9;
    % pp.SpecularExponent = 25;
    % % pp.BackFaceLighting = 'unlit';
    % % material metal

%     ZLimits = [min(min(plotLastSurface)) max(max(plotLastSurface))];
%     demcmap(ZLimits)

    % c = colorbar;
    % c.Label.String ='Z (m)';
    % c.FontSize = 18;
    % % hold on
    % % contour3(plotLastSurface)

    % %% Set figure position and dimension
    % width = 125;     % Width in inches
    % height = 85;    % Height in inches
    % set(ffOne, 'Position', [0.5 0.5 width*17, height*9]); % <- Set size

    %% Save image using save_fig
    % set(ffOne,'Color','none'); % set transparent background
    % set(gca,'Color','none');


%     export_fig(sprintf('lobyte3DPlot%d',glob.totalIterations), '-png', '-transparent', '-r600');
end