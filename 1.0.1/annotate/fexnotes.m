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
function fexnotes_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Initialization and varargin reader. Varargin can only be a fexc
% object.

if length(varargin) == 1 && isa(varargin{1},'fexc')
    % Generate Handle for fexc Object
    handles.fexc = varargin{1};
    handles.frameCount = 1;
    
    % Get image box
    B = double(handles.fexc.structural(:,3:6));
    B(:,3:4) = B(:,1:2) + B(:,3:4);
    handles.box = [min(B(:,1:2)), max(B(:,3:4)) - min(B(:,1:2))];

    % Get image data
    [idx,ti,Fdata] = get_DataOut(handles,5);
    handles.idx = idx;         % Index for the frames
    handles.Fdata = Fdata;
    handles.time  = ti;
    handles.dfps  = [1,5];     % Estimate of displaied frames per seconds

    % Video Reader/Player
    handles.VideoFReader = VideoReader(handles.fexc.video);
    img = FormatFrame(handles);
    showFrameOnAxis(handles.VideoAxes,img);
    
    % Emotions/AUs graph
    set(handles.Channel,'Value',5)
    X =  handles.time;
    Y = get_bardata2(handles);
    bar(X,Y); xlim([0,max(X)]); ylim([-2,4]);
    
    % Adjust slider for video display
    set(handles.TimeSlider,'Max',length(X));
    set(handles.TimeSlider,'Min',1);
    set(handles.TimeSlider,'Value',1);
    
    % Add video information to info panel
    [~,name,ext] = fileparts(handles.fexc.video);
    str = sprintf('Video Name: %s%s',name,ext);
    set(handles.VideoNameText,'String',str);
    td = fex_strtime(handles.fexc.videoInfo(2));
    str = sprintf('Duration: %s',td{1});
    set(handles.VideoDurationText,'String',str);
end

% Update
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexnotes wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexnotes_OutputFcn(hObject, eventdata, handles) 


varargout{1} = handles.output;


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)



% --- Executes on button press in Channel.
function Channel_Callback(hObject, eventdata, handles)
% hObject    handle to Channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Annotation_Callback(hObject, eventdata, handles)
% hObject    handle to Annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
%
% Log Annotations
% temp_notes = cellstr(repmat(get(handles.Annotation,'String'),[length(handles.frameCount:ind),1]));
% handles.annotations(handles.frameCount:ind) = temp_notes;

% Start a segment to annotate   
% Disable step button and annotation during viewing
set(handles.StepNotes,'Enable','off');
set(handles.Annotation,'Enable','off');

% Get list of frames to be streamed for "Annotation Step."
t_step = str2double(get(handles.StepSizeAnnotation,'String'));
tval = handles.time(handles.frameCount) + t_step;
ind = dsearchn(handles.time,tval);

% Loop over frames to display and timeseries
for i = handles.frameCount:ind
   tic; pause(.001)
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
   img = FormatFrame(handles);
   showFrameOnAxis(handles.VideoAxes,img);
   handles.dfps  = cat(1,handles.dfps,[handles.dfps(end,1)+1,toc]);
   handles.frameCount = handles.frameCount + 1;
   set(handles.TimeSlider,'Value',handles.frameCount);
end

% Reactivate annotation box and step
set(handles.Annotation,'Enable','on');
set(handles.StepNotes,'Enable','on');

% Update
guidata(hObject, handles);


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

if ~isfield(handles,'fexc')
    warning('You need to enter data first ... ')
    return
end

% Play Pause callback
if strcmp(get(handles.PlayButton,'String'),'Play')
    set(handles.PlayButton,'String','Pause');
else
    set(handles.PlayButton,'String','Play');
end

flag = strcmp(get(handles.PlayButton,'String'),'Pause');
while flag && handles.frameCount <= length(handles.time) && get(handles.AnnotationOn, 'Value') == 0 %handles.fexc.videoInfo(3)
   tic; pause(.001);
   
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
   img = FormatFrame(handles);
   showFrameOnAxis(handles.VideoAxes,img);
   
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
   if ceil(get(handles.TimeSlider,'Value')) == handles.frameCount;
      handles.frameCount = handles.frameCount + 1;
      set(handles.TimeSlider,'Value',handles.frameCount);
   else
      handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
   end
   handles.dfps  = cat(1,handles.dfps,[handles.dfps(end,1)+1,toc]);
%    fprintf('frame in: %d. Estimate fps (display): %d.\n',handles.frameCount-1,mean(1./TF));
end


if handles.frameCount > length(handles.time) %handles.fexc.videoInfo(3)
   handles.frameCount = 1;
   set(handles.TimeSlider,'Value',handles.frameCount);
   set(handles.PlayButton,'String','Play');
