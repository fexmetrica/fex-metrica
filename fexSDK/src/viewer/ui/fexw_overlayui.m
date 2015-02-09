function varargout = fexw_overlayui(varargin)
% 
% FEXW_OVERLAYUI - UI for overlay image and movie generation.
%
% SYNTAX:
%
% FEXW_OVERLAYUI(DATA)
%
% Currently, the input DATA can only be a <a href="FEXC">fexc</a> object.
% No output is provided. FEXW_OVERLAYUI can also be called directly from a
% FEXC object, using the method SHOW and specifying 'overlay' as argument.
%
% FEXW_OVERLAYUI opens a UI, which displays Action Units scores from the
% Emotient SDK (http://www.emotient.com) onto a model of a face. Each
% overlay is an instance of the class <a href="FEXWOVERLAY">fexwoverlay</a>. The
% building blocks for FexView are facial muscles. The location and texture
% of individual muscular fibers are defined for a set of "template" or
% (<a href="FEXWIMG">fexwimg</a> objects) and the data are displayed on top of
% these pixels. Pixels within muscular region X are indicated in the header
% of the "templates." Action Units are localized on a face based on the
% muscles that contract or relax in order to generate those action units.
% Emotions are defined on an image in terms of combination of Action Units.
%
% ===============
% UI COMPONENTS:
% ===============
%
% #IMAGE PANEL - Main panel which displays the image with related overlay.
% You can change the underlying face image using the MENU item
% tools>template. This panel additionally allows to specify an upper and
% lower threshold for the colormap using the BOUNDS controller.
%
% #CONTROL PANEL - Set of control to moves from frame to frame. The PLAY
% button will play the video. PLAY will stream the video for the entire
% duration of the origianl video, however, the number of displayed frames
% per seconds will depend on computer speed. The button PREV and NEXT
% go back or advance 1 frame. The TIME BOX shows you the current frame
% time. 
%
% #PLOT PANEL - Shows a timeseries of facial expressions. The PLOT PANEL
% updates in relation to the features displayed in the IMAGE PANEL. There
% are three possible features that will be displayed:
%   
%   1. AUs score when the overlay includes at most 3 AUs;
%   2. First 3 PCA over AUs when the overlay includes more than 3 AUs;
%   3. Emotion evidenve, when SELECT is set to one of the basic emotions.
%
% The SLIDER at the bottom of this PANEL can be used to advance to a
% desired point in time in the FEXC timeseries, and will update the IMAGE
% PANEL component.
%
% #SMOOTHING PANEL - Allows to smooth the overlay. You can select one of the
% possible smoothing kernel, the size of the kernel, and, for specifc
% kernels, such as Gaussian or Log, you can specify the extra kernel
% parameter.
%
% See also FSPECIAL, IMFILTER.
%
% #COLOR PANEL - Regulates colormap, brightness and transparency properties.
% This panel allows you to specify a COLORMAP from one of those predefined
% in MATLAB. This panel also allows to add a COLORBAR**. Finally, this
% panel includes three sliders:
%
% 1.OVERLAY - indicates the transparency of the overlay on the template.
%   This is a number between 0 and 1 (default: 0.4). When overlay is set to
%   1, no overlay is displayed.
% 2.MUSCLES - transparency of the overlay on the muscular fibers. For
%   muscles = 1, the texture of the muscles is not displayed. By default,
%   this value is set to 1.0.
% 3.BRIGHTNESS - the brightness of the colors. This is a number between -1
%   and 1, which is set by default to 0.
%
% **COLORBAR functionality currently under development.
%
% ===============
% UI MENU ITEMS:
% ===============
%
% #FEXWOVERLAY - This item can open a HELP WINDOW, or CLOSE the UI.
%
% #FILE - Main file handling procedures. FILE menu item can be used to:
%
% 1.Import data from a file (FILE > Open File), or to import a FEXC
% instance (FILE > Open FEXC).
%
% 2.Save the currently displayed frame to an image (FILE>Save Image). This
% will open a UI that allows to select the name of the file, its extension,
% and the quality expressed in number of dots per inch.
%
% 3.Generate a movie from the currenr FEXC object. All movies are saved as
% .avi files. FILE>Save Movie will open a UI that allows to select the name
% of the movie; The quality of the image (0 < q <= 100, default: 75); The
% desired Frame Rate; And a subsection of the FEXC timeseries, in case you
% dont want to save all video frames.
%
% NOTE thate the FRAME RATE argument does not change the video FPS per
% se. Instead, it adjust the frame rate of the timeseries using FEXC
% methods INTERPOLATE or DOWNSAMPLE.
%
% #VIEW - Select which facial feature is displayed. By default,
% FEXW_OVERLAYUI displays all Action Units available. However, SELECT
% allows to display AUs retalted to specific emotions. The corrispondence
% is shown in the table below:
%
%       | Emotions | Corresponding AUs |
%       | ======== | ================= |
%       | anger    | 4,5,7,23          |
%       | disgust  | 9,15              |
%       | contempt | 12r,14r           |
%       | joy      | 6,12              |
%       | fear     | 1,2,4,5,7,20,25   |
%       | sadness  | 1,4,15            |
%       | surprise | 1,2,5,25          |
%
% When an emotion is selected, the IMAGE PANEL will display scores for AUs
% associated with that emotion, and the PLOT PANEL will display the
% evidence scores for that EMOTION.
% 
% Additionally, you can select VIEW > SELECT AUs ... , and a UI will pop
% up, which will allow you to display specific AUs.
%
% #TOOLS - Overlay formatting tools. The following optional TOOLS are
% currently available:
%
% 1.TEMPLATE: Allows you to select from one of the pregenerated 11
% templates (all of which are FEXWIMG objects). Additionally, if you select
% Tools > Template > CUSTOME ... a UI will pop up and will guide you
% through a procedure for creating a new underlying image. NOTE: Option
% "Custome ..." IS NOT IMPLEMENTED YET.
%
% 2.COMBINE: One of 'Mean,'(default) 'Median' and 'Max', which indicates
% how to combine AUs scores for overlapping action units -- namely AUs that
% depend on the same face muscles. NOTE that combination methid 'median' is
% the slowest. Also NOTE that the option Combine > CUSTOME ... IS NOT
% IMPLEMENTED YET.
%
% 3.BACKGROUND: When Checked, this item adds a background color within the
% face in the IMAGE PANEL.
%
% 4.SIDE: Determines whether to display AUs score on the left side, the
% right side or both side of the face in IMAGE PANEL. The subitem "Custome
% ..." allows to specify a side per each AU (THIS OPTION IS NOT IMPLEMENTED
% YET).
%
%
% See also FEXWOVERLAY, FEXWIMG, FEXC.
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 06-Jan-2015.

