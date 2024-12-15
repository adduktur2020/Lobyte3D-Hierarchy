function plot3DView(glob, depos, newFigure, lobeOrFlowColourCoding, transparency)

    if newFigure
        figure
    end

    topChron = zeros(glob.ySize, glob.xSize);
    deposThickness = zeros(glob.ySize, glob.xSize);
    
    for y = 1:glob.ySize-1 % Loop across the xy grid
       for x = 1:glob.xSize-1 
            deposThickness(y,x) = sum(depos.transThickness(y,x,1:glob.totalIterations)); % Sum flow thicknesses at each grid point
            
            for j = 1:glob.totalIterations   
                if depos.transThickness(y,x,j) > 0
                    topChron(y,x) = j; % Loop through all the chrons at point xy and record the youngest >0 thickness chron number
                end
            end
       end
    end
    
    for y = 1:glob.ySize-1
       for x = 1:glob.xSize-1 
           
           if  deposThickness(y,x) > 0.01 % Draw a patch at xy for the flow that is at the top of the strata at xy
                yco = [y*glob.dy, y*glob.dy, (y+1)*glob.dy, (y+1)*glob.dy];  
                xco = [x*glob.dx, (x+1)*glob.dx, (x+1)*glob.dx, x*glob.dx];
                zco = [depos.elevation(y,x,1) + deposThickness(y,x), depos.elevation(y,x+1,1) + deposThickness(y,x+1), ...
                    depos.elevation(y+1,x+1,1) + deposThickness(y+1, x+1), depos.elevation(y+1,x,1) + deposThickness(y+1,x)];
                
                if lobeOrFlowColourCoding ~= 1
                    thicknessColour = [depos.flowColours(topChron(y,x),1), depos.flowColours(topChron(y,x),2), depos.flowColours(topChron(y,x),3)];
                else
                    thicknessColour = [depos.flowColoursByLobe(topChron(y,x),1), depos.flowColoursByLobe(topChron(y,x),2), depos.flowColoursByLobe(topChron(y,x),3)];
                end
                patch(xco,yco,zco, thicknessColour,'EdgeColor','none', 'facealpha', transparency);
            end
        end 
    end
end