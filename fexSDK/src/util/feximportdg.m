function varargout = feximportdg(varargin)
%
% FEXIMPORTDG - UI for importing design matrix.
%
%
% USAGE:
%
% desc = feximportdg;
% desc = feximportdg('file',filename);
%
%
% FEXIMPORTDG help you to import design file for a FEXC object. You can
% call the UI specifying a file path or a dataset, or you can import a
% dataset at a second time, uising the Menu item "Open."
%
% 
% FILE MENU:
% ===========
%
% The FILE MENU contains three items:
%
% "Open"   [cmd+O]: Opens a UI that lets you select a file;
% "Export" [cmd+E]: Close the UI and exports the FEXDESIGNC object to the
%                   command line.
% "RESET"  [cmd+R]: Deletes all changes made up to that point.
%
% Note: the shortcuts on Linux use "ctrl" instead of "cmd." 
%
%
% UI OBJECTS:
% ============
%
% "Rename Variable": Select from the scroll down menu a variable to rename.
% Once a variable is selected, an editable text box appears, and you can
% type the desired variable name. Press enter when you are done.
% 
% "Time Variable": This scroll down object allows you to indicate which
% variable contains timing information. If in the original dataset the
% variable has one of the default names (e.g. "Time"), this variable is
% identified automatically, and you don't have anything to do.
%
% "Select Variables": When you press this button, a list with the name of
% all the variables appear. You can select the variable that you want to
% delete and press "delete" (or backspace). If you press the button again
% (now labeled "Hide"), the variable list disappear and the tabled dataset
% is expanded.
%
% "Cancel": This button closes the UI and return an empty argument.
%
% "Export": Close the UI and exports the FEXDESIGNC object to the command
% line.
%
%
% TABLE WITH DATA:
% =================
% 
% The table is meant to give an overview of the dataset. Only the first
% 20 lines are displayed.
%
% 
% See also FEXDESIGNC, FEXC, FEX_CONSTRUCTORUI.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 2-Feb-2015.



% ---------------------------------------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @feximportdg_OpeningFcn, ...
                   'gui_OutputFcn',  @feximportdg_OutputFcn, ...
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


% ************************************************************************
% Constructor
% ************************************************************************
function feximportdg_OpeningFcn(hObject, eventdata, handles, varargin)
% 
%
% OPENINGFCN - operation exectuted before opening the UI


set(handles.figure1,'Name','Fex Design Import');

% ----------------------------------
% Read optional arguments
% ---------------------------------- 
ind1 = find(strcmp('file',varargin));
ind2 = find(strcmp('importcmd',varargin));

% ----------------------------------
% Import dataset when provided
% ---------------------------------- 
if ~isempty(ind1) && ~isempty(ind2)
    % Try using custome function handle
    try
        data = varargin{ind2+1}(varargin{ind1+1});
        handles.fexd = fexdesignc(data);
    catch errorID
        warning('Could''t import data, error %s.',errorID.message);
    end
elseif ~isempty(ind1) && isempty(ind2)
    % Import dataset using IMPORTDATASET method
    try
        handles.fexd = fexdesignc(varargin{ind1+1});
        % data = importasdataset(varargin{ind1+1});
    catch errorID
       warning('Could''t import data, error %s.',errorID.message);
    end
end

% ----------------------------------
% Initialize Ui properties
% ---------------------------------- 
if isfield(handles,'fexd')
    % handles.fex = initializefex();
    % Set import command if provided
    if ~isempty(ind2)
       handles.fex(1).importcmd = varargin{ind2+1};
    end
    set(handles.table, 'Data', dat2tab(handles.fexd.X));
    set(handles.table, 'ColumnName',handles.fexd.X.Properties.VarNames);
    set(handles.table,'Visible','on');

    % Update the variable names
    set(handles.variableselect,'String',['Rename Variable',handles.fexd.X.Properties.VarNames]);
    set(handles.timetagselect,'String', ['Time Variable:',handles.fexd.X.Properties.VarNames]);
    set(handles.list_select_var,'String',handles.fexd.X.Properties.VarNames);
    set(handles.list_select_var,'Visible','off');
    % Test whether time was identified:
    if ~isempty(handles.fexd.timetag)
        ind = find(strcmpi(handles.fexd.timetag,handles.fexd.X.Properties.VarNames));
        set(handles.timetagselect,'Value',ind+1);
    end
else
    handles.fexd = '';
end

handles.output = handles.fexd;
guidata(hObject, handles);
uiwait(handles.figure1);


% ************************************************************************
% Close Request
% ************************************************************************
function figure1_CloseRequestFcn(hObject, eventdata, handles)
%
% CLOSEREQUEST - closes the ui.

