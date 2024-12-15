function [glob] = waterLevelCurve (glob)
% water level curve
initialSL = 25.5;
SLAmp = 0.001; %m
SLPeriod = 0.002; %My 
glob.SL = zeros(1, glob.maxIts);
t = 1:glob.totalIterations+1;
glob.SL(t) = initialSL + ((sin(pi*(((t.*glob.deltaT)/SLPeriod)*2)))*SLAmp); 

end