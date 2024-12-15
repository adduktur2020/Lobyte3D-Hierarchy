function checkSavedLobyteModel

    filePath = 'E:/LobyteOutput/signalBumpOutputV66/'; % look here for the Lobyte and post-processing output files
    fileName = strcat(filePath, 'lobyteRunSignalBumpRunsSupA25.0-25.0P20.mat');
    load(fileName, 'glob', 'depos', 'trans', 'topog');

    thicknessesMap = zeros(glob.ySize, glob.xSize, glob.totalIterations);
    sectLenMap = zeros(glob.ySize, glob.xSize);
    for x =1:glob.xSize
        for y = 1:glob.ySize
            oneSect = nonzeros(depos.transThickness(y,x,:));
            sectLenMap(y,x) = length(oneSect);
            thicknessesMap(y,x) = sum(oneSect);
        end
    end
    
    nonZeroSectCount = sum(sum(sectLenMap > 0));
    fprintf('%d > zero length sections\n', nonZeroSectCount);
    
    figure;
    pcolor(sectLenMap);
    title(fileName);
    grid off;
    colorbar;
    
    
    fileName = strcat(filePath, 'lobyteRunSignalBumpRunsSupA25.0-25.0P70.mat');
    load(fileName, 'glob', 'depos', 'trans', 'topog');

    thicknessesMap = zeros(glob.ySize, glob.xSize, glob.totalIterations);
    sectLenMap = zeros(glob.ySize, glob.xSize);
    for x =1:glob.xSize
        for y = 1:glob.ySize
            oneSect = nonzeros(depos.transThickness(y,x,:));
            sectLenMap(y,x) = length(oneSect);
            thicknessesMap(y,x) = sum(oneSect);
        end
    end
    
    nonZeroSectCount = sum(sum(sectLenMap > 0));
    fprintf('%d > zero length sections\n', nonZeroSectCount);
    
    figure;
    pcolor(sectLenMap);
    title(fileName);
    grid off;
    colorbar;
end