function amMultiplex = checkIfMultiplex(StrPlatePath, doChaching, doPrint)

if nargin < 2
    doChaching = false;
end

if nargin < 3
    doPrint = true;
end

persistent CachedStrPlatePath
persistent CachedIsMultiplex

if isempty(CachedStrPlatePath)
    CachedStrPlatePath = cell(0);
end

if isempty(CachedIsMultiplex)
    CachedIsMultiplex = cell(0);
end

if doChaching == false
    amMultiplex = checkIfPlateIsMultiplex(StrPlatePath,doPrint);
else
    
    [isCached, cachedLoc]= ismember(StrPlatePath,CachedStrPlatePath);
    
    if ~isCached
        cachedLoc = length(CachedStrPlatePath) + 1;
        PlateIsMultipex = checkIfPlateIsMultiplex(StrPlatePath,doPrint);
        CachedIsMultiplex{cachedLoc} = PlateIsMultipex;
        CachedStrPlatePath{cachedLoc} = StrPlatePath;
    end
    
    amMultiplex = CachedIsMultiplex{cachedLoc}; % retreive data
    
end
end



function PlateIsMultipex = checkIfPlateIsMultiplex(strPlate,doPrint)

strAlignFolder = fullfile(strPlate,'ALIGNCYCLES');

if isdir(strAlignFolder)
    if doPrint == true
        fprintf('Detected a multiplex project (place an empty file called ignore.multiplex in ALIGNCYCLES folder to ignore) \n');
    end
    
    strExpectedIgnoreFile = fullfile(strAlignFolder,'ignore.multiplex');
    
    shouldBeTreatedAsMultiplex = ~any(fileattrib(strExpectedIgnoreFile));
    
    if shouldBeTreatedAsMultiplex
        PlateIsMultipex = true;
    else
        if doPrint == true
            fprintf('... but treating as a non multiplex project (ignore.multiplex present) \n');
        end
        PlateIsMultipex = false;
    end
    
else
    PlateIsMultipex = false;
end

end