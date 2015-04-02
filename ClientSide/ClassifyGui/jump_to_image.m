function varargout = jump_to_image(varargin)
% JUMP_TO_IMAGE M-file for jump_to_image.fig
%      JUMP_TO_IMAGE, by itself, creates a new JUMP_TO_IMAGE or raises the existing
%      singleton*.
%
%      H = JUMP_TO_IMAGE returns the handle to a new JUMP_TO_IMAGE or the handle to
%      the existing singleton*.
%
%      JUMP_TO_IMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JUMP_TO_IMAGE.M with the given input arguments.
%
%      JUMP_TO_IMAGE('Property','Value',...) creates a new JUMP_TO_IMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jump_to_image_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jump_to_image_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jump_to_image

% Last Modified by GUIDE v2.5 09-Apr-2008 15:02:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jump_to_image_OpeningFcn, ...
                   'gui_OutputFcn',  @jump_to_image_OutputFcn, ...
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


% --- Executes just before jump_to_image is made visible.
function jump_to_image_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jump_to_image (see VARARGIN)

% Choose default command line output for jump_to_image
handles.output = hObject;


% Update handles structure
handles.settings=varargin{1};
handles.Measurements=varargin{2};

% setting up the plate popupmenu
set(handles.popupmenu2,'String',handles.settings.platenames);
handles.goto.plate_nr=handles.settings.plate_nr;
handles.goto.image_nr=handles.settings.image_nr;
set(handles.popupmenu2,'Value',handles.goto.plate_nr);

% setting up the image slider
set(handles.slider1,'Value',handles.goto.image_nr);
set(handles.slider1,'Min',1);
maximages=length(handles.Measurements{handles.goto.plate_nr}.Image.FileNames);
set(handles.slider1,'Max',maximages); 

% settings up the image number in the edit window
set(handles.edit1,'String',{num2str(handles.goto.image_nr)})

%setting up the gene popupmenu
try
	set(handles.popupmenu1,'String',handles.settings.genenames);
catch
	set(handles.popupmenu1,'String','no genes');
end
	
% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
catch 
    [msgstr, msgid] = lasterr;
    disp(sprintf('unable to obtain gene information. message is: \n%s\n%s',msgstr,msgid))
end

%setting up the Gene popupmenu
try
	set(handles.popupmenu1,'Value',gene_index);
catch
	set(handles.popupmenu1,'Value',1);
end
	
%setting up the Oligo popupmenu
try
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
catch
	set(handles.popupmenu3,'String','no oligos');
	set(handles.popupmenu3,'Value',1);
end
	
%setting up the Replica popupmenu
try
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
catch
	set(handles.popupmenu4,'String','no replicas');
	set(handles.popupmenu4,'Value',1);
end
	
