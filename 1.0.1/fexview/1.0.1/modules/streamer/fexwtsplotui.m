function varargout = fexwtsplotui(varargin)
%
% FEXWTSPLOTUI shows a plot of timeseries for emotions
%
%
%
% See also FEXW_TIMEPLOT, FEXC, FEXC.SHOW. 
%
% 
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 17-Dec-2014.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexwtsplotui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexwtsplotui_OutputFcn, ...
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


% --- Executes just before fexwtsplotui is made visible.
function fexwtsplotui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Set output argument.


% Choose default command line output for fexwtsplotui
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexwtsplotui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexwtsplotui_OutputFcn(hObject, eventdata, handles) 
%
% 

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
%
% Escape routine
if strcmp(eventdata.Key,'escape')
    % evilin -- for output argument
    delete(handles.figure1);
    % uiresume(handles.figure1);
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);



% --------------------------------------------------------------------
function FMQuit_Callback(hObject, eventdata, handles)
% hObject    handle to FMQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure1);


% --------------------------------------------------------------------
function FMSave_Callback(hObject, eventdata, handles)
% hObject    handle to FMSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
