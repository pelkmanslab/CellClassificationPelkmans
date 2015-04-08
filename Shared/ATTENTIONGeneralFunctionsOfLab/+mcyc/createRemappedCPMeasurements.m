function createRemappedCPMeasurements(strNewBatch,strOrigBatch,strParentBatch,strMeasurementFilter,doOverwrite)

% (strOrigBatch,strNewBatch, strParentBatch, doOverwrite)
% strOrigBatch = 'O:\Data\Users\RNAFish\140417-BAC-PioneerSet-MultiScan_LN011\BAC-PioneerSet-GFP-cycle1\BATCH';
% strNewBatch = 'O:\Data\Users\RNAFish\140417-BAC-PioneerSet-MultiScan_LN011\BAC-PioneerSet-GFP-cycle1-mapped2\BATCH';
% strParentBatch = 'O:\Data\Users\RNAFish\140417-BAC-PioneerSet-MultiScan_LN005\BAC-PioneerSet-GFP-cycle2\BATCH\';
% doOverwrite = false;
% strMeasurementFilter = '^Measurements_.*';



strOrigIDRef = fullfile(strOrigBatch, 'Measurements_Nuclei_UnshiftedObjectId.mat');

if ischar(doOverwrite)
    doOverwrite = str2num(doOverwrite);
end

ensurePresenceOfDirectory(strNewBatch);
strOrigBatch = nnpc(strOrigBatch);
strNewBatch = nnpc(strNewBatch);
if strcmp(strOrigBatch, strNewBatch)
    error('Must use different folders');
end

cellMeasurmentFilesInOrig = getFilesAndDirectories(strOrigBatch,strMeasurementFilter);
cellMeasurmentFilesInNew = getFilesAndDirectories(strNewBatch,strMeasurementFilter);

if (doOverwrite == true) || isempty(cellMeasurmentFilesInNew);
    MeasurementsToConsider = cellMeasurmentFilesInOrig;
else
    f = ~ismember(cellMeasurmentFilesInOrig,cellMeasurmentFilesInNew);
    MeasurementsToConsider = cellMeasurmentFilesInOrig(f);
end

for j=1:length(MeasurementsToConsider)
    CurrMeasurementFile = MeasurementsToConsider{j};
    OutFileName = fullfile(strNewBatch, CurrMeasurementFile);
    
    fprintf('Currently processing %s \n', CurrMeasurementFile);
    
%     try
        [CurrObject, CurrMeasurement] = getObjectAndMeasurementName(CurrMeasurementFile);
        [numOfObjects, numSites, posInParent, countDiffers_InCognateOrig] = getInfoForInitializationOfNewMeasurement(strOrigBatch,strParentBatch,CurrObject);
        
        
        strMeasurementFile = fullfile(strOrigBatch, CurrMeasurementFile);
        
        [OriginalData, OriginalLabel, maxColumns] = importMeasurement(strMeasurementFile);
        ParentID = importMeasurement(strOrigIDRef);
        
        
        newMeasurement = cell(1,numSites);
        
        for jS = 1:numSites
            CurrParentPos = posInParent(jS);
            CurrNumOfObjects = numOfObjects(jS);
            countWrong  = countDiffers_InCognateOrig(jS);
            CurrParentID = ParentID{jS};
            CurrOrigData = OriginalData{jS};
            
            resortedResults = NaN(CurrNumOfObjects, maxColumns);
            if (countWrong == false) && ~isempty(CurrOrigData) && ~any(isnan(CurrParentID))
                if ~isequal(CurrOrigData, [0 0])
                    resortedResults(CurrParentID,:) = CurrOrigData;
                end
            end
            
            if (~isempty(CurrOrigData)) && (size(CurrOrigData,1) == 1) && (CurrNumOfObjects ==0)
                if ~any(CurrOrigData ~= 0)
                    resortedResults = zeros(1, maxColumns);
                end
            end
            
            newMeasurement{CurrParentPos} = resortedResults;
            
        end
        
        handles = struct;
        handles.Measurements.(CurrObject).(CurrMeasurement) = newMeasurement;
        handles.Measurements.(CurrObject).([CurrMeasurement 'Features']) = OriginalLabel;
        
        save(OutFileName, 'handles');
        %
%     catch
%         
%         [outDir, outBase] = fileparts(OutFileName);
%         failedConversion = true;
%         save(fullfile(outDir,[outBase '.failed']), 'failedConversion');
%         
%     end
end




end

