function varargout = fexw_streamerui(varargin)
%
%
%
% FexViewer .. needs to be called from a fexObject, using the viewer method
%
% Components:
% -- Load full video (this is a temporary version);
% -- Set up functional data;
% -- "perpare frame" object;
% -- Inititate plots
% -- (plot selection);
% -- Initiate bar graph on the bottom.
% -- start stop button
% -- Add "jump to" controll bar
% 
% -- controller panel:
%
%    -- crop
%    -- face box
%    -- black and white
%    -- baseline
%    -- scale (10,30,60,90,full)


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
 
% Get frame indices -- this is used to stream the video at a frame rate
% that is comparable to the display framereate. handles.idx is initiated
% as 1:numframes. Every 100 frames displayed, the average display fps is
% computed, and indices are re-evaluated.

% handles.idx  = 1:size(handles.fexc.functional,1);
% handles.video_time = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
% handles.dfps = [];

% Set up a current video time, and use it to locate the position in the
% video to stream
handles.time = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
handles.current_time = handles.time(2);
handles.frameCount = 1;
handles.nframes = length(handles.time);
handles.dfps = [];

% Get image data
% [idx,ti,Fdata] = get_DataOut(handles);
% handles.idx = idx;
% handles.Fdata = Fdata;
% handles.time  = ti;
% handles.dfps  = [1,5];

% Add sentiments information -- Which sentiment is winning, color for each
% sentiments, idx for sentiments, and data for plotting sentiment
% timeseries or piechart.
if isempty(handles.fexc.sentiments)
    handles.fexc.derivesentiments(.25);
end
sidx = 3*ones(handles.nframes,1);
sidx(~isnan(B(:,1))) = handles.fexc.sentiments.Winner;
handles.sentimentcolor = zeros(handles.nframes,3);
col =  fex_getcolors(3); col(2,:) = [1,1,1]; col = col([3,1,2],:);
for i = 1:3
   handles.sentimentcolor(sidx==i,:) = repmat(col(i,:),[sum(sidx == i),1]);
end
handles.sentimentidx = sidx;
handles.sentimentlabels = {'Positive','Negative','Neutral'};

% Piechart information & diagnostic information
axes(handles.BarAxis)
subplot(1,2,1)
perc_s = zeros(1,4);
for i = 1:3
    perc_s(i) = nansum(handles.fexc.sentiments.Winner == i);
end
perc_s(4) = sum(isnan(B(:,1)));
perc_s    = perc_s./handles.nframes;
pie(perc_s,[1,1,1,1]);
hleg = legend({'Positive','Negative','Neutral','NaNs'},'Location','NorthWest');


% Add a set of flags for the face box (recognize sentiments for now).
% Sentiments are inferred using max pooling across emotion channels. If
% none of the emotion value is larger than zero, sentiment is set to
% neutral (white box).
handles.drawbox = vision.ShapeInserter;
set(handles.drawbox,'Fill',true,'FillColorSource','Property',...
    'FillColor','Custom','Opacity',.3);
set(handles.drawbox,'CustomFillColor',[1,1,1]);
set(hleg,'Color',[0,0,0],'TextColor',[1,1,1]);
set(hleg,'Position',[0 0.5695 0.1843 0.3343],'Box','off');


% Video Reader/Player
handles.VideoFReader = VideoReader(handles.video);
img = FormatFrame(handles,1);
imshow(img,'parent',handles.FrameAxis);

% Emotions/AUs graph
% set(handles.Channel,'Value',5)
% X =  handles.time;
% Y = get_bardata2(handles);
% axes(handles.ChannelAxes); hold on
% plot(X,zeros(length(X),1),'--k');
% area(X,Y,'basevalue',-1,'LineWidth',2,'EdgeColor','b')
% alpha(.4); xlim([0,max(X)]); ylim([-1,3]);
% xt  = get(gca,'XTick');
% xts = fex_strtime(xt,'short');
% set(gca,'XTick',xt(2:end),'XTickLabel',xts(2:end),'box','on','LineWidth',2,'fontsize',12)
% ylabel('LogEvidence','fontsize',12);
% handles.ChannelAxexesChild = get(gca,'Children');
% hold off

end

% Update
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexnotes wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexw_streamerui_OutputFcn(hObject, eventdata, handles) 
%
% 
varargout{1} = '';
delete(handles.figure1);


%+++++++++++++++++++++++++++++++++++++++++++++++ Get Indices for frames
function idx = getIdx(handles)
%
%


% DOESN"T WORK -- TRY TICK TOCK OPERATION -- getCurrentTime//setCurrentTime




% nfr  = size(handles.fexc.functional,1);
% nfst = round(handles.fexc.videoInfo(1)/nfd); 
% idx1 = handles.idx(1:handles.frameCount-1);
% idx2 = handles.idx(handles.frameCount):nfst:nfr;
% idx  = [idx1(:);idx2(:)];
% idx(end) = nfr;
% handles.video_time = handles.fexc.time.TimeStamps(idx) - handles.fexc.time.TimeStamps(1);

