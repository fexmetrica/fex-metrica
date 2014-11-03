function varargout = fexwsearchg(varargin)
%
% Fex viewer multiple files selector gui.
%__________________________________________________________________________
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 10/31/14.


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


% --- Executes just before fexwsearchg is made visible.
function fexwsearchg_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% Initialization

set(handles.PathStringEdit,'String',pwd);
handles.file_list = '';
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexwsearchg_OutputFcn(hObject, eventdata, handles) 
%
% Output function

varargout{1} = get(handles.FileListEditable,'String');
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function FileListEditable_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FileListEditable_Callback(hObject, eventdata, handles)
%
%
guidata(hObject, handles);


% --- Executes on button press in SearchButton.
function SearchButton_Callback(hObject, eventdata, handles)
%
% Unix recursive search for a file with specific extensions.

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

% Generate unix cmmand -- this won't work on windows 
cmd = sprintf('find %s -name "%s" | sort',path_str,path_wch);
[~,list] = unix(cmd);
if ~isempty(list)
    set(handles.FileListEditable,'String',list);
    set(handles.FileListEditable,'Enable','on');
else
    set(handles.FileListEditable,'String','No file found ... ');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function WildCharBox_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WildCharBox_Callback(hObject, eventdata, handles)
%
% Set wild char and update list automatically

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
cmd = sprintf('find %s -name "%s" | sort',path_str,path_wch);
[~,list] = unix(cmd);
if ~isempty(list)
    set(handles.FileListEditable,'String',list);
    set(handles.FileListEditable,'Enable','on');
else
    set(handles.FileListEditable,'String','No file found ... ');
end

guidata(hObject, handles);


% --- Executes on button press in CancelSearch.
function CancelSearch_Callback(hObject, eventdata, handles)
%
% Abort search.
set(handles.FileListEditable,'String','');
guidata(hObject, handles);
uiresume(handles.figure1);


% --- Executes on button press in OpenFilesButton.
function OpenFilesButton_Callback(hObject, eventdata, handles)
%
% Exit and save.
uiresume(handles.figure1);


% --- Executes during object creation, after setting all properties.
function PathStringEdit_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PathStringEdit_Callback(hObject, eventdata, handles)
% 
% 
guidata(hObject, handles);


% --- Executes on button press in PathSearchButton.
function PathSearchButton_Callback(hObject, eventdata, handles)
%
% Find main search directory

folder_name = uigetdir;
if ~isempty(folder_name)
    set(handles.PathStringEdit,'String',folder_name);
end
guidata(hObject, handles);

    
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% Closing procedure

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(handles.figure1);
end
