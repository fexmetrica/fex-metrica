function varargout = streamernotesui(varargin)
%
% Usage:
%
% fexObj.viewer()
% Note = fexw_streamer(fexObj.clone())
%
% This function cannot be called independently, and it is part of the
% option implemented in fexw_streamerui.m.
%
% streamernotesui.m opens a window that allows the user to take notes on
% the video displayed in the viewer. This UI can be open from the
% menu toolbar, or using "Command+N" (or "Ctrl + N" on non-OSX system).
%
% Each annotation is returned by fexw_viewerui.m or it is added to the fexc
% object used to call the viewer: i.e. when the viewer is called with the
% syntax fexObj.viewer(). Annotations are K dimensional structure (where K
% is the number of notes). Each structure contains the following fields:
%
% "Start":   Starting time to which the note applies (a string). "End":
% Ending time to which the note applies (a string). "Anomaly": Boolean
% value, set to 1 when the note applies to an
%            anomaly.
% "Domain":  A string indicating the emotions to which each note
%            applies. This string can be set to "all," it can be empty, or
%            it can be a list, such as "anger:disgust:contempt."
% "Note":    String containing the actual note.
%
%  All options can be set from the "streamernoteui.m" interface. Note the
%  following: If the streamernoteui is hard closed, or if it is cancelled
%  using the "Cancel" button, no annotation is stored. Additionally, even
%  if the button "Submitt" is pressed, no annotation is stored if both the
%  anomaly box is unchecked AND if no annotation is entered.
%
%  The annotations can be submitted by pressing the "Submitt" button, or by
%  pressing "enter" on the keyboard.
%
%  If the fexc object presented in the viewer already contains annotation,
%  the new annotations are added to the existing ones.
%
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 12/12/14.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @streamernotesui_OpeningFcn, ...
                   'gui_OutputFcn',  @streamernotesui_OutputFcn, ...
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


% INITIALIZATION ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function streamernotesui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Initialization function from streamernotesui. Note that varargin is the
% entire set of handles from the calling gui.

set(handles.figure1,'Name','FxW Annotations');
if ~isempty(varargin)
    handles.masterUI = varargin{1};
    handles.time     = handles.masterUI.fexc.time.TimeStamps;
    handles.time     = handles.time  - handles.time(1);
    handles.step     = mode(diff(handles.time));
    handles.start    = handles.masterUI.current_time;
    handles.end      = handles.start + handles.step;
else
% This doesn't make any sense and is only used for testing.
    handles.step     = 1/15; 
    handles.masterUI = '';
    handles.time     = linspace(0,60,15*60)';
    handles.start    = 0;
    handles.end      = 0;
end

% set an handles for emotion names
handles.emonames = {'anger','contempt','disgust','joy','fear'...
                    'sadness','surprise','confusion','frustration'};
% Set string with time
set(handles.TimeStartValue,'String',convtime(handles.start));
set(handles.TimeEndValue,'String',convtime(handles.end));

% Update/Waiting thread set up
handles.output = hObject;
guidata(hObject, handles);
uiwait(handles.figure1);

% UTILITIES +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function str = convtime(tt)
%
% Get a string for the current time

str = fex_strtime(tt);
str = str{1};


function N = parsenote(handles)
%
% Parse the input and prepare the function output

N = struct('Start','','End','','Anomaly',0,'Domain','','Note','');
str = get(handles.NoteBoxe,'String');
if strcmpi(str,'Insert Note Here ... ')
    str = '';
end
    
if isempty(str) && get(handles.AnomalyCheck,'Value') == 0
    N = [];
else
    N.Start   = get(handles.TimeStartValue,'String');
    N.End     = get(handles.TimeEndValue,'String');
    N.Anomaly = get(handles.AnomalyCheck,'Value');
    N.Domain  = parsedomain(handles);
    N.Note    = str;
end

function str = parsedomain(handles)
%
% Parse the emotion to which the note apply.

if get(handles.SelectAll,'Value') == 1;
    str = 'all';
else
    str = '';
    for i = handles.emonames
        if get(handles.(i{1}),'Value') == 1;
            str = sprintf('%s:%s',str,lower(i{1}));
        end
    end
    str = str(2:end);
end


% START ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ENTER/EXIT

function CancelButton_Callback(hObject, eventdata, handles)
%
% Cancel annotation. This will return an empty note, and is the same as an
% hard close call. 

