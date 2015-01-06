function varargout = fexw_overlayui(varargin)
%
% FEXW_OVERLAYUI - UI for overlay image and movie generation.
%
% SYNTAX:
%
% h = FEXW_OVERLAYUI(DATA)
%
% The input DATA is a FEXC object.
%
% There are six main panels in FEXW_OVERLAYUI:
%
% IMAGE PANEL - show the image;
% CONTROL PANEL - moves from frame to frame;
% PLOT PANEL - shows a timeseries of facial expression;
% TEMPLATE PANEL - decide which image to be used as background;
% SMOOTHING PANEL - allows to smooth the overlay;
% COLOR PANEL - regulate transparencies and color properties.
%
%
% See also FEXC, FEXWOVERLAY.
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
% Set TimeSlider
set(handles.timeslider,'Min',0,'Max',handles.tn(end),'Value',0);
set(handles.timeslider,'SliderStep',[1/length(handles.tn),0.1]);

% Add plot for positive and negative
Y1 = varargin{1}.sentiments.Positive;
Y2 = varargin{1}.sentiments.Negative;
axes(handles.plotaxis);
hold on
title('Positive and Negative Sentiments','fontsize',14,'Color','w');
area(varargin{1}.sentiments.TimeStamps,Y1,'FaceColor',[1,1,1],'LineWidth',2,'EdgeColor',[1,1,1]);
alpha(0.4);
area(varargin{1}.sentiments.TimeStamps,Y2,'FaceColor',[1,0,0],'LineWidth',2,'EdgeColor',[1,0,0]);
alpha(0.4);
x = get(handles.plotaxis,'XTick');
set(gca,'Color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1],'XTick',...
    x,'XTickLabel',fex_strtime(x,'short'),'LineWidth',2);
ylim([0,max(max(Y1),max(Y2))]);
xlim([handles.tn(1),handles.tn(end)]);
legend({'Pos.','Neg.'},'TextColor',[1,1,1],'Box','off');
hold off
axes(handles.figaxis);

end

% Choose default command line output for fexw_overlayui
handles.doclose = false;
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexw_overlayui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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
    set(handles.timeslider,'Value',handles.tn(handles.n));
    set(handles.timetext,'String',handles.t{handles.n});
end
guidata(hObject, handles);

function buttonplay_Callback(hObject, eventdata, handles)
%
% BUTTONPLAY_CALLBACK - plays/pause the movie.

if strcmp(get(handles.buttonplay,'String'),'Play')
    set(handles.buttonplay,'String','Pause');
    set(handles.buttonback,'Enable','off');
    set(handles.buttonforward,'Enable','off');
else
    set(handles.buttonplay,'String','Play');
    set(handles.buttonback,'Enable','on');
    set(handles.buttonforward,'Enable','on');
end

flag = strcmp(get(handles.buttonplay,'String'),'Pause');
nframes = size(handles.overlayc.data,1);

while flag && handles.n < nframes;
    tic
    pause(0.001);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
    flag = strcmp(get(handles.buttonplay,'String'),'Pause');
    % find next frame
    if handles.current_time ~= get(handles.timeslider,'Value');
        handles.current_time = get(handles.timeslider,'Value');
    end
    handles.current_time = handles.current_time + toc; 
    handles.n =  dsearchn(handles.tn,handles.current_time);
    set(handles.timeslider,'Value',handles.tn(handles.n));
    % handles.n = handles.n + 1;
end

set(handles.buttonplay,'String','Play');

% Return to the beginning of the video
if handles.n == nframes;
    handles.n = 1;
    handles.current_time = handles.tn(handles.n);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
    set(handles.timeslider,'Value',get(handles.timeslider,'Min'));
end

guidata(hObject, handles);

function buttonforward_Callback(hObject, eventdata, handles)
%
% BUTTONFORWAWD_CALLBACK - Advance 1 frame.

if handles.n + 1 <= size(handles.overlayc.data,1)
    handles.n = handles.n + 1;
    handles.overlayc.show(handles.n);
    handles.current_time = handles.tn(handles.n);
    set(handles.timeslider,'Value',handles.tn(handles.n));
    set(handles.timetext,'String',handles.t{handles.n});
end
guidata(hObject, handles);




% **************** TEMPLATE PROPERTIES ************************************

function boundsl_Callback(hObject, eventdata, handles)
% 
% BOUNDS - set lower and upper bounds.

bl = str2double(get(handles.boundsl,'String'));
bu = str2double(get(handles.boundsu,'String'));
handles.overlayc.update('bounds',[bl,bu]);


% *************************************************************************
% **************** SMOOTHING PROPERTIES ***********************************
% *************************************************************************

function kernelmenu_Callback(hObject, eventdata, handles)
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


function colmapmenu_Callback(hObject, eventdata, handles)
%
% COLMAP - Update colormap.

list = get(handles.colmapmenu,'String');
k = lower(list{get(handles.colmapmenu,'Value')});
handles.overlayc.update('colmap',k);
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
    handles.n =  dsearchn(handles.tn,handles.current_time);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
end
guidata(hObject, handles);


% --------------------------------------------------------------------
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
handles.overlayc.update('template',lower(label));
guidata(hObject, handles);


% --------------------------------------------------------------------
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

% --------------------------------------------------------------------
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

% --------------------------------------------------------------------
function interpolatenans_Callback(hObject, eventdata, handles)
% 
% INTERPOLATENANS_CALLBACK - 


% --------------------------------------------------------------------
function saveimage_Callback(hObject, eventdata, handles)
% 
% SAVEIMAGE_CALLBACKE - 


% --------------------------------------------------------------------
function savemovie_Callback(hObject, eventdata, handles)
% 
% SAVEMOVIE_CALLBACK - 

% --------------------------------------------------------------------
function open_fexobject_Callback(hObject, eventdata, handles)
% 
% OPEN_FEXOBJECT_CALLBACK - 


% --------------------------------------------------------------------
function openfile_Callback(hObject, eventdata, handles)
%
% OPENFILE_CALLABACK -

% --------------------------------------------------------------------
function menuselect_Callback(hObject, eventdata, handles)
%
% MENUSELECT_CALLBACK - select features

% Gather the handles for the menue and the 
label = get(gcbo,'Label');
hand  =  get(get(gcbo,'Parent'),'Children');
% Uncheck all and re-chek selectde
set(hand,'Checked','off');
set(gcbo,'Checked','on');

% Update template
handles.overlayc.select(lower(label));
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

% --------------------------------------------------------------------
function menuhelp_Callback(hObject, eventdata, handles)
% 
% MENUHELP_CALLBACK

doc fexw_overlayui


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
