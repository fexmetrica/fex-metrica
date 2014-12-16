function varargout = fexw_streamerui(varargin)
%
% Usage:
% Notes = fexw_streamerui();                        [not implemented]
% Notes = fexw_streamerui(fexObj.clone());
% Notes = fexObj.viewer()  
% 
% This viewer can be called with a fexc object as argument, in which case
% it is advisiable to use the "clone" method from the fexc object,
% otherwise the fexc object will be updated as well. 
%
% Alternatively this video viewer can be called as a method from a fexc
% object.
%
% fexw_streamerui included three pannels:
% 
% 1. A video pannel, where the video associated with the fexc object is
%    displayed. This pannel also includes the play/pause button, and the
%    timestamp for the frame currently displayed.
%
% 2. A Summary pannel, which shows the proportion of frames that were
%    recognized as positive, negative or neutral, and the proportion of
%    frames with missing faces.
%
% 3. A time series plot pannel, that shows up to seven timeseries from
%    emotions and action units.
%
% Using the menu you can edit features from the video pannel and from the
% timeseries pannel. The content of the menu is described below.
%
% "File" [not implemented] includes three methods:
%
%  + "Open" imports a fexc object when fexw_streamerui is called; 
%  + "Save" saves currently displayed frame to a jpeg file;
%  + "Quit" closes the interface. 
%
% "Viewer" [not implemented] selects the type of image will be shown
% between:
%
%  + "Video" shows frames from the video;
%  + "Rendering" uses fexview to display a model of the face.
%
% "Select" [not implemented**] opens a gui that allows to select the
%    facial expressions to be displayed on each time series plot.
%
%  ** NOTE that even if this procedure is not yet implemented, the user can
%  change the emotions displayed on each timeseries plot by rightclicking
%  on each plot. This will open a context menue.
%
% "Tools" are divided in three groups: Tools for the video pannel, tools
% for the time series pannel, and tools for adding notes.
%
% (1) Video Tools include:
%
%  + "Crop Frame" Shows a region of each video frames that contains the
%     a face. Note that the cropping is done so to encompass all the face
%     box in the video.
%  + "Face Box" Drows a box around the face. The box is colorcoded to
%     indicate sentiments ("positive," "neutral," and "negative").
%  + "Landmarks" drows face landmarks on each frame.
%  + "Black & Withe" converts each frame to black and white.
%
% (2) Time Series Tools include:
%  
%  + "X-axis" lets you select whether to display a timeseries of the full
%    video, or to zoom in (5 min,1 min, or 30 sec). 
%  + "Show Nans" [not implemented] allows to select whether to have an
%    unbroken timeserie, or to brake the timeseries when a face is not
%    recognized.
%  + "Rectification" [not implemented**] allows you to select a value used
%    to rectify the timeseries (i.e. all datapoints whose value is below a
%    given threshold t are set to t).
%
% ** NOTE that all data displayed are rectified using -1 as value. 
%
% (3) Notes Tools
%
%  + "Add Notes" opens a window that allows the user to take notes on the
%     video displayed in the viewer. This option can be selected from the
%     menu toolbar, or using "Command+N" (or "Ctrl + N" on non-OSX system).
%
%     Each annotation is returned by fexw_viewerui.m or it is added to the
%     fexc object used to call the viewer (i.e. when the viewer is called
%     with the syntax fexObj.viewer()). Annotations are K dimensional
%     structure (where K is the number of notes). Each structure contains
%     the following fields:
%
%     "Start":   Starting time to which the note applies (a string).
%     "End":     Ending time to which the note applies (a string).
%     "Anomaly": Boolean value, set to 1 when the note applies to an
%                anomaly.
%     "Domain":  A string indicating the emotions to which each note
%                applies. This string can be set to "all," it can be empty,
%                or it can be a list, such as "anger:disgust:contempt."
%     "Note":    String containing the actual note.
%
%     All options can be set from the "streamernoteui.m" interface. Note
%     the following: If the streamernoteui is hard closed, or if it is
%     cancelled using the "Cancel" button, no annotation is stored.
%     Additionally, even if the button "Submitt" is pressed, no annotation
%     is stored if both the anomaly box is unchecked AND if no annotation
%     is entered.
%
%     The annotations can be submitted by pressing the "Submitt" button, or
%     by pressing "enter" on the keyboard.
%
%     If the fexc object presented in the viewer already contains
%     annotation, the new annotations are added to the existing ones.
%
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 12/11/14.



gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexw_streamerui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexw_streamerui_OutputFcn, ...
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


% --- Executes just before fexw_streamerui is made visible.
function fexw_streamerui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Initialize the viewer

set(handles.figure1,'Name','FexViewer 1.0.1')
handles.annotations = [];
handles.annotation_flag = false;
if length(varargin) == 1 && isa(varargin{1},'fexc')

% Generate handles argument for for fexc Object
handles.fexc = varargin{1};
handles.video = handles.fexc.video;
    
% Check the video-format. Matlab is not very fast at reading from video
% containers with elaborate compression. If the file is not an .avi file, I
% am converting it to an .avi file with mjpeg codec. This basically entails
% a collection of images, and it is usually more space demanding than the
% original file. The new file is saved to a directory named
% "fexwstreamermedia" in the current directory, and it has the same name of
% the original file. Note that if the directory already exists, and if the
% file already exists, that file is used instead of decoding the video
% again. Re-encoding is performed using ffmpeg. We I can't find the ffmpeg
% executable, I use the original video ... Note that this could be very slow.
[~,~,Ext] = fileparts(handles.video);
if ~strcmp(Ext,'.avi')
    handles.video = convert2mjpg(handles.video);
end

% Get frame by frame boxes and get comprehensive box for cropping
facebox = get(handles.fexc,'Face');
B = [facebox.FaceBoxX,facebox.FaceBoxY,facebox.FaceBoxW,facebox.FaceBoxH];
handles.all_boxes = int32(B);
B(:,3:4) = B(:,1:2) + B(:,3:4);
handles.box = [min(B(:,1:2)), max(B(:,3:4)) - min(B(:,1:2))];
 
% List of nans to get an unbroken line
nisnan_idx = ~isnan(sum(double(handles.fexc.functional),2));

% Set up a current video time, and use it to locate the position in the
% video to stream
handles.time = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
handles.current_time = handles.time(2);
handles.frameCount = 1;
handles.nframes = length(handles.time);
handles.dfps = [];

% Add sentiments information -- Which sentiment is winning, color for each
% sentiments, idx for sentiments, and data for plotting sentiment
% timeseries or piechart.
if isempty(handles.fexc.sentiments)
    handles.fexc.derivesentiments(.25);
end
sidx = 3*ones(handles.nframes,1); % note that 4 is for nans
sidx(nisnan_idx) = handles.fexc.sentiments.Winner;
handles.sentimentcolor = zeros(handles.nframes,3);
col =  fex_getcolors(3); col(2,:) = [1,1,1]; col = col([3,1,2],:);
for i = 1:3
   handles.sentimentcolor(sidx==i,:) = repmat(col(i,:),[sum(sidx == i),1]);
end
handles.sentimentidx = sidx;
handles.sentimentlabels = {'Positive','Negative','Neutral'};

% Piechart information & diagnostic information
axes(handles.BarAxis); subplot(1,2,1);
sidx(nisnan_idx == 0) = 4;
X = dummyvar([sidx;4]); X = nanmean(X(1:end-1,:));
L = {'Positive','Negative','Neutral','Missing'};
[~,~,hl] = fexw_pie(X,'Color',[col;[.2,1,.2]],'text',L,'isLegend',true);
set(hl,'Color',[0,0,0],'TextColor',[1,1,1]);
set(hl,'Position',[0 0.5695 0.1843 0.3343],'Box','off');


