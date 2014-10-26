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

    
    [video,ti,Fdata] = get_alldata(handles,handles.box);
    handles.video = video;
    handles.Fdata = Fdata;
    handles.time  = ti;
    
    % Display first frame
%     videoFReader = vision.VideoFileReader(handles.fexc.video);
%     handles.videoFReader = videoFReader;
%     videoFrame = imcrop(rgb2gray(step(handles.videoFReader)),handles.box);
    img = reshape(handles.video(handles.frameCount,:),handles.box(4)+1,handles.box(3)+1);
    showFrameOnAxis(handles.VideoAxes,img);

%     showFrameOnAxis(handles.VideoAxes,videoFrame);
    
    % Set bargraph for emotions
    
    set(handles.Channel,'Value',5)
    X =  handles.time;
    Y = get_bardata2(handles);
    
    
%     X =  handles.fexc.time.TimeStamps;
%     X =  X - X(1);
%     handles.time = diff(X);
%     Y = get_bardata(handles);
%     axes(handles.ChannelAxes);
    bar(X,Y);
    xlim([0,max(X)]); ylim([-3,3]);
    
    % Adjust Cursor bar
    set(handles.TimeSlider,'Max',length(X));
    set(handles.TimeSlider,'Min',1);
    set(handles.TimeSlider,'Value',1);
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
t00 = now;
while flag && handles.frameCount <= length(handles.time) %handles.fexc.videoInfo(3)
   pause(.001);
%    handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
%    videoFrame = imcrop(rgb2gray(step(handles.videoFReader)),handles.box);

%    % Add waiting time
%    
%    showFrameOnAxis(handles.VideoAxes,videoFrame);
   img = reshape(handles.video(max(handles.frameCount,1),:),handles.box(4)+1,handles.box(3)+1);
   showFrameOnAxis(handles.VideoAxes,img);

   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
   
%    tdiff = t0 - now;
%    twait = max(0,handles.time(handles.frameCount) - tdiff);
%    pause(twait);

   handles.frameCount = handles.frameCount + 1;
   set(handles.TimeSlider,'Value',handles.frameCount);
%    fprintf('frame in: %d, fps: %d.\n',handles.frameCount-1,round((handles.frameCount-1)/(now-t00)));

%    pause(.005)
    
    % ADD END OF VIDEO AND DELAY ... 


end


if handles.frameCount > length(handles.time) %handles.fexc.videoInfo(3)
   handles.frameCount = 1;
   set(handles.TimeSlider,'Value',handles.frameCount);
   set(handles.PlayButton,'String','Play');
end
   
guidata(hObject, handles);


% --- Executes on button press in FwdButton.
function FwdButton_Callback(hObject, eventdata, handles)
% hObject    handle to FwdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
% %
% %

% set(handles.PlayButton,'String','Play');
handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
guidata(hObject, handles);

% flag = false;
% if strcmp(get(handles.PlayButton,'String'),'Pause');
%     set(handles.PlayButton,'String','Play'); 
%     guidata(hObject, handles);
%     PlayButton_Callback(hObject,eventdata,handles);
%     flag = true;
% end

% flag = strcmp(get(handles.PlayButton,'String'),'Pause'); 
% set(handles.PlayButton,'String','Pause'); 
% PlayButton_Callback(hObject,eventdata,handles);
% 
% handles.frameCount = round(get(handles.TimeSlider,'Value'));
% set(handles.TimeSlider,'Value',handles.frameCount);
% guidata(hObject,handles);
%  
% if flag
%     set(handles.PlayButton,'String','Play');
% end
% guidata(hObject, handles);
% PlayButton_Callback(hObject,eventdata,handles);
    

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
%     set(handles.RwdButton,'Enable','on');
    set(handles.PlayButton,'Enable','on');
%     set(handles.FwdButton,'Enable','on');
end


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

function Y = get_bardata(handles)

fc = handles.frameCount;

Y = handles.fexc.functional.(get(handles.Channel,'String'));

if fc+1 <= length(Y)
    Y(fc+1:end) = nan;
end
    


function Y = get_bardata2(handles)

fc = handles.frameCount;
names = (get(handles.Channel,'String'));
Y = handles.Fdata.(names{get(handles.Channel,'Value')});

if fc+1 <= length(Y)
    Y(fc+1:end) = nan;
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

function [video,ti,Fdata] = get_alldata(handles,box)
%
% Crop video, store images

videoFReader = vision.VideoFileReader(handles.fexc.video);
img1  = imcrop(rgb2gray(step(videoFReader)),box);
video = single(zeros(handles.fexc.videoInfo(3),numel(img1)));
video(1,:) = reshape(img1,1,numel(img1));
tic;
fprintf('Startig video import ');
KK = round(linspace(0,handles.fexc.videoInfo(3),25)); l = 1; 
for i = 2:handles.fexc.videoInfo(3)
    img1  = imcrop(rgb2gray(step(videoFReader)),box);
    video(i,:) = reshape(img1,1,numel(img1));
    if KK(l) < i
        l = l+1;
        fprintf('.');
    end
end
fprintf('Image interpolation:...\n')
t  = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
ti = (0:1/10:t(end))';
video = single(interp1(t,video,ti,'spline'));
fprintf('Facet interpolation:...\n')
Fdata = interp1(t,double(handles.fexc.functional),ti);
Fdata = mat2dataset(Fdata,'VarNames',handles.fexc.functional.Properties.VarNames);
fprintf('\nTime elapsed: %.2f \n',toc);
