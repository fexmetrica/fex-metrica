function varargout = fex_constructorui(varargin)
%
% FEX_CONSTRUCTORUI - Helper UI for generating FEXC objects.
%
% [...] [...]
% 
%
% See also FEXGENC, FEXC.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fex_constructorui_OpeningFcn, ...
                   'gui_OutputFcn',  @fex_constructorui_OutputFcn, ...
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


% --------------------------------------------------------------------
%  Initialize UI
% --------------------------------------------------------------------
function fex_constructorui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% OPENING_FCN - initialize the user interface.


% Create an empty figure generation object.
handles.const = fexgenc();

% Choose default command line output for fex_constructorui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fex_constructorui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fex_constructorui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
%  Buttons controller
% --------------------------------------------------------------------

function selectbutton_Callback(hObject, eventdata, handles)
%
% SELECTBUTTON - select files

k = get(handles.addfilecontroller,'String');
name = k{get(handles.addfilecontroller,'Value')};

h = fexwsearchg(name);
switch name
    case 'Movies'
        prop = 'movies';
    case 'FACET Data'
        prop = 'files';
    case 'Time Stamps'
        prop = 'timeinfo';
    case 'Design'
        prop = 'design';
end

if isempty(prop)
    return
end
handles.const.set(prop,cellstr(h));

% Set active / inactive button export
if isempty(handles.const.movies) && isempty(handles.const.movies)
    set(handles.exportbutton,'Enable','off');
    set(handles.facetbutton,'Enable','off');
else
    set(handles.exportbutton,'Enable','on');
end
% Set active / inactive button facet
if isempty(handles.const.movies)
    set(handles.facetbutton,'Enable','off');
else
    set(handles.facetbutton,'Enable','on');
end
guidata(hObject, handles);


function cancelbutton_Callback(hObject, eventdata, handles)
% 
% CANCELBUTTON -- 

delete(handles.figure1);

% --- Executes on button press in facetbutton.
function facetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to facetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportbutton.
function exportbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exportbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
%  Pop Up Menue fo Select
% --------------------------------------------------------------------

% --- Executes on selection change in addfilecontroller.
function addfilecontroller_Callback(hObject, eventdata, handles)
%
% ADDFILECONTROLLER - Callback

k = get(handles.addfilecontroller,'String');
name = k{get(handles.addfilecontroller,'Value')};

switch name
    case 'Movies'
        str = sprintf('\nSelect video files for the analysis by pressing the buttoon "Select".');
    case 'FACET Data'
        str = sprintf('\nSelect Facial Expressions files by pressing the buttoon "Select".');
    case 'Time Stamps'
        str = sprintf('\nProvide information on video timing by pressing the buttoon "Select".');
    case 'Design'
        str = sprintf('\nSelect Design files by pressing the buttoon "Select".');
end
set(handles.helpbox,'String',str);
guidata(hObject, handles);

