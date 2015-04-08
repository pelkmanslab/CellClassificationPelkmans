function BFusion_calculateCycleShift_TS(strFolderDistributedJobs,maxShift,SegmentationFileNameTrunk,relativeSegmentationPlate)


%ProjectPath, RelativeSegmentationPath, SegmentationFileNameTrunk, RelativeSegmentationBATCHPath, samplingFactor, maxShift, shiftMethod,site)

% Syntax:
%   calculateCycleShift(ProjectPath, RelativeSegmentationPath, ...
%       SegmentationFileNameTrunk, samplingFactor, maxShift, shiftMethod)
%
% Description:
% CALCULATECYCLESHIFT calculates the relative shift between images, which
% were acquired in different iterative multiplexing cycles, using the last
% image, i.e.from the last cycle, as reference.
% The calculated shift can then be applied to images for measurements
% within a cellprofiler pipeline to ensure that pixels are asigned to the
% same object throughout all cycles (see CP module AlignCycleImage.m).
%
% The calculation is based on efficient subpixel image registration by
% crosscorrelation. The code for this calculation was derived from Matlab
% Central and is based on the following publication:
% Manuel Guizar-Sicairos, Samuel T. Thurman, and James R. Fienup,
% "Efficient subpixel image registration algorithms," Opt. Lett. 33,
% 156-158 (2008).
%
% Important note:
% The function depends on the hierarchical iBrain folder format. Images
% from different multiplexing cycles ('plates') need to be placed in
% seperate TIFF folders within seperate subproject folders. All subproject
% folders of one multiplexing experiment should be placed in one main
% project folder. The folder hierarchy then looks as follows:
%   Project folder
%       Subproject folder cycle 1
%           ALIGNCYCLES folder cycle 1
%           TIFF folder cycle 1
%       ...
%           ...
%           ...
%       Subproject folder cycle n
%           ALIGNCYCLES folder cycle n
%           TIFF folder cycle n
%           SEGMENTATION folder
% The subproject folders as well as the image file names should encode the
% cycle number in ascending order to allow sorting of files according to
% cycles.
%
% Input Arguments:
%   ProjectPath                 Absolute path to project folder.
%   RelativeSegmentationPath    Relative path to folder that contains
%                               segmented images within iBrain folder format
%                               (../PathToSubprojectFolder/SEGMENTATION).
%   SegmentationFileNameTrunk   Filename trunk of segmented images
%                               (FilenameTrunk_D04_T0001F001A01Z01C01.pdf).
%   samplingFactor                 Upsampling factor for image registration.
%   maxShift                    Maximally tolerated shift in pixel.
%   shiftMethod                 Method used to calculate shift (1 or 2).
%
% Authors:
%   Markus Herrmann <markus.herrmann@usz.ch>
%   Yauhen Yakimovich <yauhen.yakimovich@usz.ch>
%
% 2013 Pelkmans Lab

%
% %%% check input
% if ~isnumeric(samplingFactor)
%     samplingFactor = str2num(samplingFactor);
% end
% if ~isnumeric(maxShift)
%     maxShift = str2num(maxShift);
% end
% if ~isnumeric(shiftMethod)
%     shiftMethod = str2num(shiftMethod);
% end
%
% %%% get image filenames and the pathname for each TIFF folder and collect
% %%% both in seperate cell arrays of strings
% [TiffFiles,TiffPaths] = aligncycles.getImages(ProjectPath);
%
% %%% get information on files within each TIFF folder
% fileNum = cellfun(@length,TiffFiles);
% channelId = cell(1,length(TiffFiles));
% channelNum = NaN(1,length(TiffFiles));
% for cycle = 1:length(TiffFiles)
%     channelId{cycle} = unique(cellfun(@check_image_channel,TiffFiles{cycle}));
%     channelNum(cycle) = length(channelId{cycle});
% end
% clear cycle;
% sitesPerCycle = unique(fileNum./channelNum);
% check = numel(sitesPerCycle)==1;
%
% %%% calculate shift of each image from different cycles relative to
% %%% reference image at each site
% % make sure that number of sites is the same over all cycles
% if check==false
%     error('The number of sites has to be the same for all cycles.')
% else
%     fprintf('%s: starting shift calculation ... ',mfilename)
%     % filter image files for nuclear images and use them for registration
%     NucImageIdentifier = '.*(C|w)01.(png|tiff?)';
%     TiffFilesNuc = cellfun(@(x)flatten(regexpi(x,NucImageIdentifier,'match')),TiffFiles,'UniformOutput',false);
%     % calculate shift for each nuclear image at each site
%     yShift = zeros(sitesPerCycle,length(TiffFilesNuc));
%     xShift = zeros(sitesPerCycle,length(TiffFilesNuc));
%     tic
% %     for site = 1:sitesPerCycle % PARALLELISATION
%         refImFilename = fullfile(TiffPaths{end}, TiffFilesNuc{end}{site});
%         for cycle = 1:length(TiffFilesNuc)-1
%             regImFilename = fullfile(TiffPaths{cycle}, TiffFilesNuc{cycle}{site});
%             switch shiftMethod
%                 case 1
%                     [yShift(site,cycle), xShift(site,cycle)] = aligncycles.getimshift(refImFilename,regImFilename,samplingFactor);
%                 case 2
%                     [yShift(site,cycle), xShift(site,cycle)] = aligncycles.getimshift2(refImFilename,regImFilename,samplingFactor);
%
%             end
%         end
%
%
%
%
%     clear site;
%     clear cycle;
%     runtime = toc;


