function [maxGrad, nbrGradsTopogPlusFlow] = calcNeighbourMaxGrad(glob, topog, y, x, flowCOGHeight)
% Calculate gradients between i,j model cell and its eight neighbours 
% nbrGrads: gradient between cell(i,j) and east cell(i,j+1) and so on clockwise.

    nbrGradsTopogOnly = zeros(1,3); % Gradient of the topography in front of the flow
    nbrGradsTopogPlusFlow = zeros(1,3); % gradients from the flow center of mass to the adjacent topography points

    yPlus = y+1;
    xPlus = x+1;
    xMinus = x-1;

    % Check for grid edge conditions and adjust cell coordinate increments as required
    if yPlus > glob.ySize yPlus = y; end      
    if xPlus > glob.ySize xPlus = x; end
    if xMinus < 1 xMinus = x; end
    
    % Accounting for grid edge effects, create a 1x3 matrix of neighbouring topography, in the y+1 direction of the flow movement
    nbrTopog = [topog(yPlus,xMinus), topog(yPlus,x), topog(yPlus,xPlus)];
    
    % Calculate the topographic gradients to neghbouring cells, accounting for orthogoanl (rook) or diagonal (bish) distances between cells
    nbrGradsTopogOnly(1:3) = (nbrTopog(1:3) - topog(y,x)) / glob.dx;
    nbrGradsTopogOnly = atan(nbrGradsTopogOnly) / pi * 2; 
  
    nbrGradsTopogPlusFlow(1:3) = (nbrTopog(1:3) - (topog(y,x) + flowCOGHeight)) / glob.dx;
    nbrGradsTopogPlusFlow = atan(nbrGradsTopogPlusFlow) / pi * 2;
    nbrGradsTopogPlusFlow = nbrGradsTopogPlusFlow .* (nbrGradsTopogPlusFlow < 0.0); % We only want down-slope gradients, so set all >0 gradients to 0

    maxGrad = min(nbrGradsTopogPlusFlow); % min because down-slope gradients are negative
end