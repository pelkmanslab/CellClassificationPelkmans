function varargout = classify_gui(varargin)
% CLASSIFY_GUI M-file for classify_gui.fig
%      CLASSIFY_GUI, by itself, creates a new CLASSIFY_GUI or raises the existing
%      singleton*.
%
%      H = CLASSIFY_GUI returns the handle to a new CLASSIFY_GUI or the handle to
%      the existing singleton*.
%
%      CLASSIFY_GUI('CALLBACK',hObject,eventData,handles,...) calls the
%      local
%      function named CALLBACK in CLASSIFY_GUI.M with the given input arguments.
%
%      CLASSIFY_GUI('Property','Value',...) creates a new CLASSIFY_GUI
%      or raises the
%      existing singleton*.  Starting from the left, property value
%      pairs are
%      applied to th?e GUI before classify_gui_OpeningFunction gets
%      called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classify_gui_OpeningFcn via varargin.
%
%      When a classify.local.json file is present in the project folder,
%      the settings specified there will be used (e.g.: custom channel
%      names used in cellprofiler). See
%      ClassifyGui.writeExampleSettingsFile for example code on how to make
%      such a settings file.
%
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only
%      one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classify_gui

% Last Modified by GUIDE v2.5 08-Apr-2015 13:07:57

% Check for toolbox dependencies
checkDependencies()

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @classify_gui_OpeningFcn, ...
    'gui_OutputFcn',  @classify_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end

% --- Executes just before classify_gui is made visible.
function classify_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to classify_gui (see VARARGIN)

% Choose default command line output for classify_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%set(handles.axes1,'XLim', [0 1440], 'YLim', [0 936]);

initialize();

% UIWAIT makes classify_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = classify_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --------------------------------------------------------------------
function file_load_Callback(hObject, eventdata, handles)
% hObject    handle to file_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [Berend Snijder] get the default last used path from here
strPathFile = fullfile(matlabroot,'classify_gui_path.mat');
strLastSavedPath = '';
if fileattrib(strPathFile)
    try
        load(strPathFile,'strLastSavedPath')
        if ~ischar(strLastSavedPath)
            strLastSavedPath = '';
        end
    catch
        % failed to load last used path
    end
end

[FileName,PathName,FilterIndex] = uigetfile(fullfile(strLastSavedPath,'*.mat'),'Load classification');

% store the last used path in the pref file
try
    if ~isempty(PathName) & ~(PathName==0)
        strLastSavedPath = PathName;
        save(strPathFile,'strLastSavedPath')
    end
catch
    % failed to save classify_gui_path.mat
end


if ~isempty(PathName) & ~(PathName==0)
    disp('Loading file...')
    load([PathName FileName]);
    
    try
        handles.settings.rescaleRed=savedata.rescaleRed;
        handles.settings.rescaleGreen=savedata.rescaleGreen;
        handles.settings.rescaleBlue=savedata.rescaleBlue;
        handles.settings.rescaleFarRed=savedata.rescaleFarRed;
        handles.settings.rescaleRed_level=savedata.rescaleRed_level;
        handles.settings.rescaleGreen_level=savedata.rescaleGreen_level;
        handles.settings.rescaleBlue_level=savedata.rescaleBlue_level;
        handles.settings.rescaleFarRed_level=savedata.rescaleFarRed_level;
    catch
        handles.settings.rescaleRed=0;
        handles.settings.rescaleGreen=0;
        handles.settings.rescaleBlue=0;
        handles.settings.rescaleFarRed=0;
        handles.settings.rescaleRed_level=1;
        handles.settings.rescaleGreen_level=1;
        handles.settings.rescaleBlue_level=1;
        handles.settings.rescaleFarRed_level=1;
    end
    
    try
        handles.settings.nucleusClassNumber = savedata.nucleusClassNumber;
        handles.settings.classNames=savedata.classNames;
        
        % [BS] if these paths are existing, use those... otherwise, use the
        % location of the SVM file :)
        if fileattrib(npc(savedata.data_path))
            handles.settings.data_path=npc(savedata.data_path);
        else
            disp('using SVM location as data path)')
            handles.settings.data_path=PathName;
        end
        
        if fileattrib(npc(savedata.image_path))
            handles.settings.image_path=npc(savedata.image_path);
        else
            disp('using SVM location as image path)')
            handles.settings.image_path=PathName;
        end
        
        handles.settings.image_nr=1;%savedata.image_nr;
        handles.settings.plate_nr=savedata.plate_nr;
        handles.settings.showRedChannel=savedata.showRedChannel;
        handles.settings.showGreenChannel=savedata.showGreenChannel;
        handles.settings.showBlueChannel=savedata.showBlueChannel;
        
        if isfield(savedata,'showFarRedChannel')    % not saved in original classify_gui: add check for backward compatibility
            handles.settings.showFarRedChannel = savedata.showFarRedChannel;            
        end
        
        handles.settings.platenames=savedata.platenames;
        handles.settings.numberOfClasses = length(handles.settings.classNames);
        handles.settings.showClassified = savedata.showClassified;
        handles.settings.plate_in_memory = 0; %the measurement data of any plate is not stored (too big)
        
        handles.settings.Measurement_names=savedata.Measurement_names;
        handles.settings.classifySetup=savedata.classifySetup;
        handles.settings.classifySetupHandlers=savedata.classifySetupHandlers;
    catch
        disp('Savefile does not contain all the necessary fields (Maybe an old version?)')
    end
    
    try
        handles.settings.svm_model=savedata.svm_model;
        handles.settings.svm_data=savedata.svm_data;
        handles.settings.svm_trainIndices=savedata.svm_trainIndices;
        handles.settings.used_features=savedata.used_features;
        set(handles.classify_show, 'Enable', 'on');
        set(handles.classify_classify, 'Enable', 'on');
        set(handles.show_svm, 'Enable', 'on');
    catch
        % no model in savedata
        set(handles.classify_show, 'Enable', 'on');
        set(handles.classify_classify, 'Enable', 'off');
        set(handles.show_svm, 'Enable', 'off');
    end
    
    %redraw menus
    for t=1:1:length(handles.settings.classNames)
        class_tag = sprintf('%i', t);
        %changeme_dialog('classify_gui_test', handles.figure1);
        try
            class_name = handles.settings.classNames{t};
            menu_class_tag = sprintf('%i   ', t);
            menu_class_name = [menu_class_tag class_name];
            handles.settings.classHandlers(t) =  uimenu('Parent',handles.Untitled_4,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', class_tag, ...
                'Callback', {@Generic_Class_Callback});
        catch
            %
        end
    end
    
    % adding the Classify setup
    index=0;
    for i=1:length(handles.settings.Measurement_names)
        if i<50
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_5,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        elseif i<100
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_6,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        else
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_7,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        end
    end
    % adding the marks to the classify setup menu
    for i=1:length(handles.settings.Measurement_names)
        if handles.settings.classifySetup(i)==1;
            set(handles.settings.classifySetupHandlers(i), 'Checked', 'on');
        else
            set(handles.settings.classifySetupHandlers(i), 'Checked', 'off');
        end
    end
    
    % adding the marks to the viewed channels
    if handles.settings.showRedChannel==1;
        set(handles.view_r, 'Checked', 'on');
    else
        set(handles.view_r, 'Checked', 'off');
    end
    if handles.settings.showGreenChannel==1;
        set(handles.view_g, 'Checked', 'on');
    else
        set(handles.view_g, 'Checked', 'off');
    end
    if handles.settings.showBlueChannel==1;
        set(handles.view_b, 'Checked', 'on');
    else
        set(handles.view_b, 'Checked', 'off');
    end
    
    try
        %load([npc(handles.settings.data_path),filesep,'BASICDATA.mat']);
        load(getBasicdataForClassifyGui(handles.settings.data_path));
        disp('Loading BASICDATA...')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if iscell(BASICDATA.Path)
            % [BS, 2012] temp bug fix? %
            matBadPlateIX = cellfun(@isempty,BASICDATA.Path);
            if any(matBadPlateIX)
                warning('bd:Bla','BASICDATA had an empty plate... removing entry!')
                for iX = fieldnames(BASICDATA)'
                    BASICDATA.(char(iX))(matBadPlateIX,:) = [];
                end
            end
            BASICDATA.Path = getplatenames(BASICDATA.Path);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        handles.settings.BASICDATA=BASICDATA;
    catch
        disp('No BASICDATA available (line 273)')
    end
    
    
    %getting some stuff from the BASICDATA
    try
        for plate=1:length(handles.settings.platenames)
            [platenro, replica, batch] = filterplatedata(handles.settings.platenames{plate});
            handles.settings.plate_nrs(plate)=platenro;
            handles.settings.plate_replica(plate)=replica;
        end
    end
    try
        handles.settings.genenames=unique(handles.settings.BASICDATA.GeneData);
    end
    try
        handles.settings.possible_oligos=unique(handles.settings.BASICDATA.OligoNumber(:));
    end
    try
        handles.settings.possible_replicas=unique(handles.settings.BASICDATA.ReplicaNumber(:));
    end
    
    % loading the set of available iBrain SVM classifications
    %     list=dir([npc(handles.settings.data_path),filesep,'SVM_*.mat']);
    %[TS 150121: fix, if BATCH was used as data path - which is usually
    %supported]
    
    candidateDir = npc(handles.settings.data_path);
    posBATCH = regexp(candidateDir,'BATCH$', 'once');
    if ~isempty(posBATCH)
        candidateDir = candidateDir(1:(posBATCH-1));
    end
    list=dir([candidateDir,filesep,'SVM_*.mat']);
    
    list2=struct2cell(list);
    list3=list2(1,:);
    
    index=0;
    handles.settings.SVM_available={};
    for field=1:length(list3)
        handles.settings.SVM_available{field}=list3{field}(5:(end-4));
    end
    try
        handles.settings.showClassified=zeros(1,length(handles.settings.SVM_available)+5);
    catch
        handles.settings.showClassified=0;
    end
    if not(isempty(list3))
        set(handles.classify_show, 'Enable', 'on');
    end
    
    % The SVM data must be loaded for the first plate to get the class
    % names
    try
        PlateHandles=struct();
        for svm=1:length(handles.settings.SVM_available)
            try
                % [BS] fails because platenames contains a complete path to the
                % batch directory...
                strPlateNames = onlyNpcPotentialNetworkPath(handles.settings.platenames{1});
                if numel(strfind(strPlateNames,filesep)) > 3 && numel(strfind(lower(strPlateNames),'nas'))
                    % assume plate name contains a full path
                    PlateHandles = LoadMeasurements_withCaching(PlateHandles, fullfile(strPlateNames,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
                else
                    % try old code
                    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(npc(handles.settings.data_path),filesep,handles.settings.platenames{1},filesep,'BATCH',filesep,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
                end
            end
        end
        cellFields=fieldnames(PlateHandles.Measurements);
        for iField=cellFields'
            cellFields2=fieldnames(PlateHandles.Measurements.(char(iField)));
            for iField2=cellFields2'
                try
                    handles.Measurements{1}.(char(iField)).(char(iField2)) = PlateHandles.Measurements.(char(iField)).(char(iField2));
                end
            end
        end
        
        % adding the available SVM's to the menu
        current_h=get(handles.classify_show,'Children');
        handles.settings.SVM_availableHandlers=current_h(1);
        index=1;
        for i=1:length(handles.settings.SVM_available)
            index=index+1;
            menu_class_name = handles.settings.SVM_available{i};
            handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@classify_show_current_Callback});
        end
        % adding virus infection
        index=index+1;
        menu_class_name = 'Virus infection OLD (when available)';
        handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
            'Label',menu_class_name,...
            'HandleVisibility','callback', ...
            'Tag', num2str(index), ...
            'Callback', {@classify_show_current_Callback});
        % adding virus infection
        index=index+1;
        menu_class_name = 'Virus infection OPTIMIZED (when available)';
        handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
            'Label',menu_class_name,...
            'HandleVisibility','callback', ...
            'Tag', num2str(index), ...
            'Callback', {@classify_show_current_Callback});
        % adding cell type classification per column
        index=index+1;
        menu_class_name = 'Cell type classification per column';
        handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
            'Label',menu_class_name,...
            'HandleVisibility','callback', ...
            'Tag', num2str(index), ...
            'Callback', {@classify_show_current_Callback});
        % Single feature
        index=index+1;
        menu_class_name = 'Single feature';
        handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
            'Label',menu_class_name,...
            'HandleVisibility','callback', ...
            'Tag', num2str(index), ...
            'Callback', {@classify_show_current_Callback});
        
        
        % Adding the SVM's also to the panels menu
        current_h=get(handles.Show_panel,'Children');
        handles.settings.SVM_Show_panel_Handlers=current_h(1);
        index=1;
        for i=1:length(handles.settings.SVM_available)
            index=index+1;
            menu_class_name = handles.settings.SVM_available{i};
            handles.settings.SVM_Show_panel_Handlers(index) =  uimenu('Parent',handles.Show_panel,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@panel_select_Callback});
        end
        handles.settings.Show_panel_SVMs=zeros(1,length(handles.settings.SVM_available)); %saves which SVM's are showed in the panel
        
    end
    
    set(handles.Untitled_2, 'Enable', 'on');
    set(handles.Untitled_3, 'Enable', 'on');
    set(handles.Untitled_4, 'Enable', 'on');
    set(handles.Untitled_5, 'Enable', 'on');
    set(handles.Untitled_6, 'Enable', 'on');
    set(handles.Untitled_7, 'Enable', 'on');
    set(handles.file_configure, 'Enable', 'off');
    set(handles.file_load, 'Enable', 'off');
    set(handles.file_save, 'Enable', 'on');
    
    guidata(hObject, handles);
    load_data();
    load_picture();
    draw();
end
end

% ------------------------------------------------------------------
function file_save_Callback(hObject, eventdata, handles)
% hObject    handle to file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [Berend Snijder] get the default last used path from here
strPathFile = fullfile(matlabroot,'classify_gui_path.mat');
strLastSavedPath = '';
if fileattrib(strPathFile)
    try
        load(strPathFile,'strLastSavedPath')
        if ~ischar(strLastSavedPath)
            strLastSavedPath = '';
        end
    catch
        % failed to load last used path
    end
end

[FileName,PathName,FilterIndex] = uiputfile(fullfile(strLastSavedPath,'*.mat'),'Save current classification');

% [Berend Snijder] store the last used path in the pref file
try
    if ~isempty(PathName) & ~(PathName==0)
        strLastSavedPath = PathName;
        save(strPathFile,'strLastSavedPath')
    end
catch
    % failed to save classify_gui_path.mat
end

if(not(isempty(PathName) & isempty(PathName)))
    
    
    savedata = struct;
    savedata.nucleusClassNumber = handles.settings.nucleusClassNumber;
    savedata.rescaleRed = handles.settings.rescaleRed;
    savedata.rescaleGreen = handles.settings.rescaleGreen;
    savedata.rescaleBlue = handles.settings.rescaleBlue;
    savedata.rescaleFarRed = handles.settings.rescaleFarRed;
    savedata.rescaleRed_level = handles.settings.rescaleRed_level;
    savedata.rescaleGreen_level = handles.settings.rescaleGreen_level;
    savedata.rescaleBlue_level = handles.settings.rescaleBlue_level;
    savedata.rescaleFarRed_level = handles.settings.rescaleFarRed_level;
    
    savedata.classNames = handles.settings.classNames;
    savedata.data_path = npc(handles.settings.data_path);
    savedata.image_path = npc(handles.settings.image_path);
    savedata.image_nr = handles.settings.image_nr;
    savedata.plate_nr = handles.settings.plate_nr;
    savedata.showRedChannel = handles.settings.showRedChannel;
    savedata.showGreenChannel = handles.settings.showGreenChannel;
    savedata.showBlueChannel = handles.settings.showBlueChannel;
    savedata.showFarRedChannel = handles.settings.showFarRedChannel; % [TS150126: not saved in original classify_gui]
    savedata.platenames = handles.settings.platenames;
    savedata.showClassified = handles.settings.showClassified;
    
    
    savedata.Measurement_names=handles.settings.Measurement_names;
    savedata.classifySetup=handles.settings.classifySetup;
    savedata.classifySetupHandlers=handles.settings.classifySetupHandlers;
    
    try
        handles.settings.svm_model.options.bin_svm='smo';
        savedata.svm_model = handles.settings.svm_model;
        savedata.svm_data = handles.settings.svm_data;
        savedata.svm_trainIndices = handles.settings.svm_trainIndices;
        savedata.used_features = handles.settings.used_features;
    catch
        %no model
    end
    fullpath = fullfile(PathName, FileName);
    save(fullpath, 'savedata');