% START initialization ****************************************************
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexw_overlayui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexw_overlayui_OutputFcn, ...
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
% End initialization ******************************************************

function fexw_overlayui_OpeningFcn(hObject,eventdata,handles,varargin)
%
% FEXW_OVERLAYUI_OPENINGFCV - Initialize UI.

set(handles.figure1,'Name','Fex Viewer 1.0.1');

if ~isempty(varargin)
if ~isa(varargin{1},'fexc')
    error('Data should be a FEXC object.');
end

% Clone/Store fexc object
handles.fexobj = varargin{1}.clone();

% Update name 
str = get(handles.figure1,'Name');
if ~isempty(varargin{1}.name)
    str = sprintf('%s: %s',str,varargin{1}.name);
    set(handles.figure1,'Name',str);
elseif isempty(varargin{1}.name) && ~isempty(varargin{1}.video)
    [~,name] = fileparts(varargin{1}.video);
    str = sprintf('%s: %s',str,name);
    set(handles.figure1,'Name',str);
end

% Initialize FEXC options
axes(handles.figaxis);
axis tight
handles.overlayc = fexwoverlay(varargin{1},'fig',handles.figaxis);
handles.overlayc.show();

set(handles.boundsl,'String',sprintf('%.2f',handles.overlayc.info.bounds(1)));
set(handles.boundsu,'String',sprintf('%.2f',handles.overlayc.info.bounds(2)));

