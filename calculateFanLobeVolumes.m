function depos = calculateFanLobeVolumes(glob, depos, numberOfLobes)

    depos.fanLobeVolumes = zeros(glob.totalIterations, numberOfLobes);
    
    for j = 2:glob.totalIterations  
        depos.fanLobeVolumes(j, :) = depos.fanLobeVolumes(j-1, :);     
        oneLobeNumber = depos.flowLobeNumber(j);
        depos.fanLobeVolumes(j, oneLobeNumber) = depos.fanLobeVolumes(j-1, oneLobeNumber) + sum(sum(depos.transThickness(:,:,j)));
    end
end