end

end

% --------------------------------------------------------------------
function file_configure_Callback(hObject, eventdata, handles)
% hObject    handle to file_configure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


returndata = classify_gui_config();
initialize();

handles.settings.data_path = npc(returndata.data_path);
handles.settings.image_path = npc(returndata.image_path);
if ~isempty(strfind(npc(handles.settings.data_path),'Salmonella')) %the first plate of Salmonella does not have TIFFs
    handles.settings.plate_nr=19;
end
set(handles.Untitled_2, 'Enable', 'on');
set(handles.Untitled_3, 'Enable', 'on');
set(handles.Untitled_4, 'Enable', 'on');
set(handles.Untitled_5, 'Enable', 'on');
set(handles.Untitled_6, 'Enable', 'on');
set(handles.Untitled_7, 'Enable', 'on');
set(handles.file_configure, 'Enable', 'off'); %allow these later when bug free
set(handles.file_load, 'Enable', 'off');  %allow these later when bug free
set(handles.classify_show, 'Enable', 'off');
set(handles.classify_classify, 'Enable', 'off');
set(handles.show_svm, 'Enable', 'off');
set(handles.file_save, 'Enable', 'on');
set(handles.classify_train,'Enable', 'off');

% loading the plate list here
% keyboard
try
    disp('Loading BASICDATA...')
    getBasicdataForClassifyGui
    load(getBasicdataForClassifyGui(handles.settings.data_path));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [BS, 2012] temp bug fix? %
    matBadPlateIX = cellfun(@isempty,BASICDATA.Path);
    if any(matBadPlateIX)
        warning('bd:Bla','BASICDATA had an empty plate... removing entry!')
        for iX = fieldnames(BASICDATA)'
            BASICDATA.(char(iX))(matBadPlateIX,:) = [];
        end
    end
    BASICDATA.Path = getplatenames(BASICDATA.Path);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
catch
    disp('no BASICDATA available')
end

try
    
    
    plates=size(BASICDATA.Path,1);
    handles.settings.BASICDATA=BASICDATA;
    for plate=1:plates
        try
            %indi=strfind(BASICDATA.Path{plate},'/');
            handles.settings.platenames{plate}=BASICDATA.Path{plate};%(indi(end-2)+1:indi(end-1)-1);
        catch
            %indi=strfind(BASICDATA.Path{plate},'\');
            handles.settings.platenames{plate}=BASICDATA.Path;%(indi(end-2)+1:indi(end-1)-1);
        end
    end
    
catch
    disp('Could not load platelist from BASICDATA: Assuming that all subfolders are plates')
    
    filelist=struct2cell(dir(handles.settings.data_path));
    files=size(filelist,2);
    index=0;
    for file=3:files %the first 2 are always "." and ".."
        if filelist{4,file}==1
            index=index+1;
            handles.settings.platenames{index}=filelist{1,file};
        end
    end
end


% LOADING THE 50K assay names into the plate names instead...
if not(isempty(strfind(handles.settings.data_path,'50K_final_reanalysis'))) & isempty(strfind(handles.settings.data_path,'KY')) & isempty(strfind(handles.settings.data_path,'MZ')) & isempty(strfind(handles.settings.data_path,'TDS')) & isempty(strfind(handles.settings.data_path,'CNX'))
    disp('LOADING THE 50K reanalysis assay names')
    plates=length(BASICDATA.Path);
    handles.settings.BASICDATA=BASICDATA;
    for plate=1:plates
        try
            indi=strfind(BASICDATA.Path{plate},'/');
            handles.settings.platenames{plate}=BASICDATA.Path{plate}(indi(end-3)+1:indi(end-1)-1);
        catch
            indi=strfind(BASICDATA.Path{plate},'\');
            handles.settings.platenames{plate}=BASICDATA.Path{plate}(indi(end-3)+1:indi(end-1)-1);
        end
    end
end


%loading the available Measurement data fieldnames
try
    list=dir(format_path(handles.settings.data_path,filesep,handles.settings.platenames{1},filesep,'BATCH',filesep,'Measurements_*.mat'));
    list2=struct2cell(list);
    list3=list2(1,:);
    index=0;
    for field=1:length(list3)
        if ...
                (isempty(strfind(list3{field},'Image'))...
                && (not(isempty(strfind(list3{field},'Nuclei')))...
                || not(isempty(strfind(list3{field},'PlasmaMembrane')))...
                || not(isempty(strfind(list3{field},'Perinuclear')))...
                || not(isempty(strfind(list3{field},'Vesicles')))...
                || not(isempty(strfind(list3{field},'ShCells')))...
                || not(isempty(strfind(list3{field},'Cytoplasm')))...
                || not(isempty(strfind(list3{field},'PreNuclei')))...
                || not(isempty(strfind(list3{field},'MeanVesicles2')))...
                || not(isempty(strfind(list3{field},'Cells'))))...
                && (not(isempty(strfind(list3{field},'Intensity')))...
                || not(isempty(strfind(list3{field},'MeanVesicles2')))...
                || not(isempty(strfind(list3{field},'Texture')))...
                || not(isempty(strfind(list3{field},'Relative')))...
                || not(isempty(strfind(list3{field},'Number')))...
                || not(isempty(strfind(list3{field},'Per_U')))...
                || not(isempty(strfind(list3{field},'Maximum')))...
                || not(isempty(strfind(list3{field},'PCA')))...
                || not(isempty(strfind(list3{field},'Minimum')))...
                || not(isempty(strfind(list3{field},'Radius')))...
                || not(isempty(strfind(list3{field},'Distance')))...
                || not(isempty(strfind(list3{field},'AreaShape')))...
                || not(isempty(strfind(list3{field},'ExtractVesicle')))...
                || not(isempty(strfind(list3{field},'ExtractCell')))...
                || not(isempty(strfind(list3{field},'GridNucleiCount')))...
                || not(isempty(strfind(list3{field},'GridNucleiEdges')))))
            index=index+1;
            handles.settings.Measurement_names{index}=list3{field}(14:end-4);
        elseif ~isempty(regexpi(list3{field},'Measurements_(Cells|Nuclei|PreNuclei)_.*\.mat'))
            index=index+1;
            handles.settings.Measurement_names{index}=list3{field}(14:end-4);
        end
    end
catch
    disp('No Measurement data available')
    handles.settings.Measurement_names{1}='no_data';
end

% adding the Classify setup
index=0;
try
    for i=1:length(handles.settings.Measurement_names)
        if i<50
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_5,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        elseif i<100
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_6,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        else
            index=index+1;
            menu_class_name = handles.settings.Measurement_names{i};
            handles.settings.classifySetupHandlers(index) =  uimenu('Parent',handles.Untitled_7,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', num2str(index), ...
                'Callback', {@Classify_setup_CallBack});
        end
    end
end
handles.settings.classifySetup=zeros(1,index);

try
    for plate=1:length(handles.settings.platenames)
        [platenro replica batch] = filterplatedata(handles.settings.platenames{plate});
        handles.settings.plate_nrs(plate)=platenro;
        handles.settings.plate_replica(plate)=replica;
    end
end
try
    handles.settings.genenames=unique(handles.settings.BASICDATA.GeneData);
end
try
    handles.settings.possible_oligos=unique(handles.settings.BASICDATA.OligoNumber(:));
end
try
    handles.settings.possible_replicas=unique(handles.settings.BASICDATA.ReplicaNumber(:));
end

% loading the set of available iBrain SVM classifications
list=dir([handles.settings.data_path,filesep,'SVM_*.mat']);
list2=struct2cell(list);
list3=list2(1,:);
index=0;
handles.settings.SVM_available={};
for field=1:length(list3)
    handles.settings.SVM_available{field}=list3{field}(5:(end-4));
end
handles.settings.showClassified=zeros(1,length(handles.settings.SVM_available)+5);

if not(isempty(list3))
    set(handles.classify_show, 'Enable', 'on');
end

% The SVM data must be loaded for the first plate to get the class
% names
PlateHandles=struct();
for svm=1:length(handles.settings.SVM_available)
    try
        % [BS] fails because platenames contains a complete path to the
        % batch directory...
        strPlateNames = onlyNpcPotentialNetworkPath(handles.settings.platenames{1});
        if numel(strfind(strPlateNames,filesep)) > 3 && numel(strfind(lower(strPlateNames),'nas'))
            % assume plate name contains a full path
            PlateHandles = LoadMeasurements_withCaching(PlateHandles, fullfile(strPlateNames,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
        else
            % try old code
            PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(npc(handles.settings.data_path),filesep,handles.settings.platenames{1},filesep,'BATCH',filesep,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
            %             PlateHandles = LoadMeasurements_withCaching(PlateHandles, [handles.settings.data_path,filesep,handles.settings.platenames{1},filesep,'BATCH',filesep,'Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']);
        end
        
    end
end
try
    cellFields=fieldnames(PlateHandles.Measurements);
    for iField=cellFields'
        cellFields2=fieldnames(PlateHandles.Measurements.(char(iField)));
        for iField2=cellFields2'
            try
                handles.Measurements{1}.(char(iField)).(char(iField2)) = PlateHandles.Measurements.(char(iField)).(char(iField2));
            end
        end
    end
end
% adding the available SVM's to the menu
current_h=get(handles.classify_show,'Children');
handles.settings.SVM_availableHandlers=current_h(1);
index=1;
for i=1:length(handles.settings.SVM_available)
    index=index+1;
    menu_class_name = handles.settings.SVM_available{i};
    handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
        'Label',menu_class_name,...
        'HandleVisibility','callback', ...
        'Tag', num2str(index), ...
        'Callback', {@classify_show_current_Callback});
end

% adding virus infection
index=index+1;
menu_class_name = 'Virus infection OLD (when available)';
handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
    'Label',menu_class_name,...
    'HandleVisibility','callback', ...
    'Tag', num2str(index), ...
    'Callback', {@classify_show_current_Callback});
% adding virus infection
index=index+1;
menu_class_name = 'Virus infection OPTIMIZED (when available)';
handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
    'Label',menu_class_name,...
    'HandleVisibility','callback', ...
    'Tag', num2str(index), ...
    'Callback', {@classify_show_current_Callback});
% adding cell type classification per column
index=index+1;
menu_class_name = 'Cell type classification per column';
handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
    'Label',menu_class_name,...
    'HandleVisibility','callback', ...
    'Tag', num2str(index), ...
    'Callback', {@classify_show_current_Callback});
% adding single feature
index=index+1;
menu_class_name = 'Single feature value';
handles.settings.SVM_availableHandlers(index) =  uimenu('Parent',handles.classify_show,...
    'Label',menu_class_name,...
    'HandleVisibility','callback', ...
    'Tag', num2str(index), ...
    'Callback', {@classify_show_current_Callback});


guidata(hObject, handles);

load_data();
load_picture();
draw();

end

% --------------------------------------------------------------------
function Classify_setup_CallBack(hObject,eventdata)
handles = guidata(hObject);
current_item = str2double(get(hObject, 'Tag'));
check=get(handles.settings.classifySetupHandlers(current_item), 'Checked');
if strcmp(check,'on')
    set(handles.settings.classifySetupHandlers(current_item), 'Checked', 'off');
    handles.settings.classifySetup(current_item) = 0;
elseif strcmp(check,'off')
    set(handles.settings.classifySetupHandlers(current_item), 'Checked', 'on');
    handles.settings.classifySetup(current_item) = 1;
end

%if data changes all the data should be reloaded (just in case)
try
    handles.settings=rmfield(handles.settings,'PlateHandles');
end
handles.settings.plate_in_memory=0;

% the classify button is deactivated
set(handles.classify_classify, 'Enable', 'off');

guidata(hObject, handles);
end

% --------------------------------------------------------------------
function view_r_Callback(hObject, eventdata, handles)
% hObject    handle to view_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.settings.showRedChannel)
    handles.settings.showRedChannel = 0;
    set(hObject, 'Checked', 'off');
else
    handles.settings.showRedChannel = 1;
    if ~any(handles.picture.RedChannel(:))
        handles = obtainChannelImage(handles,'Red');
    end
    set(hObject, 'Checked', 'on');
end

guidata(hObject, handles);
draw();
end

% --------------------------------------------------------------------
function view_g_Callback(hObject, eventdata, handles)
% hObject    handle to view_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.settings.showGreenChannel)
    handles.settings.showGreenChannel = 0;
    set(hObject, 'Checked', 'off');
else
    handles.settings.showGreenChannel = 1;
    if ~any(handles.picture.GreenChannel(:))
        handles = obtainChannelImage(handles,'Green');
    end
    set(hObject, 'Checked', 'on');
end
guidata(hObject, handles);
draw();
end

% --------------------------------------------------------------------
function view_b_Callback(hObject, eventdata, handles)
% hObject    handle to view_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.settings.showBlueChannel)
    handles.settings.showBlueChannel = 0;
    set(hObject, 'Checked', 'off');
else
    handles.settings.showBlueChannel = 1;
    if ~any(handles.picture.BlueChannel(:))
        handles = obtainChannelImage(handles,'Blue');
    end
    set(hObject, 'Checked', 'on');
end
guidata(hObject, handles);
draw();
end

% --------------------------------------------------------------------
function view_y_Callback(hObject, eventdata, handles)
% hObject    handle to view_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.settings.showFarRedChannel)
    handles.settings.showFarRedChannel = 0;
    set(hObject, 'Checked', 'off');
else
    handles.settings.showFarRedChannel = 1;
    if ~any(handles.picture.FarRedChannel(:))
        handles = obtainChannelImage(handles,'FarRed');
    end
    set(hObject, 'Checked', 'on');
end
guidata(hObject, handles);
draw();

end
% --------------------------------------------------------------------
function view_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to view_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.settings.showSegmentation)
    handles.settings.showSegmentation = 0;
    set(hObject, 'Checked', 'off');
else
    handles.settings.showSegmentation = 1;
    set(hObject, 'Checked', 'on');
end
guidata(hObject, handles);
load_picture();
draw();

end

% --------------------------------------------------------------------
function view_rescale_Callback(hObject, eventdata, handles)
% hObject    handle to view_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%try
transfer = struct;
transfer.picture = handles.picture;
transfer.settings = handles.settings;
returnvalue = classify_gui_rescale(transfer);
handles.settings = returnvalue.settings;
% hack to get draw() to redraw
handles.settings.newrescaleparams = 1;
guidata(hObject, handles);
draw();
handles = guidata(gcf);
handles.settings.newrescaleparams = 0;
guidata(hObject, handles);
%end
end

% --------------------------------------------------------------------
function view_next_Callback(hObject, eventdata, handles)
% hObject    handle to view_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.image_nr = handles.settings.image_nr+1;
maximages=length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames);
handles.settings.image_nr = mod(handles.settings.image_nr-1,maximages)+1;
guidata(hObject, handles);
load_picture();
draw();
end

% --------------------------------------------------------------------
function view_previous_Callback(hObject, eventdata, handles)
% hObject    handle to view_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.image_nr = handles.settings.image_nr-1;
maximages=length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames);
handles.settings.image_nr = mod(handles.settings.image_nr-1,maximages)+1;
guidata(hObject, handles);
load_picture();
draw();
end

