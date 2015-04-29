function strBasicdataFile = getBasicdataForClassifyGui(strInputPath)

% [BS] this function is pointed by a user to a directory, and tries to find
% the corresponding BASICDATA(_*).mat file that classify_gui should work
% on. 
%
% this can right now either be: 
% 1. a project directory, 
% 2. a plate directory, or 
% 3. a BATCH directory.

strBasicdataFile = [];

if nargin==0
    strInputPath = '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\50K_final_reanalysis\SV40_MZ';
%     strInputPath = '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\50K_final_reanalysis\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1_CP071-1aa';
%     strInputPath = '\\nas-biol-imsb-1.d.ethz.ch\share-3-$\Data\Users\50K_final_reanalysis\SV40_MZ\070111_SV40_MZ_MZ_P1_1_1_CP071-1aa\BATCH';
end


% check if this points to a project directory
if fileattrib(fullfile(strInputPath,'BASICDATA.mat'))
   strBasicdataFile =  fullfile(strInputPath,'BASICDATA.mat');
   return
end

% we're pointed to a BATCH directory, get the BASICDATA_*.mat from there
if strcmp(getlastdir(strInputPath),'BATCH')
    listing = dir([strInputPath,filesep,'BASICDATA_*.mat']);
    if ~isempty(listing)
        strBasicdataFile =  fullfile(strInputPath,listing(1).name);
    end
end

% there's a BATCH directory inside the current directory, get the
% BASICDATA_*.mat from there 
if fileattrib(fullfile(strInputPath,'BATCH'))
    listing = dir([fullfile(strInputPath,'BATCH'),filesep,'BASICDATA_*.mat']);
    if ~isempty(listing)
        strBasicdataFile =  fullfile(strInputPath,'BATCH',listing(1).name);
    end
end

end