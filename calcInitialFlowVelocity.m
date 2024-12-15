function [maxVelocity, maxShearVelocity] = calcInitialFlowVelocity(glob, gradient)
    
    gradient = rad2deg(atan(gradient)); % Convert gradient to degrees, as required by following equations
    rhoFlow = (2.6 * glob.flowVolumConcentration) + (1 - glob.flowVolumConcentration); % rhoFlow is the flow bulk density
    flowDensity = ((rhoFlow - glob.rhoAmbient) / glob.rhoAmbient);
    maxShearVelocity = sqrt( glob.gravity * flowDensity .* abs(gradient) * 0.25 * glob.totalFlowThickness) * sign(gradient); % (m/s) Shear Velocity calculation, including sign indicating downslope direction
    maxVelocity = maxShearVelocity / sqrt(glob.basalFrictCoeff);   % (m/s) this converts shear velocity into velocity (Stevenson grand banks paper)
end