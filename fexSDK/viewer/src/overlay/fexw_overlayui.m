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
if ~isempty(varargin{1}.name)
    str = get(handles.figure1,'Name');
    str = sprintf('%s: %s',str,varargin{1}.name);
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

% Add plot for positive and negative
Y1 = varargin{1}.sentiments.Combined;
Y2 = Y1; Y1(Y1 < 0) = 0; Y2(Y2 > 0) = 0;
axes(handles.plotaxis);
title('Positive and Negative Sentiments','fontsize',14,'Color','w');
area(handles.plotaxis,varargin{1}.sentiments.TimeStamps,Y1,'FaceColor',[1,0,0],'LineWidth',2,'EdgeColor',[1,0,0]);
alpha(0.4);
area(handles.plotaxis,varargin{1}.sentiments.TimeStamps,Y2,'FaceColor',[0,0,1],'LineWidth',2,'EdgeColor',[0,0,1]);
alpha(0.4);
x = get(handles.plotaxis,'XTick');
set(gca,'Color',[0,0,0],'XColor',[1,1,1],'YColor',[1,1,1],'XTick',...
    x,'XTickLabel',fex_strtime(x,'short'),'LineWidth',2);
ylim([-1,1]);
hold off
axes(handles.figaxis);

end

% Make smoothing parameter invisible
set([handles.text3,handles.parambox],'Visible','off');

% Choose default command line output for fexw_overlayui
handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes fexw_overlayui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexw_overlayui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% *************************************************************************
% **************** VIDEO CONTROLLERS **************************************
% *************************************************************************

function buttonback_Callback(hObject, eventdata, handles)
% 
% BUTTONBACK_CALLBACK - Go Back one frame.

if handles.n - 1 >= 1
    handles.n = handles.n - 1;
    handles.overlayc.show(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
end
guidata(hObject, handles);

function buttonplay_Callback(hObject, eventdata, handles)
%
% BUTTONPLAY_CALLBACK - plays/pause the movie.

if strcmp(get(handles.buttonplay,'String'),'Play')
    set(handles.buttonplay,'String','Pause');
else
    set(handles.buttonplay,'String','Play');
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
    handles.current_time = handles.current_time + toc; 
    handles.n =  dsearchn(handles.tn,handles.current_time);
    % handles.n = handles.n + 1;
end

set(handles.buttonplay,'String','Play');

% Return to the beginning of the video
if handles.n == nframes;
    handles.n = 1;
    handles.current_time = handles.tn(handles.n);
    handles.overlayc.step(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
end

guidata(hObject, handles);

function buttonforward_Callback(hObject, eventdata, handles)
%
% BUTTONFORWAWD_CALLBACK - Advance 1 frame.

if handles.n + 1 <= size(handles.overlayc.data,1)
    handles.n = handles.n + 1;
    handles.overlayc.show(handles.n);
    set(handles.timetext,'String',handles.t{handles.n});
end
guidata(hObject, handles);

% **************** TEMPLATE PROPERTIES ************************************

% --- Executes on selection change in templatemenu.
function templatemenu_Callback(hObject, eventdata, handles)
%
% TEMPLATEMENU_CALLBACK - Change the template on which the imeage is
% displayed.

handles.overlayc.update('template',get(handles.templatemenu,'Value'));
guidata(hObject, handles);


function boundsl_Callback(hObject, eventdata, handles)
% 
% BOUNDSL - set lower and upper bounds

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


% --------------------------------------------------------------------
function menutemplate_Callback(hObject, eventdata, handles)
% hObject    handle to menutemplate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function interpolatenans_Callback(hObject, eventdata, handles)
% hObject    handle to interpolatenans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function open_fexobject_Callback(hObject, eventdata, handles)
% hObject    handle to open_fexobject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openfile_Callback(hObject, eventdata, handles)
% hObject    handle to openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuquit_Callback(hObject, eventdata, handles)
% hObject    handle to menuquit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuselect_Callback(hObject, eventdata, handles)
% hObject    handle to menuselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
