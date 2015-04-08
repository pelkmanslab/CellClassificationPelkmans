function [segFileNameInfo, hasSegmentation] = getReferenceSegmentationFilename(strSegmentationDir,currSegmentation)

% Unique ID for dataset: plate and object name (in case that classify_gui was used for
% multiple plates / projects)
PlateObjectReference = [strSegmentationDir currSegmentation];

persistent CachedSegmentationStats;
persistent OrigCurrSegmentationOfCached;

if isempty(CachedSegmentationStats)
    CachedSegmentationStats = cell(0);
end

if isempty(OrigCurrSegmentationOfCached)
    OrigCurrSegmentationOfCached = cell(0);
end

[isCached, cachedLoc]= ismember(PlateObjectReference,OrigCurrSegmentationOfCached);

if ~isCached   % load into cache, if absent there
    cachedLoc = length(CachedSegmentationStats) + 1;
    
    CurrObject = strrep(currSegmentation,'_Segmented','');
    fprintf('Initializing Segmentation for multiplex project (%s) ...', CurrObject)
    
    % get example name of example file
    segOrigFileName = getFilesAndDirectories(fullfile(strSegmentationDir), currSegmentation);
    
    if ~isempty(segOrigFileName)
        
        segOrigFileName = segOrigFileName{1};
        segFileNameInfo = flatten(regexp(segOrigFileName,'.+T(\d{04})F(\d{03})L(\d{02})A(\d{02})Z(\d{02})C(\d{02}).*','tokens'));
        segFileNameInfo = cellfun(@str2num,segFileNameInfo,'uniformoutput',false);
        
        CachedSegmentationStats{cachedLoc}.FileNameInfo = segFileNameInfo;
        CachedSegmentationStats{cachedLoc}.SegmentationPresent = true;
        
        OrigCurrSegmentationOfCached{cachedLoc} = PlateObjectReference;
        
        
    else
        CachedSegmentationStats{cachedLoc}.FileNameInfo = [];
        CachedSegmentationStats{cachedLoc}.SegmentationPresent = false;
    end
    
    fprintf('done \n')
    
end

segFileNameInfo = CachedSegmentationStats{cachedLoc}.FileNameInfo;
hasSegmentation = CachedSegmentationStats{cachedLoc}.SegmentationPresent;

end