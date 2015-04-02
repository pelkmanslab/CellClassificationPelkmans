function varargout = classify_gui_config(varargin)
% CLASSIFY_GUI_CONFIG M-file for classify_gui_config.fig
%      CLASSIFY_GUI_CONFIG, by itself, creates a new CLASSIFY_GUI_CONFIG or raises the existing
%      singleton*.
%
%      H = CLASSIFY_GUI_CONFIG returns the handle to a new CLASSIFY_GUI_CONFIG or the handle to
%      the existing singleton*.
%
%      CLASSIFY_GUI_CONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASSIFY_GUI_CONFIG.M with the given input arguments.
%
%      CLASSIFY_GUI_CONFIG('Property','Value',...) creates a new CLASSIFY_GUI_CONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before classify_gui_config_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classify_gui_config_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classify_gui_config

% Last Modified by GUIDE v2.5 13-May-2013 14:33:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classify_gui_config_OpeningFcn, ...
                   'gui_OutputFcn',  @classify_gui_config_OutputFcn, ...
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


% --- Executes just before classify_gui_config is made visible.
function classify_gui_config_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to classify_gui_config (see VARARGIN)

% Choose default command line output for classify_gui_config
handles.output = hObject;
handles.settings = struct;

% If there is the classify_gui_path file in the matlabroot, retreive the
% last used path and fill it in the text/path edit field [BS]
% Use userdir instead of matlabroot to guarantee settings are placed into 
% a writable folder [yy]
userdir = ClassifyGui.getuserdir();
strPathFile = fullfile(userdir, 'classify_gui_path.mat');
if fileattrib(strPathFile)
    %try
        load(strPathFile,'strLastSavedPath');
        if ischar(strLastSavedPath) & fileattrib(strLastSavedPath)
            set(handles.data_path, 'String', strLastSavedPath);
            guidata(hObject, handles);
        end
    %catch
        % failed to load last used path
    %end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes classify_gui_config wait for user response (see UIRESUME)
% uiwait(handles.figure1);

uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = classify_gui_config_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.settings;
delete(handles.figure1);



function data_path_Callback(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_path as text
%        str2double(get(hObject,'String')) returns contents of data_path as a double


% --- Executes during object creation, after setting all properties.
function data_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
%function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%    set(hObject,'BackgroundColor','white');
%end


% --- Executes on button press in Ok.
function Ok_Callback(hObject, eventdata, handles)
% hObject    handle to Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.settings.data_path = get(handles.data_path, 'String');
handles.settings.image_path = get(handles.data_path, 'String');%get(handles.edit2, 'String');
handles.settings.is_multiplate = get(handles.checkboxIsMultiplate, 'Value');
if handles.settings.is_multiplate
    ClassifyGui.ismultiplate(true);
else
    ClassifyGui.ismultiplate(false);
end
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in pushbutton3. %BROWSE BUTTON
function pushbutton3_Callback(hObject, eventdata, handles) 
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdir = ClassifyGui.getuserdir();
strPathFile = fullfile(userdir,'classify_gui_path.mat');
strLastSavedPath = '';
if fileattrib(strPathFile)
    try
        load(strPathFile,'strLastSavedPath');
        if ~ischar(strLastSavedPath)
            strLastSavedPath = '';
        end
    catch
        % failed to load last used path
    end
end

directory = uigetdir(strLastSavedPath);

if directory==0
    return
end

ibrain_directory = directory;%[directory '\BATCH\'];

% store the last used path in the pref file
try
    if ~isempty(directory) & ~(directory==0)    
        strLastSavedPath = directory;
        save(strPathFile,'strLastSavedPath')
        
    end
catch
    % failed to save classify_gui_path.mat
end

set(handles.data_path, 'String', ibrain_directory);
%set(handles.edit2, 'String', picture_directory);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function checkboxIsMultiplate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkboxIsMultiplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value', ClassifyGui.ismultiplate())