% Set up timeseries related handles
handles.tsh = [];
xct = repmat(handles.time(1),[1,10]);
axes(handles.TSAxes);
for i = 1:7
    subplot(7,1,i); hold on;
    handles.tsh = cat(1,handles.tsh,gca);
    plot(linspace(handles.time(1),handles.time(end),100),zeros(1,100),'--w','LineWidth',2);
    set(gca,'Tag',sprintf('%d',i),'Color','k','ylim',[-1,2],'YColor',[1 1 1],...
        'XTickLabel','','xlim', [handles.time(1),handles.time(end)],'XColor',[1 1 1],...
        'box','on','LineWidth',2,'fontsize',12);
    if i == 1
        x = get(gca,'XTick');
        set(gca,'XTick',x,'XTickLabel',fex_strtime(x,'short'),'XAxisLocation','Top');   
    else
        set(gca,'XTick',[]);
    end
end
% Add time at the bottom
set(gca,'XTick',x,'XTickLabel',fex_strtime(x,'short'));
emocolor = fex_getcolors(7);
Y = get(handles.fexc,'Emotions');
emoname = Y.Properties.VarNames;
allnames = handles.fexc.functional.Properties.VarNames;
Y = double(Y); Y(Y < -1) = -1;
ind = nisnan_idx;
for i = 1:7
    hth2 = plot(handles.tsh(i),handles.time(ind),Y(ind,i),'Color',emocolor(i,:),'LineWidth',2);
    set(hth2,'Tag','tsplot');
    ylabel(handles.tsh(i),emoname{i});
    hth = plot(handles.tsh(i),xct,linspace(-1,2,10),'w','LineWidth',1);
    set(hth,'Tag','tslp');
    % Add context menue
    set(handles.tsh(i),'uicontextmenu',create_contextmenue(allnames,emoname{i},handles));
end

% Add a set of flags for the face box (recognize sentiments for now).
% Sentiments are inferred using max pooling across emotion channels. If
% none of the emotion value is larger than zero, sentiment is set to
% neutral (white box).
handles.drawbox = vision.ShapeInserter;
set(handles.drawbox,'Fill',true,'FillColorSource','Property',...
    'FillColor','Custom','Opacity',.3);
set(handles.drawbox,'CustomFillColor',[1,1,1]);

% Add Markers for landmarks
handles.Landmarks = handles.fexc.get('Landmarks','double');
handles.markers = vision.MarkerInserter('Shape','X-mark','BorderColor',...
    'Custom','CustomBorderColor',uint8([255 0 0]),'Size',10);


% Video Reader/Player (make sure you can read the video)
try 
    handles.VideoFReader = VideoReader(handles.video);
catch errorId
    warning(errorId.message);
    handles.video = convert2mjpg(handles.video);
    handles.VideoFReader = VideoReader(handles.video);
end

% Set first frame
img = FormatFrame(handles,1);
imshow(img,'parent',handles.FrameAxis);

% Set Time Slider Properties
% fps = mode(diff(handles.fexc.time.TimeStamps));
set(handles.TimeSlider,'Min',0,'Max',handles.time(end),'Value',0);


% Initialize handle for x axes & set inactive the axis extent that are
% longer than the video
handles.extents = [0,5*50,60,30];
handles.xaxis = 1;
for i = 1:length(handles.extents);
    if handles.extents(i) > handles.time(end);
        hx = findobj(handles.MT_xaxisextent,'Position',i);
        set(hx,'Enable','off');
    end
end

% Annotation initialize: If the fexc object selected already has a set of
% annotations, the new annotation will be added to the existing ones by
% FEXC after you exited the viewer.
handles.annotations = [];
% if isempty(handles.fexc.get('notes'))
%     handles.annotations = [];
% else
%     N = handles.fexc.get('notes');
%     handles.annotations  = N;
% end

