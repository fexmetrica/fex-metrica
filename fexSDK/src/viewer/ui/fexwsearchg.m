function varargout = fexwsearchg(varargin)
%
% FEXWSEARCHG - Fex Metrica & Fex Viewer multiple files selector UI.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 18-Jan-2015.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexwsearchg_OpeningFcn, ...
                   'gui_OutputFcn',  @fexwsearchg_OutputFcn, ...
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

% -------------------------------------------------------------------

function fexwsearchg_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% OPENINGFCN - initialize the file search ui

% Add title:
if ~isempty(varargin)
    set(handles.figure1,'name',sprintf('FexSearch: Select %s',varargin{1}));
else
    set(handles.figure1,'name','FexSearch');
end

set(handles.PathStringEdit,'String',pwd);
handles.file_list = ''; 
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.figure1);

% -------------------------------------------------------------------

function varargout = fexwsearchg_OutputFcn(hObject, eventdata, handles) 
%
% OUTPUTFCN - Outputs from this function are returned to the command line.

l = cellstr(get(handles.FileListEditable,'String'));
ind = cellfun(@isempty,l);
varargout{1} =  char(l(ind == 0));
delete(handles.figure1);

% -------------------------------------------------------------------

function SearchButton_Callback(hObject, eventdata, handles)
%
% SEARCHBUTTON - unix recursive search for a file with specific extensions.

% Reinitialize list
set(handles.FileListEditable,'String','');
path_str = get(handles.PathStringEdit,'String');
if isempty(path_str)
% Safecheck for path search
    path_str = pwd;
    set(handles.PathStringEdit,'String',pwd);
end

path_wch = get(handles.WildCharBox,'String');
if isempty(path_wch)
% Safecheck for wildchar
    path_wch = '.*';
    set(handles.WildCharBox,'String',path_wch);
end

if ismember(upper(computer),{'MACI64','GLNXA64'})
    cmd = sprintf('find "%s" -name "%s" | sort',path_str,path_wch);
else
% Fixme: this was not tested.
    % cmd = sprintf('find "%s" %s',path_wch,path_str);
    cmd = sprintf('dir %s %s',path_wch,path_str);
end
[~,list] = system(cmd);
if ~isempty(list)
    set(handles.FileListEditable,'String',list);
    set(handles.FileListEditable,'Enable','on');
else
    set(handles.FileListEditable,'String','No file found ... ');
end
guidata(hObject, handles);

% -----------------------------------------------------------------

function WildCharBox_Callback(hObject, eventdata, handles)
%
% WILDCHARBOX - set wild char and update list automatically

path_str = get(handles.PathStringEdit,'String');
if isempty(path_str)
% Safecheck for path search
    path_str = pwd;
    set(handles.PathStringEdit,'String',pwd);
end

path_wch = get(handles.WildCharBox,'String');
if isempty(path_wch)
% Safecheck for wildchar
    path_wch = '.*';
    set(handles.WildCharBox,'String',path_wch);
end

% Generate unix cmmand -- this won't work on windows 
cmd = sprintf('find "%s" -name "%s" | sort',path_str,path_wch);
[~,list] = unix(cmd);
if ~isempty(list)
    set(handles.FileListEditable,'String',list);
    set(handles.FileListEditable,'Enable','on');
else
    set(handles.FileListEditable,'String','No file found ... ');
end
guidata(hObject, handles);

% -----------------------------------------------------------------

function CancelSearch_Callback(hObject, eventdata, handles)
%
% CANCELSEARCH - 

set(handles.FileListEditable,'String','');
guidata(hObject, handles);
uiresume(handles.figure1);

% -----------------------------------------------------------------

function OpenFilesButton_Callback(hObject, eventdata, handles)
%
% OPENFILES - use string selected and exit
uiresume(handles.figure1);

% -----------------------------------------------------------------

function PathSearchButton_Callback(hObject, eventdata, handles)
%
% PATHSEARCHBUTTON - search path button.

folder_name = uigetdir;
if ~isempty(folder_name)
    set(handles.PathStringEdit,'String',folder_name);
end
guidata(hObject, handles);

% -----------------------------------------------------------------

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% CLOSEREQUESTFCN - Executes when user attempts to close figure1.

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(handles.figure1);
end