% --------------------------------------------------------------------
function classify_train_Callback(hObject, eventdata, handles)
% hObject    handle to classify_train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CHANGED BY PAULI:
% handles.settings.classified_nuclei does not exist anymore
% handles.settings.nucleusClassNumber{plate_nr}{image_nr}:
% 1. row: manually classified
% 2. row: svm classified
newest_platehandle=handles.settings.plate_in_memory;
plates=length(handles.settings.nucleusClassNumber);
for plate=1:plates
    if not(isempty(handles.settings.nucleusClassNumber{plate}))		%there is data in this plate
        PlateHandles = struct(); %starting a new PlateHandles cache data of the new plate
        try % THERE's A WEIRD BUG SOMEWHERE! FIND IT!!!!!
            if length(handles.settings.nucleusClassNumber{plate})==length(handles.Measurements{plate}.Image.FileNames)+1
                images=length(handles.Measurements{plate}.Image.FileNames);
            else
                images=length(handles.settings.nucleusClassNumber{plate});
            end
        catch
            images=length(handles.settings.nucleusClassNumber{plate});
        end
        images=images-1; % OK. LET's SKIP THE LAST IMAGE ALWAYS! (REMOVE THIS UGLINESS)
        for image=1:images
            if not(isempty(handles.settings.nucleusClassNumber{plate}{image})) %there is data in this plate+image
                for field=1:length(handles.settings.Measurement_names)
                    if handles.settings.classifySetup(field)==1 %the current datafield is used
                        cut=strfind(handles.settings.Measurement_names{field},'_');
                        fieldname1=handles.settings.Measurement_names{field}(1:(cut-1));
                        fieldname2=handles.settings.Measurement_names{field}((cut+1):end);
                        try handles.Measurements{plate}.(fieldname1).(fieldname2){image};
                            if isempty(handles.Measurements{plate}.(fieldname1).(fieldname2){image});
                                jump_to_catch; %so ugly
                            end
                        catch %this data item is not loaded
                            try handles.settings.PlateHandles.Measurements.(fieldname1).(fieldname2){image};
                                if  handles.settings.plate_in_memory==plate % the current data item IS in the old "cache" memory
                                    handles.Measurements{plate}.(fieldname1).(fieldname2){image}=handles.settings.PlateHandles.Measurements.(fieldname1).(fieldname2){image}; %loading from the old cache
                                else
                                    jump_to_catch; %so ugly
                                end
                            catch % the current data item is NOT in the old "cache" memory
                                try PlateHandles.Measurements.(fieldname1).(fieldname2){image};
                                    % the current data item IS in the new "cache" memory
                                catch % the current data item is NOT in the new "cache" memory
                                    %                                     disp(['Loading... plate: ',num2str(plate),', field: ',handles.settings.Measurement_names{field}]);
                                    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(handles.settings.data_path,filesep,handles.settings.platenames{plate},filesep,'BATCH',filesep,['Measurements_',handles.settings.Measurement_names{field},'.mat']));
                                    newest_platehandle=plate;
                                end
                                handles.Measurements{plate}.(fieldname1).(fieldname2){image}=PlateHandles.Measurements.(fieldname1).(fieldname2){image}; %loading from the new cache
                                try
                                    handles.Measurements{plate}.(fieldname1).([fieldname2,'Features'])=PlateHandles.Measurements.(fieldname1).([fieldname2,'Features']); %loading Feature names
                                end
                            end
                        end
                    end
                end
            end
        end
        % Loading the MEAN STD and Object count
        % They are always loaded..
        % not very intelligent, but the file is really small
        %try
        PlateHandles2 = struct();
        PlateHandles2 = LoadMeasurements_withCaching(PlateHandles2, format_path(handles.settings.data_path,filesep,handles.settings.platenames{plate},filesep,'BATCH',filesep,'Measurements_Mean_Std.mat'));
        PlateHandles2 = LoadMeasurements_withCaching(PlateHandles2, format_path(handles.settings.data_path,filesep,handles.settings.platenames{plate},filesep,'BATCH',filesep,'Measurements_Image_ObjectCount.mat'));
        cellFields=fieldnames(PlateHandles2.Measurements);
        for iField=cellFields'
            cellFields2=fieldnames(PlateHandles2.Measurements.(char(iField)));
            for iField2=cellFields2'
                handles.Measurements{plate}.(char(iField)).(char(iField2)) = PlateHandles2.Measurements.(char(iField)).(char(iField2));
            end
        end
        clear PlateHandles2;
        %end
    end
end
if  handles.settings.plate_in_memory~=newest_platehandle %new PlateHandles data is loaded
    handles.settings.PlateHandles=PlateHandles;
    handles.settings.plate_in_memory=newest_platehandle;
end
clear PlateHandles;

% ADD THE NEXT IF MEMORY PROBLEMS PERSIST
try
    handles.settings=rmfield(handles.settings,'PlateHandles');
    handles.settings.plate_in_memory=0;
end

plates=length(handles.settings.nucleusClassNumber);
nucleus_index=0;

disp('Gathering the training data...')
for plate=1:plates
    if not(isempty(handles.settings.nucleusClassNumber{plate}))
        try % THERE's A WEIRD BUG SOMEWHERE! FIND IT!!!!!
            if length(handles.settings.nucleusClassNumber{plate})==length(handles.Measurements{plate}.Image.FileNames)+1
                images=length(handles.Measurements{plate}.Image.FileNames);
            else
                images=length(handles.settings.nucleusClassNumber{plate});
            end
        catch
            images=length(handles.settings.nucleusClassNumber{plate});
        end
        images=images-1; % OK. LET's SKIP THE LAST IMAGE ALWAYS! (REMOVE THIS UGLINESS)
        for image=1:images
            if not(isempty(handles.settings.nucleusClassNumber{plate}{image}))
                %nuclei=size(handles.settings.nucleusClassNumber{plate}{image},1);
                %nuclei=handles.Measurements{plate}.Image.ObjectCount{image}(find(ismember(handles.Measurements{plate}.Image.ObjectCountFeatures,'Nuclei')));
                
                foo=handles.Measurements{plate}.Image;
                Nuclei_index = getIndexOfNuclei(foo);
                
                nuclei=handles.Measurements{plate}.Image.ObjectCount{image}(Nuclei_index);
                if nuclei~=size(handles.settings.nucleusClassNumber{plate}{image},1)
                    disp('WARNING: nucleusClassNumber is of different size than there are objects! (refer to load_image possible bug)')
                else
                    for nucleus=1:nuclei
                        if handles.settings.nucleusClassNumber{plate}{image}(nucleus,1)~=0 %taking the manually classified nuclei
                            nucleus_index=nucleus_index+1;
                            
                            target(nucleus_index,1)=handles.settings.nucleusClassNumber{plate}{image}(nucleus,1);
                            index=0; %all loaded measurements index
                            for field=1:length(handles.settings.Measurement_names)
                                if handles.settings.classifySetup(field)==1
                                    cut=strfind(handles.settings.Measurement_names{field},'_');
                                    fieldname1=handles.settings.Measurement_names{field}(1:(cut-1));
                                    fieldname2=handles.settings.Measurement_names{field}((cut+1):end);
                                    
                                    for feature=1:size(handles.Measurements{plate}.(fieldname1).(fieldname2){image},2)
                                        index=index+1;
                                        try
                                            
                                            feature_matrix(nucleus_index,index)=...
                                                (handles.Measurements{plate}.(fieldname1).(fieldname2){image}(nucleus,feature)-...
                                                handles.Measurements{plate}.(fieldname1).([fieldname2,'_median'])(feature))/...
                                                handles.Measurements{plate}.(fieldname1).([fieldname2,'_mad'])(feature);
                                        catch
                                            feature_matrix(nucleus_index,index)=handles.Measurements{plate}.(fieldname1).(fieldname2){image}(nucleus,feature);
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

