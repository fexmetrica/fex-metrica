function varargout = fexnotes(varargin)
%
% FexNotes Tool for fexMetrica fexObj.
%
% Usage:
%
% note = fexnotes()
% note = fexnotes(fexObj)
% note = fexnotes(str_video, str_fexdata)**
%
% You can call the function without input and then use the drop down menu
% to import a fexObj. Alterbatively, you can enter a fexObj directly. The
% ** indicates that this syntax is not yet implemented in this version of
% the code.
%
%
% -------------------------------------------------------------------------
%
%
% Version: 10/25/2014


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexnotes_OpeningFcn, ...
                   'gui_OutputFcn',  @fexnotes_OutputFcn, ...
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


% --- Executes just before fexnotes is made visible.
function fexnotes_OpeningFcn(hObject, ~, handles, varargin)
%
% Initialization and varargin reader. Varargin can only be a fexc
% object.

if length(varargin) == 1 && isa(varargin{1},'fexc')
    % Read the video;
    % Get seconds for fps;
    % Get cropping info here
    % Get Landmarks (??)
    % Set axis for display
    % Set feature for display
    
    % Store the handle
    handles.fexc = varargin{1};
    handles.frameCount = 1;
    
    % get image cropping info
    B = double(handles.fexc.structural(:,3:6));
    B(:,3:4) = B(:,1:2) + B(:,3:4);
    handles.box = [min(B(:,1:2)), max(B(:,3:4)) - min(B(:,1:2))];

    % Display first frame
    videoFReader = vision.VideoFileReader(handles.fexc.video);
    handles.videoFReader = videoFReader;
    videoFrame = imcrop(rgb2gray(step(handles.videoFReader)),handles.box);
    showFrameOnAxis(handles.VideoAxes,videoFrame);
    
    % Set bargraph for emotions
    set(handles.Channel,'String','joy')
    X =  handles.fexc.time.TimeStamps;
    X =  X - X(1);
    Y = get_bardata(handles);
    axes(handles.ChannelAxes);
    bar(X,Y);
    xlim([0,max(X)]); ylim([-3,3]);
    
end


% Choose default command line output for fexnotes
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fexnotes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexnotes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Channel.
function Channel_Callback(hObject, eventdata, handles)
% hObject    handle to Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Annotation_Callback(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Annotation as text
%        str2double(get(hObject,'String')) returns contents of Annotation as a double


% --- Executes during object creation, after setting all properties.
function Annotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StepNotes.
function StepNotes_Callback(hObject, eventdata, handles)
% hObject    handle to StepNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function StepSizeAnnotation_Callback(hObject, eventdata, handles)
% hObject    handle to StepSizeAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepSizeAnnotation as text
%        str2double(get(hObject,'String')) returns contents of StepSizeAnnotation as a double


% --- Executes during object creation, after setting all properties.
function StepSizeAnnotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSizeAnnotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in StepUnits.
function StepUnits_Callback(hObject, eventdata, handles)
% hObject    handle to StepUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StepUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StepUnits


% --- Executes during object creation, after setting all properties.
function StepUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CropFace.
function CropFace_Callback(hObject, eventdata, handles)
% hObject    handle to CropFace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CropFace


% --- Executes on button press in ShowLandmarks.
function ShowLandmarks_Callback(hObject, eventdata, handles)
% hObject    handle to ShowLandmarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ShowLandmarks


% --- Executes on button press in RwdButton.
function RwdButton_Callback(hObject, eventdata, handles)
% hObject    handle to RwdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% 
% Play Pause callback
if strcmp(get(handles.PlayButton,'String'),'Play')
    set(handles.PlayButton,'String','Pause');
else
    set(handles.PlayButton,'String','Play');
end

flag = strcmp(get(handles.PlayButton,'String'),'Pause');
while flag
   fprintf('frame in: %d.\n',handles.frameCount)
   Y = get_bardata(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
%    refreshdata(handles.ChannelAxes)
   videoFrame = imcrop(rgb2gray(step(handles.videoFReader)),handles.box);
   showFrameOnAxis(handles.VideoAxes,videoFrame);
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
   handles.frameCount = handles.frameCount + 1;
%    pause(.005)
    
    % ADD END OF VIDEO AND DELAY ... 


end
guidata(hObject, handles);


% --- Executes on button press in FwdButton.
function FwdButton_Callback(hObject, eventdata, handles)
% hObject    handle to FwdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function TimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function open_m_Callback(hObject, eventdata, handles)
% hObject    handle to open_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function open_f_Callback(hObject, eventdata, handles)
% hObject    handle to open_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AnnotationOn.
function AnnotationOn_Callback(hObject, eventdata, handles)
% 
% Activate the Annotation Box

if get(handles.AnnotationOn, 'Value') == 1
    % Activate Annotation Box
    set(handles.StepUnits,'Enable','on');
    set(handles.StepSizeAnnotation,'Enable','on');
    set(handles.StepSizeAnnotation,'Enable','on');
    set(handles.Annotation,'Enable','on');
    set(handles.StepNotes,'Enable','on');
    % Deactivate video comands
    set(handles.TimeSlider,'Enable','off');
    set(handles.RwdButton,'Enable','off');
    set(handles.PlayButton,'Enable','off');
    set(handles.FwdButton,'Enable','off');
else
    % Deactivate Annotation Box
    set(handles.StepUnits,'Enable','off');
    set(handles.StepSizeAnnotation,'Enable','off');
    set(handles.Annotation,'Enable','off');
    set(handles.StepNotes,'Enable','off');
    % Activate Video Comands
    set(handles.TimeSlider,'Enable','on');
    set(handles.RwdButton,'Enable','on');
    set(handles.PlayButton,'Enable','on');
    set(handles.FwdButton,'Enable','on');
end


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

function Y = get_bardata(handles)

fc = handles.frameCount;

Y = handles.fexc.functional.(get(handles.Channel,'String'));

if fc+1 <= length(Y)
    Y(fc+1:end) = nan;
end
    

        

