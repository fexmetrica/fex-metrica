function varargout = fexw_saveui(varargin)
%
% FEXW_SAVEUI - Helper function to save a image or movie overlay. 
%
% SYNYAX:
%
% SaveArgs = FEXW_SAVEUI()
% SaveArgs = FEXW_SAVEUI('FileType')
%
% FEXW_SAVEUI is used by FEXW_OVERLAYUI. FEXW_SAVEUI return a structure
% SAVEARGS with information on how to save a file. SAVEARGS is used by the
% methods SAVEO and MAKEMOVIE from FEXWOVERLAY.
%
% SAVEARGS specifies:
%
% TYPE - Type to be saved (IMAGE, or MOVIE);
% NAME - NAME of the file to be saved;
% FORMAT - File format (jpg,pdf, png for IMAGE. avi,mp4, mov for MOVIE);
% QUALITY - a scalar between 1 and 100 for MOVIE, and DPI for IMAGE;
% EXTENT - Frames to be saved -- This argument is ignored for IMAGE;
% DFPS - Displayed frame rate in the video -- Ignored for IMAGE.
%
% See also FEXW_OVERLAYUI, FEXWOVERLAY.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 07-Jan-2014.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexw_saveui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexw_saveui_OutputFcn, ...
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


function fexw_saveui_OpeningFcn(hObject,eventdata,handles, varargin)
% 
% OPENINGFCN - opening function
%
% Arguments:
%
% VARARGIN - a string set to 'movie' or 'image' (default 'image').

set(handles.figure1,'Name','Fex View Overlay: Save');

% Set up default arguments
name = sprintf('fxwo_%s',datestr(now,'dd_mm_yy_HH_MM_SS'));
set(handles.namebox,'String',name);
handles.SaveArgs = struct('type','image',...
                          'name',name,...
                          'format','jpg',...
                          'quality',300,...
                          'extent',[1,Inf],...
                          'dfps',15);
% Argument handling
if isempty(varargin)
    varargin{1} = 'movie';
end
% Test whether you need a movie saving process or a video saving process
if strcmpi('movie',varargin{1});
    handles.SaveArgs.type = 'movie';
    handles.SaveArgs.format = 'avi';
    handles.SaveArgs.quality = 75;
    % Update Gui
    set(handles.savetype,'Value',2);
    set(handles.formatmenu,'String',{'avi';'mp4';'mov'});
    set(handles.qualityval,'String','75');
    set(handles.radiobuttonall,'String','All');
    set(handles.edit4,'String', 'Inf'); 
    set([handles.textdfps,handles.menudfps],'Visible','on');
    set(handles.uibuttongroup,'Visible','on');
else
    set(handles.radiobuttonall,'String','All');
    set(handles.edit4,'String', 'Inf'); 
    set(handles.uibuttongroup,'Visible','off');
    set([handles.textdfps,handles.menudfps],'Visible','off');
end


% Set UI properties
handles.output = handles.SaveArgs;
guidata(hObject, handles);
uiwait(handles.figure1);


function varargout = fexw_saveui_OutputFcn(hObject, eventdata, handles) 
% 
% OUTPUTFCN - Return OUTPUT

% Update Output Arguments:
varargout{1} = handles.output;
delete(handles.figure1);

function cancelbutton_Callback(hObject, eventdata, handles)
% 
% CANCELBUTTON - return empty SAVEARGS

handles.SaveArgs = [];
handles.output = handles.SaveArgs;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

function savebutton_Callback(hObject, eventdata, handles)
%
% SAVEBUTTON - Update SAVE button, and exit

name = get(handles.namebox,'String');
if isempty(name)
    name = sprintf('fxwo_%s',datestr(now,'dd_mm_yy_HH_MM_SS'));
end
handles.SaveArgs.name = name;
temp = get(handles.formatmenu,'String');
handles.SaveArgs.format  = temp{get(handles.formatmenu,'Value')};
handles.SaveArgs.quality = str2double(get(handles.qualityval,'String'));
handles.SaveArgs.extent = [str2double(get(handles.firstframe,'String')),str2double(get(handles.edit4,'String'))];
temp = get(handles.menudfps,'String');
handles.SaveArgs.dfps = str2double(temp{get(handles.menudfps,'Value')});

handles.output = handles.SaveArgs;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)

function savetype_Callback(hObject, eventdata, handles)
%
% SAVETYPE - Switch between IMAGE and MOVIE UI.

s = get(handles.savetype,'String');
s = s{get(handles.savetype,'Value')};

if strcmpi(s,'image')
    handles.SaveArgs.quality = 300;
    handles.SaveArgs.extent(2) = 1;
    handles.SaveArgs.format = 'jpg';
    % Update Gui
    set(handles.formatmenu,'String',{'jpeg';'pdf';'png'},'Value',1);
    set(handles.qualityval,'String','300')
    set(handles.radiobuttonall,'String','Current Frame');
    set(handles.edit4,'String', '1'); 
    set([handles.textdfps,handles.menudfps],'Visible','off');
    set(handles.uibuttongroup,'Visible','off');
else
    handles.SaveArgs.quality = 75;
    handles.SaveArgs.extent(2) = Inf;
    handles.SaveArgs.format = 'avi';
    % Update Gui
    set(handles.formatmenu,'String',{'avi';'mp4';'mov'},'Value',1);
    set(handles.qualityval,'String','75')
    set(handles.radiobuttonall,'String','All');
    set(handles.edit4,'String', 'Inf'); 
    set([handles.textdfps,handles.menudfps],'Visible','on');
    set(handles.uibuttongroup,'Visible','on');
    set(get(handles.uibuttongroup,'Children'),'Visible','on');
end

handles.SaveArgs.type = lower(s);
handles.output = handles.SaveArgs;
guidata(hObject, handles);

function uibuttongroup_SelectionChangedFcn(hObject, eventdata, handles)
%
% SELECTIONCHANGEDFCN

if get(handles.radiobuttonall,'Value') == 1
    set(handles.firstframe,'Enable','off');
    set(handles.edit4,'Enable','off');
else
    set(handles.firstframe,'Enable','on');
    set(handles.edit4,'Enable','on');
end

function firstframe_Callback(hObject, eventdata, handles)
% 
% FIRSTFRAME CALLBACK - check consistency
f = str2double(get(handles.firstframe,'String'));
l = str2double(get(handles.edit4,'String'));

if f <=0
    f = 1;
    set(handles.firstframe,'String','1');
end

if f > l
   l = f;
   set(handles.edit4,'String',sprintf('%d',f));
end
handles.SaveArgs.extent = [f,l];

% Update
handles.output = handles.SaveArgs;
guidata(hObject, handles);


function qualityval_Callback(hObject, eventdata, handles)
% 
% QUALITYVAL_CALLBACK - - check consistency

s = get(handles.savetype,'Value');
f = str2double(get(handles.qualityval,'String'));

if f < 10
% Common lower bound
    f = 10;
    set(handles.qualityval,'String','10');
elseif s == 1 && f > 450
    f = 450;
    set(handles.qualityval,'String','450');
elseif s == 2 && f > 100
    f = 100;
    set(handles.qualityval,'String','100');
end

handles.SaveArgs.extent = f;
handles.output = handles.SaveArgs;
guidata(hObject, handles);


function figure1_CloseRequestFcn(hObject, eventdata, handles)
% 
% CLOSEREQUESTFCN - Close the function

% Send Close request
if isequal(get(handles.figure1,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end
