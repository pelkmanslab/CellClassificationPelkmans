function objectIndex = grabColumnIndex(matImage, objectName)
%GRABCOLUMNINDEX Get matrix column index from 'features' cell array

matImageObjectCount = cat(1, matImage.ObjectCount{:});
cellObjectCountFeatures = matImage.ObjectCountFeatures;

if size(unique(matImageObjectCount','rows'),1)==1
    % this means that all object count columns are equal, so it doesn't
    % matter which one we take
    objectIndex = 1;
    return
end

%  otherwise, look for colum index containing object names ("Nuclei"), take that
%  column
objectIndex = find(cellfun(@(name) strcmp(name, objectName), cellObjectCountFeatures), 1, 'first');

end