%%% Brutus-adjustment: start
[xShift, yShift, sitesPerCycle, TiffFilesNuc,TiffPaths, channelId] = ...
    importBatchResults(strFolderDistributedJobs);


fileNum = cellfun(@length,TiffFilesNuc);

if strcmp(relativeSegmentationPlate(end),'/')
   relativeSegmentationPlate = relativeSegmentationPlate(1:(end-1)); 
end

RelativeSegmentationBATCHPath = [relativeSegmentationPlate '/BATCH'];
RelativeSegmentationPath = [relativeSegmentationPlate '/SEGMENTATION'];

%%% Brutus-adjustment: end




yShift = round(yShift);
xShift = round(xShift);


% fprintf('done\n')
% fprintf('%s: shift calculation took %d seconds\n',mfilename,runtime)
%
%%% calculate overlap of images at each site
lowerOverlap = zeros(sitesPerCycle,1);
upperOverlap = zeros(sitesPerCycle,1);
rightOverlap = zeros(sitesPerCycle,1);
leftOverlap = zeros(sitesPerCycle,1);
for site = 1:sitesPerCycle
    [lowerOverlap(site,:),upperOverlap(site,:),rightOverlap(site,:),leftOverlap(site,:)] = aligncycles.getimoverlap(yShift(site,:),xShift(site,:));
end

% clear site;

%%% get global overlap
globLowerOverlap = max(lowerOverlap(lowerOverlap<maxShift));
globUpperOverlap = max(upperOverlap(upperOverlap<maxShift));
globRightOverlap = max(rightOverlap(rightOverlap<maxShift));
globLeftOverlap = max(leftOverlap(leftOverlap<maxShift));

%%% get index of sites, where shift exeeds maxShift
index = zeros(size(yShift,1),1);
for cycle = 1:size(yShift,1)
    if or(any(abs(yShift(cycle,:))>maxShift), any(abs(xShift(cycle,:))>maxShift));
        index(cycle,1) = 1;
    end
end
% clear cycle;

%%% get image positions
rowNum = cell(size(fileNum));
colNum = cell(size(fileNum));
siteNum = cell(size(fileNum));
for site = 1:length(TiffFilesNuc)
    [rowNum{site},colNum{site}] = cellfun(@filterimagenamedata,TiffFilesNuc{site});
    siteNum{site} = cellfun(@check_image_position,TiffFilesNuc{site});
end
% clear site;

