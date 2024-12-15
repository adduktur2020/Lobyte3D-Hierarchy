function [topog, glob, topogReadSuccessfully] = readInitTopography(glob)

    filename = glob.initTopogFilename;
    whos(filename);
    
    if exist(filename)
        topog = load(filename,'-ascii');
        topogDims = size(topog);
        topogReadSuccessfully = 1;

        if topogDims(1) ~= glob.ySize 
            fprintf('Initial toopography y-size is %d points, but model grid defined as %d cells in y-dimension\n', topogDims(1), glob.ySize);
            topog = 0;
            topogReadSuccessfully = 0;
        end

        if topogDims(2) ~= glob.xSize
            fprintf('Initial toopography x-size is %d points, but model grid defined as %d cells in x-dimension\n', topogDims(2), glob.xSize);
            topog = 0;
            topogReadSuccessfully = 0;
        end
    else
        fprintf('Could not find the initial topography file %s\n',  glob.initTopogFilename);
        topog = 0; % because file not read successfully e.g does not exist, file name wrong etc
        topogReadSuccessfully = 0;
    end
end