%settings up the Classification popupmenu
try
	if isempty(handles.settings.SVM_available)
		set(handles.popupmenu5,'String','no SVM');
		set(handles.popupmenu5,'Value',1);
	else
		set(handles.popupmenu5,'String',handles.settings.SVM_available');
		set(handles.popupmenu5,'Value',1);
	end
catch
	set(handles.popupmenu5,'String','no SVM');
	set(handles.popupmenu5,'Value',1);
end


%settings up the Class popupmenu
try
	classes=handles.Measurements{1}.SVM.([handles.settings.SVM_available{1},'_Features']);
catch
	classes='no classes';
end
set(handles.popupmenu6,'String',classes);
set(handles.popupmenu6,'Value',1);

%settings up the Image popupmenu
images_str=1:100;
set(handles.popupmenu7,'String',cellstr(num2str(images_str')));
set(handles.popupmenu7,'Value',1);

%settings up the Row popupmenu
rows=unique(handles.settings.BASICDATA.WellRow(:));
set(handles.popupmenu8,'String',cellstr(num2str(rows)));
set(handles.popupmenu8,'Value',row);

%settings up the Column popupmenu
cols=unique(handles.settings.BASICDATA.WellCol(:));
set(handles.popupmenu10,'String',cellstr(num2str(cols)));
set(handles.popupmenu10,'Value',column);

guidata(hObject, handles);

% UIWAIT makes jump_to_image wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = jump_to_image_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.goto;
delete(handles.figure1);


% --- Executes on selection change in popupmenu2. PLATE
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

% NOTE: plante_nr is not the same as the masterdata plate number!!
% it is just an index to the folder

handles.goto.plate_nr=get(hObject,'Value');

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
	
	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);
	
	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
	
	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement. IMAGE NUMBER SLIDER
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.goto.image_nr=round(get(hObject,'Value'));

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
end

%setting up the image number editbox
set(handles.edit1,'String',{num2str(handles.goto.image_nr)});

try
	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);
	
	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
	
	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
    
        % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
    
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% IMAGE NUMBER BOX
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.goto.image_nr=str2double(get(hObject,'String'));

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
end

%setting up the image slider
set(handles.slider1,'Value',handles.goto.image_nr);

try
	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);
	
	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
	
	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
         
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1. GENE
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

Oligostr=get(handles.popupmenu3,'String');
oligo=str2double(Oligostr(get(handles.popupmenu3,'Value')));
Replicastr=get(handles.popupmenu4,'String');
replica=str2double(Replicastr(get(handles.popupmenu4,'Value')));

contents = get(handles.popupmenu1,'String');
genename = contents{get(handles.popupmenu1,'Value')};

try
	[handles.goto.plate_nr,handles.goto.image_nr,row,column]=getplateimage(genename,oligo,replica,handles);
	
	% setting up the plate popupmenu
	set(handles.popupmenu2,'Value',handles.goto.plate_nr);
	
	% setting up the image slider
	set(handles.slider1,'Value',handles.goto.image_nr);
	
	% setting up the edit box
	set(handles.edit1,'String',{num2str(handles.goto.image_nr)})
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);

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


% --- Executes on selection change in popupmenu3. OLIGO
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

Oligostr=get(handles.popupmenu3,'String');
oligo=str2double(Oligostr(get(handles.popupmenu3,'Value')));

Replicastr=get(handles.popupmenu4,'String');
replica=str2double(Replicastr(get(handles.popupmenu4,'Value')));

contents = get(handles.popupmenu1,'String');
genename = contents{get(handles.popupmenu1,'Value')};

try
	[handles.goto.plate_nr,handles.goto.image_nr,row,column]=getplateimage(genename,oligo,replica,handles);
	
	% setting up the plate popupmenu
	set(handles.popupmenu2,'Value',handles.goto.plate_nr);
	
	% setting up the image slider
	set(handles.slider1,'Value',handles.goto.image_nr);
	
	% setting up the edit box
	set(handles.edit1,'String',{num2str(handles.goto.image_nr)})
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4. REPLICA
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4

Oligostr=get(handles.popupmenu3,'String');
oligo=str2double(Oligostr(get(handles.popupmenu3,'Value')));
Replicastr=get(handles.popupmenu4,'String');
replica=str2double(Replicastr(get(handles.popupmenu4,'Value')));

contents = get(handles.popupmenu1,'String');
genename = contents{get(handles.popupmenu1,'Value')};