set(handles.MT_trackobject,'Enable','off');
% Add track selected object
% handles.trackobj.object = imrect(handles.FrameAxis);
% set(handles.trackobj.object,'Visible','off');
% handles.trackobj.data = [];


end

% Update
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexnotes wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexw_streamerui_OutputFcn(hObject, eventdata, handles) 
%
% Return the annotations
if isfield(handles,'annotations')
    varargout{1} = handles.annotations;
else
    varargout{1} = '';
end
delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

% Send Close request
if isequal(get(hObject,'waitstatus'),'waiting')
    if strcmp(get(handles.PlayButton,'String'),'Pause')
    % Safe check for closing when video is playing
        set(handles.PlayButton,'String','Play');
        pause(0.001);
    end
    uiresume(hObject);
else
    delete(hObject);
end


%+++++++++++++++++++++++++++++++++++++++++++++++ Get Indices for frames
function idx = getIdx(handles)
%
%
idx  = dsearchn(handles.time,handles.current_time);


%+++++++++++++++++++++++++++++++++++++++++++++++ Context Menue for feature
function hcmenu = create_contextmenue(features,inuse,handles)
%
%
hcmenu = uicontextmenu;
set(hcmenu,'UserData',dataset2struct(handles.fexc.functional,'AsScalar',true))
for i = 1:length(features)
    item = uimenu(hcmenu,'Label',features{i},'Callback',@feature_select_callback);
    if strcmpi(features{i},inuse)
        set(item,'Checked','on');
    end
end


function feature_select_callback(hObject,eventdata,handles)
%
% Update the feature displayed here

% Gather the handles for the menue and the 
label    = get(gcbo,'Label');
hand_ts  = findobj(get(gco,'Children'),'Tag','tsplot');
hand_cm  = get(gco,'UIContextMenu');

% Uncheck all and re-chek selectde
set(get(hand_cm,'Children'),'Checked','off');
set(gcbo,'Checked','on');

