function copyUnchangedParentMeasurements(strNewBatch,strParentBatch,doOverwrite)

if ischar(doOverwrite)
    doOverwrite = str2num(doOverwrite);
end


RefFilters = {...
    '^Measurements_Image.*';
};




for j=1:length(RefFilters)
    
    strMeasurementFilter = RefFilters{j};
    cellMeasurmentFilesInParent = getFilesAndDirectories(strParentBatch,strMeasurementFilter);
    cellMeasurmentFilesInNew = getFilesAndDirectories(strNewBatch,strMeasurementFilter);
    
    if (doOverwrite == true) || isempty(cellMeasurmentFilesInNew);
        MeasurementsToConsider = cellMeasurmentFilesInParent;
    else
        f = ~ismember(cellMeasurmentFilesInParent,cellMeasurmentFilesInNew);
        MeasurementsToConsider = cellMeasurmentFilesInParent(f);
    end
    
    if ~isempty(MeasurementsToConsider)
        for fi = j:length(MeasurementsToConsider)
            CurrMeasurement = MeasurementsToConsider{fi};
            fprintf('Processing %s \n', CurrMeasurement);
            
            templateFile = fullfile(strParentBatch, CurrMeasurement);
            targetFile = fullfile(strNewBatch, CurrMeasurement);
            copyfile(templateFile,targetFile,'f');
        end
    end
    
end

end