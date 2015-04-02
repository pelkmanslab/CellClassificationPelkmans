function varargout = warn_train_svm(varargin)
% WARN_TRAIN_SVM M-file for warn_train_svm.fig
%      WARN_TRAIN_SVM, by itself, creates a new WARN_TRAIN_SVM or raises the existing
%      singleton*.
%
%      H = WARN_TRAIN_SVM returns the handle to a new WARN_TRAIN_SVM or the handle to
%      the existing singleton*.
%
%      WARN_TRAIN_SVM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WARN_TRAIN_SVM.M with the given input arguments.
%
%      WARN_TRAIN_SVM('Property','Value',...) creates a new WARN_TRAIN_SVM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before warn_train_svm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to warn_train_svm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help warn_train_svm

% Last Modified by GUIDE v2.5 05-Dec-2007 10:28:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @warn_train_svm_OpeningFcn, ...
                   'gui_OutputFcn',  @warn_train_svm_OutputFcn, ...
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


% --- Executes just before warn_train_svm is made visible.
function warn_train_svm_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to warn_train_svm (see VARARGIN)

% Choose default command line output for warn_train_svm
handles.output = hObject;
handles.choice = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes warn_train_svm wait for user response (see UIRESUME)
% uiwait(handles.figure1);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = warn_train_svm_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
delete(handles.figure1);
varargout{1} = handles.choice;



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.choice = 0;
guidata(hObject, handles);
uiresume(handles.figure1);



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.choice = 1;
guidata(hObject, handles);
uiresume(handles.figure1);


