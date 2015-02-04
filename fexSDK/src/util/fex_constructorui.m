function varargout = fex_constructorui(varargin)
%
% FEX_CONSTRUCTORUI - Helper UI for generating FEXC objects.
%
% [...] [...]
% 
%
% See also FEXGENC, FEXC.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fex_constructorui_OpeningFcn, ...
                   'gui_OutputFcn',  @fex_constructorui_OutputFcn, ...
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


% --------------------------------------------------------------------
%  Initialize UI
% --------------------------------------------------------------------
function fex_constructorui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% OPENINGFCN - initialize the user interface.

% Create an empty figure generation object.
set(handles.figure1,'Name','Fex-Metrica Object Constructor');
handles.const = fexgenc();
update_text(handles);
% Output and update
handles.output = handles.const;
guidata(hObject, handles);
uiwait(handles.figure1);


function varargout = fex_constructorui_OutputFcn(hObject, eventdata, handles) 
%
% OUTPUTFCN - select output argument.

varargout{1} = handles.output;
delete(handles.figure1);


% --------------------------------------------------------------------
%  Buttons controller
% --------------------------------------------------------------------
function selectbutton_Callback(hObject,eventdata, handles)
%
% SELECTBUTTON - select files

k = get(handles.addfilecontroller,'String');
name = k{get(handles.addfilecontroller,'Value')};

h = fexwsearchg();
switch name
    case 'Movies'
        prop = 'movies';
    case 'FACET Data'
        prop = 'files';
    case 'Time Stamps'
        prop = 'timeinfo';
    case 'Design'
        prop = 'design';
end

if isempty(prop)
    return
end
handles.const.set(prop,h);

% Set active / inactive button export
if isempty(handles.const.movies) && isempty(handles.const.files)
    set(handles.exportbutton,'Enable','off');
    set(handles.facetbutton,'Enable','off');
elseif isempty(handles.const.movies) && ~isempty(handles.const.files)
    set(handles.exportbutton,'Enable','on');
    set(handles.facetbutton,'Enable','off');
elseif ~isempty(handles.const.movies) && isempty(handles.const.files)
    set(handles.exportbutton,'Enable','off');
    set(handles.facetbutton,'Enable','on');
else
    set(handles.exportbutton,'Enable','on');
    set(handles.facetbutton,'Enable','on');   
end

% Update checklist
set(handles.movies_cb,'Value',~isempty(handles.const.movies));
set(handles.expression_cb,'Value',~isempty(handles.const.files));
set(handles.designcb,'Value',~isempty(handles.const.design));

% Move to new item:
nv = get(handles.addfilecontroller,'Value') + 1;
if nv <= length(k)
    set(handles.addfilecontroller,'Value',nv);
    update_text(handles);
end

% Update
handles.output = handles.const;
guidata(hObject, handles);


function cancelbutton_Callback(hObject, eventdata, handles)
% 
% CANCELBUTTON -- exit constructor without data.

delete(handles.const);
handles.const = [];
handles.output = handles.const;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)

function facetbutton_Callback(hObject, eventdata, handles)
%
% FACETBUTTON - run facet SDK. 

% Test whether the executable exist
try 
    tests = importdata('fextest_report.mat');
catch
    tests.exec = 0;
end

if tests.exec == 0
    warning('Facet executable was not installed.');
    str = sprintf('\nSorry, you don''t appear to have installed the executable.');
    set(handles.helpbox,'String',str);
else
    str = sprintf('\nProcessing %d videos .... ',length(handles.const.movies));
    set(handles.helpbox,'String',str);
    pause(0.001)
    folder_name = uigetdir(pwd,'Select FACET Output Directory');
    if isempty(folder_name)
        nm = fex_facetproc(char(handles.const.movies));
    else
        nm = fex_facetproc(char(handles.const.movies),'dir',folder_name);
    end
    handles.const.set('files',nm);
    set(handles.helpbox,'String',sprintf('%s Done.',str));
    % Update UI
    set(handles.exportbutton,'Enable','on');
    set(handles.facetbutton,'Enable','on');
    set(handles.expression_cb,'Value',1);
end

handles.output = handles.const;
guidata(hObject, handles);


function exportbutton_Callback(hObject, eventdata, handles)
%
% EXPORTBUTTON - Exist constructor and save data.

% Add output directory
folder_name = uigetdir(pwd,'Select Output Directory');
if isempty(folder_name)
    folder_name = pwd;
end
handles.const.set('targetdir',folder_name);

% Return constructor object
handles.output = handles.const;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% --------------------------------------------------------------------
%  Pop Up Menue fo Select
% --------------------------------------------------------------------
function addfilecontroller_Callback(hObject, eventdata, handles)
%
% ADDFILECONTROLLER - Callback

% k = get(handles.addfilecontroller,'String');
% name = k{get(handles.addfilecontroller,'Value')};
update_text(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
%  CLOSE REQUEST
% --------------------------------------------------------------------

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% CLOSEREQUESTFCN - send close request 

if isequal(get(handles.figure1,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% --------------------------------------------------------------------
%  HELPER FUNCTIONS
% --------------------------------------------------------------------

function update_text(handles)

k = get(handles.addfilecontroller,'String');
name = k{get(handles.addfilecontroller,'Value')};

switch name
    case 'Movies'
        str = sprintf('\nSelect video files for the analysis by pressing the buttoon "Select".');
    case 'FACET Data'
        str = sprintf('\nSelect Facial Expressions files by pressing the buttoon "Select".');
    case 'Time Stamps'
        str = sprintf('\nProvide information on video timing by pressing the buttoon "Select".');
    case 'Design'
        str = sprintf('\nSelect Design files by pressing the buttoon "Select".');
end
set(handles.helpbox,'String',str);