% Time and frame count
handles.n = 1;
handles.tn = varargin{1}.time.TimeStamps;
handles.t = fex_strtime(handles.tn);
handles.current_time = handles.tn(1);
set(handles.timetext,'String',handles.t{handles.n});
set(handles.frametext,'String',sprintf('%.4d',handles.n));

% Set TimeSlider
set(handles.timeslider,'Min',0,'Max',handles.tn(end),'Value',0);
set(handles.timeslider,'SliderStep',[1/length(handles.tn),0.025]);

% Plot update
handles.cursor = plotpanelmaster(handles);

% Video streaming axis place holder
axes(handles.vidaxis);
axis tight
imshow('movie_placeholder.jpg');
handles.vidobj = [];

% return to fig axis
axes(handles.figaxis);
end

% Choose default command line output for fexw_overlayui
handles.doclose = false;
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexw_overlayui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% ***************** SET UP PLOT *******************************************
function h = plotpanelmaster(handles,varargin)
%
% PLOTPANELMASTER - Generate the plot & return handle for the cursor.

h = [];
ind = ~isnan(sum(handles.fexobj.get('aus','double'),2));
T = handles.fexobj.time.TimeStamps(ind);
if isempty(varargin)
% Display the first 3 pca components.
    Y = handles.fexobj.get('aus','double');
    [~,Y] = pca(Y(ind == 1,:));
    Y(Y < 0) = 0; Y = Y(:,1:3);
    str = 'First PCA Components';
elseif iscell(varargin{1})
    Y = []; list = handles.overlayc.list('au');
    str = '';
    for j = 1:length(varargin{1})
        if ismember(varargin{1}{j},list)
            Y = cat(2,Y,handles.fexobj.functional.(upper(varargin{1}{j}))(ind == 1));
            str = sprintf('%s - %s',str,upper(varargin{1}{j}));
        end
    end
    if isempty(Y)
       warning('Disn''t recognized plot option.');
       return
    else
        Y(Y < 0) = 0;
    end
elseif ismember(varargin{1},handles.overlayc.list('e'))
    Y = handles.fexobj.functional.(varargin{1})(ind == 1);
    Y(Y < 0) = 0;
    str = varargin{1};
elseif ismember(varargin{1},handles.overlayc.list('au'))
    Y = handles.fexobj.functional.(upper(varargin{1}))(ind == 1);
    Y(Y < 0) = 0;
    str = varargin{1};   
else
    warning('Disn''t recognized plot option.');
    return
end

% Change axis & add plots
axes(handles.plotaxis);
% Clear axis data -- 
if isfield(handles,'cursor')
    cax = setdiff(get(handles.plotaxis,'Children'),handles.cursor);
    delete(cax);
end

hold on
plot(T,Y,'LineWidth',2);
% Fix xlimit and xlabels
xlim([handles.tn(1),handles.tn(end)]);
ylim([0,max(max(reshape(Y,numel(Y),1)),1)]);
x = get(handles.plotaxis,'XTick');
set(gca,'Color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1],'XTick',...
    x,'XTickLabel',fex_strtime(x,'short'),'LineWidth',2);
% Add title
title(str,'fontsize',14,'Color','w');

% Add cursor
y = linspace(0,max(max(reshape(Y,numel(Y),1)),1),10);
t = repmat(handles.current_time,[length(y),1]);
if ~isfield(handles,'cursor')
    h = plot(t,y(:),'--w','LineWidth',2);
else
    set(handles.cursor,'YData',y(:));
end
hold off

% % Add plot for positive and negative
% Y1 = varargin{1}.sentiments.Positive;
% Y2 = varargin{1}.sentiments.Negative;
% axes(handles.plotaxis);
% hold on
% title('Positive and Negative Sentiments','fontsize',14,'Color','w');
% area(varargin{1}.sentiments.TimeStamps,Y1,'FaceColor',[1,1,1],'LineWidth',2,'EdgeColor',[1,1,1]);
% alpha(0.4);
% area(varargin{1}.sentiments.TimeStamps,Y2,'FaceColor',[1,0,0],'LineWidth',2,'EdgeColor',[1,0,0]);
% alpha(0.4);
% x = get(handles.plotaxis,'XTick');
% set(gca,'Color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1],'XTick',...
%     x,'XTickLabel',fex_strtime(x,'short'),'LineWidth',2);
% ylim([0,max(max(Y1),max(Y2))]);
% xlim([handles.tn(1),handles.tn(end)]);
% legend({'Pos.','Neg.'},'TextColor',[1,1,1],'Box','off');
% hold off


