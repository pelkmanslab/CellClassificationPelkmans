function shiftDescriptor = loadShiftDescriptor(strPlate)

persistent CachedStrAlignCyclesDir
persistent CachedShift

if isempty(CachedStrAlignCyclesDir)
    CachedStrAlignCyclesDir = cell(0);
end

if isempty(CachedShift)
    CachedShift = cell(0);
end


strAlignCyclesDir = fullfile(strPlate,'ALIGNCYCLES');
[isCached, cachedLoc]= ismember(strAlignCyclesDir,CachedStrAlignCyclesDir);

if ~isCached
    cachedLoc = length(CachedStrAlignCyclesDir) + 1;
    
    % define path to json file
    jsonDescriptorFile = fullfile(strAlignCyclesDir,'shiftDescriptor.json');
    % load json file and save its content to the handles
    
    SDescriptor = loadjson(jsonDescriptorFile);
    
    % Create additional settings for fast indexing (metainformation about
    % site);
    SDescriptor = addSiteMeta(SDescriptor);
    
    CachedShift{cachedLoc} = SDescriptor;
    
    
%     % Update such that in absence of shift: not nan, but 0 shift
%     f = isnan(CachedShift{cachedLoc}.xShift);
%     CachedShift{cachedLoc}.xShift(f) = 0;
%     
%     f = isnan(CachedShift{cachedLoc}.yShift);
%     CachedShift{cachedLoc}.yShift(f) = 0;
end

shiftDescriptor = CachedShift{cachedLoc};
end

function descriptor = addSiteMeta(descriptor)

cellNames = cellstr(descriptor.fileName);

SiteRowColumnTimepoint = cellfun(@(x) mcyc.getSiteRowColumnTimepoint(x), cellNames, 'UniformOutput',false);
SiteRowColumnTimepoint = cell2mat(SiteRowColumnTimepoint);

descriptor.SiteRowColumnTimepoint = SiteRowColumnTimepoint;

end