function [CurrObject, CurrMeasurement] = getObjectAndMeasurementName(CurrMeasurementFile)
FoundSlash = strfind(CurrMeasurementFile,'_');
FoundDot = strfind(CurrMeasurementFile,'.');

CurrObject = [];
CurrMeasurement = [];

if length(FoundSlash) == 2
    CurrObject =  CurrMeasurementFile((FoundSlash(1)+1) : (FoundSlash(2)-1));
    CurrMeasurement =  CurrMeasurementFile((FoundSlash(2)+1) : (FoundDot(1)-1));
elseif length(FoundSlash) > 2
    CurrObject =  CurrMeasurementFile((FoundSlash(1)+1) : (FoundSlash(2)-1));
%     if length(FoundSlash) == 2
        CurrMeasurement =  CurrMeasurementFile((FoundSlash(2)+1) : (FoundDot(1)-1));
%     else
%         CurrMeasurement =  CurrMeasurementFile((FoundSlash(2)+1) : (FoundSlash(3)-1));
%     end
end
end

function [numOfObjects, numSites, posInParent, countDiffers_InCognateOrig] = getInfoForInitializationOfNewMeasurement(strOrigBatch,strParentBatch,CurrObject)

strOrigObjectCounts = fullfile(strOrigBatch,'Measurements_Image_ObjectCount.mat');
strParentObjectCounts = fullfile(strParentBatch,'Measurements_Image_ObjectCount.mat');

strOrigImageNames = fullfile(strOrigBatch,'Measurements_Image_FileNames.mat');
strParentImageNames = fullfile(strParentBatch,'Measurements_Image_FileNames.mat');

RCST_Orig = getIDperSite(strOrigImageNames);
RCST_Parent = getIDperSite(strParentImageNames);


[isFound, posInParent] = ismember(RCST_Orig,RCST_Parent,'rows');
if any(~isFound) || (size(RCST_Orig,1) ~= size(RCST_Parent,1))
    error('parent plate has different sites');
end

[~, ~, countDiffers_Orig] = getObjectCounts(strOrigObjectCounts, CurrObject);
[~, numCurrObject_Parent] = getObjectCounts(strParentObjectCounts,CurrObject);

numOfObjects = numCurrObject_Parent;
numSites = size(RCST_Orig,1);
countDiffers_InCognateOrig = countDiffers_Orig(posInParent);

end

function RCST = getIDperSite(strOrigImageNames)

OrigImageNames = loadd(strOrigImageNames);
OrigImageNames = cellfun(@(x) x{1}, OrigImageNames.Measurements.Image.FileNames,'UniformOutput', false);
[intRow, intColumn, intImagePosition, intTimepoint] = cellfun(@(x) MetaFromImageName(x), OrigImageNames,'UniformOutput',false);
RCST = cell2mat([intRow' intColumn' intImagePosition' intTimepoint']);
end

function [numCurrNuclei, numCurrObject, countDiffers] = getObjectCounts(strOrigObjectCounts, CurrObject)

if strcmp(CurrObject,'SVM')
   CurrObject = 'Nuclei'; 
end

ImpObjectCount = loadd(strOrigObjectCounts);
ixNuclei = ismember(ImpObjectCount.Measurements.Image.ObjectCountFeatures,{'Nuclei'});
ixCurrObject = ismember(ImpObjectCount.Measurements.Image.ObjectCountFeatures,{CurrObject});
funObjects = @(y) cell2mat(cellfun(@(x) x(y), ImpObjectCount.Measurements.Image.ObjectCount, 'UniformOutput', false));
numCurrNuclei = funObjects(ixNuclei);
numCurrObject = funObjects(ixCurrObject);

countDiffers = numCurrNuclei ~= numCurrObject;
end


function [ImpData, Label, maxColumns] = importMeasurement(strMeasurementFile)

[~, FileBase, FileExtension]  = fileparts(strMeasurementFile);
FileName = [FileBase FileExtension];

[CurrObject, CurrMeasurement] = getObjectAndMeasurementName(FileName);


ImpData = loadd(strMeasurementFile);
if isfield(ImpData, 'Measurements')
    ImpData = ImpData.Measurements;
end

if isfield(ImpData.(CurrObject),[CurrMeasurement '_Features'])
    Label = ImpData.(CurrObject).([CurrMeasurement '_Features']);
else
    Label = [];
end
ImpData = ImpData.(CurrObject).(CurrMeasurement);


numColumns = cell2mat(cellfun(@(x) size(x,2), ImpData, 'UniformOutput', false));
maxColumns = max(numColumns);

end
