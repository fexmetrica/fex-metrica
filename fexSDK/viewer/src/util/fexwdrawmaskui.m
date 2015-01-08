function varargout = fexwdrawmaskui(varargin)
% 
% User interface to draw a mask of a face.
%
% ...
%
%
%__________________________________________________________________________
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 09/09/14.



% Initialization
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fexwdrawmaskui_OpeningFcn, ...
                   'gui_OutputFcn',  @fexwdrawmaskui_OutputFcn, ...
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


% --- Executes just before fexwdrawmaskui is made visible -----------------
function fexwdrawmaskui_OpeningFcn(hObject, eventdata, handles, varargin)
%
% Initialize parameters for the ellipses.

if ~isempty(varargin)
    img = rgb2gray(varargin{1});
    imshow(img,'Parent',handles.image_axes);
    hand = get(handles.image_axes,'Children');
    set(hand(1),'DisplayName','Image');

    % Update information
    dim = size(img);
    set(handles.elli2X,'Max',dim(2));
    set(handles.elli2Y,'Max',dim(1));
    set(handles.elli2X,'Value',round(dim(2)/2));
    set(handles.elli2Y,'Value',round(dim(1)/2));    
    
    set(handles.elli2Maj,'Max',max(dim));
    set(handles.elli2Min,'Max',min(dim));
    set(handles.elli2Cut,'Max',max(dim));
    
    set(handles.elli2Rotate,'Min',0);
    set(handles.elli2Rotate,'Max',180);
    set(handles.elli2Rotate,'Value',90);
   
    % Create Children for:
    axis(handles.image_axes);
    hold on
    plot(nan(100,1),nan(100,1),'xm','LineWidth',2);
    hand = get(handles.image_axes,'Children');
    set(hand(1),'DisplayName','Mask');
end

% start ellipses for output
handles.ellipses = mat2dataset(nan(1,2),'VarNames',{'X','Y'});
% Choose default command line output for fexwdrawmaskui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes fexwdrawmaskui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fexwdrawmaskui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.ellipses;
close(handles.figure1);


% --- Executes on slider movement.
function elli2_Callback(hObject, eventdata, handles)
%
%
% Update ellipses information

x   = get(handles.elli2X,'Value');
y   = get(handles.elli2Y,'Max') - get(handles.elli2Y,'Value');
M   = get(handles.elli2Maj,'Value');
m   = get(handles.elli2Min,'Value');
M2  = get(handles.elli2Cut,'Value');

if get(handles.freeze_elli2maj2, 'Value') == 1
    set(handles.elli2Cut,'Value',M);
    M2 = M;
end

if m > min(M,M2)
    set(handles.elli2Min,'Value',min(M,M2));
    m = get(handles.elli2Min,'Value');
end

r = get(handles.elli2Rotate,'Value');

if M > 0 && m > 0
    X = zeros(100,1); Y = zeros(100,1);
    [X1,Y1] = calculateEllipse(x,y, M, m, r, 100);
    [X2,Y2] = calculateEllipse(x,y, M2, m, r, 100);
    X([1:25,76:100]) = round(X1([1:25,76:100]));
    X(26:75) = round(X2(26:75));
    Y([1:25,76:100]) = round(Y1([1:25,76:100]));
    Y(26:75) = round(Y2(26:75));
    axes(handles.image_axes);
    hand_names = get_handle_names(handles);
    set(hand_names.Mask,'XData',X,'YData',Y);
    handles.ellipses = mat2dataset([X,Y],'VarNames',{'X','Y'});
    refresh
end

handles.output = hObject;
guidata(hObject, handles);

function [X,Y] = calculateEllipse(x,y,a,b,angle,steps)
% This functions returns points to draw an ellipse
%
% param x     X coordinate
% param y     Y coordinate
% param a     Semimajor axis
% param b     Semiminor axis
% param angle Angle of the ellipse (in degrees)
%

narginchk(5,6);
if nargin<6, steps = 36; end

beta = -angle * (pi / 180);
sinbeta = sin(beta);
cosbeta = cos(beta);

alpha = linspace(0, 360, steps)' .* (pi / 180);
sinalpha = sin(alpha);
cosalpha = cos(alpha);

X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);

if nargout==1, X = [X Y]; end


function hand_names = get_handle_names(handles)

hand_names = [];
hnd = get(handles.image_axes,'Children');
for i = 1:length(hnd)
    hand_names.(get(hnd(i),'DisplayName')) = hnd(i);
end



% --- Executes on button press in donebutton.
function donebutton_Callback(hObject, eventdata, handles)
% hObject    handle to donebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);
handles.output = hObject;
guidata(hObject, handles);