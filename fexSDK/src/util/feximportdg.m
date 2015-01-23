function varargout = feximportdg(varargin)
%
% FEXIMPORTDG - UI for importing design matrix
%
%
% USAGE:
%
% desc = feximportdg;
% desc = feximportdg('file',filename);
% desc = feximportdg('file',filename,'importcmd',importcmd);
%
%
% FEXIMPORTDG help you to import a dataset.
%
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


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


% ---------------------------------------------------
% Constructor
% ---------------------------------------------------
function feximportdg_OpeningFcn(hObject, eventdata, handles, varargin)
% 
%
% OPENINGFCN - operation exectuted before opening the UI


ind1 = find(strcmp('file',varargin));
ind2 = find(strcmp('importcmd',varargin));

% Import the dataset
if ~isempty(ind1) && ~isempty(ind2)
    % Try using custome function handle
    try
        data = varargin{ind2+1}(varargin{ind1+1});
    catch errorID
        warning('Could''t import data, error %s.',errorID.message);
    end
elseif ~isempty(ind1) && isempty(ind2)
    % Import dataset using IMPORTDATASET method
    try
        data = importasdataset(varargin{ind1+1});
    catch errorID
       warning('Could''t import data, error %s.',errorID.message);
    end
end

% Initialize ui propery
if exist('data','var')
    handles.fex = initializefex(data);
    % Set import command if provided
    if ~isempty(ind2)
       handles.fex(1).importcmd = varargin{ind2+1};
    end
    % Initialize GUI
    % Make the dataset visible (transform in table)
    set(handles.table, 'Data', dat2tab(data));
    set(handles.table, 'ColumnName', data.Properties.VarNames);
    set(handles.table,'Visible','on');

    % Update the variable names
    set(handles.variableselect,'String',['Variable Name',data.Properties.VarNames]);

    % Inintialize the fex object that will be popultated with data information
    handles.fex = struct('data',[],'ndata',[],'type',[],'rot',[],'use',[],'hdr',{});

    handles.fex(1).data = data;                     % imported dataset
    handles.fex(1).ndata = data;                    % modified dataset
    handles.fex(1).type = 2*ones(1,size(data,2));   % set everything to IV/DV
    handles.fex(1).use  = ones(1,size(data,2));     % set everything to 'use'
    handles.fex(1).rot  = nan(1,size(data,2));      % No rate of change provided
    handles.fex(1).hdr  = data.Properties.VarNames; % use existing VarNames  
end

handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes feximportdg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = feximportdg_OutputFcn(hObject, eventdata, handles) 

if isfield(handles,'fex')
    varargout{1} = handles.fex;
else
   varargout{1} = '';
end

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% MENUE FUNCTIONS

% --------------------------------------------------------------------
function m1_Callback(hObject, eventdata, handles)
% hObject    handle to m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function impdataset_Callback(hObject, eventdata, handles)
%
% Open dialog window to import dataset. If succesfull, generate the main
% table for display. Update list of variables names.
%

% File selection and attempt to import the file
[f,p] = uigetfile('*','DialogTitle','Select Dataset');
try
    data = importasdataset(sprintf('%s%s',p,f));
catch errorID
    error('Import failed: %s.',errorID.message);
end

% Make the dataset visible (transform in table)
set(handles.table, 'Data', dat2tab(data));
set(handles.table, 'ColumnName', data.Properties.VarNames);
set(handles.table,'Visible','on');

% Update the variable names
set(handles.variableselect,'String',['Variable Name',data.Properties.VarNames]);

% Inintialize the fex object that will be popultated with data information
handles.fex = initializefex(data);

handles.output = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function importspecial_Callback(hObject, eventdata, handles)
%
% Import special allows you to specify more complex commands that can be
% used to import the dataset.