% *************************************************************************
% **************** VIDEO CONTROLLERS **************************************
% *************************************************************************

function buttonback_Callback(hObject, eventdata, handles)
% 
% BUTTONBACK_CALLBACK - Go Back one frame.

if handles.n - 1 >= 1
    handles.n = handles.n - 1;
    handles.overlayc.show(handles.n);
    handles.current_time = handles.tn(handles.n);
    set(handles.cursor,'XData',repmat(handles.current_time,[10,1]));
    set(handles.timeslider,'Value',handles.tn(handles.n));
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.frametext,'String',sprintf('%.4d',handles.n));
    % Add movie frame
    if ~isempty(handles.vidobj)
        img = read(handles.vidobj,handles.fexobj.time.FrameNumber(handles.n));
        imshow(img,'parent',handles.vidaxis);
    end 
end
guidata(hObject, handles);

function buttonplay_Callback(hObject, eventdata, handles)
%
% BUTTONPLAY_CALLBACK - plays/pause the movie.

if strcmp(get(handles.buttonplay,'String'),'Play')
    set(handles.buttonplay,'String','Pause');
    set(handles.buttonback,'Enable','off');
    set(handles.buttonforward,'Enable','off');
    set(handles.saveimage,'Enable','off');
    set(handles.savemovie,'Enable','off');
    set(handles.addmovie,'Enable','off');
else
    set(handles.buttonplay,'String','Play');
    set(handles.buttonback,'Enable','on');
    set(handles.buttonforward,'Enable','on');
    set(handles.saveimage,'Enable','on');
    set(handles.savemovie,'Enable','on');
    set(handles.addmovie,'Enable','on');
end

flag = strcmp(get(handles.buttonplay,'String'),'Pause');
nframes = size(handles.overlayc.data,1);

while flag && handles.n < nframes;
    tic
    pause(0.001);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.frametext,'String',sprintf('%.4d',handles.n));
    % Add movie frame
    if ~isempty(handles.vidobj)
        img = read(handles.vidobj,handles.fexobj.time.FrameNumber(handles.n));
        imshow(img,'parent',handles.vidaxis);
    end 
    flag = strcmp(get(handles.buttonplay,'String'),'Pause');
    % find next frame
    if handles.current_time ~= get(handles.timeslider,'Value');
        handles.current_time = get(handles.timeslider,'Value');
    end
    handles.current_time = handles.current_time + toc; 
    handles.n =  dsearchn(handles.tn,handles.current_time);
    set(handles.timeslider,'Value',handles.tn(handles.n));
    set(handles.cursor,'XData',repmat(handles.current_time,[10,1]));
    % handles.n = handles.n + 1;
end

set(handles.buttonplay,'String','Play');
set(handles.buttonback,'Enable','on');
set(handles.buttonforward,'Enable','on');
set(handles.saveimage,'Enable','on');
set(handles.savemovie,'Enable','on');
set(handles.addmovie,'Enable','on');


% Return to the beginning of the video
if handles.n == nframes;
    handles.n = 1;
    handles.current_time = handles.tn(handles.n);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.frametext,'String',sprintf('%.4d',handles.n));
    set(handles.timeslider,'Value',get(handles.timeslider,'Min'));
    % Add movie frame
    if ~isempty(handles.vidobj)
        img = read(handles.vidobj,1);
        imshow(img,'parent',handles.vidaxis);
    end 
end

guidata(hObject, handles);

function buttonforward_Callback(hObject, eventdata, handles)
%
% BUTTONFORWAWD_CALLBACK - Advance 1 frame.

