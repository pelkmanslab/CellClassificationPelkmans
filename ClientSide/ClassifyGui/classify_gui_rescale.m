function varargout = classify_gui_rescale(varargin)
    % CLASSIFY_GUI_RESCALE M-file for classify_gui_rescale.fig
    %      CLASSIFY_GUI_RESCALE, by itself, creates a new CLASSIFY_GUI_RESCALE or raises the existing
    %      singleton*.
    %
    %      H = CLASSIFY_GUI_RESCALE returns the handle to a new CLASSIFY_GUI_RESCALE or the handle to
    %      the existing singleton*.
    %
    %      CLASSIFY_GUI_RESCALE('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in CLASSIFY_GUI_RESCALE.M with the given input arguments.
    %
    %      CLASSIFY_GUI_RESCALE('Property','Value',...) creates a new CLASSIFY_GUI_RESCALE or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before classify_gui_rescale_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to classify_gui_rescale_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help classify_gui_rescale

    % Last Modified by GUIDE v2.5 29-Feb-2008 13:37:35

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @classify_gui_rescale_OpeningFcn, ...
                       'gui_OutputFcn',  @classify_gui_rescale_OutputFcn, ...
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

% --- Executes just before classify_gui_rescale is made visible.
function classify_gui_rescale_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to classify_gui_rescale (see VARARGIN)

    % Choose default command line output for classify_gui_rescale
    handles.output = hObject;
    handles.settings = varargin{1}.settings;
    handles.picture = varargin{1}.picture;
   
	rr=handles.settings.rescaleRed;
	gg=handles.settings.rescaleGreen;
	bb=handles.settings.rescaleBlue;
	fr=handles.settings.rescaleFarRed;
	
	rr_level=handles.settings.rescaleRed_level;
	gg_level=handles.settings.rescaleGreen_level;
	bb_level=handles.settings.rescaleBlue_level;
	fr_level=handles.settings.rescaleFarRed_level;
	
    if rr>1 || rr<0
        rr=0;
    end
    if gg>1 || gg<0
        gg=0;
    end
    if bb>1 || bb<0
        bb=0;
    end
    if fr>1 || fr<0
        fr=0;
    end
    
    if rr_level>1 || rr_level<0
        rr_level=1;
    end
    if gg_level>1 || gg_level<0
        gg_level=1;
    end
    if bb_level>1 || bb_level<0
        bb_level=1;
    end
    if fr_level>1 || fr_level<0
        fr_level=1;
    end
    

    set(handles.value_r, 'String',num2str(rr));
    set(handles.value_g, 'String',num2str(gg));
    set(handles.value_b, 'String',num2str(bb));
    set(handles.value_fr, 'String',num2str(fr));
    set(handles.slider1, 'Value',rr);
    set(handles.slider2, 'Value',gg);
    set(handles.slider3, 'Value',bb);
    set(handles.slider4, 'Value',fr);
    set(handles.slider5, 'Value',rr_level);
    set(handles.slider6, 'Value',gg_level);
    set(handles.slider7, 'Value',bb_level);
    set(handles.slider8, 'Value',fr_level);


    
	% Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes classify_gui_rescale wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    set(handles.rescale_axes,'XLim', [0 1440], 'YLim', [0 936]);
    draw();
    uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = classify_gui_rescale_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    returnvals = struct;
    returnvals.settings = handles.settings;
    varargout{1} = returnvals;
    delete(handles.figure1);
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.settings.rescaleRed = get(hObject, 'Value');
    set(handles.value_r, 'String', handles.settings.rescaleRed);
    guidata(hObject, handles);
    draw();
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.settings.rescaleGreen = get(hObject, 'Value');
    set(handles.value_g, 'String', handles.settings.rescaleGreen);
    guidata(hObject, handles);
    draw();
end

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to slider2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
    % hObject    handle to slider3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.settings.rescaleBlue = get(hObject, 'Value');
    set(handles.value_b, 'String', handles.settings.rescaleBlue);
    guidata(hObject, handles);
    draw();
end


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
     % hObject    handle to slider3 (see GCBO)
	 % eventdata  reserved - to be defined in a future version of MATLAB
	 % handles    empty - handles not created until after all CreateFcns called

	 % Hint: slider controls usually have a light gray background.
	 if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor',[.9 .9 .9]);
	 end
end

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.settings.rescaleFarRed = get(hObject, 'Value');
    set(handles.value_fr, 'String', handles.settings.rescaleFarRed);
    guidata(hObject, handles);
    draw();
end

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % hObject    handle to pushbutton1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1);
end

% -----------------------------------------------------------
function draw()
handles = guidata(gcf);
hold on;
size_array = size(handles.picture.BlueChannel(:,:));
show(:,:,:) = zeros(size_array(1,1), size_array(1,2), 3,'uint8');
if(handles.settings.channel_exists.Red)
    %show(:,:,1) = handles.picture.RedChannel(:,:).*2^(0.5*handles.settings.rescaleRed)+handles.settings.rescaleRed_level;
    f1=handles.settings.rescaleRed;
    f2=handles.settings.rescaleRed_level;
    show(:,:,1) =256*((double(handles.picture.RedChannel(:,:))./4096-f1)./(f2-f1));
end
if(handles.settings.channel_exists.Green)
    %show(:,:,2) = handles.picture.GreenChannel(:,:).*2^(0.5*handles.settings.rescaleGreen)+handles.settings.rescaleGreen_level;
    f1=handles.settings.rescaleGreen;
    f2=handles.settings.rescaleGreen_level;
    show(:,:,2) = 256*((double(handles.picture.GreenChannel(:,:))./4096-f1)./(f2-f1));
end
if(handles.settings.channel_exists.Blue)
    %show(:,:,3) = handles.picture.BlueChannel(:,:).*2^(0.5*handles.settings.rescaleBlue)+handles.settings.rescaleBlue_level;
    f1=handles.settings.rescaleBlue;
    f2=handles.settings.rescaleBlue_level;
    show(:,:,3) = 256*((double(handles.picture.BlueChannel(:,:))./4096-f1)./(f2-f1));
end
if(handles.settings.channel_exists.FarRed)
    f1=handles.settings.rescaleFarRed;
    f2=handles.settings.rescaleFarRed_level;

    show(:,:,1) = show(:,:,1)+uint8(128*((double(handles.picture.FarRedChannel(:,:))./4096-f1)./(f2-f1)));
    show(:,:,2) = show(:,:,2)+uint8(128*((double(handles.picture.FarRedChannel(:,:))./4096-f1)./(f2-f1)));
end
try
    delete(handles.imagehandles_rescale);
catch
    %
end
handles.settings.imagehandle_rescale = imagesc(show);
%axis(handles.settings.imagehandle_rescale,'tight');
guidata(gcf, handles);
return;
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.settings.rescaleRed_level = get(hObject, 'Value');
guidata(hObject, handles);
draw();
end

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.settings.rescaleGreen_level = get(hObject, 'Value');
guidata(hObject, handles);
draw();
end

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end
% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.settings.rescaleBlue_level = get(hObject, 'Value');
guidata(hObject, handles);
draw();
end

% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.settings.rescaleFarRed_level = get(hObject, 'Value');
guidata(hObject, handles);
draw();

end
% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

end