% using the stprtool (http://cmp.felk.cvut.cz/cmp/software/stprtool/index.html)
% and svmlight (http://svmlight.joachims.org/)

%try feature_matrix;
if not(isempty(find(isnan(feature_matrix))))
    disp('Warning: data matrix has NaNs');
    %keyboard
    feature_matrix(isnan(feature_matrix))=0;
    
end


% using 90% of each class of the data for the training set.. the rest 10% are the test set
classes=length(unique(target));
train_indices=[];
for class=1:classes
    indices=find(target==class);
    indi=randperm(length(indices));
    foo=indices(indi(1:ceil(length(indi)*0.85)));	%put here 90%!!
    train_indices((end+1):(end+length(foo)))=foo;
end
test_indices=1:length(target);
test_indices(train_indices)=[];

%saving first all data;
data.X=feature_matrix';
data.y=target;
handles.settings.svm_data = data;
handles.settings.svm_trainIndices = train_indices;


% creating the test data
%data3.X=feature_matrix(train_indices,:)';
%data3.y=target(test_indices);

% doing the training and optimizing the parameters
% (linear kerner does not seem to take parameters)
Cs=40;%%[1 10 100 1000]; %40 %0.01 for linear!
args=50;%[1 10 100]; %50

% training only with the training data
data2.X=feature_matrix(train_indices,:)';
data2.y=target(train_indices);

%ldamodel = lda(data2,30);
%handles.settings.svm_ldamodel = ldamodel;

%data_lda.X=linproj(data.X,ldamodel);
%data_lda.y=data.y;
%handles.settings.svm_datalda=data_lda;

%data3.X=linproj(data2.X,ldamodel);
%data3.y=data2.y;

options = struct;
options.tmax = 50;
%options.solver = 'smo';
if ismac
    options.bin_svm = 'svmquadprog';
elseif ispc
    
    options.bin_svm = 'smo';
end
%	cd c:\Ma'tlab Toolboxes'\svmlight\
%	options.bin_svm = 'svmlight';
%end

options.ker = 'rbf'; %rbf 'linear'
options.verb=1;
%options.solver = 'mdm';


% 	disp('Performing normal SVM-training...');
% 	options.C = 0.1; %45
% 	options.arg = 0.1; %15
% 	model = oaosvm_Pauli(data2, options); %The Pauli version manages different class sizes more intelligently
% 	score=calculateScore(data,model,test_indices)
% 	handles.settings.used_features=ones(1,size(data2.X,1));
% 	handles.settings.svm_model=model;




disp('Performing SVM-training with parameter optimization...');
scores=zeros(length(Cs),length(args));
for i=1:length(Cs)
    for j=1:length(args)
        options.C = Cs(i);
        options.arg = args(j);
        %models{i,j} = bsvm2(data2,options);
        models{i,j} = oaosvm_Pauli(data2, options); %The Pauli version manages different class sizes more intelligently
        scores(i,j)=calculateScore(data,models{i,j},test_indices);
        if isnan(scores(i,j))
            scores(i,j)=0;
        end
    end
end
scores
[i,j]=find(scores==max(scores(:)));
model=models{i(1),j(1)};
handles.settings.used_features=ones(1,size(data2.X,1));
handles.settings.svm_model=model;

set(handles.Untitled_1, 'Enable', 'on');
set(handles.Untitled_2, 'Enable', 'on');
set(handles.Untitled_3, 'Enable', 'on');
set(handles.Untitled_4, 'Enable', 'on');
set(handles.classify_show, 'Enable', 'on');
set(handles.classify_classify, 'Enable', 'on');
set(handles.show_svm, 'Enable', 'on');

% Added by Pauli
% The old classification results should be removed after new training

for plate=1:plates
    if not(isempty(handles.settings.nucleusClassNumber{plate}))
        try % THERE's A WEIRD BUG SOMEWHERE! FIND IT!!!!!
            if length(handles.settings.nucleusClassNumber{plate})==length(handles.Measurements{plate}.Image.FileNames)+1
                images=length(handles.Measurements{plate}.Image.FileNames);
            else
                images=length(handles.settings.nucleusClassNumber{plate});
            end
        catch
            images=length(handles.settings.nucleusClassNumber{plate});
        end
        images=images-1; % OK. LET's SKIP THE LAST IMAGE ALWAYS! (REMOVE THIS UGLINESS)
        for image=1:images
            if not(isempty(handles.settings.nucleusClassNumber{plate}{image}))
                handles.settings.nucleusClassNumber{plate}{image}(:,2)=0; %removing all SVM classifications
            end
        end
    end
end
guidata(gcf,handles);

% redrawing the screen without classifications
disp('SVM training is finished.')

additionalInfo  = round(scores);
updateTitleOfGui(handles,'trainingdone',additionalInfo);

%load gong.mat
%sound(y,Fs);
draw();
%catch
%	disp('No data for SVM training.')
%end
%keyboard
end

% --------------------------------------------------------------------
function score=calculateScore(data,model,test_indices)
%try
[y2,votes] = mvsvmclass(data.X,model); %classification.. model is done with the training data only
%catch
%	[y2,votes] = svmclass(data.X,model); %classification.. model is done with the training data only
%end
target(:,1)=data.y(test_indices);
target(:,2)=y2(test_indices);

classes=unique(target(:,1));
matrix=zeros(length(classes));
for real=1:length(classes)
    real_indices=find(target(:,1)==classes(real));
    classified_values=target(real_indices,2);
    for classified=1:length(classes)
        matrix(classified,real)=length(find(classified_values==classified));
    end
end

% total values
matrix(1:length(classes),length(classes)+1)=sum(matrix(1:length(classes),(1:length(classes)))');
matrix(length(classes)+1,1:length(classes))=sum(matrix(1:length(classes),(1:length(classes))));

% correct percentage
matrix(length(classes)+2,1:length(classes))=round(100*diag(matrix(1:length(classes),1:length(classes)))'./matrix(length(classes)+1,1:length(classes)));

% The final score
score=mean(matrix(length(classes)+2,1:length(classes)));

end

% --------------------------------------------------------------------
function classify_classify_Callback(hObject, eventdata, handles)
% hObject    handle to classify_classify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcf);

if handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1;
    disp('CLASSIFICATION IS NOT POSSIBLE ON THE PANEL!')
else
    
    
    % This is not optimal, but should be usable (loads new data only when
    % changing the active plate)
    
    if handles.settings.plate_in_memory==handles.settings.plate_nr & isfield(handles.settings.PlateHandles,'Measurements') % the current plate is in the memory
    else % the current plate is not the memory
        try
            handles.settings=rmfield(handles.settings,'PlateHandles');
            handles.settings.plate_in_memory=0;
        end
        PlateHandles = struct();
        for field=1:length(handles.settings.Measurement_names)
            if handles.settings.classifySetup(field)==1
                %                 disp(['Loading.. plate: ',num2str(handles.settings.plate_nr),', field: ',handles.settings.Measurement_names{field}]);
                PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,['Measurements_',handles.settings.Measurement_names{field},'.mat']));
            end
        end
        % Add out of focus somehow
        % Loading the MEAN STD
        %try
        PlateHandles2 = struct();
        PlateHandles2 = LoadMeasurements_withCaching(PlateHandles2, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Mean_Std.mat'));
        PlateHandles2 = LoadMeasurements_withCaching(PlateHandles2, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Image_ObjectCount.mat'));
        
        cellFields=fieldnames(PlateHandles2.Measurements);
        for iField=cellFields'
            cellFields2=fieldnames(PlateHandles2.Measurements.(char(iField)));
            for iField2=cellFields2'
                handles.Measurements{handles.settings.plate_nr}.(char(iField)).(char(iField2)) = PlateHandles2.Measurements.(char(iField)).(char(iField2));
            end
        end
        clear PlateHandles2;
        %end
        handles.settings.PlateHandles=PlateHandles;
        handles.settings.plate_in_memory=handles.settings.plate_nr;
        clear PlateHandles;
    end
    for field=1:length(handles.settings.Measurement_names)
        if handles.settings.classifySetup(field)==1
            cut=strfind(handles.settings.Measurement_names{field},'_');
            fieldname1=handles.settings.Measurement_names{field}(1:(cut-1));
            fieldname2=handles.settings.Measurement_names{field}((cut+1):end);
            handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){handles.settings.image_nr}=handles.settings.PlateHandles.Measurements.(fieldname1).(fieldname2){handles.settings.image_nr};
        end
    end
    
    % CLASSIFYING only the current image!
    fprintf('Classifying ...')
    
    foo=handles.Measurements{handles.settings.plate_nr}.Image;
    Nuclei_index = getIndexOfNuclei(foo);
    
    nuclei=handles.Measurements{handles.settings.plate_nr}.Image.ObjectCount{handles.settings.image_nr}(Nuclei_index);
    feature_matrix=zeros(nuclei,0);
    for nucleus=1:nuclei
        index=0;
        feature_index=0; %all loaded measurements index
        for field=1:length(handles.settings.Measurement_names)
            if handles.settings.classifySetup(field)==1
                cut=strfind(handles.settings.Measurement_names{field},'_');
                fieldname1=handles.settings.Measurement_names{field}(1:(cut-1));
                fieldname2=handles.settings.Measurement_names{field}((cut+1):end);
                
                for feature=1:size(handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){handles.settings.image_nr},2)
                    feature_index=feature_index+1;
                    if handles.settings.used_features(feature_index)
                        index=index+1;
                        try
                            feature_matrix(nucleus,index)=...
                                (handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){handles.settings.image_nr}(nucleus,feature)-...
                                handles.Measurements{handles.settings.plate_nr}.(fieldname1).([fieldname2,'_median'])(feature))/...
                                handles.Measurements{handles.settings.plate_nr}.(fieldname1).([fieldname2,'_mad'])(feature);
                        catch
                            feature_matrix(nucleus,index)=handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){handles.settings.image_nr}(nucleus,feature);
                        end
                    end
                end
            end
        end
    end
    
    feature_matrix(isnan(feature_matrix))=0;
    % using the stprtool (http://cmp.felk.cvut.cz/cmp/software/stprtool/index.html)
    model=handles.settings.svm_model;
    %ldamodel=handles.settings.svm_ldamodel;
    %data=linproj(feature_matrix',ldamodel);
    %keyboard
    [y2,votes] = mvsvmclass(feature_matrix',model);
    handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(:,2)=y2';
    
    %keyboard
    handles.settings.showClassified=zeros(size(handles.settings.showClassified));
    handles.settings.showClassified(1)=1;
    guidata(gcf,handles);
    fprintf('done \n')  % refers to Classifying
    updateTitleOfGui(handles,'classificationdone');
    
    % load gong.mat
    % sound(y,Fs);
    draw();
    
end
end

% --------------------------------------------------------------------
function classify_add_Callback(hObject, eventdata, handles)
% hObject    handle to classify_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_class = handles.settings.numberOfClasses + 1;
class_tag = sprintf('%i', current_class);
menu_class_tag = sprintf('%i   ', current_class);
%changeme_dialog('classify_gui_test', handles.figure1);
try
    class_name = enter_class_name();
    menu_class_name = [menu_class_tag class_name];
    handles.settings.classHandlers(current_class) =  uimenu('Parent',handles.Untitled_4,...
        'Label',menu_class_name,...
        'HandleVisibility','callback', ...
        'Tag', class_tag, ...
        'Callback', {@Generic_Class_Callback});
    handles.settings.numberOfClasses = current_class;
    handles.settings.classNames{current_class,1} = class_name;
    guidata(hObject,handles);
    
    if handles.settings.numberOfClasses>=2
        set(handles.classify_train,'Enable','on');
    end
    
catch
    %
end
end

% --------------------------------------------------------------------
function Generic_Class_Callback(hObject,eventdata)
handles = guidata(hObject);
current_class_id = str2double(get(hObject, 'Tag'));
for z = 1:1:length(handles.settings.classHandlers)
    set(handles.classify_unclass, 'Checked', 'off');
    set(handles.settings.classHandlers(z), 'Checked', 'off');
end
set(handles.settings.classHandlers(current_class_id), 'Checked', 'on');
handles.settings.currentClass = current_class_id;
guidata(hObject, handles);

%redrawing the image title
current_class=handles.settings.currentClass;
if current_class==0
    classname='Unclassify';
else
    classname=[num2str(current_class),' ',handles.settings.classNames{current_class}];
end

% BS: added well, site and microscope information
try
    [~,~,strWellName] = filterimagenamedata(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
    [intImagePosition,strMicroscopeType] = check_image_position(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
catch objFoo %#ok<NASGU>
    strWellName = '';
    intImagePosition = NaN;
    strMicroscopeType = '';
end

try
    %             disp('berend was here')
    [genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
    set(gcf,'Name',['Plate: ',num2str(handles.settings.plate_nr),' ',strWellName,', Image: ',num2str(handles.settings.image_nr),' (Gene: ',genename,...
        ', Oligo: ',num2str(oligo),' , Replica: ',num2str(replica),')       Current class: ',classname,]);
catch
    set(gcf,'Name', sprintf('Plate %d (%s)  |  Well %s  |  Site %d  |  Image %d          Current class: %s', ...
        handles.settings.plate_nr,strMicroscopeType,strWellName,intImagePosition,handles.settings.image_nr,classname))
end

end

% --------------------------------------------------------------------
function classify_unclass_Callback(hObject, eventdata, handles)
% hObject    handle to classify_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
current_class_id = 0;
for z = 1:1:length(handles.settings.classHandlers)
    set(handles.settings.classHandlers(z), 'Checked', 'off');
end
set(handles.classify_unclass, 'Checked', 'on');
handles.settings.currentClass = current_class_id;
guidata(hObject, handles);

%redrawing the image title
% BS: added well, site and microscope information
try
    [~,~,strWellName] = filterimagenamedata(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
    [intImagePosition,strMicroscopeType] = check_image_position(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
catch objFoo %#ok<NASGU>
    strWellName = '';
    intImagePosition = NaN;
    strMicroscopeType = '';
end

try
    %             disp('berend was here')
    [genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
    set(gcf,'Name',['Plate: ',num2str(handles.settings.plate_nr),' ',strWellName,', Image: ',num2str(handles.settings.image_nr),' (Gene: ',genename,...
        ', Oligo: ',num2str(oligo),' , Replica: ',num2str(replica),')       Current class: ',classname,]);
catch
    set(gcf,'Name', sprintf('Plate %d (%s)  |  Well %s  |  Site %d  |  Image %d          Current class: %s', ...
        handles.settings.plate_nr,strMicroscopeType,strWellName,intImagePosition,handles.settings.image_nr,classname))
end
% 	try
%         disp('berend was here')
% 		[genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
% 		set(gcf,'Name',['Plate: ',num2str(handles.settings.plate_nr),', Image: ',num2str(handles.settings.image_nr),' (Gene: ',genename,...
% 			', Oligo: ',num2str(oligo),' , Replica: ',num2str(replica),')       Current class: ','Unclassify']);
% 	catch
% 		set(gcf,'Name',['Image: ',num2str(handles.settings.image_nr),', Plate: ',num2str(handles.settings.plate_nr),'      Current class: ','Unclassify']);
% 	end
end

% --------------------------------------------------------------------
function classify_remove_Callback(hObject, eventdata, handles)
% hObject    handle to classify_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    class_to_remove = classify_gui_removeclass(handles.settings.classNames);
    
    classes=length(handles.settings.classNames);
    % reading the old tags
    old_tag=[];
    for class=1:classes
        old_tag(class)=str2double(get(handles.settings.classHandlers(class), 'Tag'));
    end
    
    % deleting all the classes in the menu
    for class=1:classes
        delete(handles.settings.classHandlers(class));
    end
    handles.settings.classHandlers=[];
    
    %recreating the classes, except the deleted one
    index=0;
    new_tag=[];
    for class=1:classes
        class_tag='0';
        if class~=class_to_remove
            index=index+1;
            class_name = handles.settings.classNames{class};
            menu_class_tag = [num2str(index),'   '];
            menu_class_name = [menu_class_tag class_name];
            class_tag = num2str(index);
            handles.settings.classHandlers(index) =  uimenu('Parent',handles.Untitled_4,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', class_tag, ...
                'Callback', {@Generic_Class_Callback});
        end
        new_tag(class)=str2double(class_tag);
    end
    
    % changing the handles values
    handles.settings.classNames(class_to_remove)=[];
    handles.settings.currentClass = 0;
    handles.settings.numberOfClasses = length(handles.settings.classNames);
    
    % relabeling all the manually trained cells
    plates=length(handles.settings.nucleusClassNumber);
    for plate=1:plates
        if not(isempty(handles.settings.nucleusClassNumber{plate}))		%there is data in this plate
            try
                images=length(handles.Measurements{plate}.Image.FileNames);
            catch
                images=length(handles.settings.nucleusClassNumber{plate});
            end
            for image=1:images
                if not(isempty(handles.settings.nucleusClassNumber{plate}{image})) %there is data in this plate+image
                    for class=1:classes
                        indices = find(handles.settings.nucleusClassNumber{plate}{image}(:,1) == old_tag(class));
                        handles.settings.nucleusClassNumber{plate}{image}(indices,1) = new_tag(class);
                        handles.settings.nucleusClassNumber{plate}{image}(:,2) = 0;       %removing all svm trained
                    end
                end
            end
        end
    end
    
    % removing the svm model (svm is not up-to-date anymore)
    try
        handles.settings=rmfield(handles.settings,'svm_model');
        handles.settings=rmfield(handles.settings,'svm_data');
        handles.settings=rmfield(handles.settings,'svm_trainIndices');
    end
    
    % setting the active menu items
    for z = 1:1:length(handles.settings.classHandlers)
        set(handles.settings.classHandlers(z), 'Checked', 'off');
    end
    set(handles.classify_unclass, 'Checked', 'on');
    set(handles.classify_classify, 'Enable', 'off');
    %set(handles.classify_show, 'Enable', 'off');
    set(handles.show_svm, 'Enable', 'off');
    if handles.settings.numberOfClasses>=2
        set(handles.classify_train,'Enable','on');
    else
        set(handles.classify_train,'Enable','off');
    end
    
    guidata(hObject, handles);
    draw();
end

end

% --------------------------------------------------------------------
function classify_merge_Callback(hObject, eventdata, handles)
% hObject    handle to classify_merge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%try

out = classify_gui_mergeclass(handles.settings.classNames);

class1=out.class1;
class2=out.class2;
name=out.name;

if out.class1~=out.class2
    
    classes=length(handles.settings.classNames);
    % reading the old tags
    old_tag=[];
    for class=1:classes
        old_tag(class)=str2double(get(handles.settings.classHandlers(class), 'Tag'));
    end
    
    % deleting all the classes in the menu
    for class=1:classes
        delete(handles.settings.classHandlers(class));
    end
    handles.settings.classHandlers=[];
    newClassNames={};
    
    %recreating the classes
    index=0;
    new_tag=[];
    for class=1:classes
        class_tag=num2str(classes-1); %after merging there is one class less
        if class~=class1 && class~=class2
            index=index+1;
            class_name = handles.settings.classNames{class};
            menu_class_tag = [num2str(index),'   '];
            menu_class_name = [menu_class_tag class_name];
            class_tag = num2str(index);
            handles.settings.classHandlers(index) =  uimenu('Parent',handles.Untitled_4,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', class_tag, ...
                'Callback', {@Generic_Class_Callback});
            newClassNames{index} = class_name;
        end
        new_tag(class)=str2double(class_tag); %both new classes get the same new tag
    end
    
    % creating the new class menu item
    index=index+1;
    class_name = name;
    menu_class_tag = [num2str(index),'   '];
    menu_class_name = [menu_class_tag class_name];
    class_tag = num2str(index);
    handles.settings.classHandlers(index) =  uimenu('Parent',handles.Untitled_4,...
        'Label',menu_class_name,...
        'HandleVisibility','callback', ...
        'Tag', class_tag, ...
        'Callback', {@Generic_Class_Callback});
    newClassNames{index} = class_name;
    
    % changing the handles values
    handles.settings.classNames = newClassNames;
    handles.settings.currentClass = 0;
    handles.settings.numberOfClasses = length(handles.settings.classNames);
    
    % relabeling all the manually trained cells
    plates=length(handles.settings.nucleusClassNumber);
    for plate=1:plates
        if not(isempty(handles.settings.nucleusClassNumber{plate}))		%there is data in this plate
            try
                images=length(handles.Measurements{plate}.Image.FileNames);
            catch
                images=length(handles.settings.nucleusClassNumber{plate});
            end
            for image=1:images
                if not(isempty(handles.settings.nucleusClassNumber{plate}{image})) %there is data in this plate+image
                    old_data=handles.settings.nucleusClassNumber{plate}{image}(:,1);
                    new_data=zeros(size(old_data));
                    for class=1:classes
                        indices = find(old_data == old_tag(class));
                        new_data(indices,1) = new_tag(class);
                        handles.settings.nucleusClassNumber{plate}{image}(:,2) = 0;       %removing all svm trained
                    end
                    handles.settings.nucleusClassNumber{plate}{image}(:,1)=new_data;
                end
            end
        end
    end
    
    % removing the svm model (svm is not up-to-date anymore)
    try
        handles.settings=rmfield(handles.settings,'svm_model');
        handles.settings=rmfield(handles.settings,'svm_data');
        handles.settings=rmfield(handles.settings,'svm_trainIndices');
    end
    
    % setting the active menu items
    for z = 1:1:length(handles.settings.classHandlers)
        set(handles.settings.classHandlers(z), 'Checked', 'off');
    end
    set(handles.classify_unclass, 'Checked', 'on');
    set(handles.classify_classify, 'Enable', 'off');
    %set(handles.classify_show, 'Enable', 'off');
    set(handles.show_svm, 'Enable', 'off');
    if handles.settings.numberOfClasses>=2
        set(handles.classify_train,'Enable','on');
    else
        set(handles.classify_train,'Enable','off');
    end
    
    guidata(hObject, handles);
    draw();
end
%end
end

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function axes1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
old_distance = 1000000000000000000;
best_nucleus = 0;
CurrentPoint3d = get(hObject, 'CurrentPoint');
CurrentPoint2d = [(CurrentPoint3d(1,1)) (CurrentPoint3d(1,2))];
candidates = find(...
    (handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(:,1)>(CurrentPoint2d(1,1)-20))& ...
    (handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(:,1)<(CurrentPoint2d(1,1)+20))& ...
    (handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(:,2)>(CurrentPoint2d(1,2)-20))& ...
    (handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(:,2)<(CurrentPoint2d(1,2)+20)));
if(~isempty(candidates))
    if(length(candidates) ~= 1)
        for t = 1:1:length(candidates)
            nucleus(1,1) = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(candidates(t),1);
            nucleus(1,2) = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(candidates(t),2);
            distance = abs(CurrentPoint2d(1,1)-nucleus(1,1))+abs(CurrentPoint2d(1,2)-nucleus(1,2));
            if (distance < old_distance)
                old_distance = distance;
                best_nucleus = candidates(t);
            end
        end
    else
        best_nucleus = candidates(1);
    end
    if strcmp(get(handles.figure1,'SelectionType'),'normal')
        if handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1 % WE ARE IN THE PANEL
            
            orig_nucleus=handles.Measurements{handles.settings.plate_nr}.Nuclei.Original_nucleus_index{handles.settings.image_nr}(best_nucleus);
            orig_image=handles.Measurements{handles.settings.plate_nr}.Nuclei.Original_image_index{handles.settings.image_nr}(best_nucleus);
            
            % Adding the information both on the original image and the panel image
            handles.settings.nucleusClassNumber{handles.settings.plate_nr}{orig_image}(orig_nucleus,1) = handles.settings.currentClass;
            handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(best_nucleus,1) = handles.settings.currentClass;
            handles.settings.clicced_nucleus=best_nucleus;
        else
            handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(best_nucleus,1) = handles.settings.currentClass;
            handles.settings.clicced_nucleus=best_nucleus;
        end
        %handles.settings.nucleusClassNumber{handles.settings.image_nr}(best_nucleus,2) = 1;
    end
end
if strcmp(get(handles.figure1,'SelectionType'),'normal')
    % draw numbers here
    guidata(gcf, handles);
    draw_one();
else
    
    table=cell(0);
    row=0;
    for field=1:length(handles.settings.Measurement_names)
        if handles.settings.classifySetup(field)==1 %the current datafield is used
            try
                cut=strfind(handles.settings.Measurement_names{field},'_');
                fieldname1=handles.settings.Measurement_names{field}(1:(cut-1));
                fieldname2=handles.settings.Measurement_names{field}((cut+1):end);
                try
                    subtypes=handles.Measurements{handles.settings.plate_nr}.(fieldname1).([fieldname2,'Features']);
                catch
                    try
                        nonemptyimage=find(not(isempty(handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2))));
                        nonemptyimage=nonemptyimage(1);
                        subs=size(handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){nonemptyimage},2);
                        subtypes=cell(0);
                        for s=1:subs
                            subtypes{s}=['NoName_',num2str(s)];
                        end
                    end
                end
                for subtype=1:length(subtypes)
                    try
                        row=row+1;
                        fieldname3=subtypes{subtype};
                        value=handles.Measurements{handles.settings.plate_nr}.(fieldname1).(fieldname2){handles.settings.image_nr}(best_nucleus,subtype);
                        fullname=[fieldname1,'-',fieldname2,'-',fieldname3,': '];
                        
                        table{row,1}=fullname;
                        table{row,2}=num2str(value);
                    end
                end
            end
        end
    end
    
    %keyboard
    figure
    uitable('Data',table,'Units','normalized','Position',[0 0 1 1]); end

end

% --------------------------------------------------------------------
function initialize()
% get handles from current figure
handles = guidata(gcf);

handles.settings = struct;
handles.Measurements = cell(0,0);
handles.picture = struct;
handles.settings.showRedChannel = 1;
handles.current_settings.showRedChannel = 0;
handles.settings.showGreenChannel = 1;
handles.current_settings.showGreenChannel = 0;
handles.settings.showBlueChannel = 1;
handles.current_settings.showBlueChannel = 0;
handles.settings.showFarRedChannel = 1;
handles.current_settings.showFarRedChannel = 0;
handles.settings.showSegmentation = 1;
handles.current_settings.showSegmentation = 0;


handles.settings.showNucleiCenter = 1;

handles.current_settings.showNucleiCenter = 0;
handles.settings.showClassified = 1;
handles.settings.classHandlers(1,1) = 0;
handles.settings.numberOfClasses = 0;
handles.settings.currentClass = 0;
handles.settings.classNames = cell(0,0);
handles.settings.nucleusClassNumber = cell(0,0);
handles.settings.nucleusClassNumberHandle = zeros(2,0);
handles.settings.image_nr = 1;
handles.settings.plate_nr = 1;
handles.current_settings.image_nr = 1;
handles.current_settings.plate_nr = 1;
handles.settings.imageHandle = 0;
handles.settings.crossesHandle = 0;
handles.settings.channel_exists.Blue = 0;
handles.settings.channel_exists.Green = 0;
handles.settings.channel_exists.Red = 0;
handles.settings.channel_exists.FarRed = 0;
handles.settings.rescaleRed = 0;
handles.settings.rescaleGreen = 0;
handles.settings.rescaleBlue = 0;
handles.settings.rescaleFarRed = 0;
handles.settings.rescaleRed_level = 1;
handles.settings.rescaleGreen_level = 1;
handles.settings.rescaleBlue_level = 1;
handles.settings.rescaleFarRed_level = 1;
handles.settings.newrescaleparams = 0;
handles.settings.plate_in_memory = 0;

handles.settings.maximalCameraValue = 65535;

set(handles.axes1, 'ButtonDownFcn', {@axes1_Callback});
set(handles.figure1, 'WindowScrollWheelFcn', {@MouseWheel_Callback});

guidata(gcf, handles);
end

% --------------------------------------------------------------------
function load_data()
handles = guidata(gcf);

try
    handles.Measurements{handles.settings.plate_nr}.Nuclei.Location;
catch
    % load dataset
    disp(['Loading image information for plate: ',num2str(handles.settings.plate_nr)])
    
    PlateHandles = struct();
    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Image_FileNames.mat'));
    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Nuclei_Location.mat'));
    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Image_ObjectCount.mat'));
    
    % Loading a SINGLE FEATURE
    try
        % used to be Cells_AreaShape (but this can be a very large file
        % in some screens...), so why not try Measurements_Nuclei_Children.mat :)
        fprintf('%s: try loading Measurements_Nuclei_Children.mat\n',mfilename)
        strTempFile = format_path(handles.settings.data_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,'Measurements_Nuclei_Children.mat');
        if fileattrib(strTempFile)
            PlateHandles = LoadMeasurements_withCaching(PlateHandles, strTempFile);
        else
            fprintf('%s: file not found ''Measurements_Nuclei_Children.mat''. This measurement should be present, if iBrain was running correctly. \n',mfilename)
        end
    end
    
    
    % loading available iBRAIN SVM cell classifications
    try
        fprintf('%s: attempting to load existing SVMs\n',mfilename)
        for svm=1:length(handles.settings.SVM_available)
            try
                
                % [BS] fails because platenames contains a complete path to the
                % batch directory...
                fprintf('%s: \t ''%s''\n',mfilename,handles.settings.SVM_available{svm})
                strPlateNames = onlyNpcPotentialNetworkPath(handles.settings.platenames{handles.settings.plate_nr});
                if numel(strfind(strPlateNames,filesep)) > 3 && numel(strfind(lower(strPlateNames),'nas'))
                    % assume plate name contains a full path
                    PlateHandles = LoadMeasurements_withCaching(PlateHandles, fullfile(strPlateNames,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
                else
                    % try old code
                    PlateHandles = LoadMeasurements_withCaching(PlateHandles, format_path(npc(handles.settings.data_path),filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'BATCH',filesep,['Measurements_SVM_',handles.settings.SVM_available{svm},'.mat']));
                end
                
            end
        end
    end
    cellFields=fieldnames(PlateHandles.Measurements);
    for iField=cellFields'
        cellFields2=fieldnames(PlateHandles.Measurements.(char(iField)));
        for iField2=cellFields2'
            handles.Measurements{handles.settings.plate_nr}.(char(iField)).(char(iField2)) = PlateHandles.Measurements.(char(iField)).(char(iField2));
        end
    end
    
    
    % Determine if channel exists and find index
    handles = getChannelExistenceAndIndex(handles);
    
    %updating the available channel items
    if handles.settings.channel_exists.Red
        set(handles.view_r,'Enable','on');
    else
        set(handles.view_r,'Enable','off');
    end
    if handles.settings.channel_exists.Green
        set(handles.view_g,'Enable','on');
    else
        set(handles.view_g,'Enable','off');
    end
    if handles.settings.channel_exists.Blue
        set(handles.view_b,'Enable','on');
    else
        set(handles.view_b,'Enable','off');
    end
    if handles.settings.channel_exists.FarRed
        set(handles.view_y,'Enable','on');
    else
        set(handles.view_y,'Enable','off');
    end
    
    guidata(gcf, handles);
end
end

% --------------------------------------------------------------------
function load_picture()
handles = guidata(gcf);
handles = loadImagesFromDiskToHandles(handles);
guidata(gcf,handles);
return;
end

% --------------------------------------------------------------------
function draw_one()
handles = guidata(gcf);

hold on;

if isfield(handles.settings,'clicced_nucleus')
    nucleus_index=handles.settings.clicced_nucleus;
else
    nucleus_index=0;
end

if nucleus_index==0
    %load chirp.mat
    %sound(y,Fs);
else
    try
        delete(handles.settings.nucleusClassNumberHandle(nucleus_index));
    end
    
    position = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(nucleus_index,:);
    
    if handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(nucleus_index,1)~=0 %printing the user classified
        handles.settings.nucleusClassNumberHandle(nucleus_index,1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(nucleus_index,1)));
    else %drawing the SVM result
        if handles.settings.showClassified(1)==1 %drawing the current classification
            handles.settings.nucleusClassNumberHandle(nucleus_index,1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(nucleus_index,2)));
        else
            try
                handles.settings.nucleusClassNumberHandle(nucleus_index,1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.Measurements{handles.settings.plate_nr}.SVM.(handles.settings.SVM_available{find(handles.settings.showClassified)-1}){handles.settings.image_nr}(nucleus_index)));
            catch
                handles.settings.nucleusClassNumberHandle(nucleus_index,1) = text(position(1,1)+3, position(1,2),'');
            end
        end
    end
    uistack(handles.settings.nucleusClassNumberHandle(nucleus_index,1), 'bottom');
    
    if handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(nucleus_index,1) ~= 0
        set(handles.settings.nucleusClassNumberHandle(nucleus_index,1), 'Color', [1 1 1]);
    else
        set(handles.settings.nucleusClassNumberHandle(nucleus_index,1), 'Color', [1 1 0]);
    end
    set(handles.settings.nucleusClassNumberHandle(nucleus_index,1), 'HitTest', 'off');
    
    handles.settings.clicced_nucleus=0;
    
    uistack(handles.settings.crossesHandle, 'bottom');
    uistack(handles.settings.imageHandle, 'bottom');
    uistack(handles.settings.classHandlers, 'top');
    
    guidata(gcf,handles);
end
end

% --------------------------------------------------------------------
function draw()
handles = guidata(gcf);
hold on;
% check current display settings
% draw existing classifications
try
    existing_handles = find(handles.settings.nucleusClassNumberHandle ~= 0);
    delete(handles.settings.nucleusClassNumberHandle(existing_handles));
catch
    %keyboard;
end

% PANEL DISPLAY
try
    
    if handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1
        
        try
            delete(handles.settings.panelHandles);
        end
        classifications=length(handles.settings.SVM_available_panel);
        % getting the classification names PUT THIS TO DRAW
        SVM_classnames={};
        for class=1:classifications
            try
                SVM_classnames{class}{1}=strrep(handles.Measurements{handles.settings.plate_nr}.SVM.([handles.settings.SVM_available_panel{class},'_Features']){1},'_',' ');
                SVM_classnames{class}{2}=strrep(handles.Measurements{handles.settings.plate_nr}.SVM.([handles.settings.SVM_available_panel{class},'_Features']){2},'_',' ');
                
            catch
                SVM_classnames{class}{1}='YES';
                SVM_classnames{class}{2}='NO';
            end
        end
        
        
        xsize=size(handles.picture.BlueChannel,2);
        ysize=size(handles.picture.BlueChannel,1);
        xx=xsize/(classifications+1);
        panelHandles=[];
        
        ypos_delta=6*size(handles.picture.BlueChannel,2)/1100;
        xpos_delta=5*size(handles.picture.BlueChannel,2)/1920;
        
        for class=1:classifications
            panelHandles(end+1)=plot([class*xx class*xx], [0 ysize],'w');
            h=text((class-1)*xx+xpos_delta,ysize-ypos_delta,[strrep(handles.settings.SVM_available_panel{class},'_',' '),': ',SVM_classnames{class}{1}]);
            set(h,'Color',[1 1 1],'FontSize',8,'FontWeight','bold','BackgroundColor',[0 0 0]);
            panelHandles(end+1)=h;
            h=text((class-1)*xx+xpos_delta,ysize/2-ypos_delta,[strrep(handles.settings.SVM_available_panel{class},'_',' '),': ',SVM_classnames{class}{2}]);
            set(h,'Color',[1 1 1],'FontSize',8,'FontWeight','bold','BackgroundColor',[0 0 0]);
            panelHandles(end+1)=h;
        end
        panelHandles(end+1)=plot([0 xx*classifications], [ysize/2 ysize/2],'w');
        h=text(xx*classifications+xpos_delta,ysize-ypos_delta,['OTHERS']);
        set(h,'Color',[1 1 1],'FontSize',8,'FontWeight','bold','BackgroundColor',[0 0 0]);
        panelHandles(end+1)=h;
        handles.settings.panelHandles=panelHandles;
        
    else
        
        delete(handles.settings.panelHandles);
        
    end
    
end

handles.settings.nucleusClassNumberHandle = zeros(length(handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}),1);

if sum(handles.settings.showClassified)>0 %printing the SVM classified value
    if handles.settings.showClassified(1)==1 %drawing the current classification (current are saved in nucleusClassNumber)
        not_zero_nuclei = find( (handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(:,1) ~= 0) | (handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(:,2) ~= 0));
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+2)==1% drawing OLD virus infection scoring
        try
            not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.Nuclei.VirusScreen_ClassicalInfection{handles.settings.image_nr} ~= inf);
        end
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+3)==1% drawing OPTIMAL virus infection scoring
        try
            not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.Nuclei.VirusScreen_OptimalInfection{handles.settings.image_nr} ~= inf);
        end
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+4)==1% drawing CelltypeClassificationPerColumn
        try
            not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.Nuclei.CellTypeClassificationPerColumn{handles.settings.image_nr} ~= 0);
        end
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+5)==1% drawing single feature value
        try
            not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.Cells.AreaShape{handles.settings.image_nr}(:,1) ~= 0);
        end
        
    else %drawing an iBRAIN SVM classification
        try
            not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.SVM.(handles.settings.SVM_available{find(handles.settings.showClassified)-1}){handles.settings.image_nr} ~= 0);
        catch
            not_zero_nuclei = find( (handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(:,1) ~= 0));
        end
    end
