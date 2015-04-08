function [SiteSpecificShiftDescriptor, posInFullDescriptor] = getShiftForSingleSite(ShiftDescriptor,ReferenceImage)

if ~isfield(ShiftDescriptor,'SiteRowColumnTimepoint')
    error('SiteRowColumnTimepoint field is absent')
else
    DescriptorSRCT = ShiftDescriptor.SiteRowColumnTimepoint;
end

RefSRCT = mcyc.getSiteRowColumnTimepoint(ReferenceImage);

[isPresent, posInFullDescriptor] = ismember(RefSRCT,DescriptorSRCT,'rows');

if isPresent == false
   error('Did not find corresponding entry in ShiftDescriptor')
end


FieldsToFullyImport = {'SegmentationDirectory';'SegmentationFileNameTrunk';'SegmentationBATCHDirectory';...
    'cycleNum';'maxShift'};

FieldsToSelectivelyImport = {'fileName','yShift','xShift','noShiftIndex'};

SiteSpecificShiftDescriptor = struct();

for j=1:length(FieldsToFullyImport)
   SiteSpecificShiftDescriptor.(FieldsToFullyImport{j}) = ShiftDescriptor.(FieldsToFullyImport{j});    
end

for j=1:length(FieldsToSelectivelyImport)
   SiteSpecificShiftDescriptor.(FieldsToSelectivelyImport{j}) = ShiftDescriptor.(FieldsToSelectivelyImport{j})(posInFullDescriptor,:);    
end

end