if handles.n + 1 <= size(handles.overlayc.data,1)
    handles.n = handles.n + 1;
    handles.overlayc.show(handles.n);
    handles.current_time = handles.tn(handles.n);
    set(handles.cursor,'XData',repmat(handles.current_time,[10,1]));
    set(handles.timeslider,'Value',handles.tn(handles.n));
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.frametext,'String',sprintf('%.4d',handles.n));
    % Add movie frame
    if ~isempty(handles.vidobj)
        img = read(handles.vidobj,handles.fexobj.time.FrameNumber(handles.n));
        imshow(img,'parent',handles.vidaxis);
    end 
end
guidata(hObject, handles);


% *************************************************************************
% **************** SMOOTHING PROPERTIES ***********************************
% *************************************************************************

function kernelmenu_Callback(hObject,eventdata,handles)
%
% KERNELMENU_CALLBACK - Change smoothing kernel & test whether it is legal.

% Gather all values
list = get(handles.kernelmenu,'String');
k = lower(list{get(handles.kernelmenu,'Value')});
param = str2double(get(handles.parambox,'String'));
ksize = str2double(get(handles.sizebox,'String'));

% Check size and reset
if ksize <= 1 || isempty(ksize) || isnan(ksize)
   ksize = 1;
   set(handles.sizebox,'String','1.00');
end

% Set up the kenrel & check parameters
if strcmp(k,'none')
    set(handles.kernelmenu,'Value',1);
    set([handles.text3,handles.parambox],'Visible','off');
elseif ismember(k,{'gaussian','log'});
    set(handles.sizebox,'Enable','on');
    set([handles.text3,handles.parambox],'Visible','on');
    if isempty(param) || isnan(param) || param <=0
        param = 2.5;
        set(handles.parambox,'String','2.50');
    end
elseif strcmp(k,'laplacian');
    set(handles.sizebox,'Enable','off');
    set([handles.text3,handles.parambox],'Visible','on');
    if isempty(param) || param < 0 || param > 1 || isnan(param)
        param = 0.5;
        set(handles.parambox,'String','0.5');
    end
else
% average and disk methods
    set(handles.sizebox,'Enable','on');
end

handles.overlayc.update('smoothing',struct('kernel',k,'size',ksize,'param',param));
guidata(hObject, handles);


% *************************************************************************
% **************** COLOR PROPERTIES ***************************************
% *************************************************************************

function boundsl_Callback(hObject, eventdata, handles)
% 
% BOUNDS - set lower and upper bounds.

% Safety checks:
% - bl < bu
% - ~isempty(bl) && ~isempty(bu)

bl = str2double(get(handles.boundsl,'String'));
bu = str2double(get(handles.boundsu,'String'));
axes(handles.figaxis);
handles.overlayc.update('bounds',[bl,bu]);
set(handles.sliderboundsl,'Value',bl);
set(handles.sliderboundsu,'Value',bu);
guidata(hObject, handles);


function sliderboundsl_Callback(hObject, eventdata, handles)
%
% SLIDERBOUNDSL_CALLBACK - Update lower bound

% Safety checks:
% - bl < bu

bl = get(handles.sliderboundsl,'Value');
bu = get(handles.sliderboundsu,'Value');
axes(handles.figaxis);
handles.overlayc.update('bounds',[bl,bu]);
% Update UI
set(handles.boundsl,'String',sprint('%.2f',bl));
set(handles.boundsu,'String',sprint('%.2f',bu));
guidata(hObject, handles);

% --------------------------------------------------------------------
function c1_Callback(hObject, eventdata, handles)
%
% C1_CALLBACK - Update colormap.

% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(handles.colormapprop,'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');
set(gcbo,'Checked','on');
handles.overlayc.update('colmap',lower(label));
guidata(hObject, handles);


function slideroverlay_Callback(hObject, eventdata, handles)
% 
% SLIDEROVERLAY_CALLBACK - Update transparencies and brightness.

vals = [get(handles.slideroverlay,'Value'),...
        get(handles.sliderfibers,'Value'),...
        get(handles.sliderbrightness,'Value')];

