function [glob, depos, numberOfLobes] = calculateFanLobesFromFlowCentroids(glob, depos)

    lobeSeparationDistance = glob.maxBedStrikeLength / 4.0;
    interLobeDuration = 20;
    
    glob = calculateCentroidsAndFlowOverlapsIB(glob, depos);
    
    depos.lobeNumbering = zeros(1, glob.totalIterations);   
    depos.lobeCentroidXY(1,:) = [glob.centroidX(2), glob.centroidY(2)]; % Record first flow as new lobe. Note as ever first flow is chron 2 because chron 1 is initial condition
    numberOfLobes = 1;
    depos.flowLobeNumber(2) = numberOfLobes; % First iteration is initial condition so start from iteration 2...
    closestLobe = 1;
    
    % Loop through all the flows to assign each flow to a lobe according to analysis of flow apex positions and seperations
    for j = 3:glob.totalIterations % loop from second flow

        % Calc separation of flow centroid j and the centroid of the previous flow j-1
        separationX = glob.centroidX(j) - glob.centroidX(j-1);
        separationY = glob.centroidY(j) - glob.centroidY(j-1);
        separationXY = sqrt((separationX .* separationX) + (separationY .* separationY));

        if separationXY > 5.0 % So flow centroid is at least 5 grid points separated from previous flow centroid
           
            lobeNumber = 1;
            lobeAssigned = false;
            while ~lobeAssigned && lobeNumber <= numberOfLobes % Loop through already identified lobes to find nearest one less than lobeSeparationDistance away
                
                % Calc separation of flow apex j and flow apex k
                separationX = glob.centroidX(j) - depos.lobeCentroidXY(lobeNumber,1);
                separationY = glob.centroidY(j) - depos.lobeCentroidXY(lobeNumber,2);
                separationXY = sqrt((separationX .* separationX) + (separationY .* separationY));
                
                % so flow j is close to flow k and not separated by a significant hiatus
                if separationXY < lobeSeparationDistance && checkHiatusBelow(glob, depos, j, interLobeDuration) == false 
                    % Record flow j as same lobe as flow k
                    depos.flowLobeNumber(j) = lobeNumber;
                    closestLobe = lobeNumber;
                    lobeAssigned = true;
                end
                lobeNumber = lobeNumber + 1;
            end
            
            if lobeAssigned == false % Not close in xy to any existing lobe, so mark as a new lobe
                numberOfLobes = numberOfLobes + 1;
                closestLobe = numberOfLobes;
                depos.lobeCentroidXY(numberOfLobes,:) = [glob.centroidX(j), glob.centroidY(j)];
                depos.flowLobeNumber(j) = numberOfLobes;
            end
            
        else
            
             % Record flow j as same lobe as previous flow j-1
            depos.flowLobeNumber(j) = closestLobe;
            
            % Loop (implicit) through all flows so far analysed
            % check if each flow belong to the closestLobe, and calculate the average XY coords of those that do
            closestLobeFlowsCentroidX = glob.centroidX(depos.flowLobeNumber == closestLobe); 
            closestLobeFlowsCentroidY = glob.centroidY(depos.flowLobeNumber == closestLobe);
            depos.lobeCentroidXY(closestLobe, :) = [mean(closestLobeFlowsCentroidX), mean(closestLobeFlowsCentroidY)];
        end
    end
end
    
   
function hiatusBelow = checkHiatusBelow(glob, depos, iteration, interLobeDuration)
% Loop back through previous interlobeDuration number of chrons and
% check at flow centroid x,y if flow thickness exceeds threshold in any
% layer - if it does, no hiatus present, if not, then the new flow
% centroid does overly a hiatus as long or longer than required
% interLobeDuration

    xco = round(glob.centroidX(iteration));
    yco = round(glob.centroidY(iteration));
    hiatusBelow = true;
    
    t = iteration; % Starting at current iteration, loop back through previous interLobeDurationChrons and check of thickness
    while hiatusBelow == true && t > iteration - interLobeDuration && t > 1
        if depos.transThickness(yco,xco,t) > glob.thicknessThreshold
            hiatusBelow = false; % thickness found in underlying layer, so no hiatus present
        end
        t = t - 1;
    end
end