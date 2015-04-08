function objectIndex = grabColumnIndex(matImage, objectName)
%GRABCOLUMNINDEX Get matrix column index from 'features' cell array

cellObjectCountFeatures = matImage.ObjectCountFeatures;

% [TS150408: removed the following block since it appears quite dangerous,
% e.g.: if no objects (of those specified in  "objectName") are present or
% if index is reused (and by chance on first site e.g.: "nuclei" and
% "spots" are same ] 
%
% matImageObjectCount = cat(1, matImage.ObjectCount{:});
% if size(unique(matImageObjectCount','rows'),1)==1
%     % this means that all object count columns are equal, so it doesn't
%     % matter which one we take  
%     objectIndex = 1;
%     return
% end

%  otherwise, look for colum index containing object names ("Nuclei"), take that
%  column
objectIndex = find(cellfun(@(name) strcmp(name, objectName), cellObjectCountFeatures), 1, 'first');

% [TS150408: note that one of our repositories - dep/master - has
% implementation of upper line, which is slightly different and less 
% stringent, namely:
% objectIndex = find(~cellfun(@isempty,strfind(cellObjectCountFeatures, objectName)), 1 ,'first'); 
% [TS150408 -end]

end