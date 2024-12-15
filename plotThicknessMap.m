function plotThicknessMap(glob, depos)

        scrsz = get(0,'ScreenSize'); % screen dimensions vector
        ffOne = figure('Visible','on','Position',[1 1 (scrsz(3)*0.9) (scrsz(4)*0.9)]);
        
        totalStratThickness = depos.elevation(:,:,glob.maxIts-2) - depos.elevation(:,:,1);
        surface(totalStratThickness);
        
        view([220 60]);

        ax = gca;
        xlabel('X Strike Distance (km)');
        ylabel('Y Dip Distance (km)');
        ax.LineWidth = 0.5;
        ax.FontSize = 12;
        axis tight
        grid off
end