warning('Not implemented. No action performed.');
fprintf('\nThis is not implemented yet. Sorry.\n');
fprintf('If you are having problem loading the dataset:\n');
fprintf('\t(1) create a function handle that works for your dataset;\n');
fprintf('\t(2) call: >> feximportdg(''importcmd'',cmd).\n\n');
fprintf('\tNOTE that cmd is a function handle.\n');

% --------------------------------------------------------------------
function resetchanges_Callback(hObject, eventdata, handles)
% 
% Restore initial dataset from the given file: all changes will be lost.
%

if isfield(handles,'fex')
    % Make the dataset visible (transform in table)
    data = handles.fex(1).data;
    set(handles.table, 'Data', dat2tab(data));
    set(handles.table, 'ColumnName', data.Properties.VarNames);
    set(handles.table,'Visible','on');

    % Update the variable names
    set(handles.variableselect,'String',['Variable Name',data.Properties.VarNames]);

    % Inintialize the fex object that will be popultated with data information
    handles.fex = initializefex(data);    
else
    warning('Nothing to reset.');
end

handles.output = hObject;
guidata(hObject, handles);  


% --------------------------------------------------------------------
function helpm_Callback(hObject, eventdata, handles)
% hObject    handle to helpm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function helpdocs_Callback(hObject, eventdata, handles)
% 
% Add here opening comand for the manual in .pdf.




% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% VARIABLES SELECTION & USAGE

% --- Executes during object creation, after setting all properties.
function variableselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variableselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function variableselect_Callback(hObject, eventdata, handles)
% hObject    handle to variableselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns variableselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variableselect

ind = get(handles.variableselect,'Value');
if ind > 1
    % If the variable is not used, matrk as such
    set(handles.usecmd,'Value',handles.fex.use(ind-1));
end


handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in usecmd.
function usecmd_Callback(hObject, eventdata, handles)
%
% Use/Not use a variable

ind = get(handles.variableselect,'Value');
val = get(handles.usecmd,'Value');

if ind > 1;
   handles.fex(1).use(ind - 1) = val;
else
    warning('You need to select a variable.');
end

handles.output = hObject;
guidata(hObject, handles);


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% VARIABLES RENAME


% --- Executes during object creation, after setting all properties.
function newname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newname_Callback(hObject, eventdata, handles)
% hObject    handle to newname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newname as text
%        str2double(get(hObject,'String')) returns contents of newname as a double


ind = get(handles.variableselect,'Value');
val  = get(handles.newname,'String');

if ind > 1;
   handles.fex(1).hdr{ind - 1} = val;
else
    warning('You need to select a variable.');
end

handles.output = hObject;
guidata(hObject, handles);


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% VARIABLES TYPE DETERMINATION


% --- Executes during object creation, after setting all properties.
function variabletype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to variabletype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in variabletype.
function variabletype_Callback(hObject, eventdata, handles)
% hObject    handle to variabletype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns variabletype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from variabletype


ind = get(handles.variableselect,'Value');
val = get(handles.variabletype,'Value');

if ind > 1
   switch val
       case 1
           warning('You need to indicate a variable type.');
           return
       case 2
           handles.fex(1).type(ind-1) = val;
           set(handles.rotselect,'Enable','on');
       case {3,4,5,6,7}
           handles.fex(1).type(ind-1) = val;
       otherwise
           warning('Returning without actions')
           return
   end
else
    warning('You need to select a variable.');
end

handles.output = hObject;
guidata(hObject, handles);


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% OPERATIONS ON DV/IV

% --- Executes during object creation, after setting all properties.
function rotselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in rotselect.
function rotselect_Callback(hObject, eventdata, handles)
% hObject    handle to rotselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns rotselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from rotselect

ind = get(handles.variableselect,'Value');
val = get(handles.rotselect,'Value');

% update value
if val > 1
    handles.fex.rot(ind-1) = val-1;
end
% activate stage selector if set to stage:

if val == 5
    set(handles.stagenumselect,'Enable','on');