try
	[handles.goto.plate_nr,handles.goto.image_nr,row,column]=getplateimage(genename,oligo,replica,handles);
	
	% setting up the plate popupmenu
	set(handles.popupmenu2,'Value',handles.goto.plate_nr);
	
	% setting up the image slider
	set(handles.slider1,'Value',handles.goto.image_nr);
	
	% setting up the edit box
	set(handles.edit1,'String',{num2str(handles.goto.image_nr)})
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1. OK BUTTON
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);
% -----------------------------------------------------------------
function [genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(plate_nr,image_nr,handles)
platenumber=handles.settings.plate_nrs(plate_nr);
replicanumber=handles.settings.plate_replica(plate_nr);
plate_index=find(handles.settings.BASICDATA.PlateNumber(:,1)==platenumber & handles.settings.BASICDATA.ReplicaNumber(:,1)==replicanumber);

%bs, bugfix. allow to jump to well on non-parsed plate names
if isempty(plate_index) && size(handles.settings.BASICDATA.PlateNumber,1)==1 || isnan(platenumber) && isnan(replicanumber)
    % in all these cases, just process first plate image indices only. with
    % a bit of luck they are the same for multiple plates.
    plate_index = 1;
end

if length(plate_index)>1
    disp('WARNING: current plate scanned many times');
    plate_index=plate_index(1);
elseif isempty(plate_index)
    disp('WARNING: current plate number can not be determined');    
end

nonempty_indices = ~cellfun(@isempty,handles.settings.BASICDATA.ImageIndices(plate_index,:));

min_image_indices = nan(size(nonempty_indices));
max_image_indices = nan(size(nonempty_indices));

min_image_indices(nonempty_indices)=cellfun(@min,handles.settings.BASICDATA.ImageIndices(plate_index,nonempty_indices))';
max_image_indices(nonempty_indices)=cellfun(@max,handles.settings.BASICDATA.ImageIndices(plate_index,nonempty_indices))';
well=find(min_image_indices<=image_nr & max_image_indices>=image_nr);
try
    well=well(1);
    genename=handles.settings.BASICDATA.GeneData{plate_index,well};
    gene_index=find(ismember(handles.settings.genenames,genename));
    oligo=handles.settings.BASICDATA.OligoNumber(plate_index,well);
    oligo_index=find(handles.settings.possible_oligos==oligo);
    replica=handles.settings.BASICDATA.ReplicaNumber(plate_index,well);
    replica_index=find(handles.settings.possible_replicas==replica);
    row=handles.settings.BASICDATA.WellRow(plate_index,well);
    column=handles.settings.BASICDATA.WellCol(plate_index,well);
catch
    genename='no_name';
    gene_index=1;
    oligo=1;
    oligo_index=1;
    replica=1;
    replica_index=1;
    row=1;
    column=1;
end


% -----------------------------------------------------------------
function [plate_nr,image_nr,row,column]=getplateimage(genename,oligo,replica,handles)
try
	[plate,well]=find(strcmpi(handles.settings.BASICDATA.GeneData,genename)& handles.settings.BASICDATA.OligoNumber==oligo & handles.settings.BASICDATA.ReplicaNumber==replica);
	plate_number=handles.settings.BASICDATA.PlateNumber(plate,well);
	foo=handles.settings.plate_nrs;
	foo(handles.settings.plate_replica~=replica)=inf;
	plate_nr=find(foo==plate_number);
	
	image_indices=handles.settings.BASICDATA.ImageIndices{plate,well};
	image_nr=image_indices(1);
    
    column=handles.settings.BASICDATA.WellCol(plate,well);
    row=handles.settings.BASICDATA.WellRow(plate,well);
catch
	disp('IMAGE NOT FOUND!')
	plate_nr=handles.settings.plate_nr;
	image_nr=handles.settings.image_nr;
    [genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(plate_nr,image_nr,handles);
end



% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5

contents = get(hObject,'String');
classification= contents{get(hObject,'Value')};
try
	classes=handles.Measurements{1}.SVM.([classification,'_Features']);
catch
	classes='no classes';
end
	
%settings up the Class popupmenu
set(handles.popupmenu6,'String',classes);
set(handles.popupmenu6,'Value',1);



% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7

number=get(handles.popupmenu7,'Value');
contents = get(handles.popupmenu5,'String');
classification= contents{get(handles.popupmenu5,'Value')};
try
	classes=handles.Measurements{1}.SVM.([classification,'_Features']);
catch
	classes='no classes';
end
class=get(handles.popupmenu6,'Value');
plate=get(handles.popupmenu2,'Value');
%try
	try handles.Measurements{plate}.SVM.(classification);
	catch
		disp('Loading classification data...')
		PlateHandles=struct();
		PlateHandles = LoadMeasurements(PlateHandles, [handles.settings.data_path,filesep,handles.settings.platenames{plate},filesep,'BATCH',filesep,'Measurements_SVM_',handles.settings.SVM_available{get(handles.popupmenu5,'Value')},'.mat']);
		handles.Measurements{plate}.SVM.(classification)=PlateHandles.Measurements.SVM.(classification);
	end
	images=length(handles.Measurements{plate}.SVM.(classification));

	found_class=zeros(1,images);
	for image=1:images
		found_class(image)=length(find(handles.Measurements{plate}.SVM.(classification){image}==class));
	end
	[sorted_values,order]=sort(found_class);

	image_number=order(end-number+1);

	handles.goto.plate_nr=plate;
	handles.goto.image_nr=image_number;

	% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
	[genename,gene_index,oligo,oligo_index,replica,replica_index]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);

	% setting up the image slider
	set(handles.slider1,'Value',handles.goto.image_nr);

	%setting up the image number editbox
	set(handles.edit1,'String',{num2str(handles.goto.image_nr)});

	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);

	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);

	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);

	guidata(hObject, handles);
