function plotTraverseAnimation(glob, depos)

    fName = strcat('modelOutput\animations\sectionsAnmiation', glob.modelName,'.avi');
    vid = VideoWriter(fName);
    vid.FrameRate = 5;
    open(vid)

    % So loop from proximal to distal down dip drawing a strike-oriented chronostrat diagram for each location
    for sectionLoop = 50:1:180 
        
        % glob, depos, yCross, lowerLimitX, upperLimitX, maxZ, lobeOrFlowColourCoding, modelName
       
        figHandle = plotCrossSectionStrikeDirection(glob, depos, sectionLoop, 150, 350, 20, 0, glob.modelName);  
        oneFrame = getframe(figHandle); % Capture the current figures as one frame, ensure whole figure not one axes by passing figHandle
        writeVideo(vid, oneFrame);

        close(figHandle);
    end
    
    close(vid);
end