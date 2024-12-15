function [neighboursXYIncs, neighboursXYDists] = initialiseGridAndGradientMatrices(dx, dy)

    neighboursXYIncs = [0,1; 1,1; 1,0; 1,-1; 0,-1]; % create a vector with all Nbr cell coords and XY distances, anticlclockiwse from due East neighbour
    diagDist = sqrt((dx * dx) + (dy * dy));
    neighboursXYDists = [dx; diagDist; dy; diagDist; dx]; % dist from cell xy to 5 strike and down-dip neighbour cells     
end