end

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function stagenumselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stagenumselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stagenumselect.
function stagenumselect_Callback(hObject, eventdata, handles)
% hObject    handle to stagenumselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stagenumselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stagenumselect

ind = get(handles.variableselect,'Value');
val = get(handles.stagenumselect,'Value');

% update value
if val > 1
    handles.fex.stage(ind-1) = val-1;
end

% Update all
handles.output = hObject;
guidata(hObject, handles);


% -------------------------------------------------------
% Update Variables
% -------------------------------------------------------
function submittvarbutton_Callback(hObject, eventdata, handles)
%
% SUBMITTVARBUTTON - Update variable view

% Update table
idx  = handles.fex.use;
set(handles.table, 'Data', dat2tab(handles.fex.data(:,idx == 1)));
set(handles.table, 'ColumnName',handles.fex.hdr(idx == 1));

% Reser Variable Select, name and usage
% set(handles.usecmd,'Value',1);
set(handles.variableselect,'String',['Variable Name',handles.fex.hdr]);
set(handles.variableselect,'Value',1);
% set(handles.variabletype,'Value',1);
set(handles.newname,'String','');

% Inactivate DV/IV box
set(handles.rotselect,'Value',1);
set(handles.rotselect,'Enable','off');
set(handles.stagenumselect,'Value',1);
set(handles.stagenumselect,'Enable','off');

% Update all
handles.output = hObject;
guidata(hObject, handles);


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_vars.
function select_vars_Callback(hObject, eventdata, handles)
% hObject    handle to select_vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_time.
function select_time_Callback(hObject, eventdata, handles)
% hObject    handle to select_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% -------------------------------------------------------
% Helper Functions
% -------------------------------------------------------
function [C,H] = dat2tab(data)
%
% 
% DAT2TAB - Convert dataset into table
%
%
% NOTE: for some reason, 2014a does not have this function, despite
% advertized.


H  = data.Properties.VarNames;
cl = datasetfun(@class,data,'UniformOutput',false); 
I  = min(size(data,1),10);

if sum(strcmp('double',cl)) == size(data,2)
    C = double(data(1:I,:));
else
    C = {};
    for i = 1:I
        tcell = dataset2cell(data(i,:)); 
        C = cat(1,C,tcell(2,:));
    end
end

% -------------------------------------------------------
function data = importasdataset(name)
%
% IMPORTDATASET - Helper function for importing design matrix

if isa(name,'dataset')
    data = name;
elseif ~exist(name,'file');
    error('File provided does not exists.')
else
    [~,~,e] = fileparts(name);
    switch e
        case '.mat'
            temp   = importdata(name);
            if isa(temp,'struct')
                data = str2dataset(temp);
            elseif isa(temp,'double')
                data = mat2dataset(temp);
            elseif isa(temp,'dataset')
                data = temp;
            else
                error('Couldn''t import the dataset.');
            end
                
            %fnames = fieldnames(temp);  
        case '.txt'
            data = dataset('File',name,'Delimiter','\t');
        case '.csv'
            data = dataset('File',name,'Delimiter',',');
        case {'.xlsx','.xls'}
            data = dataset('XLSFile',fname);
        otherwise
            warning('File %s not recognized.', fname);
            return
    end
end

% -------------------------------------------------------
function fex = initializefex(data)
%
% INITIALIZEFEX - Helper function for design handle

fex = struct('importcmd','','data',[],'ndata',[],'type',[],'rot',[],'use',[],'hdr',{});
fex(1).data = data;                         % imported dataset
fex(1).ndata = data;                        % modified dataset
fex(1).type = 2*ones(1,size(data,2));       % set everything to IV/DV
fex(1).use  = ones(1,size(data,2));         % set everything to 'use'
fex(1).rot  = nan(1,size(data,2));          % No rate of change provided
fex(1).hdr  = data.Properties.VarNames;     % use existing VarNames

