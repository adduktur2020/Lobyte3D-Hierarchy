function [glob] = initializeLobyteParameters(glob)

    % ambient fluid properties
    glob.gammaAmbient = glob.rhoAmbient * glob.gravity;% specific weight of ambient fluid (water) kg/m2.*s2

    % grain properties
    glob.gammaSolid = glob.rhoSolid * glob.gravity; % specific weight of the grains kg/m2.*s2

    % flow properties
    % flow volume concentration is the key distinguishing factor for the three flow types
    glob.rhoFlow = glob.rhoSolid * glob.flowVolumConcentration; % 1.70;  % flow mass density (kg/m^3) (specific mass)
    glob.reducedGravity = glob.gravity .*(glob.rhoFlow./glob.rhoAmbient - 1); % gravity reduced by the buoyancy force when the flow is underwater 
    a = glob.gammaSolid .* glob.flowVolumConcentration;
    b = glob.gammaAmbient .* (1 - glob.flowVolumConcentration);
    glob.gammaFlow = a + b; % specific weight of a mixture kg/m2.*s2  
end