function findLocationsWithRunsAnalysisOrder

    outputDir = 'modelOutput/';
    
    modelName = 'lobyteRunAAPGAnimation_ConstSupply_T1000Sup20Hp0.02';
    fName = sprintf('%s%s_pValueMapsCutOff%7.6f.mat',outputDir, modelName, 0.001);
    if exist(fName, 'file')
        load(fName,'-mat','runsMetricMap', 'runsPValueMap'); 
        runsMetricMapConstSupply = runsMetricMap;
        runsPValueMapConstSupply = runsPValueMap;
        failedIHave = false;
    else
        fprintf('Cannot find file %s\n', fName);
        failedIHave = true;
    end

    modelName = 'lobyteRunAAPGAnimation_VarSupply_T1000SupA5-35P25Hp0.02';
    fName = sprintf('%s%s_pValueMapsCutOff%7.6f.mat',outputDir, modelName, 0.001);
    if exist(fName, 'file')
        load(fName,'-mat','runsMetricMap', 'runsPValueMap'); 
        runsMetricMapVarSupply = runsMetricMap;
        runsPValueMapVarSupply = runsPValueMap;
        failedIHave = false;
    else
        fprintf('Cannot find file %s\n', fName);
        failedIHave = true;
    end

    
    if ~failedIHave
        
        maxX = 200; maxY = 200; % Assuming map size is 200x200
        sameMap = zeros(maxY, maxX);
        j = 1;
       for x = 1:maxX
           for y = 1:maxY
               if runsPValueMapVarSupply(y,x) > 0 && runsPValueMapVarSupply(y,x) < 0.01 && runsPValueMapConstSupply(y,x) > 0.00 && runsPValueMapConstSupply(y,x) < 0.01
                   samePointsOrdered(j,1:2) = [x,y];
                   sameMap(y,x) = 1;
                   j = j + 1;
               end
           end
       end
       
       samePointsOrdered
       pcolor(sameMap);
    end
end
