function strPath = format_path(varargin)

strPath=varargin{1};

if ClassifyGui.ismultiplate
    %PlateName=getlastdir(varargin{3}(1:end-1-length(getlastdir(varargin{3}))));
    
    if strcmp(os.path.basename(varargin{3}),'BATCH') == false
        PlateName = os.path.basename(varargin{3});
    else  % if plate name is 'BATCH', try to find better plate name
        TemporaryPlateName = varargin{3};
        if any(strfind(TemporaryPlateName,'/BATCH'))
            TemporaryPlateName = strrep(TemporaryPlateName,'/BATCH','');
        end
        if any(strfind(TemporaryPlateName,'\BATCH'))
            TemporaryPlateName = strrep(TemporaryPlateName,'\BATCH','');
        end
        PlateName = os.path.basename(TemporaryPlateName);
    end
    strPath = fullfile(strPath, PlateName);
elseif strcmp(strPath((end-5):(end-1)),'BATCH')
    strPath = strPath(1:(end-7));
elseif strcmp(strPath((end-4):(end)),'BATCH')
    strPath = strPath(1:(end-6));
end


for i = 4:length(varargin)
    strPath = fullfile(strPath,varargin{i});
end


% remove obvious nonsense paths
TextToSimplify = '/BATCH/BATCH/';
if any(strfind(strPath,TextToSimplify))
    strPath = strrep(strPath,TextToSimplify,'/BATCH/');
end

TextToSimplify = '\BATCH\BATCH\';
if any(strfind(strPath,TextToSimplify))
    strPath = strrep(strPath,TextToSimplify,'\BATCH\');
end

TextToSimplify = '\BATCH\BATCH/';
if any(strfind(strPath,TextToSimplify))
    strPath = strrep(strPath,TextToSimplify,'\BATCH\');
end


end