% t   = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
% ctime = handles.video_time(handles.frameCount);
% ltime = handles.fexc.time.TimeStamps(end) - handles.fexc.time.TimeStamps(1);
% ti1 = ctime:1/(nfd-1):ltime;
% ti2 = handles.video_time(1:handles.frameCount);
% ti  = [ti1(:); ti2(:)];
% ti(end) = t(end);
% 
% % find new indices
% idx = dsearchn(t,ti);
% 
% % Update video time and frame count
% handles.video_time = ti;
% handles.frameCount = find((ti - ctime) >= 0,1,'first');
idx  = dsearchn(handles.time,handles.current_time);

% ctime = handles.video_time(handles.frameCount);
% t   = handles.fexc.time.TimeStamps - handles.fexc.time.TimeStamps(1);
% ti  = (0:1/nfd:t(end))';
% idx = dsearchn(t,ti);
% idx = min(idx,size(handles.fexc.functional,1));
% 
% % Update video time and frame count
% handles.video_time = ti;
% handles.frameCount = find((ti - ctime) >= 0,1,'first');



%+++++++++++++++++++++++++++++++++++++++++++++++ Frame Formatting function
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
img = read(handles.VideoFReader,frame_n);

% Set to black and white
if strcmp(get(handles.MT_BlackWhite,'Checked'),'on');
% if get(handles.BWOption,'Value') == 1
    img = repmat(rgb2gray(img),[1,1,3]);
end

% Draw/Don't Draw an image box
% if get(handles.FaceBoxOption,'Value') == 1
if strcmp(get(handles.MT_feelfacebox,'Checked'),'on');
    current_box = handles.all_boxes(frame_n,:);
    col   = uint8(255*handles.sentimentcolor(frame_n,:));
    label = handles.sentimentlabels{handles.sentimentidx(frame_n)};
    img = insertObjectAnnotation(img,'rectangle',current_box,label,'Color',col);
    release(handles.drawbox);
    set(handles.drawbox,'CustomFillColor',col);
    img = step(handles.drawbox,img,current_box);
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

% I am manually inserting the ffmpeg executable
cmd = sprintf('ffmpeg -i %s -vcodec mjpeg -q 5 %s',oldname,new_name);
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
else
    set(handles.PlayButton,'String','Play');
end

flag = strcmp(get(handles.PlayButton,'String'),'Pause');


while flag && handles.frameCount < handles.nframes;
% main loop for streaming the video
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
   handles.current_time = handles.current_time + handles.dfps(end); 
   handles.frameCount = getIdx(handles);

   % Re-evaluate frame cound
   if mod(length(handles.dfps),100) == 0
       dfps = round(1/mean(handles.dfps));
       handles.dfps = [];
       fprintf('FN = %d: Display rate: %d per second.\n',handles.frameCount, dfps);
   end
   
   % Update flag
   flag = strcmp(get(handles.PlayButton,'String'),'Pause');
%    handles.frameCount = handles.frameCount + 1;
end

if handles.frameCount >= handles.nframes
    % Reinitialize video
    set(handles.PlayButton,'String','Play');
    handles.frameCount = 1;
    handles.current_time = handles.time(2);
    img = FormatFrame(handles);
    imshow(img,'parent',handles.FrameAxis);
    set(handles.TimeSrtingUpdate,'String','00:00:00.000');
end

guidata(hObject,handles);





% --- Executes on button press in CropOption.
function CropOption_Callback(hObject, eventdata, handles)
% hObject    handle to CropOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CropOption


% --- Executes on button press in BWOption.
function BWOption_Callback(hObject, eventdata, handles)
% hObject    handle to BWOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BWOption


% --- Executes on button press in FaceBoxOption.
function FaceBoxOption_Callback(hObject, eventdata, handles)
% hObject    handle to FaceBoxOption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FaceBoxOption


% --- Executes on selection change in TSPlotXLim.
function TSPlotXLim_Callback(hObject, eventdata, handles)
% hObject    handle to TSPlotXLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TSPlotXLim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TSPlotXLim


% --- Executes during object creation, after setting all properties.
function TSPlotXLim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TSPlotXLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --------------------------------------------------------------------
% function MainMenu_Callback(hObject, eventdata, handles)
% % hObject    handle to MainMenu (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MainMenueClose_Callback(hObject, eventdata, handles)
% hObject    handle to MainMenueClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSelection_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSelectAU_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelectAU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSelectEmotions_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelectEmotions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function MenuSelectSentiments_Callback(hObject, eventdata, handles)
% hObject    handle to MenuSelectSentiments (see GCBO)
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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% Send Close request
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


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