% Get timeseries and refresh data
Y = get(hand_cm,'UserData');
Y = Y.(label); Y = Y(~isnan(Y));
set(hand_ts,'YData',Y');

% Update Ylabel
set(get(get(hand_ts,'Parent'),'Ylabel'),'String',label);


%+++++++++++++++++++++++++++++++++++++++++++++++ Frame Formatting function
function img = FormatFrame(handles,frame_n)
%
% Get/format the current frame


if nargin == 1
    frame_n = handles.fexc.time.FrameNumber(handles.frameCount);
end
% Read the image
img = read(handles.VideoFReader,frame_n);

% Set to black and white
if strcmp(get(handles.MT_BlackWhite,'Checked'),'on');
    img = repmat(rgb2gray(img),[1,1,3]);
end

% Draw/Don't Draw an image box
if strcmp(get(handles.MT_feelfacebox,'Checked'),'on');
    current_box = handles.all_boxes(frame_n,:);
    col   = uint8(255*handles.sentimentcolor(frame_n,:));
    label = handles.sentimentlabels{handles.sentimentidx(frame_n)};
    img = insertObjectAnnotation(img,'rectangle',current_box,label,'Color',col);
    release(handles.drawbox);
    set(handles.drawbox,'CustomFillColor',col);
    img = step(handles.drawbox,img,current_box);
end

% Add/don't add landmarks
if strcmp(get(handles.MT_Landmarks,'Checked'),'on')
    lpoint = reshape(handles.Landmarks(frame_n,:),2,7)';
    img = step(handles.markers,img,int32(lpoint));
end

% Crop/Don't Crop The Image
if strcmp(get(handles.MT_Cropframe,'Checked'),'on');
% if get(handles.CropOption,'Value') == 1
    img = imcrop(img,handles.box);
end

% Resize to fit the scrren
img = imresize(img,[340,310]);


%+++++++++++++++++++++++++++++++++++++++++++++++ Video Re-encoding function
function new_name = convert2mjpg(oldname)
% 
% Use ffmpeg to re-encode the video to .avi with mjpeg.

if ~exist('fexwstreamermedia','dir')
    mkdir('fexwstreamermedia');
end
[~,fname] = fileparts(oldname);
new_name  = sprintf('%s/fexwstreamermedia/%s.avi',pwd,fname);

if exist(new_name,'file')
% If a file with the same name was already re-encoded, return and use that
% file.
    return
end

% This may not work if I can't find the ffmpeg executable.
cmd = sprintf('ffmpeg -i %s -vcodec mjpeg -an -q 2 %s',oldname,new_name);
[isError,output] = unix(sprintf('source ~/.bashrc && %s',cmd),'-echo');

if isError ~= 0 
% Something went wrong: print error, use the old video and leave.
    warning(output);
    new_name = oldname;
end    


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
%
% Play/Pause video

% Safety check for data
if ~isfield(handles,'fexc')
    warning('You need to enter data first ... ')
    return
end

% Play Pause callback
if strcmp(get(handles.PlayButton,'String'),'Play')
    set(handles.PlayButton,'String','Pause');
%     set(handles.MT_trackobject,'Enable','off');
else
    set(handles.PlayButton,'String','Play');
%     set(handles.MT_trackobject,'Enable','on');
end

flag = strcmp(get(handles.PlayButton,'String'),'Pause');


while flag && handles.frameCount < handles.nframes;
% main loop for streaming the video

   % Handle annotation here 
   pause(0.001);
   if strcmp(get(handles.MT_AddNotes,'Checked'),'on')
      set(handles.PlayButton,'Enable','off');
      set(handles.TimeSlider,'Enable','off');
      set(handles.MT_AddNotes,'Enable','off');

      % Run the note handle
      N = streamernotesui(handles);
      % Store the note
      if ~isempty(N)
         handles.annotations = cat(1,handles.annotations,N);
      end
      % Restart the video if "flag" is set to true
      set(handles.PlayButton,'Enable','on');
      set(handles.TimeSlider,'Enable','on');
      set(handles.MT_AddNotes,'Checked','off');
      set(handles.MT_AddNotes,'Enable','on');
   end
   
   tic
   img = FormatFrame(handles);
   strnowtime = fex_strtime(handles.current_time);
   set(handles.TimeSrtingUpdate,'String',strnowtime{1});
   try
       imshow(img,'parent',handles.FrameAxis);
   catch
       warning('Something wrong happened.');
       return
   end
   handles.dfps = cat(1,handles.dfps,toc);
   
   if handles.current_time == get(handles.TimeSlider,'Value')
       handles.current_time = handles.current_time + handles.dfps(end); 
   else
      handles.current_time =  get(handles.TimeSlider,'Value');
   end
   handles.frameCount = getIdx(handles);
   set(handles.TimeSlider,'Value',handles.current_time);
   set(findobj(handles.tsh,'Tag','tslp'),'XData',repmat(handles.current_time,[1,10]))

   % Adjust xlim
   if  ~isempty(get(findobj(handles.MT_xaxisextent,'Checked','on'),'UserData'));
       span = get(findobj(handles.MT_xaxisextent,'Checked','on'),'UserData');
       if handles.current_time < span
          set(handles.tsh,'xlim',[0,span]);
          % update scroller position
          % set(handles.TimeSlider,'Value',handles.current_time,'Min',0,'Max',span);
       else
          lim = [max(0,handles.current_time - span/2),min(handles.current_time + span/2,handles.time(end))];
          set(handles.tsh,'xlim',lim);
          % set(handles.TimeSlider,'Value',handles.current_time,'Min',lim(1),'Max',lim(2));
       end 
   end

   % Re-evaluate frame cound
   if mod(length(handles.dfps),100) == 0
       dfps = round(1/mean(handles.dfps));
       handles.dfps = [];
       fprintf('FN = %d: Display rate: %d per second.\n',handles.frameCount, dfps);
   end
   
   % Update flag
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
end

if handles.frameCount >= handles.nframes
    % Reinitialize video
    set(handles.PlayButton,'String','Play');
    handles.frameCount = 1;
    set(handles.TimeSlider,'Value',handles.time(1));
    handles.current_time = handles.time(1);
    img = FormatFrame(handles);
    imshow(img,'parent',handles.FrameAxis);
    set(handles.TimeSrtingUpdate,'String','00:00:00.000');
end

guidata(hObject, handles);

% +++++++++++++++++++++++++++++++++++++++++++++++++++ Main menu Callbacks
% --------------------------------------------------------------------
function MainMenueClose_Callback(hObject, eventdata, handles)
% hObject    handle to MainMenueClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function MainMenueOpen_Callback(hObject, eventdata, handles)
% hObject    handle to MainMenueOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MainMenueSave_Callback(hObject, eventdata, handles)
% hObject    handle to MainMenueSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% +++++++++++++++++++++++++++++++++++++++++++++++++++++ Selection Callback
% --------------------------------------------------------------------
function MenuSelection_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function MenuSelectHelp_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelectHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MSAU1_Callback(hObject, eventdata, handles)
% hObject    handle to MSAU1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% +++++++++++++++++++++++++++++++++++++++++++++++++++++ Menu Tools Calbacks
% --------------------------------------------------------------------
function MenuTools_Callback(hObject, eventdata, handles)
% hObject    handle to MenuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MT_feelfacebox_Callback(hObject, eventdata, handles)
%
% FaceBox on/off call back

if strcmp(get(handles.MT_feelfacebox,'Checked'),'on')
    set(handles.MT_feelfacebox,'Checked','off');
else
    set(handles.MT_feelfacebox,'Checked','on');
end


% --------------------------------------------------------------------
function MT_Cropframe_Callback(hObject, eventdata, handles)
%
% Face cropping on/of callback

if strcmp(get(handles.MT_Cropframe,'Checked'),'on')
    set(handles.MT_Cropframe,'Checked','off');
else
    set(handles.MT_Cropframe,'Checked','on');
end


% --------------------------------------------------------------------
function MT_BlackWhite_Callback(hObject, eventdata, handles)
%
% Black & White on/off callback

if strcmp(get(handles.MT_BlackWhite,'Checked'),'on')
    set(handles.MT_BlackWhite,'Checked','off');
else
    set(handles.MT_BlackWhite,'Checked','on');
end

% --------------------------------------------------------------------
function MT_ShowNaNs_Callback(hObject, eventdata, handles)
% hObject    handle to MT_ShowNaNs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MT_xaxisextent_Callback(hObject, eventdata, handles)
% hObject    handle to MT_xaxisextent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MT_XaxisLength_Callback(hObject, eventdata, handles)
% hObject    handle to MT_XaxisLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hand_sel = get(handles.MT_xaxisextent,'Children');
set(hand_sel,'Checked','off');
set(handles.MT_XaxisLength,'Checked','on');
% update xaxis
set(handles.tsh,'xlim',[0,handles.time(end)]);

% --------------------------------------------------------------------
function MTX5_Callback(hObject, eventdata, handles)
%
hand_sel = get(handles.MT_xaxisextent,'Children');
set(hand_sel,'Checked','off');
set(handles.MTX5,'Checked','on');
t = handles.current_time;
if t <= 300
    set(handles.tsh,'xlim',[0,300]);
else
    lim = [max(0,t-150),min(t+150,handles.time(end))];
    set(handles.tsh,'xlim',lim);
end


% --------------------------------------------------------------------
function MTX1_Callback(hObject, eventdata, handles)
%
hand_sel = get(handles.MT_xaxisextent,'Children');
set(hand_sel,'Checked','off');
set(handles.MTX1,'Checked','on');
t = handles.current_time;
if t <= 60
    set(handles.tsh,'xlim',[0,60]);
else
    lim = [max(0,t-60),min(t+60,handles.time(end))];
    set(handles.tsh,'xlim',lim);
end

% --------------------------------------------------------------------
function MTX30s_Callback(hObject, eventdata, handles)
%
hand_sel = get(handles.MT_xaxisextent,'Children');
set(hand_sel,'Checked','off');
set(handles.MTX30s,'Checked','on');
t = handles.current_time;
if t <= 30
    set(handles.tsh,'xlim',[0,30]);
else
    lim = [max(0,t-15),min(t+15,handles.time(end))];
    set(handles.tsh,'xlim',lim);
end

% --------------------------------------------------------------------
function MT_rectification_Callback(hObject, eventdata, handles)
% hObject    handle to MT_rectification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MT_AddNotes_Callback(hObject, eventdata, handles)
%
% Start the annotation gui. This uses "streamernotesui.m."

% Store flag to decide whether to re-start the video
if strcmp(get(handles.PlayButton,'String'),'Pause')
    set(handles.MT_AddNotes,'Checked','on');
else
%     set(handles.PlayButton,'String','Play');
%     pause(0.001);

set(handles.PlayButton,'Enable','off');
set(handles.TimeSlider,'Enable','off');
set(handles.MT_AddNotes,'Enable','off');

% Run the note handle
N = streamernotesui(handles);

% Store the note
if ~isempty(N)
    handles.annotations = cat(1,handles.annotations,N);
end

% Restart the video if "flag" is set to true
set(handles.PlayButton,'Enable','on');
set(handles.TimeSlider,'Enable','on');
set(handles.MT_AddNotes,'Enable','on');

end
% Update all
handles.output = hObject;
guidata(hObject,handles);
% pause(0.001);

% if flag
%    PlayButton_Callback(hObject, eventdata, handles);
% end



% --------------------------------------------------------------------
function MT_Landmarks_Callback(hObject, eventdata, handles)
% hObject    handle to MT_Landmarks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.MT_Landmarks,'Checked'),'on')
    set(handles.MT_Landmarks,'Checked','off');