else
    not_zero_nuclei = find( (handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(:,1) ~= 0));
end


for u=1:1:length(not_zero_nuclei)
    position = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(not_zero_nuclei(u),:);
    
    if handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(not_zero_nuclei(u),1)~=0 %printing the user classified
        handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(not_zero_nuclei(u),1)));
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+2)==1% drawing OLD virus infection scoring
        foo=handles.Measurements{handles.settings.plate_nr}.Nuclei.VirusScreen_ClassicalInfection{handles.settings.image_nr}(not_zero_nuclei(u),1);
        if isnan(foo)
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('x'));
        elseif foo==1
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i',foo));
        elseif foo==0
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i',2));
        end
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+3)==1% drawing OPTIMAL virus infection scoring
        foo=handles.Measurements{handles.settings.plate_nr}.Nuclei.VirusScreen_OptimalInfection{handles.settings.image_nr}(not_zero_nuclei(u),1);
        if isnan(foo)
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('x'));
        elseif foo==1
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i',foo));
        elseif foo==0
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i',2));
        end
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+4)==1% drawing CellTypeClassificationPerColumn
        handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.Measurements{handles.settings.plate_nr}.Nuclei.CellTypeClassificationPerColumn{handles.settings.image_nr}(not_zero_nuclei(u),1)));
    elseif handles.settings.showClassified(length(handles.settings.SVM_available)+5)==1% drawing single feature
        foo=round(handles.Measurements{handles.settings.plate_nr}.Cells.AreaShape{handles.settings.image_nr}(:,1));
        handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i', foo(not_zero_nuclei(u),1)));
        
    else %drawing the SVM result
        if handles.settings.showClassified(1)==1 %drawing the current classification
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(not_zero_nuclei(u),2)));
        else
            handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1) = text(position(1,1)+3, position(1,2), sprintf('%i', handles.Measurements{handles.settings.plate_nr}.SVM.(handles.settings.SVM_available{find(handles.settings.showClassified)-1}){handles.settings.image_nr}(not_zero_nuclei(u))));
        end
    end
    
    
    uistack(handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1), 'bottom');
    if handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(not_zero_nuclei(u),1) ~= 0
        set(handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1), 'Color', [1 1 1]);
    else
        set(handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1), 'Color', [1 1 0]);
    end
    set(handles.settings.nucleusClassNumberHandle(not_zero_nuclei(u),1), 'HitTest', 'off');
    %keyboard;
end

% draw nuclei centers first (stacking)
if(not(handles.settings.showNucleiCenter == handles.current_settings.showNucleiCenter))| handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1
    % redraw Nuclei Center
    try
        delete(handles.settings.crossesHandle);
    catch
        % no crosses jet, first image
    end
    
    array_size = size(handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr});
    
    for i = 1:1:array_size(1,1)
        nucleus(i,1) = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(i,1);
        nucleus(i,2) = handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}(i,2);
    end
    if array_size(1,1)>0 % if there are detected nuclei
        handles.settings.crossesHandle = plot(nucleus(:,1),nucleus(:,2), '*');
        set(handles.settings.crossesHandle,'MarkerFaceColor',[1 1 1]);
        set(handles.settings.crossesHandle,'MarkerSize',4);
        set(handles.settings.crossesHandle,'Color',[1 1 1]);
        set(handles.settings.crossesHandle,'HitTest','off');
        uistack(handles.settings.crossesHandle, 'bottom');
    end
else
    % keep nuclei center and put them to the bottom of the stack
    uistack(handles.settings.crossesHandle, 'bottom');
