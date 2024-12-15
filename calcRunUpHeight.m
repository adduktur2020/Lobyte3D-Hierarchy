function [runUpHeight] = calcRunUpHeight(topog, velocity, glob, deepY, deepX, iteration)

% NB: when flow is underwater the REDUCED GRAVITY must be used g' = g.*(rhoCurrent./rhoAmbient - 1)
% g' is the reduced gravity by the buoyancy force

    if topog(deepY, deepX) < glob.SL(iteration) 
       glob.gravity = glob.reducedGravity;
    else
       glob.gravity = glob.gravity;
    end

    runUpHeight = 0.5.*(velocity.^2./glob.gravity);
end
