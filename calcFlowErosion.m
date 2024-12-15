function [depos, topog, erosionMap, flowSedVolume, flowSedConcentration] = calcFlowErosion(glob, depos, flow, topog, erosionMap, xco, yco)
    
   if flow.velocity > glob.deposVelocity && ~flow.stopped % Flow is moving and velocity is greater than settling velocity threshold, so erode
       
       flowCellTime = abs((glob.dx) / flow.velocity); % (s) Residence time in each cell along x-axis
        
        % Calculate basal erosion and entrainment rate
        Z = (flow.ReP .^ 0.6) * (flow.shearVelocity / flow.settlingVelocity); % Z is "dimensionless tractive stress" from Garcia and Parker, part of erosion equation
        EsNumerator = glob.erosionRateConstant * Z ^ 5; 
        EsDenominator = 1 + ((glob.erosionRateConstant / 0.3) * Z ^ 5); 
        flowErosionRate = flow.settlingVelocity * (EsNumerator / EsDenominator); % (m/s) vertical erosion/scour rate

        % Calculate total depth of erosion from rate and residence time
        erosionMap(yco,xco) = flowCellTime * flowErosionRate;

        if erosionMap(yco, xco) > 0
            [depos, topog(yco,xco), erosionMap(yco, xco)] = calcErodeStrata(glob, depos, topog, erosionMap, xco, yco);
        end

        flowSedVolume = flow.sedVolume + (erosionMap(yco,xco) * glob.dx * glob.dy); % this just calculates the cumulative eroded sediment at point x(n)
        flowSedConcentration = flowSedVolume  / flow.totalVolume; % this calculates the new concentration
  
   elseif flow.velocity < glob.deposVelocity && ~flow.stopped % Flow is moving but velocity is less than settling velocity threshold, so do not erode
      erosionMap(yco, xco) = 0;
   end 
end