end
if(not(handles.settings.showRedChannel == handles.current_settings.showRedChannel && handles.settings.showGreenChannel == handles.current_settings.showGreenChannel ...
        && handles.settings.showBlueChannel == handles.current_settings.showBlueChannel && handles.settings.showFarRedChannel == handles.current_settings.showFarRedChannel ...
        && handles.settings.image_nr == handles.current_settings.image_nr...
        && handles.settings.showSegmentation == handles.current_settings.showSegmentation...
        && handles.settings.plate_nr == handles.current_settings.plate_nr && not(handles.settings.newrescaleparams))) | handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1
    
    % redraw picture
    size_array = size(handles.picture.BlueChannel(:,:));
    show(:,:,:) = zeros(size_array(1,1), size_array(1,2), 3,'uint16');
    
    if(handles.settings.showRedChannel==1 && handles.settings.channel_exists.Red)
        f1=handles.settings.rescaleRed;
        f2=handles.settings.rescaleRed_level;
        show(:,:,1) = 256*((double(handles.picture.RedChannel(:,:))./4096-f1)./(f2-f1));
    end
    
    if(handles.settings.showGreenChannel==1 && handles.settings.channel_exists.Green)
        f1=handles.settings.rescaleGreen;
        f2=handles.settings.rescaleGreen_level;
        show(:,:,2) = 256*((double(handles.picture.GreenChannel(:,:))./4096-f1)./(f2-f1));
    end
    
    if(handles.settings.showBlueChannel==1 && handles.settings.channel_exists.Blue)
        f1=handles.settings.rescaleBlue;
        f2=handles.settings.rescaleBlue_level;
        show(:,:,3) = 256*((double(handles.picture.BlueChannel(:,:))./4096-f1)./(f2-f1));
    end
    
    if(handles.settings.showFarRedChannel==1 && handles.settings.channel_exists.FarRed)
        f1=handles.settings.rescaleFarRed;
        f2=handles.settings.rescaleFarRed_level;
        
        % If no red is displayed, far red will shown in red
        if handles.settings.showRedChannel == 1 && handles.settings.channel_exists.Red == 1;
            show(:,:,1) = show(:,:,1)+uint16(128*((double(handles.picture.FarRedChannel(:,:))./4096-f1)./(f2-f1)));
            show(:,:,2) = show(:,:,2)+uint16(128*((double(handles.picture.FarRedChannel(:,:))./4096-f1)./(f2-f1)));
        else
            show(:,:,1) = uint16(128*((double(handles.picture.FarRedChannel(:,:))./4096-f1)./(f2-f1)));
        end
    end
    
    
    % display segmentation
    if handles.settings.showSegmentation == true
        SegmentationMask = handles.picture.Segmentation;
        if ~isempty(SegmentationMask)
            LinearSegmentationMask = handles.picture.Segmentation(:);
            IndicesForSegmentation = [LinearSegmentationMask; LinearSegmentationMask; LinearSegmentationMask];
            show(IndicesForSegmentation) = handles.settings.maximalCameraValue;
        end
    end
    
    try
        delete(handles.settings.imageHandle);
        handles.settings.imageHandle = 0;
    catch
        handles.settings.imageHandle = 0;
    end
    %figure(handles.axes1);
    %keyboard
    handles.settings.imageHandle = imagesc(uint8(show));
    axis(handles.axes1,'tight');
    %set(handles.axes1,'Visible','off');
    axis(handles.axes1,'equal');
    
    
    updateTitleOfGui(handles,'default');
    
    set(handles.settings.imageHandle,'HitTest','off');
    uistack(handles.settings.imageHandle, 'bottom');
    
    handles.current_settings.showRedChannel = handles.settings.showRedChannel;
    handles.current_settings.showGreenChannel = handles.settings.showGreenChannel;
    handles.current_settings.showBlueChannel = handles.settings.showBlueChannel;
    handles.current_settings.showFarRedChannel = handles.settings.showFarRedChannel;
    handles.current_settings.showSegmentation = handles.settings.showSegmentation;
else
    % keep picture but put move to the bottom of the stack
    uistack(handles.settings.imageHandle, 'bottom');
end
try
    uistack(handles.settings.classHandlers, 'top');
catch
    % no classifications yet
end
handles.current_settings.image_nr = handles.settings.image_nr;
handles.current_settings.plate_nr = handles.settings.plate_nr;


guidata(gcf,handles);
return;
end

% --------------------------------------------------------------------
function zoom_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom;
axis(handles.axes1,'tight');
%set(handles.axes1,'Visible','off');
axis(handles.axes1,'equal');
end

% --------------------------------------------------------------------
function print_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcf,'PaperPositionMode','auto');
print;
end

% --------------------------------------------------------------------
function show_svm_Callback(hObject, eventdata, handles)
% hObject    handle to show_svm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% changed by Pauli
% Now calculates and displays the confusion matrix
handles = guidata(gcf);

data = handles.settings.svm_data;
train_indices=handles.settings.svm_trainIndices;
model=handles.settings.svm_model;

%try
[y2,votes] = mvsvmclass(data.X,model); %classification.. model is done with the training data only %%(find(handles.settings.used_features),:)
%catch
%	[y2,votes] = svmclass(data.X,model); %classification.. model is done with the training data only
%end

for time=1:2
    if time==1
        % first only the training data
        target=[];
        target(:,1)=data.y(train_indices);
        target(:,2)=y2(train_indices);
        figure;
        subplot(2,1,1)
        axis([0 1.5 -0.8 1.1])
        title('Confusion matrix (training set)')
        axis off;
    else
        % second the test data
        target=[];
        max_index=length(y2);
        test_indices=1:max_index;
        test_indices(train_indices)=[];
        target(:,1)=data.y(test_indices);
        target(:,2)=y2(test_indices);
        subplot(2,1,2)
        axis([0 1.5 -0.8 1.1])
        title('Confusion matrix (test set)')
        axis off;
    end
    
    classes=unique(target(:,1));
    matrix=zeros(length(classes));
    for real=1:length(classes)
        real_indices=find(target(:,1)==classes(real));
        classified_values=target(real_indices,2);
        for classified=1:length(classes)
            matrix(classified,real)=length(find(classified_values==classified));
        end
    end
    
    % total values
    matrix(1:length(classes),length(classes)+1)=sum(matrix(1:length(classes),(1:length(classes)))');
    matrix(length(classes)+1,1:length(classes))=sum(matrix(1:length(classes),(1:length(classes))));
    
    % correct percentage
    matrix(length(classes)+2,1:length(classes))=round(100*diag(matrix(1:length(classes),1:length(classes)))'./matrix(length(classes)+1,1:length(classes)));
    
    % drawing all numbers
    for i=1:(length(classes)+1)
        for j=1:(length(classes)+2)
            text((i+1)*0.1,1-(j+1)*0.1,num2str(matrix(j,i)));
        end
    end
    
    % The final score
    score=mean(matrix(length(classes)+2,1:length(classes)));
    h=text(0.02,1-(j+4)*0.1,['Score: ',num2str(score)]);
    set(h,'FontSize',16);
    
    %displaying titles
    for i=1:length(classes)
        h=text((i+1)*0.1,0.9,handles.settings.classNames{i});
        set(h,'Rotation',12);
    end
    h=text((i+2)*0.1,0.9,'Total');
    set(h,'Rotation',12);
    for j=1:length(classes)
        text(0.02,1-(j+1)*0.1,handles.settings.classNames{j});
    end
    text(0.02,1-(j+2)*0.1,'Total');
    text(0.02,1-(j+3)*0.1,'Correct %');
    
    %text(0.4,1,'Manually classified');
    %h=text(0,0.8,'SVM classified');
    %set(h,'Rotation',270);
end

% matWindowSize = [1900/2, 1200/2]
Position = [375  200, 1250, 800]; %[475  300, 950, 600]
set(gcf,'Position',Position);

end

% --------------------------------------------------------------------
function view_jump_Callback(hObject, eventdata, handles)
% hObject    handle to view_jump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%try
% ONLY a simple fix for the panels
if handles.settings.image_nr==length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames)+1
    handles.settings.image_nr=handles.settings.image_nr-1;
end

vargout=jump_to_image(handles.settings,handles.Measurements);

if vargout.plate_nr~=handles.settings.plate_in_memory
    handles.settings.PlateHandles=[];%freeing up memory
    handles.settings.plate_in_memory=0;
end

handles.settings.image_nr=vargout.image_nr;
handles.settings.plate_nr=vargout.plate_nr;
guidata(hObject,handles);

load_data();
load_picture();
draw();
%end

end

% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

end

% --------------------------------------------------------------------
function classify_show_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%handles.settings.showClassified=(1-handles.settings.showClassified);
%guidata(hObject,handles);
%draw();
end

% --------------------------------------------------------------------
function debug_Callback(hObject, eventdata, handles)
% hObject    handle to debug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

keyboard
end

% -----------------------------------------------------------------
function [genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(plate_nr,image_nr,handles)

platenumber=handles.settings.plate_nrs(plate_nr);
replicanumber=handles.settings.plate_replica(plate_nr);
plate_index=find(handles.settings.BASICDATA.PlateNumber(:,1)==platenumber & handles.settings.BASICDATA.ReplicaNumber(:,1)==replicanumber);

nonempty_indices = ~cellfun(@isempty,handles.settings.BASICDATA.ImageIndices(plate_index,:));

min_image_indices = nan(size(nonempty_indices));
max_image_indices = nan(size(nonempty_indices));

min_image_indices(nonempty_indices)=cellfun(@min,handles.settings.BASICDATA.ImageIndices(plate_index,nonempty_indices))';
max_image_indices(nonempty_indices)=cellfun(@max,handles.settings.BASICDATA.ImageIndices(plate_index,nonempty_indices))';
well=find(min_image_indices<=image_nr & max_image_indices>=image_nr);

genename=handles.settings.BASICDATA.GeneData{plate_index,well};
gene_index=find(ismember(handles.settings.genenames,genename));
oligo=handles.settings.BASICDATA.OligoNumber(plate_index,well);
oligo_index=find(handles.settings.possible_oligos==oligo);
replica=handles.settings.BASICDATA.ReplicaNumber(plate_index,well);
replica_index=find(handles.settings.possible_replicas==replica);
end

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% DO NOT REMOVE THIS FUNCTION!!
end

% --------------------------------------------------------------------
function view_next10_Callback(hObject, eventdata, handles)
% hObject    handle to view_next10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.image_nr = handles.settings.image_nr+10;
maximages=length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames);
handles.settings.image_nr = mod(handles.settings.image_nr-1,maximages)+1;
guidata(hObject, handles);
load_picture();
draw();

end

% --------------------------------------------------------------------
function view_previous10_Callback(hObject, eventdata, handles)
% hObject    handle to view_previous10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.image_nr = handles.settings.image_nr-10;
maximages=length(handles.Measurements{handles.settings.plate_nr}.Image.FileNames);
handles.settings.image_nr = mod(handles.settings.image_nr-1,maximages)+1;
guidata(hObject, handles);
load_picture();
draw();

end

% --------------------------------------------------------------------
function classify_rename_Callback(hObject, eventdata, handles)
% hObject    handle to classify_rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    out = classify_gui_renameclass(handles.settings.classNames);
    
    class=out.class;
    name=out.name;
    handles.settings.classNames{class}=name;
    
    % deleting all the classes in the menu
    for class=1:length(handles.settings.classHandlers)
        delete(handles.settings.classHandlers(class));
    end
    handles.settings.classHandlers=[];
    
    %redraw menus
    for t=1:1:length(handles.settings.classNames)
        class_tag = sprintf('%i', t);
        %changeme_dialog('classify_gui_test', handles.figure1);
        try
            class_name = handles.settings.classNames{t,1};
            menu_class_tag = sprintf('%i   ', t);
            menu_class_name = [menu_class_tag class_name];
            handles.settings.classHandlers(t) =  uimenu('Parent',handles.Untitled_4,...
                'Label',menu_class_name,...
                'HandleVisibility','callback', ...
                'Tag', class_tag, ...
                'Callback', {@Generic_Class_Callback});
        catch
            %
        end
    end
    guidata(hObject,handles);
end
end

% --------------------------------------------------------------------
function classify_accept_Callback(hObject, eventdata, handles)
% hObject    handle to classify_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

imagedata=handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr};
indices=find(imagedata(:,1)==0);
imagedata(indices,1)=imagedata(indices,2);
handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}=imagedata;
guidata(hObject,handles);
draw();

end

% --------------------------------------------------------------------
function panel_select_Callback(hObject, eventdata, handles)
% hObject    handle to classify_show_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
items=length(handles.settings.Show_panel_SVMs);

current_item = str2double(get(hObject, 'Tag'));
if isnan(current_item) % the current
    current_item = 1;
end
displaywindow=0;
check=get(handles.settings.SVM_Show_panel_Handlers(current_item), 'Checked');
if strcmp(check,'on')
    set(handles.settings.SVM_Show_panel_Handlers(current_item), 'Checked', 'off');
    handles.settings.Show_panel_SVMs(current_item-1)=0;
elseif strcmp(check,'off')
    set(handles.settings.SVM_Show_panel_Handlers(current_item), 'Checked', 'on');
    handles.settings.Show_panel_SVMs(current_item-1)=1;
end
guidata(hObject, handles);

end
% --------------------------------------------------------------------
function classify_show_current_Callback(hObject, eventdata, handles)
% hObject    handle to classify_show_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
items=length(handles.settings.showClassified);

current_item = str2double(get(hObject, 'Tag'));
if isnan(current_item) % the current
    current_item = 1;
end
displaywindow=0;
check=get(handles.settings.SVM_availableHandlers(current_item), 'Checked');
if strcmp(check,'on')
    set(handles.settings.SVM_availableHandlers(current_item), 'Checked', 'off');
    handles.settings.showClassified(current_item)=0;
elseif strcmp(check,'off')
    %removing existing checked tics
    for item=1:items
        set(handles.settings.SVM_availableHandlers(item), 'Checked', 'off');
    end
    set(handles.settings.SVM_availableHandlers(current_item), 'Checked', 'on');
    handles.settings.showClassified=zeros(size(handles.settings.showClassified));
    handles.settings.showClassified(current_item)=1;
    %if current_item>1
    displaywindow=1;
    %end
end

guidata(hObject, handles);
draw();

% popping up the classnames in another window
if displaywindow
    try
        h=figure(200);
        clf;
        axis off;
        if current_item==1
            set(gcf,'Position',[380 378 260 420],'MenuBar','none','NumberTitle','off','Name','Current');
            for j=1:length(handles.settings.classNames)
                menu_class_name = [num2str(j),'  ',handles.settings.classNames{j}];
                text(0,1-j*0.05,menu_class_name);
            end
        else
            set(gcf,'Position',[380 378 260 420],'MenuBar','none','NumberTitle','off','Name',handles.settings.SVM_available{current_item-1});
            for j=1:length(handles.Measurements{1}.SVM.([handles.settings.SVM_available{current_item-1},'_Features']))
                menu_class_name = [num2str(j),'  ',strrep(handles.Measurements{1}.SVM.([handles.settings.SVM_available{current_item-1},'_Features']){j},'_','\_')];
                text(0,1-j*0.05,menu_class_name);
            end
        end
    end
end

end

