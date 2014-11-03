function varargout = fexmetrica(varargin)
% FEXMETRICA MATLAB code for fexmetrica.fig
%      FEXMETRICA, by itself, creates a new FEXMETRICA or raises the existing
%      singleton*.
%
%      H = FEXMETRICA returns the handle to a new FEXMETRICA or the handle to
%      the existing singleton*.
%
%      FEXMETRICA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEXMETRICA.M with the given input arguments.
%
%      FEXMETRICA('Property','Value',...) creates a new FEXMETRICA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fexmetrica_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fexmetrica_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fexmetrica

% Last Modified by GUIDE v2.5 02-Nov-2014 10:39:57

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

% Choose default command line output for fexmetrica
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fexmetrica wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexmetrica_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
% hObject    handle to EmotientVideoSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
% hObject    handle to EmotientExecute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