handles.overlayc.update('optlayers',vals);
guidata(hObject, handles);


function colorbarbox_Callback(hObject, eventdata, handles)
%
% ADDCOLORBAR - insert a colorbar.
%
% This option is not currently implemented.

% *************************************************************************
% **************** PLOT OPTION ********************************************
% *************************************************************************

function timeslider_Callback(hObject, eventdata, handles)
% 
%
% TIMESLIDER_CALLBACK - update image displayed.

if strcmp(get(handles.buttonplay,'String'),'Play')
    handles.current_time = get(handles.timeslider,'Value');
    set(handles.cursor,'XData',repmat(handles.current_time,[10,1]));
    handles.n =  dsearchn(handles.tn,handles.current_time);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.frametext,'String',sprintf('%.4d',handles.n));
    % Add movie frame
    if ~isempty(handles.vidobj)
        img = read(handles.vidobj,handles.fexobj.time.FrameNumber(handles.n));
        imshow(img,'parent',handles.vidaxis);
    end 
end
guidata(hObject, handles);


% *************************************************************************
% **************** MENU ITEMS *********************************************
% *************************************************************************

function menuhelp_Callback(hObject, eventdata, handles)
% 
% MENUHELP_CALLBACK

doc fexw_overlayui

function menuselect_Callback(hObject, eventdata, handles)
%
% MENUSELECT_CALLBACK - select features
%
%
% See also FEW_SELECTUI.

% Focus on figure axis
axes(handles.figaxis);
% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(get(gcbo,'Parent'),'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');

if strcmpi(label,'Select AUs ...')
% this sets up the selection ui -- preselect used AUs.
    vars = handles.overlayc.data.Properties.VarNames;
    S = [];
    for i = 1:length(vars)
        S = cat(2,S,str2double(vars{i}(3:end)));
    end
    newvars = fexw_selectui(S);
    if isempty(newvars)
    % In case FEXW_SELECTUI was aborted.
        return
    end
    handles.overlayc.select(newvars);
    % Update plots
    if length(newvars) <= 3
        plotpanelmaster(handles,newvars);
    else
        plotpanelmaster(handles);
    end
    axes(handles.figaxis);
else
% Direct selection of features.
    set(gcbo,'Checked','on');
    handles.overlayc.select(lower(label));
    % Update plot with Emotion output
    if strcmpi(label,'aus')
        plotpanelmaster(handles);
    else
        plotpanelmaster(handles,lower(label));
    end
    axes(handles.figaxis);
end

% Update left and right side
if strcmpi(label,'contempt')
    handles.overlayc.update('side','right');
    set(get(handles.menuside,'Children'),'Checked','off');
    set(handles.sider,'Checked','on');
else
    handles.overlayc.update('side','both');
    set(get(handles.menuside,'Children'),'Checked','off');
    set(handles.sideb,'Checked','on');
end

set(handles.boundsl,'String',sprintf('%.2f',handles.overlayc.info.bounds(1)));
set(handles.boundsu,'String',sprintf('%.2f',handles.overlayc.info.bounds(2)));
guidata(hObject, handles);


function menutemplate_Callback(hObject, eventdata, handles)
%
% MENUTEMPLATE_CALLBACK - updates template.

% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(get(gcbo,'Parent'),'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');
set(gcbo,'Checked','on');
% Update template
if strcmpi(label(1),'t')
    label = label(end);
end
axes(handles.figaxis);
handles.overlayc.update('template',lower(label));
guidata(hObject, handles);


function menucombine_Callback(hObject, eventdata, handles)
% 
% MENUCOMBINE_CALLBACK - determines how to combine overlapping features.

% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(get(gcbo,'Parent'),'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');
set(gcbo,'Checked','on');
% Update template
handles.overlayc.update('combine',lower(label));
guidata(hObject, handles);


function menuside_Callback(hObject, eventdata, handles)
% 
% MENUSIDE_CALLBACK - determines the side of the image.

% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(get(gcbo,'Parent'),'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');
set(gcbo,'Checked','on');
% Update template
handles.overlayc.update('side',lower(label));
guidata(hObject, handles);