else
    set(handles.MT_Landmarks,'Checked','on');
end


% ++++++++++++++++++++++++++++++++++++++++++++++++++++ Time Slider Callback
% --- Executes on slider movement.
function TimeSlider_Callback(hObject, eventdata, handles)
%
%
handles.current_time = get(handles.TimeSlider,'Value'); 
handles.frameCount = getIdx(handles);

if strcmp(get(handles.PlayButton,'String'),'Play')
   img = FormatFrame(handles);
   strnowtime = fex_strtime(handles.current_time);
   set(handles.TimeSrtingUpdate,'String',strnowtime{1});
   set(findobj(handles.tsh,'Tag','tslp'),'XData',repmat(handles.current_time,[1,10]))
   imshow(img,'parent',handles.FrameAxis);
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function TimeSlider_CreateFcn(hObject, eventdata, handles)
%
%
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% ++++++++++++++++++++++++++++++++++++++++++++++ Viewer Selection Callbacks
% --------------------------------------------------------------------
function MenuViewerMode_Callback(hObject, eventdata, handles)
% hObject    handle to MenuViewerMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function VM_video_Callback(hObject, eventdata, handles)
% hObject    handle to VM_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function VM_Rendering_Callback(hObject, eventdata, handles)
% hObject    handle to VM_Rendering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MT_trackobject_Callback(hObject, eventdata, handles)
% hObject    handle to MT_trackobject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if strcmp(get(handles.trackobj.object,'Visible'),'off');
%     set(handles.trackobj.object,'Visible','on')
%     handles.trackobj.position = getPosition(handles.trackobj.object);
% end
% set(handles.trackobj.object,'Visible','off')


% 
% if isempty(handles.trackobj.object)
% % Initialize track object here   
% %
% %
% h = imrect(handles.FrameAxis);
% Pos = getPosition(h);
% fprintf('I am here')
% end