%end
% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% The ROW
% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8

new_row=round(get(hObject,'Value'));

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
end

% finding out the well index
try
    wellindex=find(handles.settings.BASICDATA.WellRow(handles.goto.plate_nr,:)==new_row & handles.settings.BASICDATA.WellCol(handles.goto.plate_nr,:)==column);
    newimages=handles.settings.BASICDATA.ImageIndices{handles.goto.plate_nr,wellindex};
    newimage=newimages(1);
catch
    newimage=handles.goto.image_nr;
end
handles.goto.image_nr=newimage;

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,newimage,handles);
end

%setting up the image number editbox
set(handles.edit1,'String',{num2str(newimage)});

% setting up the image slider
set(handles.slider1,'Value',newimage);

try
	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);
	
	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
	
	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% The COLUMN
% --- Executes on selection change in popupmenu10.
function popupmenu10_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu10 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu10
new_column=round(get(hObject,'Value'));

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,handles.goto.image_nr,handles);
end

% finding out the well index
try
    wellindex=find(handles.settings.BASICDATA.WellRow(handles.goto.plate_nr,:)==row & handles.settings.BASICDATA.WellCol(handles.goto.plate_nr,:)==new_column);
    newimages=handles.settings.BASICDATA.ImageIndices{handles.goto.plate_nr,wellindex};
    newimage=newimages(1);
catch
    newimage=handles.goto.image_nr;
end
handles.goto.image_nr=newimage;

% DETECTING WHICH IS THE CURRENT GENE, OLIGO AND REPLICA
try
	[genename,gene_index,oligo,oligo_index,replica,replica_index,row,column]=getgene(handles.goto.plate_nr,newimage,handles);
end

%setting up the image number editbox
set(handles.edit1,'String',{num2str(newimage)});

% setting up the image slider
set(handles.slider1,'Value',newimage);

try
	%setting up the Gene popupmenu
	set(handles.popupmenu1,'Value',gene_index);
	
	%setting up the Oligo popupmenu
	set(handles.popupmenu3,'String',cellstr(num2str(handles.settings.possible_oligos)));
	set(handles.popupmenu3,'Value',oligo_index);
	
	%setting up the Replica popupmenu
	set(handles.popupmenu4,'String',cellstr(num2str(handles.settings.possible_replicas)));
	set(handles.popupmenu4,'Value',replica_index);
    
    % Row
    set(handles.popupmenu8,'Value',row);

    % Column
    set(handles.popupmenu10,'Value',column);
end
%keyboard
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