function menubackground_Callback(hObject, eventdata, handles)
%
% MENUBACKGROUND_CALLBACK - Add a background

s = get(handles.menubackground,'Checked');
if strcmp(s,'off')
    set(handles.menubackground,'Checked','on');
    handles.overlayc.update('background',true);
else
    set(handles.menubackground,'Checked','off');
    handles.overlayc.update('background',false);
end

% --------------------------------------------------------------------
% --------------------------------------------------------------------
function interpolatenans_Callback(hObject, eventdata, handles)
% 
% INTERPOLATENANS_CALLBACK - 

function saveimage_Callback(hObject, eventdata, handles)
% 
% SAVEIMAGE_CALLBACKE - Save the current image.
%
% Saving can only be done when the video is not playing.

imsave(handles.figaxis);
% h = fexw_saveui('image');
% handles.overlayc.saveo('format',['-d',h.format],'dpi',h.quality,'name',h.name);


function savemovie_Callback(hObject, eventdata, handles)
% 
% SAVEMOVIE_CALLBACK - Save a video
%
% Saving can only be done when the video is not playing.

h = fexw_saveui('movie');
handles.overlayc.makemovie('cut',h.extent,'quality',h.quality,'name',h.name);


function open_fexobject_Callback(hObject, eventdata, handles)
% 
% OPEN_FEXOBJECT_CALLBACK - 


function openfile_Callback(hObject, eventdata, handles)
%
% OPENFILE_CALLABACK -


function addcolorbar_Callback(hObject, eventdata, handles)
% 
% ADDCOLORBAR_CALLBACK - Add colorbar
%
% CURRENTLY NOT IMPLEMENTED.


% --------------------------------------------------------------------
% --------------------------------------------------------------------

% ********************************* CLOSE REQUESTS ************************

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% 
% FIGURE1_CLOSEREQUESTFCN - request closing.

if strcmp(get(handles.buttonplay,'String'),'Pause')
    set(handles.buttonplay,'String','Play');
    handles.doclose = true;
    handles.output = hObject;
    guidata(hObject, handles);
else
    delete(handles.figure1);
end


function menuquit_Callback(hObject, eventdata, handles)
%
% MENUQUIT_CALLBACK - request closing.

if strcmp(get(handles.buttonplay,'String'),'Pause')
    set(handles.buttonplay,'String','Play');
    handles.doclose = true;
    handles.output = hObject;
    guidata(hObject, handles);
else
    figure1_CloseRequestFcn(hObject,[],handles);
end


function varargout = fexw_overlayui_OutputFcn(hObject, eventdata, handles) 
%
% FEXW_OEVRLAYUI_OUTPUTFCN - Get output

varargout{1} = handles.output;


function slider7_CreateFcn(hObject,eventdata,handles)
%
% SLIDER7_CREATEFCN - I don't know what's using this ... but some object is
% FIX THIS.


% --------------------------------------------------------------------
function addmovie_Callback(hObject,eventdata, handles)
% 
% ADDMOVIE_CALLBACK - stream the movie alongside the overlay image.
%
% CALLBACK disabled during playback. 

% Check whether the movie exists
if ~exist(handles.fexobj.video,'file')
    warning('No movie was provided ... ignoring command.');
    return
end

% handle checked - unchecked version
if strcmp(get(handles.addmovie,'Checked'),'on')
    handles.vidobj = [];
    set(handles.addmovie,'Checked','off');
    imshow('movie_placeholder.jpg','parent',handles.vidaxis);
else
% Check whether there is a compression friendly version of the movie
    [~,newname] = fileparts(handles.fexobj.video);
    newname = sprintf('fexwstreamermedia/c%s.avi',newname);
    if ~exist(newname,'file')
        handles.fexobj.videoutil(true);
    end
    handles.vidobj = VideoReader(newname);
    frame_n = handles.fexobj.time.FrameNumber(handles.n);
    img = read(handles.vidobj,frame_n);
    imshow(img,'parent',handles.vidaxis);
    set(handles.addmovie,'Checked','on')
end
guidata(hObject, handles);






