function [glob, depos, numberOfLobes] = calculateFanLobesFromFlowApices(glob, depos)

% Need to calculate how long mean interlobe hiatus is e.g.
% Calculate min, mean and max thickness of mud-only intervals in each vertical section across the grid where:
% 1.	Max trans thickness from all layers at xy is > model threshold e.g. 1mm
% 2.	At least two mud layers occur adjacent without any transported sand - hiatus between flows
% Use mean hiatus thickness as another criterion for new lobe - is the flow apex separated vertically from any other within-flow-width-distance apex by at least the mean hiatus thickness of only mud layers?



    lobeSeparationDistance = glob.maxBedStrikeLength / 2;
    interLobeDuration = 20;
    depos.lobeNumbering = zeros(1, glob.totalIterations);   
    depos.lobeApexXY(1,:) = [glob.apexCoords(2,2), glob.apexCoords(2,3)]; % Record first flow as new lobe. Note as ever first flow is chron 2 because chron 1 is initial condition
    numberOfLobes = 1;
    depos.flowLobeNumber(2) = numberOfLobes; % First iteration is initial condition so start from iteration 2...
    closestLobe = 1;

    % Loop through all the flows to assign each flow to a lobe according to analysis of flow apex positions and seperations
    for j = 3:glob.totalIterations % loop from second flow

        % Calc separation of flow apex j and the apex of the previous flow j-1
        separationX = glob.apexCoords(j,2) - glob.apexCoords(j-1,2);
        separationY = glob.apexCoords(j,3) - glob.apexCoords(j-1,3);
        separationXY = sqrt((separationX .* separationX) + (separationY .* separationY));

        if separationXY > 2.0 % So flow apex is at least one grid point separated from previous flow flow aspex
           
            lobeNumber = 1;
            lobeAssigned = false;
            while ~lobeAssigned && lobeNumber <= numberOfLobes % Loop through already identified lobes to find nearest one less than lobeSeparationDistance away
                
                % Calc separation of flow apex j and flow apex k
                separationX = glob.apexCoords(j,2) - depos.lobeApexXY(lobeNumber,1);
                separationY = glob.apexCoords(j,3) - depos.lobeApexXY(lobeNumber,2);
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
                depos.lobeApexXY(numberOfLobes,:) = glob.apexCoords(j,2:3);
                depos.flowLobeNumber(j) = numberOfLobes;
            end
            
        else
            
             % Record flow j as same lobe as previous flow j-1
            depos.flowLobeNumber(j) = closestLobe;
            
            % Loop (implicit) through all flows so far analysed
            % check if each flow belong to the closestLobe, and calculate the average XY coords of those that do
            closestLobeFlowsApexX = glob.apexCoords(depos.flowLobeNumber == closestLobe, 2); % index 2 and 3 in glob.apexCoords are the x,y coords
            closestLobeFlowsApexY = glob.apexCoords(depos.flowLobeNumber == closestLobe, 3);
            depos.lobeApexXY(closestLobe, :) = [mean(closestLobeFlowsApexX), mean(closestLobeFlowsApexY)];
        end
    end
end
    
   
function hiatusBelow = checkHiatusBelow(glob, depos, iteration, interLobeDuration)

    xco = glob.apexCoords(iteration,2);
    yco = glob.apexCoords(iteration,3);
    hiatusBelow = true;
    
    t = iteration; % loop back from layer iteration to check all previous layers
    while hiatusBelow == true && t > iteration - interLobeDuration && t > 1
        if depos.transThickness(yco,xco,t) > glob.thicknessThreshold
            hiatusBelow = false;
        end
        t = t - 1;
    end
end