% --------------------------------------------------------------------
function MouseWheel_Callback(hObject, eventdata, handles)
try
    handles = guidata(hObject);
    change=eventdata.VerticalScrollCount;
    
    current_class=handles.settings.currentClass;
    new_class=mod(current_class+change,length(handles.settings.classHandlers)+1);
    
    for z = 1:1:length(handles.settings.classHandlers)
        set(handles.classify_unclass, 'Checked', 'off');
        set(handles.settings.classHandlers(z), 'Checked', 'off');
    end
    if new_class~=0
        set(handles.settings.classHandlers(new_class), 'Checked', 'on');
    else
        set(handles.classify_unclass,'Checked', 'on');
    end
    handles.settings.currentClass = new_class;
    guidata(hObject, handles);
    
    %redrawing the image title
    current_class=new_class;
    if current_class==0
        classname='Unclassify';
    else
        classname=[num2str(current_class),' ',handles.settings.classNames{current_class}];
    end
    
    % BS: added well, site and microscope information
    try
        [~,~,strWellName] = filterimagenamedata(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
        [intImagePosition,strMicroscopeType] = check_image_position(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
    catch objFoo %#ok<NASGU>
        strWellName = '';
        intImagePosition = NaN;
        strMicroscopeType = '';
    end
    
    try
        %             disp('berend was here')
        [genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
        set(gcf,'Name',['Plate: ',num2str(handles.settings.plate_nr),' ',strWellName,', Image: ',num2str(handles.settings.image_nr),' (Gene: ',genename,...
            ', Oligo: ',num2str(oligo),' , Replica: ',num2str(replica),')       Current class: ',classname,]);
    catch
        set(gcf,'Name', sprintf('Plate %d (%s)  |  Well %s  |  Site %d  |  Image %d          Current class: %s', ...
            handles.settings.plate_nr,strMicroscopeType,strWellName,intImagePosition,handles.settings.image_nr,classname))
    end
    
end
end

% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
% COMPLETELY USELESS.. HOW TO GET RID OF THIS FUNCTION?!?!?
end


% --------------------------------------------------------------------
function Show_panel_Callback(hObject, eventdata, handles)
% hObject    handle to Show_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end


% --------------------------------------------------------------------
function Show_panels_Callback(hObject, eventdata, handles)
% hObject    handle to Show_panels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(isempty(strfind(handles.settings.data_path,'50')))
    box_size=40;
elseif not(isempty(strfind(handles.settings.data_path,'DG')))
    box_size=23;
else
    box_size=130;
end

rand_images=10;
disp('Creating classification panels. Please wait a minute...')

% if training a 50K or DG data
if not(isempty(strfind(handles.settings.data_path,'50'))) | not(isempty(strfind(handles.settings.data_path,'DG')))
    apop_name = search_latest_svm_file(handles.settings.data_path,'apop','newest');
    mito_name = search_latest_svm_file(handles.settings.data_path,'mito','newest');
    inte_name = search_latest_svm_file(handles.settings.data_path,'inte','newest');
    blob_name = search_latest_svm_file(handles.settings.data_path,'blob','newest');
    
    classifications=4;
    SVM_available_temp=handles.settings.SVM_available;
    handles.settings.SVM_available_panel={};
    handles.settings.SVM_available_panel{1}=inte_name;
    handles.settings.SVM_available_panel{2}=mito_name;
    handles.settings.SVM_available_panel{3}=apop_name;
    handles.settings.SVM_available_panel{4}=blob_name;
    xsize=size(handles.picture.BlueChannel,2);
    ysize=size(handles.picture.BlueChannel,1);
else
    classifications=sum(handles.settings.Show_panel_SVMs);
    if classifications==0
        disp('PLEASE SELECT SVMS FOR THE PANEL!')
        return
    end
    indi=find(handles.settings.Show_panel_SVMs);
    handles.settings.SVM_available_panel={};
    for class=1:classifications
        handles.settings.SVM_available_panel{class}=handles.settings.SVM_available{indi(class)};
    end
    
    %keyboard
    rand_images=30;
    xsize=2*1920;
    ysize=2*1100;
end

current_plate=handles.settings.plate_nr;

% not_zero_nuclei = find(handles.Measurements{handles.settings.plate_nr}.SVM.(handles.settings.SVM_available_panel{find(handles.settings.showClassified)-1}){handles.settings.image_nr} ~= 0);

panel.BlueChannel = uint16(zeros(ysize,xsize));
panel.GreenChannel = uint16(zeros(ysize,xsize));
panel.RedChannel = uint16(zeros(ysize,xsize));
panel.FarRedChannel = uint16(zeros(ysize,xsize));

xcolumn=floor((xsize)/(classifications+1)); %width of the column
yrow=floor(ysize/2);   % heigth of a row
xboxes=floor((xcolumn-5)/box_size); %number of boxes per row
yboxes=floor((yrow-10)/box_size); %number of boxes per column
nuclei=xboxes*yboxes; %total number of boxes
table=reshape(1:nuclei,[yboxes,xboxes]);

box1=zeros(box_size);
box2=zeros(box_size);
box3=zeros(box_size);
box4=zeros(box_size);

images=length(handles.Measurements{current_plate}.Image.FileNames);
handles.Measurements{current_plate}.Nuclei.Location{images+1}=[];
handles.Measurements{current_plate}.Nuclei.Original_nucleus_index{images+1}=[];
handles.Measurements{current_plate}.Nuclei.Original_image_index{images+1}=[];

nucleus_index=0;
for i=1:rand_images%1:1 %taking cells from randomly chosen images from the current plate
    image=ceil(rand*images);
    picture=load_picture_for_panels(current_plate,image);
    
    for class=1:classifications
        for j=1:2 %pos classified, neg classified
            try
                nuclei_indices=find(handles.Measurements{current_plate}.SVM.(handles.settings.SVM_available_panel{class}){image}==j);
            catch
                nuclei_indices=[];
            end
            nuclei_pos=handles.Measurements{current_plate}.Nuclei.Location{image}(nuclei_indices,:);
            for n=(((i-1)*ceil(nuclei/rand_images))+1):((i)*ceil(nuclei/rand_images))
                [y,x]=find(table==n);
                if not(isempty(y)) %goes over for the last image (fills the panel completely)
                    
                    if length(nuclei_indices>0)
                        nucleus=ceil(rand*length(nuclei_indices));
                        z=ceil(nuclei_pos(nucleus,:)); %'CenterX'    'CenterY'
                        box1=imcrop(picture.BlueChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]); %[XMIN YMIN WIDTH HEIGHT]
                        box2=imcrop(picture.GreenChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                        box3=imcrop(picture.RedChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                        box4=imcrop(picture.FarRedChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                        
                        xmin=(class-1)*xcolumn+(x-1)*box_size+1;
                        ymin=ysize-((j-1)*yrow+(y-1)*box_size)-box_size-1; %space for the text
                        
                        panel.BlueChannel((ymin+1):(ymin+size(box1,1)),(xmin+1):(xmin+size(box1,2)))=box1;
                        panel.GreenChannel((ymin+1):(ymin+size(box2,1)),(xmin+1):(xmin+size(box2,2)))=box2;
                        panel.RedChannel((ymin+1):(ymin+size(box3,1)),(xmin+1):(xmin+size(box3,2)))=box3;
                        panel.FarRedChannel((ymin+1):(ymin+size(box4,1)),(xmin+1):(xmin+size(box4,2)))=box4;
                        
                        % creating the pseudodata for the panel
                        nucleus_index=nucleus_index+1;
                        handles.Measurements{current_plate}.Nuclei.Location{images+1}(nucleus_index,:)=[xmin+box_size/2, ymin+box_size/2];
                        handles.Measurements{current_plate}.Nuclei.Original_nucleus_index{images+1}(nucleus_index)=nuclei_indices(nucleus);
                        handles.Measurements{current_plate}.Nuclei.Original_image_index{images+1}(nucleus_index)=image;
                    end
                end
            end
        end
    end
    
    % the others class
    others=zeros(size(handles.Measurements{current_plate}.SVM.(handles.settings.SVM_available_panel{1}){image}));
    for class=1:classifications
        try
            others=others+double(handles.Measurements{current_plate}.SVM.(handles.settings.SVM_available_panel{class}){image}==2);
        end
    end
    
    nuclei_indices=find(others==classifications);
    nuclei_pos=handles.Measurements{current_plate}.Nuclei.Location{image}(nuclei_indices,:);
    table2=reshape(1:2*nuclei,[2*yboxes,xboxes]);
    for n=(((i-1)*ceil(2*nuclei/rand_images))+1):((i)*ceil(2*nuclei/rand_images))
        [y,x]=find(table2==n);
        if not(isempty(y)) %goes over for the last image (fills the panel completely)
            
            if length(nuclei_indices>0)
                nucleus=ceil(rand*length(nuclei_indices));
                z=ceil(nuclei_pos(nucleus,:)); %'CenterX'    'CenterY'
                box1=imcrop(picture.BlueChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]); %[XMIN YMIN WIDTH HEIGHT]
                box2=imcrop(picture.GreenChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                box3=imcrop(picture.RedChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                box4=imcrop(picture.FarRedChannel,[z(1)-box_size/2,z(2)-box_size/2,box_size,box_size]);
                
                xmin=classifications*xcolumn+(x-1)*box_size+1;
                ymin=ysize-((y-1)*box_size)-box_size-1; %space for the text
                
                panel.BlueChannel((ymin+1):(ymin+size(box1,1)),(xmin+1):(xmin+size(box1,2)))=box1;
                panel.GreenChannel((ymin+1):(ymin+size(box2,1)),(xmin+1):(xmin+size(box2,2)))=box2;
                panel.RedChannel((ymin+1):(ymin+size(box3,1)),(xmin+1):(xmin+size(box3,2)))=box3;
                panel.FarRedChannel((ymin+1):(ymin+size(box4,1)),(xmin+1):(xmin+size(box4,2)))=box4;
                
                % creating the pseudodata for the panel
                nucleus_index=nucleus_index+1;
                handles.Measurements{current_plate}.Nuclei.Location{images+1}(nucleus_index,:)=[xmin+box_size/2, ymin+box_size/2];
                handles.Measurements{current_plate}.Nuclei.Original_nucleus_index{images+1}(nucleus_index)=nuclei_indices(nucleus);
                handles.Measurements{current_plate}.Nuclei.Original_image_index{images+1}(nucleus_index)=image;
                
            end
            
        end
    end
    
    
end

% activating the panel on the tool
handles.settings.PlateHandles=[];%freeing up memory
handles.settings.plate_in_memory=0;

handles.settings.image_nr=images+1;
handles.settings.plate_nr=current_plate;
handles.settings.nucleusClassNumber{current_plate}{images+1}=zeros(nucleus_index,2);
guidata(hObject,handles);

if(not(handles.settings.channel_exists.Blue == 0))
    handles.picture.BlueChannel = panel.BlueChannel;
else
    handles.picture.BlueChannel = uint16(zeros(ysize,xsize));
end
if(not(handles.settings.channel_exists.Green == 0))
    handles.picture.GreenChannel = panel.GreenChannel;
else
    handles.picture.GreenChannel = uint16(zeros(ysize,xsize));
end
if(not(handles.settings.channel_exists.Red == 0))
    handles.picture.RedChannel = panel.RedChannel;
else
    handles.picture.RedChannel = uint16(zeros(ysize,xsize));
end
if(not(handles.settings.channel_exists.FarRed == 0))
    handles.picture.FarRedChannel = panel.FarRedChannel;
else
    handles.picture.FarRedChannel = uint16(zeros(ysize,xsize));
end

handles.settings.showClassified=zeros(size(handles.settings.showClassified));
handles.settings.showClassified(1)=1;
guidata(gcf,handles);
draw();



end
% --------------------------------------------------------------------
function picture=load_picture_for_panels(plate_nr,image_nr)
handles = guidata(gcf);
disp(['Loading image: ',num2str(image_nr)])

handles=loadImagesFromDiskToHandles(handles);

picture.BlueChannel = handles.picture.BlueChannel;
picture.GreenChannel = handles.picture.GreenChannel;
picture.RedChannel = handles.picture.RedChannel;
picture.FarRedChannel = handles.picture.FarRedChannel;

end
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end
% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

function checkDependencies
% Checking for required toolboxes
expected_version='2.11';
try
    if verLessThan('stprtool', expected_version)
        warndlg(sprintf(...
            ['Wrong version of Statistical Pattern Recognition Too'...
            'lbox for machine learning (stprtool). Expected versio'...
            'n is %s'], expected_version), 'Wrong stprtool version')
    end
catch exception
    if ~isempty(regexp(exception.message, 'not found', 'match'))
        warndlg(...
            ['Missing Statistical Pattern Recognition Toolbox for '...
            'machine learning (stprtool). Make sure it is own your'...
            ' MATLAB path or download it at http://cmp.felk.cvut.c'...
            'z /cmp/software/stprtool/index.html'], 'Missing tlbx')
    else
        warndlg(sprintf('Unknown dependency error: %s.', ...
            exception.message),'Unknown dependency error')
    end
end
end


% --------------------------------------------------------------------
function is_multiplate_Callback(hObject, eventdata, handles)
% hObject    handle to is_multiplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Inverse status/update application wide settings
checked_property = get(handles.is_multiplate, 'Checked');

if strcmp(checked_property, 'on')
    set(handles.is_multiplate, 'Checked', 'off');
    ClassifyGui.ismultiplate(false);
else
    set(handles.is_multiplate, 'Checked', 'on');
    ClassifyGui.ismultiplate(true);
end

% Update handles
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function is_multiplate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to is_multiplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Give initial state as configured.
if ClassifyGui.ismultiplate()
    set(hObject, 'Checked', 'on');
end

end


function handles=loadImagesFromDiskToHandles(handles)
% Load Segmentation
handles = loadSegmentationFromDiskToHandles(handles);
handles = getImageDimensions(handles,handles.picture.Segmentation);


% [TS-comment: I have left this piece of code unchanged since its function
% seems unclear to me. It seems to be a way to initialize the number of
% nuclei]
try  %
    handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr}(1,1);
catch %#ok<*CTCH>
    % THIS MIGHT BE WRONG SOMETIMES. USE OBJECT COUNT
    handles.settings.nucleusClassNumber{handles.settings.plate_nr}{handles.settings.image_nr} = zeros(length(handles.Measurements{handles.settings.plate_nr}.Nuclei.Location{handles.settings.image_nr}),2);
end
% [TS-comment-end]


handles = obtainChannelImage(handles,'Blue');
handles = obtainChannelImage(handles,'Green');
handles = obtainChannelImage(handles,'Red');
handles = obtainChannelImage(handles,'FarRed');
end


function handles = obtainChannelImage(handles,NameOfChannel)

ImageDimensions = handles.settings.ImageDimensions;


% load pictures
if handles.settings.channel_exists.Blue
    image_name_blue = handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}(handles.settings.blue_index);
end
if handles.settings.channel_exists.Green
    image_name_green = handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}(handles.settings.green_index);
end
if handles.settings.channel_exists.Red
    image_name_red = handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}(handles.settings.red_index);
end
if handles.settings.channel_exists.FarRed
    image_name_farred = handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}(handles.settings.farred_index);
end


switch NameOfChannel
    case 'Blue'
        if(not(handles.settings.channel_exists.Blue == 0)) && handles.settings.showBlueChannel==1
            handles.picture.BlueChannel = readImages_withIlluminationCorrection(format_path(handles.settings.image_path,filesep,handles.settings.platenames{handles.settings.plate_nr}),image_name_blue{1},handles);
        else
            handles.picture.BlueChannel(:,:) = zeros(ImageDimensions,'uint16');
        end
        
    case 'Green'
        if(not(handles.settings.channel_exists.Green == 0)) && handles.settings.showGreenChannel==1
            handles.picture.GreenChannel = readImages_withIlluminationCorrection(format_path(handles.settings.image_path,filesep,handles.settings.platenames{handles.settings.plate_nr}),image_name_green{1},handles);
        else
            handles.picture.GreenChannel(:,:) = zeros(ImageDimensions,'uint16');
        end
        
    case 'Red'
        if(not(handles.settings.channel_exists.Red == 0)) && handles.settings.showRedChannel==1
            
            strPathToImage = format_path(handles.settings.image_path,filesep,handles.settings.platenames{handles.settings.plate_nr});
            
            handles.picture.RedChannel = readImages_withIlluminationCorrection(strPathToImage,image_name_red{1},handles);
            
            
            % [TS 14-05-07 included shift for specific plate and channel for a
            % specific experiment of Thomas and Nico. Can be removed in
            % future
            
            % correct shift of image for specific project and plate
            strPlateToShift.A = '140417-BAC-PioneerSet-MultiScan_LN00';
            strPlateToShift.B = 'BAC-PioneerSet-GFP-cycle2';
            
            needsShift = (~isempty(strfind(strPathToImage,strPlateToShift.A)) & ~isempty(strfind(strPathToImage,strPlateToShift.B)));
            
            if needsShift
                ReconstituteImage = zeros(size(handles.picture.RedChannel));
                fixDistance = 38; % constant shift obtained outside of CP or Classify_gui
                
                numRows = size(handles.picture.RedChannel,1);
                ReconstituteImage(fixDistance:end,:) = handles.picture.RedChannel(1:(numRows-fixDistance+1),:);
                handles.picture.RedChannel = ReconstituteImage;
            end
            
            % [TS 14-05-07 end]
            
            
        else
            handles.picture.RedChannel(:,:) = zeros(ImageDimensions,'uint16');
        end
        
    case 'FarRed'
        if(not(handles.settings.channel_exists.FarRed == 0))  && handles.settings.showFarRedChannel==1
            handles.picture.FarRedChannel = readImages_withIlluminationCorrection(format_path(handles.settings.image_path,filesep,handles.settings.platenames{handles.settings.plate_nr}),image_name_farred{1},handles);
        else
            handles.picture.FarRedChannel(:,:) = zeros(ImageDimensions,'uint16');
        end
end

end


function handles = loadSegmentationFromDiskToHandles(handles)

handles.picture.Segmentation = [];
hasAnySegmentationBeenCalculated = false;
joined_edges_cells = [];

isMultiplexProject = isMultiplex(handles);

if handles.settings.showSegmentation
    %     disp('Loading segmentation information ...') % [TS deactivated since
    %     not important information in most cases]
    raw_name=handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1};
    raw_name_withoutEnding = raw_name(1:(end-4)); % there should be a cleaner way (compared to this classify gui default);
    
    % Definitio of possible objects; [TS]: have removed TfVesicles etc.
    % which were in original classify_gui
    segmentation_objects={'_SegmentedNuclei','_SegmentedCells'};
    
    for object=1:length(segmentation_objects)
        currSegmentation = segmentation_objects{object};
        considerLoadingSegmentation = true;
        
        if isMultiplexProject == false % default: no multiplex
            path_cells_segmentation = format_path(handles.settings.image_path,filesep,handles.settings.platenames{handles.settings.plate_nr},filesep,'SEGMENTATION',filesep,[raw_name_withoutEnding,currSegmentation,'.png']);
        else  % is multiplex project
            
            shift = mcyc.loadShiftDescriptor(handles.settings.image_path);
            currentTIFFfolder = handles.settings.image_path;
            
            
            [path_cells_segmentation, considerLoadingSegmentation] = ...
                getPathToSegmentationFileFromOtherCycle(shift,raw_name_withoutEnding,currentTIFFfolder,currSegmentation);
        end
        
        % Check, if file exists
        if considerLoadingSegmentation == true
            if any(fileattrib(path_cells_segmentation)) == false;
                considerLoadingSegmentation = false;
            end
        end
        
        % Create segmentation to display
        if considerLoadingSegmentation
            im_cells=imread(path_cells_segmentation);
            if isMultiplexProject
                % crop segmentation image
                if abs(shift.yShift(handles.settings.image_nr))>shift.maxShift || abs(shift.xShift(handles.settings.image_nr))>shift.maxShift
                    % pretend this is an empty image if shift values are
                    % above predefined cutoff
                    im_cells = double(zeros(size(im_cells(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap))));
                else
                    im_cells = im_cells(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap);
                end
            end
            edges_cells=edge(double(im_cells),'roberts',0);
            
            if hasAnySegmentationBeenCalculated == false
                joined_edges_cells = edges_cells;
                hasAnySegmentationBeenCalculated = true;
            else
                joined_edges_cells = joined_edges_cells | edges_cells;
            end
        end
    end
end

handles.picture.Segmentation = joined_edges_cells;
end


function handles = getImageDimensions(handles,joined_edges_cells)
% check whether this is a multiplexing project
isMultiplexProject = isMultiplex(handles);

% get dimensions of image
if ~isfield(handles.settings,'ImageDimensions')
    if nargin == 2
        if ~isempty(joined_edges_cells)
            handles.settings.ImageDimensions = size(joined_edges_cells);
            return;
        end
    end
    ReferenceImageName = handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1};
    FullPathToReference = format_path(handles.settings.image_path,filesep,...
        handles.settings.platenames{handles.settings.plate_nr},filesep,'TIFF',...
        filesep,ReferenceImageName);
    Im = double(imread(FullPathToReference));
    if isMultiplexProject
        % crop image
        Im = Im(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap);
    end
    handles.settings.ImageDimensions = size(Im);
    
