function varargout = fex_lsg(varargin)
%
%
% fex_lsg selects the data that will be preprocessed using facet SDK. You
% can select movies, or frames.
% 
% If you select a directory, that directory can contain directories, movies
% or frames. In any case, you should specify a filter that will be applied
% to the file selection.
%
% Note that you can't select directly all frames from a directory -- you
% should instead select the directory with the frame, and specify your
% selection criterion.



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fex_lsg_OpeningFcn, ...
                   'gui_OutputFcn',  @fex_lsg_OutputFcn, ...
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


% --- Executes just before fex_lsg is made visible.
function fex_lsg_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for fex_lsg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fex_lsg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fex_lsg_OutputFcn(hObject, eventdata, handles) 

try
    varargout{1} = get(handles.uilist,'String');
catch
    varargout{1} = [];
end
close(handles.figure1);


% --- Executes on button press in ui_done.
function ui_done_Callback(hObject, eventdata, handles)

uiresume;


% --- Executes on button press in ui_button_add.
function ui_button_add_Callback(hObject, eventdata, handles)
% hObject    handle to ui_button_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is the main selection procedure (it changes if it is dir or files)


k1 = get(handles.uitype,'Value');   % Get directory or file selection
strk2 = get(handles.filtertbox,'String'); % Get filter
if strcmp(strk2,'filter')
    strk2 = '';
end

% if k2 == 1
%     strk2 = '';
% else
%     strk2 = get(handles.uifilter,'String');
%     strk2 = strk2{k2};
%     strk3 = sprintf('*.%s', strk2); 
%     strk2 = {sprintf('*.%s', strk2),sprintf('Format (*.%s)',strk2)};
% end

if ismember(k1,1:2)
    PathName = uigetdir('','FexSelect');
else
    [FileName,PathName] = uigetfile(strk2,'DialogTitle','FexSelect','MultiSelect','on');
end


if PathName ==0
    return
end

if k1 == 1
    % This applies to movies not to frames
    str_show = get(handles.uilist,'String');
    % Handle existing string
    if  ~strcmp(str_show,'Select')
        temp_list = str_show;
        str_show = sprintf('%s',temp_list(1,:));
        for i = 2:size(temp_list,1)
            str_show = sprintf('%s\n%s',str_show,temp_list(i,:));
        end    
    end 
    
    % Get the new data
    [~,new_list] = unix(sprintf('find %s -name "%s"',PathName,strk2));
    % Divide the string into cell
    new_list = strsplit(new_list);
    
    if strcmp(str_show,'Select')
        str_show = sprintf('%s',new_list{1});
        kl = 2;
    else
        kl = 1;
    end
    for i = kl:length(new_list)-1
        str_show = sprintf('%s\n%s',str_show,new_list{i});
    end
    set(handles.uilist,'String',str_show);
end


handles.output = hObject;
guidata(hObject, handles);

% --- Executes on selection change in uitype.
function uitype_Callback(hObject, eventdata, handles)

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function uitype_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in uifilter.
% function uifilter_Callback(hObject, eventdata, handles)
% hObject    handle to uifilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns uifilter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uifilter


% --- Executes during object creation, after setting all properties.
% function uifilter_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to uifilter (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function uilist_Callback(hObject, eventdata, handles)

handles.output = hObject;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uilist_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filtertbox_Callback(hObject, eventdata, handles)

handles.output = hObject;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function filtertbox_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
