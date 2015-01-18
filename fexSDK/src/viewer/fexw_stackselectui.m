function varargout = fexw_stackselectui(varargin)
%
% FEXW_STACKSELECTUI - Helper ui for FEXC subobject selection.
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 18-Jan-2015.


% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexw_stackselectui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexw_stackselectui_OutputFcn, ...
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


% ------------------------------------
% Initialization
% ------------------------------------
function fexw_stackselectui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% OPENINGFCN - initialization function.

if isempty(varargin)
    error('FEXW_STACKSELECTUI requires FEXC as argument.');
elseif ~isa(varargin{1},'fexc');
    error('FEXW_STACKSELECTUI requires FEXC as argument.');    
else
    list = {};
    for i = 1:length(varargin{1})
        [~,fname] = fileparts(varargin{1}(i).video);
        list = cat(1,list,fname);
    end
    set(handles.popupmenu1,'String',list); 
    set(handles.popupmenu1,'Value',1);
end

if length(varargin) == 2
    set(handles.popupmenu1,'Value',varargin{2});
end


handles.output = get(handles.popupmenu1,'Value');
guidata(hObject, handles);
uiwait(handles.figure1);

function varargout = fexw_stackselectui_OutputFcn(hObject, eventdata, handles) 
% 
% OUTPUTFCN - output selection function.

if nargout > 0
    varargout{1} = handles.output;
end
delete(handles.figure1);

% ------------------------------------
% Selection proper option
% ------------------------------------
function popupmenu1_Callback(hObject, eventdata, handles)
%
% POPUOMENU1_CALLBACK -- make selection and close UI

handles.output = get(handles.popupmenu1,'Value');
guidata(hObject, handles);
uiresume(handles.figure1);