end

end

function updateTitleOfGui(handles,InfoToDisplayInTitle,additionalInfo)

if nargin < 3
    additionalInfo = '';
end

current_class=handles.settings.currentClass;
if current_class==0
    classname='Unclassify';
else
    classname=[num2str(current_class),' ',handles.settings.classNames{current_class}];
end

% BS: added well, site and microscope information
try
    [~,~,strWellName] = filterimagenamedata(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
    [intImagePosition,strMicroscopeType] = check_image_position(handles.Measurements{handles.settings.plate_nr}.Image.FileNames{handles.settings.image_nr}{1,1});
catch objFoo %#ok<NASGU>
    strWellName = '';
    intImagePosition = NaN;
    strMicroscopeType = '';
end

try
    %     [genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
    [genename,~,oligo,~,replica]=getgene(handles.settings.plate_nr,handles.settings.image_nr,handles);
    defaultTitle = ['Plate: ',num2str(handles.settings.plate_nr),' ',strWellName,', Image: ',num2str(handles.settings.image_nr),' (Gene: ',genename,...
        ', Oligo: ',num2str(oligo),' , Replica: ',num2str(replica),')            Current class: ',classname,];
catch  dummyFoo %#ok<NASGU>
    defaultTitle = sprintf('Plate %d (%s)  |  Well %s  |  Site %d  |  Image %d          Current class: %s', ...
        handles.settings.plate_nr,strMicroscopeType,strWellName,intImagePosition,handles.settings.image_nr,classname);
end

InfoToDisplayInTitle = lower(InfoToDisplayInTitle);
switch InfoToDisplayInTitle
    case 'default'
        DisplayAsTitle = defaultTitle;
    case 'classificationinprogress'
        DisplayAsTitle = [defaultTitle ' - classification in progress'];
    case 'classificationdone'
        DisplayAsTitle = [defaultTitle ' - classification finished'];
    case 'traininginprogress'
        DisplayAsTitle = [defaultTitle ' - training in progress'];
    case 'trainingdone';
        DisplayAsTitle = [defaultTitle ' - training finished  - Score:' num2str(additionalInfo)];
end

set(gcf,'Name',DisplayAsTitle);

end

function potentialNetworkPath = onlyNpcPotentialNetworkPath(potentialNetworkPath)
% for some strange reason, the orginal classify_gui npcs titles, which
% results in many warnings. Here only npc potential network pathes
if any(ismember(potentialNetworkPath,'/\:'))
    potentialNetworkPath = npc(potentialNetworkPath);
end
end

function handles = getChannelExistenceAndIndex(handles)

% Create existence with original heuristics of classify_gui
handles.settings.channel_exists.Green = 0;
handles.settings.channel_exists.Blue = 0;
handles.settings.channel_exists.Red = 0;
handles.settings.channel_exists.FarRed = 0;

handles.settings.blue_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigBlue'));
if ~isempty(handles.settings.blue_index)
    handles.settings.channel_exists.Blue = 1;
end
handles.settings.green_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigGreen'));
if ~isempty(handles.settings.green_index)
    handles.settings.channel_exists.Green = 1;
end
handles.settings.red_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigRed') | strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigRed1'));
if ~isempty(handles.settings.red_index)
    handles.settings.channel_exists.Red = 1;
end
handles.settings.farred_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigFarRed') | strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,'OrigRed3'));
if ~isempty(handles.settings.farred_index)
    handles.settings.channel_exists.FarRed = 1;
end


% get names of channels from settings file, if not channel has been found
if ~doesAnyChannelExist(handles.settings.channel_exists)
    
    settings = getClassifySettingsFromFile(handles);
    if isempty(settings)
        fprintf('Failed to find images called OrigBlue (etc.) in CellProfiler and a classify.local.json file within the project folder \n.');
    elseif isfield(settings,'images')
        if isfield(settings.images,'channelname')
            
            ChannelNames = settings.images.channelname;
            if isfield(ChannelNames,'Blue')
                handles.settings.blue_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,ChannelNames.Blue));
                if ~isempty(handles.settings.blue_index)
                    handles.settings.channel_exists.Blue = 1;
                end
            end
            if isfield(ChannelNames,'Green')
                handles.settings.green_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,ChannelNames.Green));
                if ~isempty(handles.settings.green_index)
                    handles.settings.channel_exists.Green = 1;
                end
            end
            if isfield(ChannelNames,'Red')
                handles.settings.red_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,ChannelNames.Red));
                if ~isempty(handles.settings.red_index)
                    handles.settings.channel_exists.Red = 1;
                end
            end
            if isfield(ChannelNames,'FarRed')
                handles.settings.farred_index = find(strcmp(handles.Measurements{handles.settings.plate_nr}.Image.FileNamesText,ChannelNames.FarRed));
                if ~isempty(handles.settings.farred_index)
                    handles.settings.channel_exists.FarRed = 1;
                end
            end
            
        end
        
        if  ~doesAnyChannelExist(handles.settings.channel_exists)
            fprintf('No channel name set within classify.local.json file . See GlassifyGui.writeExampleSettingsFile \n.');
        end
    end
    
end

end

function Image = readImages_withIlluminationCorrection(BaseDir,imageName,handles)

isMultiplexProject = isMultiplex(handles);

iChannel = check_image_channel(imageName);
strBatchDir = fullfile(BaseDir,filesep,'BATCH');
strImageName = fullfile(BaseDir,filesep,'TIFF',filesep,imageName);

[matMeanImage, matStdImage, CorrectForIllumination] = getIlluminationReferenceWithCaching(strBatchDir, iChannel);


if CorrectForIllumination == true
    Image = double(imread(strImageName));
    Image = IllumCorrect(Image,matMeanImage,matStdImage,true);
else
    Image = double(imread(strImageName));
end

if isMultiplexProject == true
    shift = mcyc.loadShiftDescriptor(BaseDir);
    
    if abs(shift.yShift(handles.settings.image_nr))>shift.maxShift || abs(shift.xShift(handles.settings.image_nr))>shift.maxShift % don't shift images if shift values are very high (reflects empty images)
        % pretend this is an empty image if shift values are
        % above predefined cutoff
        Image = double(zeros(size(Image(1+shift.lowerOverlap : end-shift.upperOverlap, 1+shift.rightOverlap : end-shift.leftOverlap))));
    else
        Image = Image(1+shift.lowerOverlap-shift.yShift(handles.settings.image_nr) : end-(shift.upperOverlap+shift.yShift(handles.settings.image_nr)), 1+shift.rightOverlap-shift.xShift(handles.settings.image_nr) : end-(shift.leftOverlap+shift.xShift(handles.settings.image_nr)));
    end
end

% convert back to integer
Image = uint16(Image);

end

function [matMeanImage, matStdImage, CorrectForIllumination] = getIlluminationReferenceWithCaching(strBatchDir, iChannel)
useRAMCaching = true;

[matMeanImage, matStdImage, CorrectForIllumination] = getIlluminationReference(strBatchDir, iChannel,useRAMCaching);
IlluminationReferenceCache{iChannel}.matMeanImage = matMeanImage;
IlluminationReferenceCache{iChannel}.matStdImage = matStdImage;
IlluminationReferenceCache{iChannel}.CorrectForIllumination = CorrectForIllumination;

matMeanImage = IlluminationReferenceCache{iChannel}.matMeanImage;
matStdImage = IlluminationReferenceCache{iChannel}.matStdImage;
CorrectForIllumination = IlluminationReferenceCache{iChannel}.CorrectForIllumination;
end

function doesAnyChannelExist = doesAnyChannelExist(x)
doesAnyChannelExist = x.Blue ~= 0   || x.Green ~= 0     || ...
    x.Red ~= 0    || x.FarRed ~= 0;
end

function settings = getClassifySettingsFromFile(handles)
persistent classifySettingsFromFile;
if isempty(classifySettingsFromFile)
    classifySettingsFromFile = [];
    pathstr = handles.settings.data_path;
    name = 'classify';
    jsonSettingsFile = [pathstr filesep name '.local.json'];
    if os.path.exists(jsonSettingsFile)
        if ~exist('loadjson','file')
            % Please install JSONlab package from
            % http://www.mathworks.com/matlabcentral/fileexchange/33381
            return
        end
        classifySettingsFromFile = loadjson(jsonSettingsFile);
    end
end
settings = classifySettingsFromFile;
end

function dat = loadFileWithCaching(strFileName)
% Initialize Persistent variables for caching
persistent CachedMeasurments;
persistent OriginalPathOfChached;

if isempty(OriginalPathOfChached)
    CachedMeasurments = cell(0);
    OriginalPathOfChached = cell(0);
end

nStrFileName = npc(strFileName);

[isCached, cachedLoc]= ismember(nStrFileName,OriginalPathOfChached);

if ~isCached   % load into cache, if absent there
    cachedLoc = length(CachedMeasurments) + 1;
    OriginalPathOfChached{cachedLoc} = nStrFileName;
    
    [~, strMeasurementName] = fileparts(strFileName);
    
    fprintf('Caching %s ... ',strMeasurementName);
    CachedMeasurments{cachedLoc} = load(strFileName);
    fprintf('complete \n');
    
end

dat = CachedMeasurments{cachedLoc}; % retreive data
end


function [handles,ListOfObjects,ListOfMeasurements] = LoadMeasurements_withCaching(handles, strFileName)
% [TS] : This is a version of the origianl LoadMeasurements_withCaching of iBrain
% basics; in contrast to the Original iBrain version, this one calls a
% caching function

%%%%%%%%%%%%%%%%%%% Start of original function   %%%%%%%%%%%%%
ListOfObjects = {};
ListOfMeasurements = {};

% remove double fileseparators from file name if present, and if not at
% the first index
matDoubleFileSepIX = strfind(strFileName,[filesep,filesep]);
if length(matDoubleFileSepIX) > 1
    if matDoubleFileSepIX(1)==1
        boolStartsWithDoubleFilesep = 1;
    end
    % remove all double fileseparators
    strFileName = strrep(strFileName,[filesep filesep],filesep);
    % if it started with one put the starting file separator back in
    % the string
    if boolStartsWithDoubleFilesep
        strFileName = [filesep,strFileName];
    end
end

if not(isstruct(handles))
    error('LoadMeasurements_withCaching: Handles should be a valid structure variable.')
end

try
    % [TS] Altered loading routine: now call local version which includes caching
    tempHandles = loadFileWithCaching(strFileName);
    % [TS]: end of insert / modification
catch ME
    fprintf('%s: error loading %s\n',mfilename,strFileName)
    fprintf('%s: error message %s\n',mfilename,ME.message)
    fprintf('%s: error message %s\n',mfilename,ME.identifier)
    error(['LoadMeasurements_withCaching: Unable to load ', strFileName]);
end

if isfield(tempHandles, 'handles') && isfield(tempHandles.handles, 'Measurements')
    tempHandles.Measurements = tempHandles.handles.Measurements;
    tempHandles = rmfield(tempHandles,'handles');
elseif not(isfield(tempHandles, 'Measurements'))
    error('LoadMeasurements_withCaching: Input file does not contain a Measurements field');
end

newHandles = handles;

if not(isfield(newHandles, 'Measurements'))
    % if the struct didnt have any Measurements field, dump everything in as
    % is, we will not overwrite anything.
    newHandles.Measurements = tempHandles.Measurements;
else
    ListOfObjects = fieldnames(tempHandles.Measurements);
    for i = 1:length(ListOfObjects)
        ListOfCurrentMeasurements = fieldnames(tempHandles.Measurements.(char(ListOfObjects(i))));
        ListOfMeasurements = [ListOfMeasurements;ListOfCurrentMeasurements]; %#ok<AGROW>
        if not(isfield(newHandles.Measurements, ListOfObjects(i)))
            % if the first field wasn't already present we can add it as is
            newHandles.Measurements.(char(ListOfObjects(i))) = tempHandles.Measurements.(char(ListOfObjects(i)));
        else
            % else we need to look for fields inside the
            % Measurements.ObjectField which weren't already present
            for ii = 1:length(ListOfCurrentMeasurements)
                % check if measurement was already present, if so, only
                % fill in the measurements that are present in this
                % particular measurement file (COMPATIBILITY WITH PARTIAL CLUSTER RESULT FILES)
                
                if not(isfield(newHandles.Measurements.(char(ListOfObjects(i))), ListOfCurrentMeasurements(ii) ))
                    %                         disp(sprintf('copying handles.Measurements.%s.%s',(char(ListOfObjects(i))),char(ListOfCurrentMeasurements(ii))))
                    newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii))) = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii)));
                else
                    
                    % find measurements indices that are present, and
                    % only fill in those..
                    if iscell(tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii))))
                        % for cells
                        matMeasurementIndexes = find(~cellfun('isempty',tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii)))));
                        for iii = 1:length(matMeasurementIndexes)
                            newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii))){matMeasurementIndexes(iii)} = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii))){matMeasurementIndexes(iii)};
                        end
                    else
                        % for matrices (OutOfFocus exception... perhaps not smart?)
                        matMeasurementIndexes = find(tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii))));
                        newHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii)))(matMeasurementIndexes) = tempHandles.Measurements.(char(ListOfObjects(i))).(char(ListOfCurrentMeasurements(ii)))(matMeasurementIndexes);
                    end
                end
            end
        end
    end
end
handles = newHandles;
end

function amMultiplex = isMultiplex(handles)
% check whether this is a multiplexing project

putativePlatePath  = handles.settings.image_path;

doChaching = true;
doPrint = true;

amMultiplex = mcyc.checkIfMultiplex(putativePlatePath, doChaching, doPrint);

end


function Nuclei_index = getIndexOfNuclei(foo)

Nuclei_index = grabColumnIndex(foo, 'Nuclei');

% foo = foo.ObjectCountFeatures;
% % Old code
% for g=1:length(foo)
%     if not(isempty(strfind(foo{g},'Nuclei')))
%         Nuclei_index=g;
%     end
% end


end



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
