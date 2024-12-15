function [gradDestinationCells, negGradients] = calcSingleDestinationCellGradients(x, y, topog, neighbYXDists, neighbYXIncs)
% Calculate the gradients from source cell x,y to each of five neighbouring cells
  
    gradDestinationCells = zeros(1,numel(neighbYXDists));
    for k = 1 : length(neighbYXDists) % implicit loop through all the five possible destination cells
        topogDestX = x + neighbYXIncs(k,2);
        topogDestY = y + neighbYXIncs(k,1);
        gradDestinationCells(k) = (topog(y,x) - topog(topogDestY, topogDestX)) / neighbYXDists(k);
    end
    
    negGradients = (gradDestinationCells < 0); % Up-slope gradients are negative values, so mark them as 1 in negGradients vector
end