set(handles.NoteBoxe,'String','');
uiresume(handles.figure1);


function SubmittButton_Callback(hObject, eventdata, handles)
%
% Submitt annotation: This is the only method that allow to save the
% annotation.

uiresume(handles.figure1);


function figure1_KeyPressFcn(hObject, eventdata, handles)
%
% Accelerator for exiting the UI. Note, the cursor cannot be within the
% Note Box.

if strcmp(eventdata.Key,'return')
    uiresume(handles.figure1);
end


function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% Execute close reques -- this doesn't return any output

if isequal(get(hObject,'waitstatus'),'waiting')
    set(handles.NoteBoxe,'String','');
    uiresume(hObject);
else
    delete(hObject);
end


function varargout = streamernotesui_OutputFcn(hObject, eventdata, handles) 
%
% Set output function

varargout{1} = parsenote(handles);
delete(hObject);


% END ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ENTER/EXIT


% START +++++++++++++++++++++++++++++++++++++++++++++++++++++++ FORMAT TIME

function TimeStartValue_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TimeStartValue_Callback(hObject, eventdata, handles)
%
% Need to implement save checks

function TimeEndValue_CreateFcn(hObject, eventdata, handles)
%
%
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TimeEndValue_Callback(hObject, eventdata, handles)
%
% Need to implement save checks

% END +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ FORMAT TIME


% START ++++++++++++++++++++++++++++++++++++++++++++ CONTROLL OF TIMESTAMPS

function InreaseSt_Callback(hObject, eventdata, handles)
%
% Step forward for Start Time handle.

t1 = min(fex_strtime(get(handles.TimeStartValue,'String')) + handles.step,handles.time(end));
t2 = fex_strtime(get(handles.TimeEndValue,'String'));

% Make sure that t2 is larger
if t1 > t2 
    t2 = min(t1 + handles.step,handles.time(end));
end

%  Update Time
set(handles.TimeStartValue,'String',convtime(t1));
set(handles.TimeEndValue,'String',convtime(t2));


function DecreaseST_Callback(hObject, eventdata, handles)
%
% Step backward for Start Time handle.

t1 = max(fex_strtime(get(handles.TimeStartValue,'String')) - handles.step,0);
set(handles.TimeStartValue,'String',convtime(t1));

function IncreaseET_Callback(hObject, eventdata, handles)
%
% Step forward for End Time handle.

t2 = min(fex_strtime(get(handles.TimeEndValue,'String')) + handles.step,handles.time(end));
set(handles.TimeEndValue,'String',convtime(t2));

function DecreaseET_Callback(hObject, eventdata, handles)
%
% Step forward for Start Time handle.

t1 = fex_strtime(get(handles.TimeStartValue,'String'));
t2 = max(fex_strtime(get(handles.TimeEndValue,'String')) - handles.step,0);


% Make sure that t2 is larger
if t1 > t2 
    t1 = max(t2 - handles.step,0);
end

%  Reset Time
set(handles.TimeStartValue,'String',convtime(t1));
set(handles.TimeEndValue,'String',convtime(t2));

% END ++++++++++++++++++++++++++++++++++++++++++++++ CONTROLL OF TIMESTAMPS


% START +++++++++++++++++++++++++++++++++++++++++++++++++++++++ APPLICATION 

function SelectAll_Callback(hObject, eventdata, handles)
%
% Select & unselect all emotions.

if get(handles.SelectAll,'Value') == 1
    for i = handles.emonames
        set(handles.(i{1}),'Value',1);
    end
end

function SelectEmotions_Callback(hObject, eventdata, handles)
%
% Deselect "All Selected" if not all emotions are selected.

idx = [];
for i = handles.emonames
    idx = cat(2,idx,get(handles.(i{1}),'Value'));
end

if sum(idx) == length(handles.emonames);
    set(handles.SelectAll,'Value',1);
else
    set(handles.SelectAll,'Value',0);
end


% END +++++++++++++++++++++++++++++++++++++++++++++++++++++++++ APPLICATION 

% START ++++++++++++++++++++++++++++++++++++++++++++++++++++++ BOX CONTROLL


function NoteBoxe_CreateFcn(hObject, eventdata, handles)
%
% Create Notebox.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NoteBoxe_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to NoteBoxe (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% 
% if strcmp(eventdata.Key,'return')
%     uiresume(handles.figure1);
% end


% END ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ BOX CONTROLL
