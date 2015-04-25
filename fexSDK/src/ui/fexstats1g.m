function varargout = fexstats1g(varargin)
% FEXSTATS1G MATLAB code for fexstats1g.fig
%      FEXSTATS1G, by itself, creates a new FEXSTATS1G or raises the existing
%      singleton*.
%
%      H = FEXSTATS1G returns the handle to a new FEXSTATS1G or the handle to
%      the existing singleton*.
%
%      FEXSTATS1G('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEXSTATS1G.M with the given input arguments.
%
%      FEXSTATS1G('Property','Value',...) creates a new FEXSTATS1G or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fexstats1g_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fexstats1g_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fexstats1g

% Last Modified by GUIDE v2.5 25-Apr-2015 14:45:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexstats1g_OpeningFcn, ...
                   'gui_OutputFcn',  @fexstats1g_OutputFcn, ...
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


% --- Executes just before fexstats1g is made visible.
function fexstats1g_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fexstats1g (see VARARGIN)

% Choose default command line output for fexstats1g
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fexstats1g wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexstats1g_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in select_trial.
function select_trial_Callback(hObject, eventdata, handles)
% hObject    handle to select_trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_trial contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_trial


% --- Executes on button press in trial_summary.
function trial_summary_Callback(hObject, eventdata, handles)
% hObject    handle to trial_summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in select_summary.
function select_summary_Callback(hObject, eventdata, handles)
% hObject    handle to select_summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_summary contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_summary


% --- Executes on button press in inspect_features.
function inspect_features_Callback(hObject, eventdata, handles)
% hObject    handle to inspect_features (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in iv_add.
function iv_add_Callback(hObject, eventdata, handles)
% hObject    handle to iv_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rm_iv.
function rm_iv_Callback(hObject, eventdata, handles)
% hObject    handle to rm_iv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in select_model.
function select_model_Callback(hObject, eventdata, handles)
% hObject    handle to select_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_model contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_model


% --- Executes on button press in is_multilevel.
function is_multilevel_Callback(hObject, eventdata, handles)
% hObject    handle to is_multilevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of is_multilevel


% --- Executes on selection change in dv_select.
function dv_select_Callback(hObject, eventdata, handles)
% hObject    handle to dv_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dv_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dv_select


% --- Executes on selection change in iv_select.
function iv_select_Callback(hObject, eventdata, handles)
% hObject    handle to iv_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns iv_select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iv_select


% --- Executes on button press in model_specification.
function model_specification_Callback(hObject, eventdata, handles)
% hObject    handle to model_specification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
