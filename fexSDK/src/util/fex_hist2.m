function varargout = fex_hist2(varargin)
% FEX_HIST2 MATLAB code for fex_hist2.fig
%      FEX_HIST2, by itself, creates a new FEX_HIST2 or raises the existing
%      singleton*.
%
%      H = FEX_HIST2 returns the handle to a new FEX_HIST2 or the handle to
%      the existing singleton*.
%
%      FEX_HIST2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEX_HIST2.M with the given input arguments.
%
%      FEX_HIST2('Property','Value',...) creates a new FEX_HIST2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fex_hist2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fex_hist2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fex_hist2

% Last Modified by GUIDE v2.5 04-Oct-2015 12:12:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fex_hist2_OpeningFcn, ...
                   'gui_OutputFcn',  @fex_hist2_OutputFcn, ...
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


% --- Executes just before fex_hist2 is made visible.
function fex_hist2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fex_hist2 (see VARARGIN)

% Read optional argunents
% ========================
args = struct('data',rand(100,2),'stepsize',0.1,'varnames',{{'Var1';'Var2'}},'type','prob','class',[]);
if length(varargin) == 1
    args.data = varargin{1};
elseif length(varargin) > 1
    targs = cell2struct(varargin(2:2:end),varargin(1:2:end),round(length(varargin)/2));
    for k = fieldnames(targs)'
        if isfield(args,lower(k{1}));
            args.(lower(k{1})) = targs.(k{1});
        end
    end
end


if isa(args.data,'dataset') || isa(args.data,'table');
    args.varnames = args.data.Properties.VarNames;
end
data = double(args.data);

% Vertical Histogram
axes(handles.axesV)
h1 = histogram(data(:,1),0:args.stepsize:1,'Normalization','Probability');
set(gca,'view',[-90 90]);%,'Ytick',[]);
xlabel(args.varnames{1},'fontsize',12);


% Horizontal Histogram
axes(handles.axesH)
h2 = histogram(data(:,2),0:args.stepsize:1,'Normalization','Probability');
set(gca,'view',[0 -90]);%,'Ytick',[]);
xlabel(args.varnames{2},'fontsize',12);

axes(handles.axesM)
hold on, box on


[X,Y] = meshgrid(linspace(0,1,length(h1.Values)));
JP = h1.Values'*h2.Values;
surf(X,Y,JP);
% view(90,0)
% axis square
shading interp
colorbar;
% colormap hot,


xlim([0,1]); ylim([0,1]);
set(gca,'Xtick',[],'Ytick',[],'Ztick',[],'LineWidth',1)



% Choose default command line output for fex_hist2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fex_hist2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fex_hist2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