%%% save information on the relative shift together with image filename
%%% and image position into descriptor variable (struct) as json
for cycle = 1:size(xShift,2) % create seperate file for each subproject
    % create descriptor variable
    shiftDescriptor = struct();
    shiftDescriptor.fileName = TiffFilesNuc{cycle}';
    shiftDescriptor.SegmentationDirectory = RelativeSegmentationPath;
    shiftDescriptor.SegmentationFileNameTrunk = SegmentationFileNameTrunk;
    shiftDescriptor.SegmentationBATCHDirectory = RelativeSegmentationBATCHPath;
    shiftDescriptor.cycleNum = cycle;
    shiftDescriptor.channelId = channelId{cycle};
    shiftDescriptor.siteNum = siteNum{cycle}';
    shiftDescriptor.wellRowNum = rowNum{cycle}';
    shiftDescriptor.wellColNum = colNum{cycle}';
    shiftDescriptor.yShift = yShift(:,cycle);
    shiftDescriptor.xShift = xShift(:,cycle);
    shiftDescriptor.lowerOverlap = globLowerOverlap;
    shiftDescriptor.upperOverlap = globUpperOverlap;
    shiftDescriptor.rightOverlap = globRightOverlap;
    shiftDescriptor.leftOverlap = globLeftOverlap;
    shiftDescriptor.maxShift = maxShift;
    shiftDescriptor.noShiftIndex = index;
    shiftDescriptor.noShiftCount = sum(index);
    % define output path
    AlignCyclesPath = strrep(TiffPaths{cycle},'TIFF','ALIGNCYCLES');
    AlignCyclesPath = nnpc(AlignCyclesPath);  % Adjustment: so that fusion works locally
    % create output path if it doesn't exist
    if ~isdir(AlignCyclesPath)
        mkdir(AlignCyclesPath)
    end
    % define output filename
    shiftDescriptorFilename = fullfile(AlignCyclesPath, 'shiftDescriptor.json');
    % save json file
    string.write(shiftDescriptorFilename, savejson('', shiftDescriptor));
end
% clear cycle;
end

function [xShift, yShift, sitesPerCycle, TiffFilesNuc,TiffPaths, channelId] = importBatchResults(strFolderDistributedJobs)

strIndividualJobFiles = getFilesAndDirectories(strFolderDistributedJobs,'AlignJob_.*.mat');

fieldsToLoadAndSynchronize = {'samplingFactor','sitesPerCycle','TiffFilesNuc','TiffPaths','channelId'};
fieldsToLoadAndRebuild = {'xShift','yShift'};

% Reconstitute full results
for j=1:length(strIndividualJobFiles)
    CurrFile = fullfile(strFolderDistributedJobs,strIndividualJobFiles{j});
    
    CurrentResults = loadd(CurrFile);
    
    % Meta data handling and checking
    
    if j == 1     % initialization according to first job
        
        for jFieldsMeta = 1:length(fieldsToLoadAndSynchronize)
            CurrField = fieldsToLoadAndSynchronize{jFieldsMeta};
            Agg.(CurrField) = CurrentResults.MetaToCheck.(CurrField) ;
        end
        
        for jFieldsData = 1:length(fieldsToLoadAndRebuild)
            CurrField = fieldsToLoadAndRebuild{jFieldsData};
            Agg.(CurrField) = NaN(size(CurrentResults.(CurrField)));
        end
        
        amountOfJobs = size(Agg.xShift,1);  % take a measurement which should always be present
        hasBeenImported = false(amountOfJobs,1);
        
    else    % check for consistency of other jobs: e.g.: exclude that individual nodes had different sorting
        
        for jFieldsMeta = 1:length(fieldsToLoadAndSynchronize)
            CurrField = fieldsToLoadAndSynchronize{jFieldsMeta};
            CurrReferenceMeta = Agg.(CurrField);
            CurrImportedMeta = CurrentResults.MetaToCheck.(CurrField);
            
            if ~isequal(CurrReferenceMeta,CurrImportedMeta)
                error(fprintf('%s differs among jobs \n', CurrField));
            end
            
        end
    end
    
    % Check if individual jobs are not overlapping (which could be possible
    % if jobs had accidentaly been resubmitted with varying amount of
    % images)
    
    putativeImageSitesToProcess =  CurrentResults.sitesToProcess;
    if any(hasBeenImported(putativeImageSitesToProcess))
        error('Some output seems overlapping');
    else
        SitesToProcess = putativeImageSitesToProcess;
        hasBeenImported(SitesToProcess) = true;
    end
    
    
    for jFieldsData = 1:length(fieldsToLoadAndRebuild)
        CurrField = fieldsToLoadAndRebuild{jFieldsData};
        Agg.(CurrField)(SitesToProcess,:) = CurrentResults.(CurrField)(SitesToProcess,:);
    end
    
end

% Check if results are complete
if any(~hasBeenImported)
    error('Some data sets could not be found')
end

% Return data of interest
xShift = Agg.xShift;
yShift = Agg.yShift;
sitesPerCycle = Agg.sitesPerCycle;
TiffFilesNuc = Agg.TiffFilesNuc;
channelId = Agg.channelId;
TiffPaths  = Agg.TiffPaths;
end