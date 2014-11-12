function varargout = fexnotes(varargin)
%
% FexNotes Tool for fexMetrica fexObj.
%
% Usage:
%
% note = fexnotes()
% note = fexnotes(fexObj)
%
% You can call the function without input and then use the drop down menu
% to import a fexObj. Alterbatively, you can enter a fexObj directly. 
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
function fexnotes_OpeningFcn(hObject,eventdata, handles, varargin)
%
% Initialization and varargin reader. Varargin can only be a fexc
% object.

if length(varargin) == 1 && isa(varargin{1},'fexc')
    % Generate Handle for fexc Object
    handles.fexc = varargin{1};
    handles.frameCount = 1;
    
    % Get image box
    str_names = handles.fexc.structural.Properties.VarNames';
    [~,ind] = ismember({'FaceBoxX','FaceBoxY','FaceBoxW','FaceBoxH'},str_names);
    B = double(handles.fexc.structural(:,ind));
    handles.all_boxes = int32(B);
%     B = double(handles.fexc.structural(:,3:6));
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
    axes(handles.ChannelAxes);
    
    area(X,Y,'basevalue',-1,'LineWidth',2,'EdgeColor','b')
    alpha(.4)
    xlim([0,max(X)]); ylim([-1,3]);   
%     bar(X,Y); xlim([0,max(X)]); ylim([-2,4]);
    
    % Adjust slider for video display
    set(handles.TimeSlider,'Max',length(X));
    set(handles.TimeSlider,'Min',1);
    set(handles.TimeSlider,'Value',1);
    
    % Add video information to info panel
