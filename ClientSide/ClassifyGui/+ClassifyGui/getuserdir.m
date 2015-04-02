function [ userdir ] = getuserdir( )
%GETUSERDIR Returns user dir where MATLAB can potentially write or store 
%settings
%   Platform independent way to determine a full path to user directory
%   (i.e. a folder writable by user).
%
%   @author: Yauhen Yakimovich <yauhen.yakimovich@uzh.ch>
%
    if ispc 
        userdir= getenv('USERPROFILE');
    else
        userdir= getenv('HOME');
    end
    [stat, attrs] = fileattrib(userdir);
    if ~attrs.('UserWrite')
         errordlg(['User folder is not writable: ' userdir], 'Error', 'modal');
         delete(gcf);
    end
end

