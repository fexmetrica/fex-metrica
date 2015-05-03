function varargout = fexchannelsg(varargin)
%
% FEXCHANNELSG - UI for selecting features to be included in the output file.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 24-Apr-2015.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexchannelsg_OpeningFcn, ...
                   'gui_OutputFcn',  @fexchannelsg_OutputFcn, ...
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


% --- Executes just before fexchannelsg is made visible.
function fexchannelsg_OpeningFcn(hObject, eventdata, handles, varargin)
% 
% OPENINGFCN - UI Initializer

set(handles.figure1,'Name','Select Channels');

handles.exporules = struct('emotions',1,'secondary',1,'sentiments',1,'dsentiments',1,...
              'actionunits',0,'structural',0,'timestamps',1,'design',0,...
              'include_nan',1,'save_extension','.csv','select_dir',pwd);

if ~isempty(varargin)
    if isa(varargin{1},'fexc')
        if isempty(varargin{1}(1).design);
            set(handles.select_design,'Enable','off');
        end
    end
end
    
handles.output = handles.exporules;
guidata(hObject, handles);
uiwait(handles.figure1);


% Close Request **********************************************************
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% CLOSEREQUEST - closes the ui.

if isequal(get(handles.figure1,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


% Select Output **********************************************************
function varargout = fexchannelsg_OutputFcn(hObject, eventdata, handles) 
%
% OUTPUTFCN - Select command line output.

varargout{1} = handles.exporules;
delete(handles.figure1);



% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, handles)
% 
% BUTTON_CANCEL - Close without outputing rules

handles.exporules = '';
handles.output = handles.exporules;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% --- Executes on button press in button_done.
function button_done_Callback(hObject, eventdata, handles)
% 
% BUTTON_DONE - EXIT THE UI

handles.output = handles.exporules;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% --- Executes during object creation, after setting all properties.
function select_extension_Callback(hObject, eventdata, handles)
% 
% SELECT EXTENSION - Extension for the file to be saved

ind  = get(handles.select_extension,'Value');
str  = get(handles.select_extension,'String');
handles.exporules.save_extension = str{ind};
handles.output = handles.exporules;
guidata(hObject, handles);

% --- Executes on button press in select_design.
function select_design_Callback(hObject, eventdata, handles)
%
% SELECT_DESIGN - Include Design

handles.exporules.design = get(handles.select_design,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);


% --- Executes on button press in select_time.
function select_time_Callback(hObject, eventdata, handles)
%
% SELECT_TIME - Include Time Stamps

handles.exporules.select_time = get(handles.select_time,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);


% --- Executes on button press in include_nans.
function include_nans_Callback(hObject, eventdata, handles)
%
% INCLUDE_NANS - Include nan in the data file

handles.exporules.include_nans = get(handles.include_nans,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);


% --- Executes on button press in select_au.
function select_au_Callback(hObject, eventdata, handles)
%
% SELECT_AU - Include Action Unit

handles.exporules.actionunits = get(handles.select_au,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);


% --- Executes on button press in select_emo.
function select_emo_Callback(hObject, eventdata, handles)
% 
% SELECT_EMO - Inclide Emotions

handles.exporules.emotions = get(handles.select_emo,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);

% --- Executes on button press in select_sentiments.
function select_sentiments_Callback(hObject, eventdata, handles)
%
% SELECT_SENTIMENTS - Include sentiments

handles.exporules.dsentiments = get(handles.select_sentiments,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);

% --- Executes on button press in select_structural.
function select_structural_Callback(hObject, eventdata, handles)
%
% SELECT_STRUCTURAL - Include structural

handles.exporules.structural = get(handles.select_structural,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);


% --- Executes on button press in secondary.
function secondary_Callback(hObject, eventdata, handles)
% 
% SECONDARY - Select secondary emotions

handles.exporules.secondary = get(handles.secondary,'Value');
handles.output = handles.exporules;
guidata(hObject, handles);
