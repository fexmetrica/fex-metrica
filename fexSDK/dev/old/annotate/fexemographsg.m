function varargout = fexemographsg(varargin)
%
% args = varargout = fexemographsg;
%
%
%__________________________________________________________________________
%
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
                   'gui_OpeningFcn', @fexemographsg_OpeningFcn, ...
                   'gui_OutputFcn',  @fexemographsg_OutputFcn, ...
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


% --- Executes just before fexemographsg is made visible.
function fexemographsg_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Initialization Function for "fexemographsg."

% Initialize output argument
handles.args = struct('data','',...
                      'type',1,...
                      'smoothing',struct('kernel','none','size',nan),...
                      'rectification',-1,...
                      'features',[1,0,1,1,1,1,1,0,0],...
                      'outdir',pwd);
       
% Note that features numbering is:
% 1:sadness;2:contempt;3:joy;4:anger;5:disgust;
% 6:fear;7:surprise;8:confusion;9:frustration
                  

% Initialize output directory to current working directory
set(handles.OutputDirPath,'String',pwd);

% Update and wait
handles.output = hObject;
guidata(hObject, handles);

uiwait(handles.figure1);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Outputs from this function are returned to the command line.
function varargout = fexemographsg_OutputFcn(hObject, eventdata, handles) 
%
% Set up output argument.

varargout{1} = handles.args;
delete(handles.figure1);



% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Executes on button press in ImageGenButton.
function ImageGenButton_Callback(hObject, eventdata, handles)
% 
% Resume function

uiresume(handles.figure1);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Executes on button press in ChangeOutDir.
function ChangeOutDir_Callback(hObject, eventdata, handles)
%
% Enter a new output directory
folder_name = uigetdir;
set(handles.OutputDirPath,'String',folder_name);
handles.args.outdir = folder_name;
guidata(hObject, handles);


function OutputDirPath_Callback(hObject, eventdata, handles)
% 
% Space for new outut directory string
handles.args.outdir = get(handles.OutputDirPath,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function OutputDirPath_CreateFcn(hObject, eventdata, handles)
%
% Create out dir field

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Executes on button press in IncludeSadness.
function IncludeSadness_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(1) = get(handles.IncludeSadness,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeContempt.
function IncludeContempt_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(2) = get(handles.IncludeContempt,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeJoy.
function IncludeJoy_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(3) = get(handles.IncludeJoy,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeAnger.
function IncludeAnger_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(4) = get(handles.IncludeAnger,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeDisgust.
function IncludeDisgust_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(5) = get(handles.IncludeDisgust,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeFear.
function IncludeFear_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(6) = get(handles.IncludeFear,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeSurprise.
function IncludeSurprise_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(7) = get(handles.IncludeSurprise,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeConfusion.
function IncludeConfusion_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(8) = get(handles.IncludeConfusion,'Value');
guidata(hObject, handles);

% --- Executes on button press in IncludeFrustration.
function IncludeFrustration_Callback(hObject, eventdata, handles)
%
% Update selected features
handles.args.features(9) = get(handles.IncludeFrustration,'Value');
guidata(hObject, handles);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Executes during object creation, after setting all properties.
function PlotType_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in PlotType.
function PlotType_Callback(hObject, eventdata, handles)
%
% Set plot type
handles.args.type = get(handles.PlotType,'Value');
guidata(hObject, handles);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% --- Executes on button press in SmoothingOn.
function SmoothingOn_Callback(hObject, eventdata, handles)
%
% Activate/Deactivate Smoothing options

if get(handles.SmoothingOn,'Value') == 0
    set(handles.SmoothingTypeMenu,'Value',1);
    set(handles.SmoothingTypeMenu,'Enable','off');
    set(handles.NFramesSmooth,'String','nan');
    set(handles.NFramesSmooth,'Visible','off');
else
    set(handles.SmoothingTypeMenu,'Value',1);
    set(handles.SmoothingTypeMenu,'Enable','on');
    set(handles.NFramesSmooth,'String','15');
    set(handles.NFramesSmooth,'Visible','on');
end

% Update Smoothing field structure
opt = {'Gaussian','Box'};
handles.args.smoothing.kernel = opt{get(handles.SmoothingTypeMenu,'Value')};
handles.args.smoothing.size   = str2double(get(handles.NFramesSmooth,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SmoothingTypeMenu_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SmoothingTypeMenu.
function SmoothingTypeMenu_Callback(hObject, eventdata, handles)
%
% Update Smoothing kernel information
opt = {'Gaussian','Box'};
handles.args.smoothing.kernel = opt{get(handles.SmoothingTypeMenu,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function NFramesSmooth_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NFramesSmooth_Callback(hObject, eventdata, handles)
%
% Set size parameter for smoothing in frames
handles.args.smoothing.size = str2double(get(handles.NFramesSmooth,'String'));
guidata(hObject, handles);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

% --- Executes on button press in RectificationOn.
function RectificationOn_Callback(hObject, eventdata, handles)
%
% Active/Inactive rectification and upodated "RectificationVal" field.

if get(handles.RectificationOn,'Value') == 0
    set(handles.RectificationVal,'String','nan');
    set(handles.RectificationVal,'Enable','off');
else
    set(handles.RectificationVal,'String','-1');
    set(handles.RectificationVal,'Enable','on');
end

% Update rectification field
val =  get(handles.RectificationVal,'String');
handles.args.rectification = str2double(val);
guidata(hObject, handles);
  

% --- Executes during object creation, after setting all properties.
function RectificationVal_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RectificationVal_Callback(hObject, eventdata, handles)
%
% Update data lower bound.

val =  get(handles.RectificationVal,'String');
handles.args.rectification = str2double(val);
guidata(hObject, handles);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --------------------------------------------------------------------
function open_m_Callback(hObject, eventdata, handles)
%
% Main open banner ... no action required.


% --------------------------------------------------------------------
function open_file_menu_Callback(hObject, eventdata, handles)
% 
% File selector: Select a single file.
handles.args.data = '';
[filename,pathname] = uigetfile({'*.mat','fexc Object (*.mat)';
                                 '*.csv;*.txt;','Text File (*.csv, *.txt)'; ...
                                 '*.json','Json file'},'Select a file');
                              
handles.args.data = sprintf('%s%s',pathname,filename);
guidata(hObject, handles);

% --------------------------------------------------------------------
function open_files_menu_Callback(hObject,eventdata,handles)
% 
% Select multiple files
handles.args.data = '';
file_list = fexwsearchg();
handles.args.data = file_list;
guidata(hObject, handles);

% --------------------------------------------------------------------
function open_var_menue_Callback(hObject, eventdata, handles)
%
% Get variable from "base" workspace.
handles.args.data = '';
list_vars = evalin('base','who');
[s,flag] = listdlg('PromptString','Select Workspave Variable:',...
                'SelectionMode','single',...
                'ListString',list_vars);           
if flag == 1
    handles.args.data = evalin('base',list_vars{s});
end
guidata(hObject, handles);


% @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% Closing procedure

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(handles.figure1);
end