%     [~,name,ext] = fileparts(handles.fexc.video);
%     str = sprintf('Video Name: %s%s',name,ext);
%     set(handles.VideoNameText,'String',str);
    td = fex_strtime(handles.fexc.videoInfo(2),'short');
    str = sprintf('Duration: %s',td{1});
    set(handles.VideoDurationText,'String',str);
    str = sprintf('Frame:\t %d/%d',handles.idx(handles.frameCount),handles.idx(end));
    set(handles.FrameTimeLog,'String',str);
    
    % Check whether you can asses track number (this get's updated)
    try
        nt  = length(unique(handles.fexc.diagnostics.track_id));
        txt = sprintf('Number of Tracks: %.0f. Current track = 0.',nt);
        set(handles.TranString,'String',txt);
        handles.trackN = [handles.fexc.diagnostics.track_id];
        handles.trackN = cat(2,repmat(nt,[length(handles.trackN),1]),handles.trackN);
    catch errorId
        warning(errorId.message);
        warning('No diagnostic information provided.');
        txt = 'Number of Tracks: Nan. Current track = 0.';
        set(handles.TranString,'String',txt);
        handles.trackN = [nan(length(Y),1),zeros(length(Y),1)];
    end

    % Initialize annotation
    handles.WriteAnnotation  = false;
    handles.annotations.str  = cellstr('');
    handles.annotations.time = []; 
    
    % Add box Inserter object
    handles.drawbox = vision.ShapeInserter;
end

% Update
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexnotes wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexnotes_OutputFcn(hObject, eventdata, handles) 

% varargout{1} = handles.annotations;
% 

if isfield(handles,'annotations')
    varargout{1} = handles.annotations;
else
    varargout{1} = '';
end
delete(handles.figure1);

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
function StepNotes_Callback(hObject,eventdata, handles)
%
% Log Annotations
% temp_notes = cellstr(repmat(get(handles.Annotation,'String'),[length(handles.frameCount:ind),1]));
% handles.annotations(handles.frameCount:ind) = temp_notes;

% Write annotation when required
if handles.WriteAnnotation
    handles.annotations.str = cat(1,handles.annotations.str,get(handles.Annotation,'String'));
end
set(handles.Annotation,'String','');


% Test whether you reached the end of the video:
if handles.frameCount >= length(handles.time)
    handles.frameCount = 1;
    set(handles.TimeSlider,'Value',handles.frameCount);
    set(handles.Annotation,'String','Reached the end of the Video');
    guidata(hObject, handles);
    return    
end

% Disable step button and annotation during viewing
set(handles.StepNotes,'Enable','off');
set(handles.Annotation,'Enable','off');
set(handles.FrameTimeLog,'String','Loading frames in memory ...');
set(handles.VideoImportText,'String','FPS (display): 5.00');

% Boundaries on annotation segment length
t_step = str2double(get(handles.StepSizeAnnotation,'String'));
if t_step < 1 || t_step > 30
    t_step = 5;
    set(handles.StepSizeAnnotation,'String','5.00');
end

% Get list of frames to be streamed for "Annotation Step."
tval = handles.time(handles.frameCount) + t_step;
use_frames = handles.frameCount:dsearchn(handles.time,tval);

% Log time for annotation
handles.annotations.time = cat(1,handles.annotations.time,...
    [handles.time(handles.frameCount),tval,use_frames([1,end])]);

% Pre-load all images in memory now
img = cell(1,length(use_frames));
for i = 1:length(use_frames)
    img{i} = FormatFrame(handles,use_frames(i));
end
t_disp = linspace(0,t_step,length(use_frames));

% Display images
timer2 = tic;
for i = 1:length(use_frames)
   while toc(timer2) < t_disp(i)
   % Fix delay for frame display
       pause(.001)
   end  
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
   showFrameOnAxis(handles.VideoAxes,img{i});
   handles.frameCount = min(handles.frameCount + 1,length(handles.time));
   set(handles.TimeSlider,'Value',handles.frameCount);
   % Set Frame Time Displayed
   str = sprintf('Frame:\t %d/%d',handles.frameCount,length(handles.time));
   set(handles.FrameTimeLog,'String',str);
end

% Reactivate annotation box and step
set(handles.Annotation,'Enable','on');
set(handles.StepNotes,'Enable','on');
handles.WriteAnnotation  = true;

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
timer1 = tic;
nfps   = 0;
while flag && handles.frameCount <= length(handles.time) && get(handles.AnnotationOn, 'Value') == 0 %handles.fexc.videoInfo(3)
   pause(.001);
   Y = get_bardata2(handles);
   set(get(handles.ChannelAxes,'Children'),'YData',Y)
   img = FormatFrame(handles);
   try
       showFrameOnAxis(handles.VideoAxes,img);
   catch
   % change of frame size -- reinitialize
       clear(handles.VideoAxes);
       showFrameOnAxis(handles.VideoAxes,img);
   end
   
   % Update the track number information
   txttn = sprintf('Number of Tracks: %.0f. Current track = %.0f.',...
       handles.trackN(handles.idx(handles.frameCount),1),handles.trackN(handles.idx(handles.frameCount),2));
   set(handles.TranString,'String',txttn);
   
   % Set Frame Time Displayed
   str = sprintf('Frame:\t %d/%d',handles.idx(handles.frameCount),handles.idx(end));
   set(handles.FrameTimeLog,'String',str);
   
   
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
   if ceil(get(handles.TimeSlider,'Value')) == handles.frameCount;
      handles.frameCount = handles.frameCount + 1;
      set(handles.TimeSlider,'Value',min(handles.frameCount,length(handles.idx)));
   else
      handles.frameCount = ceil(get(handles.TimeSlider,'Value'));
   end
   nfps = nfps + 1;
   handles.dfps  = cat(1,handles.dfps,[nfps,toc(timer1)]);
   set(handles.VideoImportText,'String',sprintf('FPS (display): %.2f',handles.dfps(end,1)/handles.dfps(end,2)));
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
% [~,name,ext] = fileparts(handles.fexc.video);
% str = sprintf('Video Name: %s%s',name,ext);
% set(handles.VideoNameText,'String',str);
td = fex_strtime(handles.fexc.videoInfo(2));
str = sprintf('Duration: %s',td{1});
set(handles.VideoDurationText,'String',str);

% Set Frame Time Displayed
str = sprintf('Frame:\t %d/%d',handles.frameCount,length(handles.time));
set(handles.FrameTimeLog,'String',str);

% Initialize annotation
handles.WriteAnnotation  = false;
handles.annotations.str  = cellstr('');
handles.annotations.time = []; 

% Choose default command line output for fexnotes
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in AnnotationOn.
function AnnotationOn_Callback(hObject, eventdata, handles)
% 
% Activate the Annotation Box

if get(handles.AnnotationOn, 'Value') == 1
    set(handles.Annotation,'String','');
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
    handles.annotations.str = cat(1,handles.annotations.str,get(handles.Annotation,'String'));
    handles.WriteAnnotation  = false;
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

% Rectification and normalization step
Fdata(Fdata < -1) = -1;
% Fdata = Fdata+1;


Fdata = mat2dataset(Fdata,'VarNames',handles.fexc.functional.Properties.VarNames);


function img = FormatFrame(handles,frame_n)
%
% Get/format the current frame

% Get size of the image Axes
% ss = round(get(handles.VideoAxes,'Position'));
% Get image
if nargin == 1
    frame_n = handles.frameCount;
end
% Read the image
img = read(handles.VideoFReader,handles.idx(frame_n));

% Draw/Don't Draw an image box
if get(handles.DrawFaceBox,'Value') == 1
    current_box = handles.all_boxes(handles.idx(frame_n),:);
    img = step(handles.drawbox,img,current_box);
end

% Crop/Don't Crop The Image
if get(handles.FaceCropSelect,'Value') == 1
    img = imcrop(img,handles.box);
end

% Set to black and white
if get(handles.BlackWhiteMode,'Value') == 1
    img = rgb2gray(img);
end
% Resize to fit the scrren
img = imresize(img,[340,310]);



function Y = get_bardata2(handles)

fc = handles.frameCount;
names = (get(handles.Channel,'String'));
Y = handles.Fdata.(names{get(handles.Channel,'Value')});

if fc+1 <= length(Y)
    Y(fc+1:end) = -1; % This was nan
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuHome_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHome (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSaveMain_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MenuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuOpenHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MenuOpenHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSaveImage_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSaveGif_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveGif (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSaveNotes_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSaveNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuLoadVideo_Callback(hObject, eventdata, handles)
% hObject    handle to MenuLoadVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuMask_Callback(hObject, eventdata, handles)
% hObject    handle to MenuMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to MenuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SmoothingMenu_Callback(hObject, eventdata, handles)
% hObject    handle to SmoothingMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in OvCombineSelect.
function OvCombineSelect_Callback(hObject, eventdata, handles)
% hObject    handle to OvCombineSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OvCombineSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OvCombineSelect


% --- Executes during object creation, after setting all properties.
function OvCombineSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OvCombineSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in OvColmapSelect.
function OvColmapSelect_Callback(hObject, eventdata, handles)
% hObject    handle to OvColmapSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OvColmapSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OvColmapSelect


% --- Executes during object creation, after setting all properties.
function OvColmapSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OvColmapSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OvColbar.
function OvColbar_Callback(hObject, eventdata, handles)
% hObject    handle to OvColbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OvColbar


% --- Executes on button press in OvSelectFeatures.
function OvSelectFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to OvSelectFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in OvAdvanced.
function OvAdvanced_Callback(hObject, eventdata, handles)
% hObject    handle to OvAdvanced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in OvTemplate.
function OvTemplate_Callback(hObject, eventdata, handles)
% hObject    handle to OvTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns OvTemplate contents as cell array
%        contents{get(hObject,'Value')} returns selected item from OvTemplate


% --- Executes during object creation, after setting all properties.
function OvTemplate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OvTemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OvApply.
function OvApply_Callback(hObject, eventdata, handles)
% hObject    handle to OvApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in FaceCropSelect.
function FaceCropSelect_Callback(hObject, eventdata, handles)
% hObject    handle to FaceCropSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FaceCropSelect


% --- Executes on button press in DrawFaceBox.
function DrawFaceBox_Callback(hObject, eventdata, handles)
% hObject    handle to DrawFaceBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DrawFaceBox
