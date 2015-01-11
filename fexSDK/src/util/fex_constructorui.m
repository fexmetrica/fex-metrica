function varargout = fex_constructorui(varargin)
% FEX_CONSTRUCTORUI MATLAB code for fex_constructorui.fig
%      FEX_CONSTRUCTORUI, by itself, creates a new FEX_CONSTRUCTORUI or raises the existing
%      singleton*.
%
%      H = FEX_CONSTRUCTORUI returns the handle to a new FEX_CONSTRUCTORUI or the handle to
%      the existing singleton*.
%
%      FEX_CONSTRUCTORUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEX_CONSTRUCTORUI.M with the given input arguments.
%
%      FEX_CONSTRUCTORUI('Property','Value',...) creates a new FEX_CONSTRUCTORUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fex_constructorui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fex_constructorui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fex_constructorui

% Last Modified by GUIDE v2.5 10-Jan-2015 20:35:15

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


% --- Executes just before fex_constructorui is made visible.
function fex_constructorui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fex_constructorui (see VARARGIN)

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


% --- Executes on selection change in addfilecontroller.
function addfilecontroller_Callback(hObject, eventdata, handles)
% hObject    handle to addfilecontroller (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns addfilecontroller contents as cell array
%        contents{get(hObject,'Value')} returns selected item from addfilecontroller


% --- Executes during object creation, after setting all properties.
function addfilecontroller_CreateFcn(hObject, eventdata, handles)
% hObject    handle to addfilecontroller (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
