function varargout = classify_gui_removeclass(varargin)
% CLASSIFY_GUI_REMOVECLASS M-file for classify_gui_removeclass.fig
%      CLASSIFY_GUI_REMOVECLASS, by itself, creates a new CLASSIFY_GUI_REMOVECLASS or raises the existing
%      singleton*.
%
%      H = CLASSIFY_GUI_REMOVECLASS returns the handle to a new CLASSIFY_GUI_REMOVECLASS or the handle to
%      the existing singleton*.
%
%      CLASSIFY_GUI_REMOVECLASS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASSIFY_GUI_REMOVECLASS.M with the given input arguments.
%
%      CLASSIFY_GUI_REMOVECLASS('Property','Value',...) creates a new CLASSIFY_GUI_REMOVECLASS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before classify_gui_removeclass_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classify_gui_removeclass_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classify_gui_removeclass

% Last Modified by GUIDE v2.5 17-Jan-2008 11:44:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classify_gui_removeclass_OpeningFcn, ...
                   'gui_OutputFcn',  @classify_gui_removeclass_OutputFcn, ...
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


% --- Executes just before classify_gui_removeclass is made visible.
function classify_gui_removeclass_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to classify_gui_removeclass (see VARARGIN)

% Choose default command line output for classify_gui_removeclass
handles.output = hObject;

set(handles.popupmenu1,'String',varargin{1});
%keyboard

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes classify_gui_removeclass wait for user response (see UIRESUME)
% uiwait(handles.figure1);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = classify_gui_removeclass_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.class;
delete(handles.figure1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.class = get(handles.popupmenu1, 'Value');
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


