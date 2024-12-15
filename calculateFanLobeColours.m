function depos = calculateFanLobeColours(glob, depos, numberOfLobes) 

    % Set the lobe colours, ready for plotting
    depos.lobeColours = zeros(numberOfLobes,3);
    for j = 1:numberOfLobes
        depos.lobeColours(j, :) = [0.5+(rand/2), rand, 0.0];
    end
    
    % assign the appropriate lobe colour to each flow
    depos.flowColoursByLobe = zeros(glob.totalIterations,3);
    for j = 2:glob.totalIterations
        lobeNumber = depos.flowLobeNumber(j);
        depos.flowColoursByLobe(j,:) = depos.lobeColours(lobeNumber,:); % Select a new random lobe colour for any new lobe number
    end
    
end