if isequal(get(handles.figure1,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

% ************************************************************************
% Select Output 
% ************************************************************************
function varargout = feximportdg_OutputFcn(hObject, eventdata, handles) 
%
% OUTPUTFCN - Select command line output.

varargout{1} = handles.fexd;
delete(handles.figure1);


% ************************************************************************
% Menu import dataset
% ************************************************************************
function impdataset_Callback(hObject, eventdata, handles)
%
% IMPDATASET - Opens ui to import a dataset.

% -------------------------------------------------
% File selection 
% -------------------------------------------------
[f,p] = uigetfile('*','DialogTitle','Select Dataset');
try
    handles.fexd = fexdesignc(sprintf('%s%s',p,f));
catch errorID
    error('Import failed: %s.',errorID.message);
end

% -------------------------------------------------
% Show design matrix as table
% -------------------------------------------------
set(handles.table, 'Data', dat2tab(handles.fexd.X));
set(handles.table, 'ColumnName',handles.fexd.X.Properties.VarNames);
set(handles.table,'Visible','on');

% -------------------------------------------------
% Update variables names
% -------------------------------------------------
set(handles.variableselect,'String',['Rename Variable',handles.fexd.X.Properties.VarNames]);
set(handles.timetagselect,'String', ['Time Variable:',handles.fexd.X.Properties.VarNames]);
if ~isempty(handles.fexd.timetag)
    ind = find(strcmpi(handles.fexd.timetag,handles.fexd.X.Properties.VarNames));
    set(handles.timetagselect,'Value',ind+1);
end
set(handles.list_select_var,'String',handles.fexd.X.Properties.VarNames);
set(handles.list_select_var,'Visible','off');

% -------------------------------------------------
% Update all
% -------------------------------------------------
handles.output = handles.fexd;
guidata(hObject, handles);


% ************************************************************************
% Menu Reset Changes
% ************************************************************************
function resetchanges_Callback(hObject, eventdata, handles)
% 
% RESETCHANGES - remove all changes made to dataset

% -------------------------------------------------
% Reset FEXD field
% -------------------------------------------------
if isa(handles.fexd,'fexdesignc')
    handles.fexd.reset();
    set(handles.table,'Data', dat2tab(handles.fexd.X));
    set(handles.table,'ColumnName',handles.fexd.X.Properties.VarNames);
    set(handles.table,'Visible','on');
    set(handles.variableselect,'String',['Rename Variable',handles.fexd.X.Properties.VarNames]);
    set(handles.list_select_var,'String',handles.fexd.X.Properties.VarNames);
    % Reset Time Variables
    set(handles.timetagselect,'String', ['Time Variable:',handles.fexd.X.Properties.VarNames]);
    % Reset fexd
    handles.fexd.include = [];
    handles.timetag = '';
else
    warning('Nothing to reset.');
end

% -------------------------------------------------
% Update all
% -------------------------------------------------
handles.output = handles.fexd;
guidata(hObject, handles);


% ************************************************************************
% Menu Export Changes
% ************************************************************************
function exportmenu_Callback(hObject, eventdata, handles)
%
% EXPORTMENU - export FEXDESIGNC object.

handles.output = handles.fexd;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% ************************************************************************
% Select variables button for renaming
% ************************************************************************
function variableselect_Callback(hObject, eventdata, handles)
%
% VARIABLESELECT - select a subset of variables.

% -------------------------------------------------
% Clean name when changing variable
% -------------------------------------------------
set(handles.newname,'String','');
ind  = get(handles.variableselect,'Value');
if ind == 1
   set(handles.newname,'BackgroundColor',[0,0,0]); 
else
   set(handles.newname,'BackgroundColor',[1,1,1]);
end

% -------------------------------------------------
% Update all
% -------------------------------------------------
handles.output = handles.fexd;
guidata(hObject, handles);


% ************************************************************************
% Renaming procedure
% ************************************************************************
function newname_Callback(hObject, eventdata, handles)
%
% NEWNAME - CHANGE NAME CALLBACK

ind  = get(handles.variableselect,'Value');
new_name = get(handles.newname,'String');

if ind > 1;
    old_name = handles.fexd.X.Properties.VarNames{ind-1};
    handles.fexd.rename(old_name,new_name);
    set(handles.table,'Data', dat2tab(handles.fexd.X));
    set(handles.table,'ColumnName',handles.fexd.X.Properties.VarNames);
    set(handles.variableselect,'String',['Rename Variable:',handles.fexd.X.Properties.VarNames]);
    set(handles.timetagselect,'String', ['Time Variable:',handles.fexd.X.Properties.VarNames]);
    set(handles.list_select_var,'String',handles.fexd.X.Properties.VarNames);
    % Return to init position
    set(handles.variableselect,'Value',1);
    set(handles.newname,'BackgroundColor',[0,0,0]); 
    set(handles.newname,'String','');
    % Look for time when not set
    if isempty(handles.fexd.timetag)
        opt_name = {'time','timestamp','timestamps','timetag'};
        ind = ismember(lower(handles.fexd.X.Properties.VarNames),opt_name);
        if sum(ind) > 1
            warning('Multiple possible "timetag" found.');
            handles.fexd.timetag = handles.fexd.X.Properties.VarNames(ind == 1);
        elseif sum(ind) == 1
            handles.fexd.timetag = handles.fexd.X.Properties.VarNames{ind == 1};
        end   
        ind = find(strcmpi(handles.fexd.timetag,handles.fexd.X.Properties.VarNames));
        set(handles.timetagselect,'Value',ind+1);
    end    
else
    warning('You need to select a variable.');
end

% -------------------------------------------------
% Update all
% -------------------------------------------------
handles.output = handles.fexd;
guidata(hObject, handles);


% ************************************************************************
% Select variables 
% ************************************************************************
function select_vars_Callback(hObject, eventdata, handles)
% 
% SELECT_VARS - Select variables to be used.

% -------------------------------------------------
% Activate Deactivate Select Variables
% -------------------------------------------------
if strcmp(get(handles.select_vars,'String'),'Select Variables')
    set(handles.select_vars,'String','Hide');
    set(handles.list_select_var,'Visible','on');
    set(handles.table,'Position',[4,1.426,77.5,29.923]);
else
    set(handles.select_vars,'String','Select Variables');
    set(handles.list_select_var,'Visible','off'); 
    set(handles.table,'Position',[4,1.426,104.667,29.923]);
end

% -------------------------------------------------
% Update all
% -------------------------------------------------
handles.output = handles.fexd;
guidata(hObject, handles);

% ************************************************************************
% Select Timetag variable
% ************************************************************************
function timetagselect_Callback(hObject, eventdata, handles)
% 
% TIMETAGSELECT - Select variable with timing information

ind  = get(handles.timetagselect,'Value');
str  = get(handles.timetagselect,'String');
if ind > 1
    handles.fexd.timetag = str{ind};
else
    handles.fexd.timetag = '';
end

handles.output = handles.fexd;
guidata(hObject, handles);



% ************************************************************************
% Export FEXDESIGNC object
% ************************************************************************
function exportbutton_Callback(hObject, eventdata, handles)
% 
% EXPORTBUTTON - export FEXDESIGNC object.

handles.output = handles.fexd;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% ************************************************************************
% Cancel UI operation
% ************************************************************************
function cancelbutton_Callback(hObject, eventdata, handles)
%
% CANCELBUTTON - cancel UI operations.

handles.fexd = '';
handles.output = handles.fexd;
guidata(hObject, handles);
figure1_CloseRequestFcn(handles.figure1,[],handles)


% ************************************************************************
% Helper functions
% ************************************************************************
function [C,H] = dat2tab(data)
%
% 
% DAT2TAB - Convert dataset into table for display.
%
%
% NOTE: for some reason, 2014a does not have this function, despite
% advertized.

H  = data.Properties.VarNames;
cl = datasetfun(@class,data,'UniformOutput',false); 
I  = min(size(data,1),50);

if sum(strcmp('double',cl)) == size(data,2)
    C = double(data(1:I,:));
else
    C = {};
    for i = 1:I
        tcell = dataset2cell(data(i,:)); 
        C = cat(1,C,tcell(2,:));
    end
end

% --- Executes on selection change in list_select_var.
function list_select_var_Callback(hObject, eventdata, handles)
%
% LIST_SELECT_VAR - Inactive.



% --- Executes on key press with focus on list_select_var and none of its controls.
function list_select_var_KeyPressFcn(hObject, eventdata, handles)
%
% LIST_SELECT_VAR_KEYPRESSFCN - Exclude variables.

str = get(handles.list_select_var,'String');
ind = get(handles.list_select_var,'Value');

if strcmp(eventdata.Key,'backspace')
% ------------------------------------------------
% Do not allow to delete time
% ------------------------------------------------ 
if strcmpi(handles.fexd.timetag,str{ind})
   warning('Can''t delete time variable.');
   return
end
% ------------------------------------------------
% SELECT & UPDATE all
% ------------------------------------------------ 
handles.fexd.select(str{ind},0);
set(handles.table,'Data', dat2tab(handles.fexd.X));
set(handles.table,'ColumnName',handles.fexd.X.Properties.VarNames);
set(handles.variableselect,'String',['Rename Variable:',handles.fexd.X.Properties.VarNames]);
set(handles.timetagselect,'String', ['Time Variable:',handles.fexd.X.Properties.VarNames]);

% ------------------------------------------------
% Adjust TimeTag Variable
% ------------------------------------------------ 
if ~isempty(handles.fexd.timetag)
    indt = find(strcmpi(handles.fexd.timetag,handles.fexd.X.Properties.VarNames));
    set(handles.timetagselect,'Value',indt+1);
end
% ------------------------------------------------
% Update List of variables
% ------------------------------------------------
set(handles.list_select_var,'String',handles.fexd.X.Properties.VarNames);
set(handles.list_select_var,'Value',min(ind,length(handles.fexd.X.Properties.VarNames)));
end

% ------------------------------------------------
% UPDATE
% ------------------------------------------------ 
handles.output = handles.fexd;
guidata(hObject, handles);
