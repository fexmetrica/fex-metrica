function varargout = fexmetrica(varargin)
%
% Main user interface for fexmetrica.
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
% Version: 11/3/14.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexmetrica_OpeningFcn, ...
                   'gui_OutputFcn',  @fexmetrica_OutputFcn, ...
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


% --- Executes just before fexmetrica is made visible.
function fexmetrica_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fexmetrica (see VARARGIN)

set(handles.figure1,'Name','FexMetrica (1.0.1)')
% Choose default command line output for fexmetrica
handles.output = hObject;
% Initialize empty files, videos, and variable lists
handles.file_list  = '';
handles.ws_var     = [];
handles.video_list = '';

% Flag for interruption during preprocessing
handles.interrupt_pp = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fexmetrica wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexmetrica_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1);


% --- Executes on button press in RectificationButton.
function RectificationButton_Callback(hObject, eventdata, handles)
% hObject    handle to RectificationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in InterpolationButton.
function InterpolationButton_Callback(hObject, eventdata, handles)
% hObject    handle to InterpolationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CoregistrationButton.
function CoregistrationButton_Callback(hObject, eventdata, handles)
% hObject    handle to CoregistrationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FalsePositiveButton.
function FalsePositiveButton_Callback(hObject, eventdata, handles)
% hObject    handle to FalsePositiveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in TemporalFilterButton.
function TemporalFilterButton_Callback(hObject, eventdata, handles)
% hObject    handle to TemporalFilterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NormalizationButton.
function NormalizationButton_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in FeaturesTypeButton.
function FeaturesTypeButton_Callback(hObject, eventdata, handles)
% hObject    handle to FeaturesTypeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FeaturesTypeButton contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FeaturesTypeButton


% --- Executes on button press in FeatParamButton.
function FeatParamButton_Callback(hObject, eventdata, handles)
% hObject    handle to FeatParamButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FeatExportButton.
function FeatExportButton_Callback(hObject, eventdata, handles)
% hObject    handle to FeatExportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FeatInspectButtoon.
function FeatInspectButtoon_Callback(hObject, eventdata, handles)
% hObject    handle to FeatInspectButtoon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in EmotientVideoSelect.
function EmotientVideoSelect_Callback(hObject, eventdata, handles)
%
% Select video to pass to the Emotient SDK.

handles.video_list = fexwsearchg();
if ~isempty(handles.video_list);
    % Activate "EmotientExecute" button.
    set(handles.EmotientExecute,'Enable','on');
end
guidata(hObject, handles);



% --- Executes on selection change in EmotientOutputType.
function EmotientOutputType_Callback(hObject, eventdata, handles)
% hObject    handle to EmotientOutputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EmotientOutputType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EmotientOutputType


% --- Executes during object creation, after setting all properties.
function EmotientOutputType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EmotientOutputType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in EmotientExecute.
function EmotientExecute_Callback(hObject, eventdata, handles)
%
% Execute the emotient comand

% Deactivate this panel/Change the string on "EmotientExecute"
if strcmp('Execute',get(handles.EmotientExecute,'String'))
    set(handles.EmotientExecute,'String','Stop');
else
    set(handles.EmotientExecute,'String','Execute');
    handles.interrupt_pp = 1; 
    guidata(hObject, handles);
    return
end


% 1. Select an output directory or create one:
handles.output_dir = uigetdir();
if handles.output_dir == 0
    handles.output_dir = sprintf('%s/facet%.0f',pwd,now);
end
% 2. Get chanels type required for the Emotient output
val = get(handles.EmotientOutputType,'Value');
chanels = get(handles.EmotientOutputType,'String');
if val == 1
    set(handles.EmotientOutputType,'Value',2);
    chanels = 'All';
else
    chanels = chanels{val};
end
% 3. Make sure that the facesize is within the constrained value
face_box = str2double(get(handles.EmotientFaceSize,'String'));
if face_box < 0.15 || face_box > 1
    set(handles.EmotientFaceSize,'String','1.00');
    face_box = 1;
end

% 4. Create Preprocessing Object
handles.PpObj = fex_ppo2('files',char(handles.video_list(1:end-1,:)),'chanels',chanels,'outdir',handles.output_dir);
for ivideo = 1:length(handles.PpObj);
% 5. Run Emotient SDK on each video.
    clc
    fprintf('Processing Video %d/%d ... \n',ivideo,length(handles.PpObj));
    handles.PpObj(ivideo).getvideoInfo();
    handles.PpObj(ivideo).setminfacewidth(face_box);
    if handles.interrupt_pp
        break
    end
%    handles.PpObj.step();
end

% --- Need to create a fexc object!
% --- Save the fexc object somewhere!


% Reactivate the buttons
clc
set(handles.EmotientExecute,'String','Execute');
handles.interrupt_pp = 0;

% Update all
guidata(hObject, handles);


function EmotientFaceSize_Callback(hObject, eventdata, handles)
% hObject    handle to EmotientFaceSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EmotientFaceSize as text
%        str2double(get(hObject,'String')) returns contents of EmotientFaceSize as a double


% --- Executes during object creation, after setting all properties.
function EmotientFaceSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EmotientFaceSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function fm_menu_Callback(hObject, eventdata, handles)
% hObject    handle to fm_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fm_menu_about_Callback(hObject, eventdata, handles)
%
% Open about image

fexaboutg;

% --------------------------------------------------------------------
function fm_menu_quit_Callback(hObject, eventdata, handles)
%
% Quit function
uiresume(handles.figure1);


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_menu1_Callback(hObject, eventdata, handles)
% 
% File selector: Select a single file.
handles.args.data = '';
[filename,pathname] = uigetfile({'*.mat','fexc Object (*.mat)';
                                 '*.csv;*.txt;','Text File (*.csv, *.txt)'; ...
                                 '*.json','Json file';...
                                 '*.mov;*.avi;*.mp4','Video File'},'Select a file');
                              
handles.file_list = sprintf('%s%s',pathname,filename);
guidata(hObject, handles);


% --------------------------------------------------------------------
function file_menu_openN_Callback(hObject, eventdata, handles)
%
% Select multiple files at once.

% Reinitialize file list
handles.file_list = fexwsearchg();
guidata(hObject, handles);


% --------------------------------------------------------------------
function file_menu_wvariable_Callback(hObject, eventdata, handles)
%
% Get variable from "base" workspace.
list_vars = evalin('base','who');
if ~isempty(list_vars)
    [s,flag] = listdlg('PromptString','Select Workspave Variable:',...
                    'SelectionMode','single',...
                    'ListString',list_vars);           
    if flag == 1
        handles.ws_var = evalin('base',list_vars{s});
    end
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function tools_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tools_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tools_menu_fexview_Callback(hObject, eventdata, handles)
% hObject    handle to tools_menu_fexview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_menu_docs_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu_docs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% Closing procedure

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(handles.figure1);
end
