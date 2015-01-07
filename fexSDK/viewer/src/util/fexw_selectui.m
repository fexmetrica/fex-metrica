function varargout = fexw_selectui(varargin)
%
% FEXW_SELECTUI - Selects a set of AUs to be displayed.
%
% SYNTAX:
%
% h = FEXW_SELECTUI()
% h = FEXW_SELECTUI(LIST)
%
%
% For internal use only with FEXW_OVERLAYUI.M. LIST is a vector with
% preselected AUs (i.e. [1,2,4] selects AU1, AU2, and AU4).
%
% See also: FEXW_OVERLAYUI, FEWXOVERLAY.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 6-Jan-2015.
    

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexw_selectui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexw_selectui_OutputFcn, ...
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


% --- Executes just before fexw_selectui is made visible.
function fexw_selectui_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% FEXW_SETECTUI_OPENINGFNC - Initialize the selector UI. 

if ~isempty(varargin)
% Set pre-checked arguments
S = varargin{1};
for i = S(:)'
    try
        set(handles.(sprintf('au%d',i)),'Value',1);
    catch
        warning('No Action Unit: AU%d.',i);
    end
end
end

set(handles.figure1,'Name','Select AUs for the OVERLAY.');
% Choose default command line output for fexw_selectui
handles.output = get(findobj(get(handles.uipanel1,'Children'),'Value',1),'Tag');

guidata(hObject, handles);
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexw_selectui_OutputFcn(hObject, eventdata, handles) 
%
% FEXW_SELECTUI_OUTPUTFCN - Updates the output and close the GUI.

varargout{1} = handles.output;
delete(hObject);
    
% --- Executes on button press in buttoncancel.
function buttoncancel_Callback(hObject, eventdata, handles)
%
% BUTTONCANCEL_CALLBACK - uncheck all and exit

set(get(handles.uipanel1,'Children'),'Value',0);
handles.output = [];
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in buttonselect.
function buttonselect_Callback(hObject, eventdata, handles)
%
% BUTTONSELECT_CALLBACK - select features and exit.

handles.output = get(findobj(get(handles.uipanel1,'Children'),'Value',1),'Tag');
guidata(hObject,handles);
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% 
% FIGURE1_CLOSEREQYESTFCN - issue close request

% Send Close request
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
