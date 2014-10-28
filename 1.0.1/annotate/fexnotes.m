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

    
    [idx,ti,Fdata] = get_DataOut(handles,5);
    % [video,ti,Fdata] = get_alldata(hObject, eventdata,handles,handles.box);
    % handles.video = video;
    handles.idx = idx;         % Index for the frames
    handles.Fdata = Fdata;
    handles.time  = ti;


    handles.VideoFReader = VideoReader(handles.fexc.video);
%     img = read(handles.VideoFReader,handles.idx(1));
%     img = imcrop(rgb2gray(img),handles.box);
    img = FormatFrame(handles);

%     axes(handles.VideoAxes);
%     handles.videoPlayer = vision.VideoPlayer();
%     handles.videoPlayer.step(img);

    % img = reshape(handles.video(handles.frameCount,:),handles.box(4)+1,handles.box(3)+1);
    showFrameOnAxis(handles.VideoAxes,img);
    
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
    
    % Add video information
    [~,name,ext] = fileparts(handles.fexc.video);
    str = sprintf('Video Name: %s%s',name,ext);
    set(handles.VideoNameText,'String',str);
    td = fex_strtime(handles.fexc.videoInfo(2));
    str = sprintf('Duration: %s',td{1});
    set(handles.VideoDurationText,'String',str);
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
% release(handles.VideoFReader);
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


% Start a segment to annotate
if strcmp(get(handles.StepNotes,'Enable'),'on');
   % disable
   set(handles.StepNotes,'Enable','off');
   set(handles.Annotation,'Enable','off');

   t_step = str2double(get(handles.StepSizeAnnotation,'String'));
   tval = handles.time(handles.frameCount) + t_step;
   ind = dsearchn(handles.time,tval);
   for i = handles.frameCount:ind
       pause(.001)
       Y = get_bardata2(handles);
       set(get(handles.ChannelAxes,'Children'),'YData',Y)
%        img = read(handles.VideoFReader,handles.idx(handles.frameCount));
%        img = imcrop(rgb2gray(img),handles.box);
       img = FormatFrame(handles);

       showFrameOnAxis(handles.VideoAxes,img);
       handles.frameCount = handles.frameCount + 1;
       set(handles.TimeSlider,'Value',handles.frameCount);
   end
   set(handles.Annotation,'Enable','on');

%    temp_notes = cellstr(repmat(get(handles.Annotation,'String'),[length(handles.frameCount:ind),1]));
%    handles.annotations(handles.frameCount:ind) = temp_notes;
end

set(handles.StepNotes,'Enable','on');
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
TF   = [];
axes(handles.VideoAxes)
while flag && handles.frameCount <= length(handles.time) && get(handles.AnnotationOn, 'Value') == 0 %handles.fexc.videoInfo(3)
   tic;
   pause(.001);
%    handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
   
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
%    videoFrame = imcrop(rgb2gray(step(handles.videoFReader)),handles.box);

%    % Add waiting time
%    
%    showFrameOnAxis(handles.VideoAxes,videoFrame);
%    img = reshape(handles.video(max(handles.frameCount,1),:),handles.box(4)+1,handles.box(3)+1);

%    img = read(handles.VideoFReader,handles.idx(handles.frameCount));
%    img = imcrop(rgb2gray(img),handles.box);
   img = FormatFrame(handles);
   showFrameOnAxis(handles.VideoAxes,img);
   
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
   
%    tdiff = t0 - now;
%    twait = max(0,handles.time(handles.frameCount) - tdiff);
%    pause(twait);

   if ceil(get(handles.TimeSlider,'Value')) == handles.frameCount;
      handles.frameCount = handles.frameCount + 1;
      set(handles.TimeSlider,'Value',handles.frameCount);
   else
      handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
   end
   TF = cat(1,TF,toc);
   fprintf('frame in: %d. Estimate fps (display): %d.\n',handles.frameCount-1,mean(1./TF));

%    pause(.005)
    
    % ADD END OF VIDEO AND DELAY ... 


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
% [video,ti,Fdata] = get_alldata(hObject, eventdata,handles,handles.box);
% handles.video = video;
handles.idx = idx;         % Index for the frames
handles.Fdata = Fdata;
handles.time  = ti;
    

handles.VideoFReader = VideoReader(handles.fexc.video);
% img = read(handles.VideoFReader,handles.idx(1));
% img = imcrop(rgb2gray(img),handles.box);
img = FormatFrame(handles);
% img = reshape(handles.video(handles.frameCount,:),handles.box(4)+1,handles.box(3)+1);
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

% Add handles for annotation --> this is a cell with one annotation per
% frame at 6 frames per seconds
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

function [idx,ti,Fdata] = get_DataOut(handles,nfd)
%
% Gets the new timestamps, the index of the frame to use, and the
% interporlated facial expression data -- fps are set at 6fps

t   = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
ti  = (0:1/nfd:t(end))';  % Sampling at 6 frames per second
idx = dsearchn(t,ti);
Fdata = interp1(t,double(handles.fexc.functional),ti);
Fdata = mat2dataset(Fdata,'VarNames',handles.fexc.functional.Properties.VarNames);


function [video,ti,Fdata] = get_alldata(hObject,eventdata,handles,box)
%
% Crop video, store images

videoFReader = vision.VideoFileReader(handles.fexc.video);
img1  = imcrop(rgb2gray(step(videoFReader)),box);
video = single(zeros(handles.fexc.videoInfo(3),numel(img1)));
video(1,:) = reshape(img1,1,numel(img1));
tic;

fprintf('\nStartig video import ');
str = 'Startig video import ';
set(handles.VideoImportText,'String',str);
KK = round(linspace(0,handles.fexc.videoInfo(3),25)); l = 1; 
for i = 2:handles.fexc.videoInfo(3)
    img1  = imcrop(rgb2gray(step(videoFReader)),box);
    video(i,:) = reshape(img1,1,numel(img1));
    if KK(l) < i
        l = l+1;
        str = sprintf('%s.',str);
        set(handles.VideoImportText,'String',str);
        guidata(hObject, handles);
        fprintf('.');
    end
end
fprintf('\nImage interpolation:...\n')
t  = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
ti = (0:1/10:t(end))';
video = single(interp1(t,video,ti,'spline'));
fprintf('Facet interpolation:...\n')
Fdata = interp1(t,double(handles.fexc.functional),ti);
Fdata = mat2dataset(Fdata,'VarNames',handles.fexc.functional.Properties.VarNames);
fprintf('Time elapsed: %.2f \n',toc);
set(handles.VideoImportText,'String','');


function img = FormatFrame(handles)

% Get size of the image Axes
% ss = round(get(handles.VideoAxes,'Position'));
% Get image
img = imcrop(read(handles.VideoFReader,handles.idx(handles.frameCount)),handles.box);
if get(handles.BlackWhiteMode,'Value') == 1
    img = rgb2gray(img);
end
% img = imresize(img,[348,316]);



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