end

set(handles.PlayButton,'String','Play');
guidata(hObject, handles);


% --- Executes on button press in FwdButton.
function FwdButton_Callback(hObject, eventdata, handles)
% hObject    handle to FwdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
%
% Update time slider

handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
guidata(hObject, handles);

    

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

filename = uigetfile('*.mat', 'Select a fexc Object');
if isequal(filename,0)
   return
end

handles.fexc = importdata(filename);
if ~isa(handles.fexc,'fexc')
    error('File must contain a fexc Class object.');
end
    
% Initialize frame count   
handles.frameCount = 1;    
% get image cropping info
B = double(handles.fexc.structural(:,3:6));
B(:,3:4) = B(:,1:2) + B(:,3:4);
handles.box = [min(B(:,1:2)), max(B(:,3:4)) - min(B(:,1:2))];
    
[idx,ti,Fdata] = get_DataOut(handles,5);
handles.idx = idx;         % Index for the frames
handles.Fdata = Fdata;
handles.time  = ti;
handles.dfps  = [];        % estimate of display frames per seconds
    
handles.VideoFReader = VideoReader(handles.fexc.video);
img = FormatFrame(handles);
showFrameOnAxis(handles.VideoAxes,img);
    
set(handles.Channel,'Value',5)
X =  handles.time;
Y = get_bardata2(handles);    
bar(X,Y);
xlim([0,max(X)]); ylim([-3,3]);

% Adjust Cursor bar
set(handles.TimeSlider,'Max',length(X));
set(handles.TimeSlider,'Min',1);
set(handles.TimeSlider,'Value',1);
    
% Add video information
[~,name,ext] = fileparts(handles.fexc.video);
str = sprintf('Video Name: %s%s',name,ext);
set(handles.VideoNameText,'String',str);
td = fex_strtime(handles.fexc.videoInfo(2));
str = sprintf('Duration: %s',td{1});
set(handles.VideoDurationText,'String',str);

% Andles annotation
handles.annotations = cellstr(repmat('',[length(handles.time),1]));

% Choose default command line output for fexnotes
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in AnnotationOn.
function AnnotationOn_Callback(hObject, eventdata, handles)
% 
% Activate the Annotation Box

if get(handles.AnnotationOn, 'Value') == 1
    % Activate Annotation Box
    set(handles.StepUnits,'Enable','on');
    set(handles.StepSizeAnnotation,'Enable','on');
    set(handles.Annotation,'Enable','on');
    set(handles.StepNotes,'Enable','on');
    % Deactivate video comands
    set(handles.TimeSlider,'Enable','inactive');
    set(handles.PlayButton,'Enable','off');
else
    % Deactivate Annotation Box
    set(handles.StepUnits,'Enable','off');
    set(handles.StepSizeAnnotation,'Enable','off');
    set(handles.Annotation,'Enable','off');
    set(handles.StepNotes,'Enable','off');
    % Activate Video Comands
    set(handles.TimeSlider,'Enable','on');
    set(handles.PlayButton,'Enable','on');
end


% --- Executes on button press in ActivateAudio.
function ActivateAudio_Callback(hObject, eventdata, handles)
% hObject    handle to ActivateAudio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ActivateAudio


% --- Executes on button press in BlackWhiteMode.
function BlackWhiteMode_Callback(hObject, eventdata, handles)
% hObject    handle to BlackWhiteMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BlackWhiteMode


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


function [idx,ti,Fdata] = get_DataOut(handles,nfd)
%
% Gets the new timestamps, the index of the frame to use, and the
% interporlated facial expression data -- fps are set at 6fps

t   = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
ti  = (0:1/nfd:t(end))';  % Sampling at 6 frames per second
idx = dsearchn(t,ti);
Fdata = interp1(t,double(handles.fexc.functional),ti);
Fdata = mat2dataset(Fdata,'VarNames',handles.fexc.functional.Properties.VarNames);


function img = FormatFrame(handles)
%
% Get/format the current frame

% Get size of the image Axes
% ss = round(get(handles.VideoAxes,'Position'));
% Get image
img = imcrop(read(handles.VideoFReader,handles.idx(handles.frameCount)),handles.box);
if get(handles.BlackWhiteMode,'Value') == 1
    img = rgb2gray(img);
end


function Y = get_bardata2(handles)

fc = handles.frameCount;
names = (get(handles.Channel,'String'));
Y = handles.Fdata.(names{get(handles.Channel,'Value')});

if fc+1 <= length(Y)
    Y(fc+1:end) = nan;
end
