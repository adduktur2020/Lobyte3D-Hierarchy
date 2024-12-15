function [glob] = initializeSedimentSupplyParams(glob)

    % Initialise sediment supply history for duration of model run, assuming that 
    % glob.sedimentSupplyMax, glob.sedimentSupplyMin and glob.sedimentSupplyPeriod were successfully input and passed here in glob
  
    glob.flowSedVolStart = glob.flowSedVolMin + ((glob.flowSedVolMax - glob.flowSedVolMin) / 2.0);
    glob.flowSedVolOscillationAmplitude = (glob.flowSedVolMax - glob.flowSedVolMin) / 2.0;
    
    % Initialize sediment supply sinusoid
    % General equation: y = A sin(Bx + C) + D
    % A = amplitude; 2pi/B = period; C = phase shift; D vertical shift or min supply
    t = 1 : glob.maxIts; % Create an implicit loop with vector t
    glob.flowSedVolHistory(t) =  glob.flowSedVolStart + (glob.flowSedVolOscillationAmplitude * sin((t / glob.flowSedVolOscillationPeriod) .* 2 .* pi));
end
