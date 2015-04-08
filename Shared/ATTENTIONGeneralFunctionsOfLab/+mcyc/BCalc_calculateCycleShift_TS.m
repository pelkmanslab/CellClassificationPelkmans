function BCalc_calculateCycleShift_TS(ProjectPath, samplingFactor, shiftMethod,firstSite,lastSite)
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


%%% Check inputs

if ischar(firstSite)
    firstSite = str2num(firstSite); %#ok<*ST2NM>
end

if ischar(lastSite)
    lastSite = str2num(lastSite); 
end

if ~isnumeric(samplingFactor)
    samplingFactor = str2num(samplingFactor);
end

% if ~isnumeric(maxShift)
%     maxShift = str2num(maxShift);
% end

if ~isnumeric(shiftMethod)
    shiftMethod = str2num(shiftMethod);
end


%%% Check / intialize current job
sitesToProcess = firstSite:lastSite;
strOutputFolder = fullfile(nnpc(ProjectPath),'RegistrationSetup'); % note: name also hardcoded in .getImages
strOutputBaseName = sprintf('AlignJob_%06d_%06d.mat',firstSite,lastSite);
strOutputFileName = fullfile(strOutputFolder,strOutputBaseName);
ensurePresenceOfDirectory(strOutputFolder)

if any(fileattrib(strOutputFileName))
    error('Output file of job already present');
end



%%% get image filenames and the pathname for each TIFF folder and collect
%%% both in seperate cell arrays of strings
[TiffFiles,TiffPaths] = aligncycles.getImages(ProjectPath);

%%% get information on files within each TIFF folder
fileNum = cellfun(@length,TiffFiles);
channelId = cell(1,length(TiffFiles));
channelNum = NaN(1,length(TiffFiles));
for cycle = 1:length(TiffFiles)
    channelId{cycle} = unique(cellfun(@check_image_channel,TiffFiles{cycle}));
    channelNum(cycle) = length(channelId{cycle});
end
clear cycle;
sitesPerCycle = unique(fileNum./channelNum);
check = numel(sitesPerCycle)==1;

%%% calculate shift of each image from different cycles relative to
%%% reference image at each site
% make sure that number of sites is the same over all cycles
if check==false
    error('The number of sites has to be the same for all cycles.')
else
    fprintf('%s: starting shift calculation ... ',mfilename)
    % filter image files for nuclear images and use them for registration
    NucImageIdentifier = '.*(C|w)01.(png|tiff?)';
    TiffFilesNuc = cellfun(@(x)flatten(regexpi(x,NucImageIdentifier,'match')),TiffFiles,'UniformOutput',false);
    % calculate shift for each nuclear image at each site
        
    yShift = nan(sitesPerCycle,length(TiffFilesNuc));  
    xShift = nan(sitesPerCycle,length(TiffFilesNuc));
        
    tic
    
    for site = sitesToProcess(1):sitesToProcess(end) % PARALLELISATION
        refImFilename = fullfile(TiffPaths{end}, TiffFilesNuc{end}{site});
        
        fprintf('Processing site %d \n' , site);
        
        
        for cycle = 1:length(TiffFilesNuc)-1
            regImFilename = fullfile(TiffPaths{cycle}, TiffFilesNuc{cycle}{site});
            switch shiftMethod
                case 1
                    [yShift(site,cycle), xShift(site,cycle)] = aligncycles.getimshift(refImFilename,regImFilename,samplingFactor);
                case 2
                    [yShift(site,cycle), xShift(site,cycle)] = aligncycles.getimshift2(refImFilename,regImFilename,samplingFactor);
                    
            end
        end
    end
    
   
    JobResults.sitesToProcess = sitesToProcess;
    JobResults.xShift = xShift;
    JobResults.yShift = yShift;
    JobResults.MetaToCheck.refImFilename = refImFilename;
    JobResults.MetaToCheck.regImFilename = regImFilename;
    JobResults.MetaToCheck.samplingFactor = samplingFactor;
    JobResults.MetaToCheck.sitesPerCycle = sitesPerCycle;
    JobResults.MetaToCheck.TiffFilesNuc = TiffFilesNuc;
    JobResults.MetaToCheck.TiffPaths = TiffPaths;
    JobResults.MetaToCheck.channelId = channelId; %#ok<STRNU>
    
    save(strOutputFileName,'JobResults');
    
end

