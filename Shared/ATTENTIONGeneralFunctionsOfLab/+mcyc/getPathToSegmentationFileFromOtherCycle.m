function [path_cells_segmentation, considerLoadingSegmentation] = getPathToSegmentationFileFromOtherCycle(shiftDescriptor,strOrigImageName,currentPlateFolder,SegmentationOfInterest)
% gets the full path corresponding to the segmentation image saved in
% another cycle

% format the segmentation file name
matDotIndices=strfind(strOrigImageName,'.');
if ~isempty(matDotIndices)
    raw_name_withoutEnding = strOrigImageName(1,1:matDotIndices(end)-1);
else
    raw_name_withoutEnding = strOrigImageName;
end

% ensure that there is no tailing file separator
if strcmp(currentPlateFolder(end),filesep);
   currentPlateFolder = currentPlateFolder(1:(end-1)); 
end

% get segmentation filename trunk from handles and modify filename accordingly
strSegmentationFileNameTrunk = shiftDescriptor.SegmentationFileNameTrunk;
% built absolute SEGMENTATION path from relative path stored in handles
strSegmentationDir = [currentPlateFolder, filesep, shiftDescriptor.SegmentationDirectory];

% get information about segmentation files
[segFileNameInfo, considerLoadingSegmentation] = mcyc.getReferenceSegmentationFilename(strSegmentationDir,SegmentationOfInterest);

% get correct Site
currentImageSite = flatten(regexp(raw_name_withoutEnding,'.+T\d{04}F(\d{03})L.*','tokens'));
currentImageSite = str2num(currentImageSite{1}); %#ok<ST2NM>

strSegmentationFilename = [regexprep(raw_name_withoutEnding,'.+(_\w{1}\d{2}_)T\d{04}F\d{03}L\d{02}A\d{02}Z\d{02}C\d{02}',...
    sprintf('%s$1T%.4dF%.3dL%.2dA%.2dZ%.2dC%.2d',strSegmentationFileNameTrunk,segFileNameInfo{1},currentImageSite,segFileNameInfo{3},segFileNameInfo{4},...
    segFileNameInfo{5},segFileNameInfo{6})),...
    SegmentationOfInterest,'.png'];

% full path to segmentation image
path_cells_segmentation = fullfile(strSegmentationDir,strSegmentationFilename);

end


