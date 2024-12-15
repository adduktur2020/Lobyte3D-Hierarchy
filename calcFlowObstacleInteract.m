
function [flow, deposMap, obstDeposVol] = calcFlowObstacleInteract(glob, flow, deposMap, y, x, obstacleRelief, obstDeposVol)

    depositedThickness = abs(obstacleRelief) * glob.pondFillProportion; % Abs because relief is usually a negative number because upslope gradient is negative

    % make sure depos behind obstacle does not exceed avialble sediment volume, and reduce depos thickness if it deos
    if depositedThickness * glob.dx * glob.dy > flow.sedVolume 
        depositedThickness = flow.sedVolume / (glob.dx * glob.dy);
    end

    % Record the deposition, reduce flow thickness, volume and sediment concentration
    deposMap(y,x) = deposMap(y,x) + depositedThickness;
    flow.sedVolume = flow.sedVolume - (depositedThickness * glob.dx * glob.dy);
    flow.sedConcentration = flow.sedVolume / flow.totalVolume;
    obstDeposVol = obstDeposVol + (depositedThickness * glob.dx * glob.dy); % Record this deposition volume specifically to keep track of obstacle versus dispersive volumes
end