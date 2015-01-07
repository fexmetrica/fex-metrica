classdef fexwoverlay < handle
%
%
% FEXWOVERLAY - Generate overlay for FEXWIMG object
%
% FEXWOVERLAY can be used to display overlays on a 2D image of a face. The
% underlying image, or template, can be any of the 12 provided and it is a
% FEWIMG object.
%
% The building blocks for FEXWOVERLAY are facial muscles. The location and
% texture of individual muscular fibers are defined for each ?template,?
% and the data are displayed on top of these pixels. Pixels within muscular
% region X are indicated in the header of the ?template.? Action Units are
% localized on a face based on the muscles that contract/relax in order to
% generate those action units. Emotions are defined on an image in terms of
% combination of Action Units.
% 
% The correspondence of muscular activity with facial muscle was derived
% from the Facial Action Coding System (FACS). However, we simplified this
% model in order to have only one muscle per Action Units. Additionally,
% there are several combinations of Action Units that can results in the
% expression of basic emotions. We used one AUs configuration per emotions,
% derived from the Emotional Facial Action Coding System (EMFACS).
% 
%
% FEXWOVERLAY Properties:
%
% data - FEXC object or dataset with variable Names and Scores.
% info - information on how the FEXWOVERLAY is generated.
% fig -  main handle for the figure.
% handles - Vector of handles to the generated image.
%
% FEXWOVERLAY Private properties:
%
% template - Name of the FEXWIMG template to be used.
% side - Side where DATA is displayed on the template. 
% bounds - Threshold for upper and lower data.
% combine - Method to combine overlapping facial features.
% smoothing - Parameters for 2-D smoothing of overlay.
% colmap - Colormap used by the template.
% colbar - Rule to insert colorbar. 
% background - Rule for filling background within a face.
% optlayers - transparency and brightness of the overlay.
% 
% FEXWOVERLAY Methods:
% 
% fexwoverlay - Constructor for FEXWOVERLAY.
% update - Set or updates properties for FEXWOVERLAY.
% select - Select subset of features when FEXC is provided.
% makeoverlay - Generates overlay data (use with SHOW).
% coldataidx - Converts DATA into a set of indices for a 256-color map.
% show - Shows or updates the image.
% saveo - Save the current image, or the FEXWOVERLAY object.
% list - Display a list of muscles, action units, or emotions.
% makemovie - generates a movie from data - (only applies to FEXC objects). 
%
% See also FEXWHDR, FEXWIMG, FEXWDRAWMASKUI, FEXC, FEXC.VIEWER.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Sep-2014. 

    
properties
    % DATA: The dataset property is a dataset object with 'VarNames' properties
    % set to the names of the muscles, Action Units or emotions to bedisplayed.
    % The naming of the variables needs to be consistent with that used in
    % Fex-Metrica. In order to get a list of available channels, you can use
    % the method LIST. For example, the code: FEXWOVERLAY.LIST('AU') will
    % display naming for the Action Units. All columns of DATA with
    % unrecognized names are ignored.
    %
    % Instead of a dataset, the property DATA can be initialized to a cell of
    % strings. For example, data can be set to {?AU1?, ?AU2?, AU3}. In this
    % case, colors are generated for each facial expression channel.
    %
    % Two important caveats to the constructor procedure are:
    %
    % 1. Channel types (e.g. muscles, AUs, or emotions) don?t mix;
    % 2. Only one emotion can be displayed.
    %
    % See also LIST.
    data
    % INFO: a structure with fields associated to the parameters used for
    % creating the overlay. Fields of info include:
    %
    % TEMPLATE - name of the template to be used. (See also TEMPLATE).
    % SIDE - A string between indicating whether to display AUs and
    %          emotions on both sides of the face.
    % BOUNDS - Threshold for upper and lower data.
    % COMBINE - Method to combine overlapping facial features.
    % SMOOTHING - Parameters for 2-D smoothing of overlay.
    % COLMAP - Colormap used by the template.
    % COLBAR - Rule to insert colorbar. 
    % BACKGROUND - Rule for filling background within a face.
    % OPTLAYERS - transparency and brightness of the overlay.
    % 
    % See also GET.INFO.
    info
    % FIG: main handle for the figure.
    fig
    % HANDLES: structure of handles for the generated image. Each field
    % stands for one of the layer of the image. Fields are:
    %
    % face - handle to the image layer displaying the face template. 
    % muscles - handle to the image layer displaying mucular fibers.
    % overlay - handles to the layer displaying the overlay.
    % colorbar - handles to the colorbar.
    %
    % See also COLBAR.
    handles
end
    
properties (Access = private)
    % TEMPLATE: name of the template to be used. The argument TEMPLATE can
    % be a string, an integer between 1 and 12, or a FEXWIMG object.
    % 
    % When the user wants to display an overlay that is not between the 12
    % included in the VIEWER, ?template? must be a FEXWIMG. A list of
    % available names for the 12 templates is provided below:
    %
    %
    %       | Number | Description|
    %       |--------|------------|
    %       | 1      | template_1 |
    %       | 2      | template_2 |
    %       | 3      | template_3 |
    %       | 4      | template_4 |
    %       | 5      | anger      |
    %       | 6      | disgust    |
    %       | 7      | joy        |
    %       | 8      | sadness    |
    %       | 9      | surprise   |
    %       | 10     | contempt   |
    %       | 11     | fear       |
    %       | 12     | beutral    |
    %
    %
    % Default is set to template 1.
    %
    % See also FEXWIMG, FEXWHDR.
    template
    % SIDE: A string between 'right','left' or 'both' (default), indicating
    % whether to display AUs and emotions on both sides of the face, or on
    % a single side. SIDE can also be a cell, with one entry per feature in
    % DATA.
    side
    % BOUNDS: a two-component vector, which determines the data to be
    % displayed. For instance, suppose that data is [AU1:-1.00, AU2:2.00,
    % AU4:3:00], if you set bounds to [0,10], the overlay will have a
    % 256-dimension color map for values between 0 and 10; value smaller
    % than 0 (e.g. AU1 in the example) won?t be displaied. By default, the
    % property bounds is set to:
    % 
    % + [0, max(data)] when data is between 0 and infinity.
    % + [0,min(data)] when data is between negative infinity and 0.
    % + [-ValMax, ValMax] when data includes both positive and negative
    %    entry. In this case, 'ValMax' is the largest absolute value in
    %    data.
    bounds
    % COMBINE: a string between 'mean,'(default) 'median' and 'max', which
    % indicates how to combine data scores for overlapping action units.
    % Note that combination methid 'median' is the slowest.
    combine
    % SMOOTHING: can be a string in which case it is one of the possible
    % kernel functions ('none', 'gaussian', 'log', 'motion', 'average',
    % 'disk', 'laplace'). Alternatively, SMOOTHING is a structure, with
    % fields:
    %
    % kernel - a string with the name of a kernel used to smooth the
    %          overlay. Default: 'gaussian.'
    % size   - a scalar which indicates the size of the kernel in pixels.
    %          Default: 10.
    % param  - extra parameter when a kernel requires it. The field
    %          PARAM is used only when KERNEL is set to 'Gaussian'
    %          (default: 2.5), 'Log' (default: 2.5) and 'Laplacian'
    %          (default: 2.0).
    %
    % All kernels are generated using FSPECIAL are allowed.
    %
    % See also FSPECIAL.
    smoothing
    % COLMAP: The argument COLMAP is a string, and the optional values
    % are all the color maps defined in Matlab. The default is 'jet'.
    %
    % Alternatively, COLMAP can be a K × 3 matrix of rgb color providing a
    % customary color map.
    %
    % See also COLORMAP.
    colmap
    % COLBAR: a Boolean value, set by default to false. When COLBAR is set
    % to true, the image will comprise a colorbar position on the bottom of
    % the image. In order to change properties of the colorbar, the user
    % can manipulate directly the handle for the colorbar store in the
    % HANDLES property. Note that a colorbar is generated only of the
    % property DATA contains values and not only names of expressions
    % channels.
    %
    % COLORBAR requires the external functions CBFREEZE and CBHANDLE
    % (Copyright (c) - 2014 Carlos Adrian Vargas Aguilera), available at
    % http://www.mathworks.com/matlabcentral/fileexchange, and included in
    % the folder INCLUDE.
    %
    %
    % See also HANDLES, DATA, COLORBAR, CBFREEZE, CBHANDLE.
    colbar
    % BACKGROUND property is a Boolean value, which determines whether the
    % image will be shown with or without a background color within the
    % face. By default, the background argument is set to false.
    background
    % OPTLAYERS argument is a vector, comprising one, two, or three
    % components. When you privide this vector using FEXWOVERLAY, or using
    % the method UPDATE, the property OPTLAYERS is set to a structure with
    % three fields:
    %
    % overlay - indicates the transparency of the overlay on the template.
    %       This is a number between 0 and 1 (default: 0.4). When overlay
    %       is set to 1, no overlay is displayed.
    % fibers -  transparency of the overlay on the muscular fibers. For
    %       FIBERS = 1, the texture of the muscles is not displayed. By
    %       default, this value is set to 1.0.
    % brightness - the brightness of the colors. This is a number between
    %       -1 and 1, which is set by default to 0.
    %
    % See also FEXWOVERLAY, UPDATE.
    optlayers
    % TYPECH is an integer between 1 and 3 indicating whther the features
    % required are muscles, Action Units, or Emotions.
    typech
    % OVERLAYDATA. This property is a structure with fields:
    %
    % OD - Matrix with overlay data;
    % OT - Matrix with fiber texture;
    % ColDataIdx - Index of colors;
    % basecolor - Rgb base color for the background within the face.
    overlaydata
    % FEXWC: field containing the FEXC object, when a FEXC object is
    % entered as DATA.
    fexwc
    % VISIBLE: flag determining whether the image is displayed or not.
    % Default: false.
    visible
end
    
    
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************

methods
function self = fexwoverlay(data,varargin)
%
% FEXWOVERLAY - Constructor for FEXWOVERLAY.
%
% SYNTAX:
%
% OvObj = FEXWOVERLAY()
% OvObj = FEXWOVERLAY(data)
% OvObj = FEXWOVERLAY(data,'VarName',VarVal, ...)
%
% FEXWOVERLAY can be called without argument, in which case all properties
% needs to be specified using the method UPDATE. Alternatively, you can
% specify DATA, and additional optional arguments.
%
% DATA: The dataset property is a dataset object with 'VarNames' properties
% set to the names of the muscles, Action Units or emotions to bedisplayed.
% The naming of the variables needs to be consistent with that used in
% Fex-Metrica. In order to get a list of available channels, you can use
% the method LIST. For example, the code: FEXWOVERLAY.LIST('AU') will
% display naming for the Action Units. All columns of DATA with
% unrecognized names are ignored.
%
% Instead of a dataset, the property DATA can be initialized to a cell of
% strings. For example, data can be set to {?AU1?, ?AU2?, AU3}. In this
% case, colors are generated for each facial expression channel.
%
% The property DATA can be initialized from the constructor FEXWOVERLAY
% to a FEXC object. In this case, the internal property FEXWC is set to the
% FEXC object used. Note that by default, DATA is set to all the Action
% Units values in the FEXC object provided. You can use the method SELECT
% to use a subsample of AUs or to select Emotions.
%
% Two important caveats to the constructor procedure are:
%
% 1. Channel types (e.g. muscles, AUs, or emotions) don?t mix;
% 2. Only one emotion can be displayed.
%
% Optional arguments:
%
% fig - a figure handle for the image. When fig is not provided, a new
%   handle is generated. 
% template - set the template to be used (See also TEMPLATE). Default: 1.
% side - a string (or a cell for each column of DATA) between 'left,'
%   'right,' or 'both.' Default: 'both.' This sets the propery SIDE.
% combine - a string between 'mean,' 'median,' and 'max' which indicates
%   the method used to combine overlapping features. Default: 'mean.'
% bounds - 2-D vector with costumized threshold for DATA. Default is set to
%   []. See also BOUNDS.
% background - boolean value inidicating whether to fill the face
%   background. Default: false.
% smoothing - string with smoothing kernel, or structure with kernel
%   properties. See also SMOOTHING. By default, smoothing is performed
%   using a Gaussian kernel covering a patch of 10^2 pixels, and standard
%   deviation set to 2.5.
% colmap - a string with the name of a colormap, or a K*3 matrix with
%   costume rgb colormap. Default: 'jet.'
% colorbar - boolean indicating whether to include a colorbar. Default:
%   false.
% optlayers - a vector with 1 to 3 components. In order, these components
%   include: overlay transparanecy (between 0.0 and 1.0, default 0.4);
%   muscles transparency (between 0 and 1, default 1.0); and brightness of
%   the overlay (between -1.0 and 1.0, default 0.0).
%
%
% See also UPDATE, TEMPLATE, DATA, BOUNDS, SMOOTHING.

% Determine whether data is present, and which type of variable it is.        
if exist('data','var')
    self.update('data',data);
else
    self.data = [];
end  

% Variabe arguments in: set defaults, insert provided values, and
% use the function "check" to make sure that the arguments are
% properily specified.
args  = struct('template','template_01','side','both',...
    'combine','mean','bounds',[],'background',false,...
    'smoothing',struct('kernel','gaussian','size',10,'param',2.5),...
    'colmap','jet','colbar',false,...
    'optlayers',struct('overlay',.4,'fibers',1,'brightness',0),'fig', []);
fnames = fieldnames(args);
[~,inds] = ismember(fnames,varargin(1:2:end));
for i = 1:length(inds)
    if inds(i) ~= 0
        % Set/Test that arguments are properly specified
        args.(fnames{i}) = varargin{inds(i)*2};
    end
    self.update(fnames{i},args.(fnames{i}));
end

if isempty(self.fig)
% Initialize an handle for the main axes -- This won't be displayed. 
    self.fig = figure('Name','FexView','NumberTitle','off', 'Visible', 'off'); 
%     set(self.fig,'NextPlot','replaceChildren');
end

% Set the Visible flag off/Initialize overlay
self.visible = false;
if ~isempty(self.data)
    ind = find(~isnan(double(self.data(:,1))),1,'first');
    self.makeoverlay(ind);
end

end
        
%**************************************************************************

function self = update(self,varargin)
%
% UPDATE - sets or updates FEXWOVERLAY properties.
%
% SYNTAX:
%
% self.UPDATE('PropName1',PropVal1,...)
%
% The UPDATE method sets overlay arguments. You can update more properties
% at once. The arguments are handled one by one from the internal method
% SETOI. The string 'PropName1' can be any of the properties of
% FEXWOVERLAY.
%
% When you already have an image, this procedure also updates the image.
%
%
% See also FEXWOVERLAY, SETOI, PROPERTIES.

% Handle arguments in
numargs = length(varargin);
if mod(numargs,2) ~= 0
    error('wrong number of arguments in.');
else
    for i = 1:2:length(varargin)
        self.setoi(varargin{i},varargin{i+1});
    end
end

% Select the correct frame
if isa(self.overlaydata,'struct')
    k = self.overlaydata.odn;
else
    k = 1;
end

% Test whether you need to update any image based on existence of
% handles, and based on the type of argument.
if ~isempty(self.fig)
% Change only if there are handles to update
    if ~isempty(intersect(varargin(1:2:end),{'data','template','bounds'}))
    % When you change "data" or "template," you need to recompute
    % the overlay.
        ind = find(~isnan(double(self.data(:,1))),1,'first');
        self.makeoverlay(ind);
        self.show(k,self.visible);
    else
    % For all other properties, you can simply update the image.
        self.show(k,self.visible);
    end
end

end

%**************************************************************************

function self = select(self,arg)
%
% SELECT - select features when FEXC object is entered for DATA.
%
% SYNTAX:
%
% self.SELECT('emotion_name')
% self.SELECT('aus')
% self.SELECT({'au1','au2',...})
%
% ARG can be:
%
% - A string with one of the seven basic emotions;
% - A string with one of the available action units;
% - A string set to 'aus' or 'AUS', which will select all action units;
% - A cell of string with selected action units.
%
%
% See also FEXC, LIST.

% Check that the method can be applied
if isempty(self.fexwc)
    warning('Method SELECT required a FEXC object.');
    return
end

if ischar(arg)
    if ismember(lower(arg),self.list('e'))
    % One emotion is provided
        meta = importdata('fexwmetadata.mat');    
        inds = strcmpi(arg,meta.emoinfo.Properties.VarNames);
        inds = double(meta.emoinfo(:,inds)); 
        inds = inds(inds ~=0);
        inds = strsplit(sprintf(repmat('AU%d\n',[1,length(inds)]),inds'));
        D = self.fexwc.functional(:,inds(1:end-1));
    elseif ismember(lower(arg),self.list('aus'))
    % one action unit
        D = self.fexwc.functional(:,{upper(arg)});
    elseif strcmpi(arg, 'aus')
    % all action units
        D = self.fexwc.functional(:,upper(self.list('aus')));
    end
elseif isa(arg,'cell')
    % List of action units
    D = [];
    for j = 1:length(arg)
        if ismember(lower(arg),self.list('aus'))
            D = cat(2,D,self.fexwc.functional(:,upper(arg(j))));
        else
            warning('Feature %s not recognized.',arg{j});
        end
    end
end
% Update dataset
self.update('data',D);

end

%**************************************************************************

function self = step(self,k)
%
% STEP - advance one frame in the video.
%
% SYNTAX:
%
% frame = self.STEP()
% frame = self.STEP(k)
%
% K is the frame number to which STEP jumps to.

if ~exist('k','var') && ~isfield(self.handles,'overlay')
    self.show(1,self.visible)
elseif ~exist('k','var') && isfield(self.handles,'overlay')
    self.show(self.overlaydata.odn + 1,self.visible);
else
    % Grab relevant values
    X = self.overlaydata.X;
    ColDataIdx = self.overlaydata.ColDataIdx;
    % Reserve space
    dim = self.template.hdr.imsize(1:2);
    OD = nan(dim(1),dim(2),length(X));
    nk = 0; inc_k = numel(OD(:,:,1));
    for i = 1:length(X)
        OD(self.template.hdr.muscles.(X{i}).idx + nk) = ColDataIdx(k,i);    
        nk = nk + inc_k;
    end
    self.overlaydata.odn = k;
    self.overlaydata.OD = OD; 
    set(self.handles.overlay,'CData',imresize(self.formato,'OutputSize',[720,600]));
end

end

%**************************************************************************

function self = makeoverlay(self,imgnum)
%
% MAKEOVERLAY -  Generates overlay data.
%
% SYNTAX:
% 
% self.MAKEOVERLAY()
% self.MAKEOVERLAY(IMGNUM)
%
% When the data provided have multiple rows, each row is assumed to stand
% for an independent image -- for example a different frame. IMGNUM is a
% scalar with indicates which row to use. Default is 1.
%
% MAKEOVERLAY uses the arguments specify with the FEXWOVERLAY constructor
% method or with UPDATE, and it generates data for the overlay. Data for
% the overlay are stored in the private property OVERLAYDATA. This property
% is a structure with fields:
%
% OD - Matrix with overlay data;
% OT - Matrix with fiber texture;
% ColDataIdx - Index of colors;
% basecolor - Rgb base color for the background within the face.
%
%
% See also CONVERTDATA, COLDATAIDX, MASKINGO.

% set image number
if ~exist('imgnum','var')
    imgnum = 1;
end

% Converts self.data into a cell X of muscles names, and a
% vector/matrix Y of statistical values.
[X,Y] = self.ConvertData();
[ColDataIdx,BaseColor] = self.coldataidx(Y,self.typech == 3);

% Generate the Overlay
dim = self.template.hdr.imsize(1:2);
OD = nan(dim(1),dim(2),length(X));         % Space for Overlay data
OT = nan(dim(1),dim(2),length(X));         % Space for Overlay texture information
nk = 0; inc_k = numel(OD(:,:,1));          % Shift across the 3rd dimension
for i = 1:length(X)
    OD(self.template.hdr.muscles.(X{i}).idx + nk) = ColDataIdx(imgnum,i);    
    OT(self.template.hdr.muscles.(X{i}).idx + nk) = self.template.hdr.muscles.(X{i}).texture;
    nk = nk + inc_k;
end

% Store overlay data (this is a private property)
self.overlaydata.X = X;                             % Selected features
self.overlaydata.odn = imgnum;                      % Current image number
self.overlaydata.OD = OD;                           % Overlay data
self.overlaydata.OT = self.maskingo(nanmean(OT,3)); % Fibers data
self.overlaydata.ColDataIdx = ColDataIdx;           % Colormap index
self.overlaydata.basecolor  = BaseColor;            % Base color

end
 
        function [ColDataIdx,BaseColor] = coldataidx(self,Y,repval,bnds)
        %
        % -----------------------------------------------------------------
        %
        % "Y" can be a vector of values, one component per facial
        % expression feature. ALternatively, "Y" can be a matrix: the
        % columns indicate facial expressions features, while the rows
        % indicate a different overlay image (in case you have a
        % time-series of features). If you set "Y" to a 1*K vector of nans,
        % "coldataidx" will generate K equally spaced indices.
        %
        % "repval" its a boolean value (i.e. 1/0, true/false), and it
        % applies to emotions. With emotions, multiple action units,
        % associated with the same value. Default is: false.
        %
        % bnds is a 2 component vector [b1,b2], such that the only features
        % displayed are those associated with values (in "Y") between b1
        % and b2. When you specify bnds, the property "self.bounds" is
        % updated. The default is to use the existing values from
        % "self.bounds."
        %
        % -----------------------------------------------------------------
        %
        
        % Arguments check.
        if nargin == 0
            error('You need to provide "Y."');
        elseif nargin == 1
        % Repeat same value for all features.
            repval = false;
        elseif nargin == 4
        % Update the bounds argument.
            self.bounds = bnds;
        end
        
        % Fexview uses 256-color maps.
        if isa(self.colmap,'char') || isempty(self.colmap)
            ncolors = 256;
        else
            ncolors = size(self.colmap,1);
        end

        % Check whether there are nans in Y (or if Y is enterely composed
        % of nans).
        ytest = reshape(Y,numel(Y),1);

        % Set up bounds when not provided. There are three cases:
        %  (1) +/- values: bounds are set to be symmetric, and base value
        %      is set to first color.
        %  (2) + values: all data are positive,and bounds are set between 0
        %      and the maximum value of the data;
        %  (3) - values: all data are negative, they are convert to
        %      positive, and we use the same procedure as in (2).
        if isempty(self.bounds) || isnan(sum(self.bounds))
            % Make bounds symmetric
            if min(ytest) < 0 && max(ytest) > 0
                % maxVal = max(abs([min(min(ytest),0),max(ytest)]));
                self.bounds = [min(ytest),max(ytest)];
            elseif min(ytest) < 0 && max(ytest) <= 0
            % If all values are negative, we change sign in the process of
            % assigning color index.
                ytest  = abs(ytest);
                self.bounds = [0,max(ytest)];
            elseif min(ytest) >= 0 && max(ytest) >= 0
                self.bounds = [0,max(ytest)];
            end  
        end
        % I DON'T KNOW IF EXCLUDING OUT OF BOUND DATA, OR CAPING THEM IS
        % THE BEST IDEA. FOR NOW I AM EXCLUDING THEM.
        ytest(ytest < self.bounds(1) | ytest > self.bounds(2)) = nan;
        
        % Set the colormap
        if sum(isnan(ytest)) == length(ytest)
        % No data provided, so you generate an equally spaced colormap. In
        % this case, self.bounds are ignored even when provided.
            if repval
                ColDataIdx = repmat(ncolors,[1,size(Y,2)]);
            else
                ColDataIdx = linspace(1,ncolors,size(Y,2));
            end
        else
        % This is the expected case -- when you provided data.   
            YY = linspace(self.bounds(1),self.bounds(2),ncolors);
            ColDataIdx = dsearchn(YY(:),ytest(:)); 
        end
        % Get ColDataIdx matrix
        ColDataIdx = reshape(ColDataIdx,size(Y,1),size(Y,2));
        
        % Set base color information.
        if self.bounds(1) == 0
            BaseColor = 1;
        elseif self.bounds(1) < 0
            BaseColor = round(ncolors/2);
        end
        
        end

%************************************************************************** 

function [self,args] = makemovie(self,varargin)
%
% MAKEMOVIE - generates a movie from data - (only applies to FEXC objects).
%
% SYNTAX:
%
% self.MAKEMOVIE()
% self.MAKEMOVIE('ArgName1',ArgVal1, ...)
%
% Arguments:
% 
% 'name' - name of the resulting file. By default, MAKEMOVIE looks into the
%      FEXC.name field. if the field is empty, FEXC uses the convenction of
%      naming the file 'fxwdd:mm:yy:HH:MM:SS.avi'. Alternatively, you can
%      enter a costume name. All movies are saved as .avi files, so if you
%      enter an extension different from .avi, it is replaced.
% 'interpolate' - a boolean value (default false), which derermine what to
%      do with null observation in the FEXC object. When set to false, the
%      missing frames do not have any overlay. When set to true, all frames
%      are recovered with interpolation. 
% 'cut' - a vector with [time_start, time_end], used to select a
%      subsample of data from FEXC object for display.
% 'quality' - a scalar between 0 and 100, default: 100.
% 'fps' - desired frame per second (by default, this is set to the average
%      frame rate in the video.
%
% The output ARGS is a structure with the parameters used to generate the
% video.
%
% NOTE: CURRENTLY INTERPOLATE AND FPS ARGUMENT ARE IGNORED.
%
%
% See also FEXC, VIDEOWRITER.
    

% MAKEMOVIE can only be apply when FEXWOVERLAY was called with a FEXC
% class for DATA.
if isempty(self.fexwc)
    error('You need to generate FEXWOVERLAY with DATA set to a FEXC object.');
end

% suppress warning
warning('off','images:initSize:adjustingMag');

% Set defaults:
args = struct('name',sprintf('fxw%s.avi',datestr(now,'dd:mm:yy:HH:MM:SS')),...
              'interpolate',false,...
              'cut',[1,size(self.data,1)],...
              'quality',50,...
              'fps',15);

% Read arguments:
fnames = fieldnames(args);
[~,inds] = ismember(fnames,varargin(1:2:end));
for i = 1:length(inds)
    if inds(i) ~= 0
        % Set/Test that arguments are properly specified
        args.(fnames{i}) = varargin{inds(i)*2};
    end
end

% Make sure that cut is properly set
if isinf(args.cut(end))
    args.cut(end) = size(self.data,1);
elseif args.cut(1) < 1 || args.cut(2) > size(self.data,1)
    error('Indices exceed number of frames.');
end


% Initialization of the image
% delete(self.fig);
% self.fig = [];
ind = find(~isnan(double(self.data(:,1))),1,'first');
self.show(ind,false);

% Initialize video writer object
writerObj = VideoWriter(args.name);
writerObj.FrameRate = args.fps;
writerObj.Quality = args.quality;
open(writerObj);

self.step(args.cut(1));
frame = getframe(self.fig);
writeVideo(writerObj,frame);

h = waitbar(0,'Creating Movie');
for k = args.cut(1)+1:args.cut(2)
    % generate image
    self.step(k);
    % self.show(k,false);
    waitbar((k-args.cut(1))/range(args.cut),h);
    % writer component 
    frame = getframe(self.fig);
    writeVideo(writerObj,frame);
end

% Close video writer, delete waitbar
close(writerObj);
delete(h);
% delete(self.fig);
% self.fig = [];
warning('on','images:initSize:adjustingMag');

end
     
%************************************************************************** 

function [self, frame] = show(self,n,vis)
%
% SHOW - display or update overlay image.
%
% SYNTAX:
%
% self.SHOW()
% self.SHOW(n)
% self.SHOW(n,vis)
%
% The method SHOW displays the image. If no image exist, a image is
% generated and the handle os stored in the privare property self.FIG. If
% the data for the overlay need to be generated, SHOW calls the method
% MAKEOVERLAY. The COLMAP argument is used to specify a colormap. The
% COMBINE property is also used by SHOW to combibe overlapping facial
% features. Next, SHOW set the background color, masks the image when
% required, and smooths the overlay. The colorbar argument is also handled
% at this stage.
%
%
% N - a scalar, which indicates with row of DATA should be used. N must be
%   between 1 and size(DATA,1). 
%
% VIS - a truth value which determines whether the image is set to visible
%   or not. Default: true.
%
%
%
% SHOW update the HANDLES property.
%
% See also MAKEOEVERLAY, COMBINE, SETBACKGROUND, SMOOTHING, HANDLES.

frame = [];

% Read optional VIS argument
if ~exist('vis','var')
    vis = true;
end

% Read optional N argument
if ~exist('n','var')
    if ~isempty(self.overlaydata)
        n = self.overlaydata.odn;
    else
        n = 1;
    end
else
    if n < 1 || n > size(self.data,1)
        error('Index out of bound: n = %d, rows of data = %d',n,size(self.data,1));
    end
end

% try
%     axes(self.fig)
% catch
%     self.fig = figure('Name','FexView','NumberTitle','off', 'Visible', 'off'); 
% %     set(self.fig,'NextPlot','replaceChildren');
% end

% 
if isempty(self.fig) || ~isa(self.fig,'handle')
% Initialize handle for the image
    self.fig = figure('Name','FexView','NumberTitle','off', 'Visible', 'off'); 
    set(self.fig,'NextPlot','replaceChildren');
else
    try
        set(self.fig,'Visible', 'off');
        set(self.fig,'NextPlot','replaceChildren');
    catch
        self.fig = figure('Name','FexView','NumberTitle','off', 'Visible', 'off'); 
        set(self.fig,'NextPlot','replaceChildren');
    end
end

% Escape without showing when data are missing
if isnan(double(self.data(n,1)))
    hold on
    self.handles.face = imshow(imresize(rgb2gray(self.template.img),'OutputSize','OutputSize',[720,600]));
    hold off
    if vis
        set(self.fig,'Visible','on');
    end
    return
end
  
% Test whether the overlay exists, and generate one, if required.
if isempty(self.overlaydata)
    self.makeoverlay(n);
end

% Update the OVERLAYDATA.OD in case looping across images
if n ~= self.overlaydata.odn
    X = self.overlaydata.X;
    ColDataIdx = self.overlaydata.ColDataIdx;
    dim = self.template.hdr.imsize(1:2);
    OD = nan(dim(1),dim(2),length(X));
    nk = 0; inc_k = numel(OD(:,:,1));
    for i = 1:length(X)
        OD(self.template.hdr.muscles.(X{i}).idx + nk) = ColDataIdx(n,i);    
        nk = nk + inc_k;
    end
    self.overlaydata.odn = n;
    self.overlaydata.OD = OD; 
end
imo = self.formato();

% Fig. Handle for muscles (use mean value)
self.handles.muscles = imshow(imresize(uint8(self.overlaydata.OT),'OutputSize',[720,600]));

% Colormap
% if ischar(self.colmap)
%     funmap = str2func(self.colmap);
%     map = colormap(funmap(256));
% else
%     map = self.colmap;
% end

% Combine images
% if strcmp(self.combine,'max')
%     funcomb = str2func(sprintf('%s',self.combine));
%     imo = round(funcomb(self.overlaydata.OD,[],3));
% else
%     funcomb = str2func(sprintf('nan%s',self.combine));
%     imo = round(funcomb(self.overlaydata.OD,3));
% end

% Add background image
% if self.background
%     imo = self.setbackground(imo);
% end

% Convert index image to rgb
% imo = ind2rgb(imo,brighten(map,self.optlayers.brightness));

% Smoothing
% switch self.smoothing.kernel
%     case {'gaussian','log','motion'}
%       KK = fspecial(self.smoothing.kernel,self.smoothing.size,self.smoothing.param);  
%     case {'average','disk'}
%       KK = fspecial(self.smoothing.kernel,self.smoothing.size);
%     case 'laplacian'
%       KK = fspecial(self.smoothing.kernel,self.smoothing.param);
%     otherwise
%     % no smoothing
%       KK = 1;
% end

% Apply smoothing & mask to image
% imo = self.maskingo(imfilter(imo,KK));

% Fig. Handles for overlay and background image
hold on
self.handles.overlay = imshow(imresize(imo,'OutputSize',[720,600]));
% Fig. Handles for colorbar
if isa(self.colbar,'struct') && ~isempty(self.bounds)
% You need to freeze the colorbar here. Otherwise it will be
% updated, and won't reflect the overlay colormap. THIS PART OF THE CODE
% NEEDS TO BE UPDATED FOR 2015a.
    cbfreeze('del')
    self.handles.cbar = colorbar;
    optcb = fieldnames(self.colbar);
    for i = 1:length(optcb)
    % Set optional properties for colorbar
        set(self.handles.cbar,optcb{i},self.colbar.(optcb{i}));
    end
    % Add thicks on colorbar:
    set(self.handles.cbar,'XTickLabel',roundn(linspace(self.bounds(1),self.bounds(2),6),-2))
    cbfreeze;
end

% Fig Handle for face image
self.handles.face = imshow(imresize(rgb2gray(self.template.img),'OutputSize',[720,600]));
hold off

% Generate transparency data for overlay
INDS   = ~isnan(nanmean(self.overlaydata.OT,3));
alpha1 = ones(size(INDS,1),size(INDS,2));
alpha1(INDS) = self.optlayers.fibers;
alpha1 = imfilter(imresize(alpha1,'OutputSize',[720,600]),fspecial('disk',5),'replicate');

% Generate transparency data for fibers
if self.background
    INDS = self.template.getmask();
end
alpha2 = ones(size(INDS,1),size(INDS,2));
alpha2(INDS) = self.optlayers.overlay;
alpha2 = imfilter(imresize(alpha2,'OutputSize',[720,600]),fspecial('disk',5),'replicate');

% When needed, show AUs/Emotions on one side only
switch self.side
    case 'right'
       mind = 1:round(size(alpha1,2)/2);
       alpha1(:,mind) = 1;
       alpha2(:,mind) = 1;
    case 'left' 
       mind = round(size(alpha1,2)/2):size(alpha1,2);
       alpha1(:,mind) = 1;
       alpha2(:,mind) = 1;
end

% Set Transparency & visibility
set(self.handles.overlay,'AlphaData',alpha1);
set(self.handles.face,   'AlphaData',alpha2);
if vis
    set(self.fig,'Visible','on');
    self.visible = true;
end

% frame = getframe(self.fig);

end
        
%**************************************************************************         
        
function self = saveo(self,varargin)
%
% SAVEO - saves the image or the overlay data.
%
% SYNTAX: 
%
% self.SAVEO();
% self.SAVEO('ArgName1',ArgVal,...)
%
% By default, SAVEO saves an jpg image of the current axes with 300 dpi,
% and named following the convenction 'dd:mm:yy:HH:MM:SS.jpg'
%
% Optional arguments:
%
% 'format' - a format string between '-dpdf', '-djpeg' (default), '-dpng',
%   '-dtiffn', '-dbmp' to save an image. Alternativly, '-dfxw' saves the
%   FEXWOVERLAY object.
%
% 'dpi' - Number of dots per inch. Default 300. This argument has no effect
%    if 'format' is set to '-dfxw.'
%
% 'name' - name of the file to be saved. By default the file is saved in
%    the current working directory and named following the convenction:
%    'dd:mm:yy:HH:MM:SS'. The extension depend on the argument 'format.'
%
% See also FEXWOVERLAY, PRINT.

% Set defaults and assign varargin arguments.
args = struct('format','-djpeg','dpi',300,'name','');
for i = 1:2:length(varargin)
% Assign variable arguments in.
    if ismember(varargin{i},fieldnames(args));
        args.(varargin{i}) = varargin{i+1};
    end
end    
% Test "name" argument
if isempty(args.name)
    args.name = sprintf('fxwo_%s',datestr(now,'dd:mm:yy:HH:MM:SS'));
end
% Test type & format:
if ismember(args.format,{'-dpdf', '-djpeg','-dpng','-dtiffn','-dbmp'});
% Save the image
    print(self.fig,args.format,sprintf('-r%d',round(args.dpi)),args.name);
else
% Save the overlay object
    save(sprintf('%s.fxw',args.name),'self');
end

end

%************************************************************************** 

function [names,self] = list(self,type)
%
% LITS - makes a list of facaial exepression features.
%
% SYNTAX:
%
% NAMES = self.LIST(TYPE)
%
% TYPE is a string set to 'muscles', 'aus' or 'emo.' The avaailable
% features are lostes in in the cell NAMES.
% 
% If TYPE is empty, all features are listed.
%
% See also FEXWMETADATA.

load('fexwmetadata');
metadata = fexwmetadata;

switch lower(type)
    case {'muscles','m'}
        names = lower(fieldnames(metadata.sourceimg.muscles));
    case {'actionunits','au','aus'}    
        names = lower(metadata.auinfo.Properties.ObsNames);
    case {'emotions','emo','e'}
        names = lower(metadata.emoinfo.Properties.VarNames');
    otherwise
        names = lower(fieldnames(metadata.sourceimg.muscles));
        names = cat(1,names,metadata.auinfo.Properties.ObsNames);
        names = cat(1,names,metadata.emoinfo.Properties.VarNames');
end 
end             

%************************************************************************** 

end

%**************************************************************************
%************************** GETTER FUNCTIONS ******************************
%**************************************************************************

methods        
function H = get.info(self)
%
% get.INFO - provide information on image creation argument.
%
% SYNTAX:
%
% H = self.HEADER()
%
% H is a structure with the private properties not displayed:
%
% template - Name of the FEXWIMG template to be used as template.
% side - Side where DATA is displayed on the template. 
% bounds - Threshold for upper and lower data.
% combine - Method to combine overlapping facial features.
% smoothing - Parameters for 2-D smoothing of overlay.
% colmap - Colormap used by the template.
% colbar - Rule to insert colorbar. 
% background - Rule for filling background within a face.
% optlayers - transparency and brightness of the overlay.
%
% See also FEWOVERLAY, UPDATE.
   
if ~isempty(self.template)
    H.template = self.template.name;
else
    H.template = '';
end

for prop = {'side','bounds','combine','smoothing','colbar','background','optlayers'}
    H.(prop{1}) = self.(prop{1});
end



end

%**************************************************************************

end
    

%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
  
    
methods (Access = private)
%
% Private Methods:
%
% setoi - Helper function to set FEXWOVERLAY properties.
% read_data - Helper function to read DATA argument.
% ConvertData - Converts data to muscle coordinates.
% setbackground - Set the within face background.
% maskingo - applies mask to current image.
    
function self = setoi(self,names,args)
%
% SETOI - Helper function to set FEXWOVERLAY properties.
%
% See also UPDATE.

% Import metadata 
load('fexwmetadata');
meta = fexwmetadata;

% Switch across properties
switch lower(names)
    case 'fig'
        if ~isempty(self.fig)
            delete(self.fig);
        end
        self.fig = args;
    case 'data'
    % Read the data argument.
        self.data = self.read_data(args);            
    case 'template'
    % Manage template selection -- > template can be a path to a
    % template (in case you are entering one that is not between
    % the 12 basic one. Otherwise it refers to a template in the
    % list. Template can also be a fexwimg.
        if isa(args,'fexwimg')
            self.template = args;
        elseif isa(args,'char')
            fun = @(a)sum(strcmp(args,a));
            ind = find(cellfun(fun,meta.templates));
            if isempty(ind)
                ind = 1;
                warning('template: %s was not recognize.',args);
            end
            self.template = importdata(meta.templates{ind}{end});  
        elseif ismember(args,1:12)
            self.template = importdata(meta.templates{args}{end});  
        else
            warning('template option not recognized. Using template 1.');
            self.template = importdata(meta.templates{1}{end});  
        end                    
    case 'combine'
    % Function used to combine information when there are action
    % units overlayed on the same muscles. The options available
    % are: 'mean','median','max.'
        if ismember(args,{'mean','median','max'})
            self.combine = args;
        else
            warning('Combination method "%s" not recognized. Using "mean."',args);
            self.combine = 'mean';
        end
    case 'bounds'
    % This sets up the bounds for color. It is used only if you
    % provide data.
        self.bounds = args;
    case 'background'
        if args
            self.background = true;
        else
            self.background = false;
        end
    case 'side'
    % determine whether you should use only one sided expressions.
    % NOTE THAT THIS SHOULD BE UPDATE,SO THAT YOU CAN SELECTIVELY
    % DECIDE THE SIZE FOR EACH FEATURE.
        self.side = args;
    case 'smoothing'
    % Set up the smoothing structure
        smt = struct('kernel','gaussian','size',10,'param',2.5);
        if isa(args,'char')
            if ismember(lower(args),{'gaussian','log','motion','average','disk','laplacian','none'});
                smt.kernel = lower(args);
            else
                warning('Unrecognized kernel type: %s (using gaussian).',args);
            end
        elseif isa(args,'struct')
            fnames = intersect(fieldnames(args),fieldnames(smt));
            for i = 1:length(fnames)
                smt.(fnames{i}) = args.(fnames{i});
            end
        end
        if ~strcmp(smt.kernel,'gaussian')
        % Only the Gaussian kernell has an extra parameter (i.e. std)
            smt = rmfield(smt,'param');
        end
        % ADD SOME SAFE CHECK HERE !!
        self.smoothing = smt;
    case 'colmap' 
        if ischar(args)
            funmap = str2func(args);
            self.colmap = colormap(funmap(256));
        else
            self.colmap = args;
        end
    case 'colbar'
    % Set info for the colorbar. If set to true, the defaults are
    % used, you can change the colorbar option latter using
    % directly the colorbar habdle.
        if args
            self.colbar.box      = 'on';
            self.colbar.location = 'southoutside';
            self.colbar.fontsize = 12;
        else
            self.colbar = false;
        end                                      
    case 'optlayers'
    % This include transparency info for the overlay (support:
    % [0,1]), for the fibers (support: [0,1]), and brightness of
    % the image (support: [-1,1]).
    defval = [.1,.7,0];
    if isa(args,'double')
    % You can enter a vector with 1 to 3 components -- they will be
    % interpret as: [overlay, fibers, brightness].
        defval(1:length(args)) = args(:)';
    elseif isa(args,'struct')
        fnames = {'overlay','fibers','brightness'};
        for i = 1:length(fnames)
            if ismember(fnames{i},fieldnames(args))
                defval(i) = args.(fnames{i});
            end
        end
    end
    % set "optlayers" arguments.
    self.optlayers = struct('overlay',defval(1),'fibers',defval(2),'brightness',defval(3));
    otherwise
        warning('No option named "%s."',names);
end

end 
        
%**************************************************************************        

function ndata = read_data(self,data)
%
% READ_DATA - reads the data argumnet. Data can be:
%
% 1. A FEXC object;
% 2. A dataset;
% 3. A string or cell array of features names.
%
%    [...] [...]    

% Cast data into dataset >> if it's a char or a cell, meaning that
% you haven't provided actual data, and only selected to display
% channels, the values of each entry is set to nan.
switch class(data)
    case 'dataset'
        ndata = data;
    case 'cell'
        ndata = mat2dataset(nan(1,length(data)),'VarNames',data);
    case 'char'
        ndata = mat2dataset(nan,'VarNames',data);
    case 'fexc'
        self.fexwc = data.clone();
        ndata = self.fexwc.get('au');
    otherwise
        error('"data" argument can be a cell, a char, a FEXC object or a dataset.');
end     
% Determine the type; note:
%
% 1. You can't mix types (e.g. emotions and aus).
% 2. Emotions are combinations of AUs.
% 3. You can display only one emotion at the time.   
vardata  = lower(ndata.Properties.VarNames);
names    = [self.list('m'); self.list('au'); self.list('e')];
% non recognized features
unrecog = setdiff(vardata,names);

% identify type
type = [sum(ismember(vardata,self.list('m'))) ~=0,...
        sum(ismember(vardata,self.list('au')))~=0,...
        sum(ismember(vardata,self.list('e'))) ~=0];

if sum(type) > 1
% Only one type per image
    warning('Types (e.g. emotions and aus),can''t be mixed.');
end
% Get the type to be used
type = find(type,1,'first');
if type == 1
    ind   = ismember(vardata,self.list('m'));
    ndata = ndata(:,ind == 1);
elseif type == 2
    ind = ismember(vardata,self.list('au'));
    ndata = ndata(:,ind == 1);
elseif type == 3
% Here you make sure that there is only one emotion.
    ind = ismember(vardata,self.list('e'));
    ndata = ndata(:,ind == 1);
    if size(ndata,2) > 1
        warning('Emotions are displayed one at the time.');
        ndata = ndata(:,1);
    end
    if strcmpi(ndata.Properties.VarNames,'contempt')
    % Contempt is a sided emotion.
        self.side = 'right';
    end
else
    warning('Data not recognized.');
end
% store image type
self.typech = type;
% Report unrecognized channels;
if ~isempty(unrecog) && ~strcmpi('au26',unrecog);
    warning('Unrecognized features.')
    disp(cell2dataset(unrecog,'VarNames',{'Unrecognized'}));
end

end
            

%**************************************************************************        
        
        function [X,Y] = ConvertData(self)
        %
        % -----------------------------------------------------------------
        %
        % Convert data to X,Y format for image generation
        %
        % -----------------------------------------------------------------

        % Get metatdata
        load('fexwmetadata');
        meta = fexwmetadata;
        
        % Select image data type & convert emotions/aus to muscles        
        if self.typech == 1
        % Muscles visualization
            X = self.data.Properties.VarNames;
            Y = double(self.data);
        elseif self.typech == 2
        % Action Units visualization
            [ind1,ind2] = ismember(meta.auinfo.Properties.ObsNames,self.data.Properties.VarNames);  
            X = meta.auinfo.Muscle(ind1 == 1);
            X = X(ind2(ind1 == 1));
            Y = double(self.data);
        elseif self.typech == 3
        % Emotion (need to expand the emotions here) 
            inds = strcmpi(self.data.Properties.VarNames{1},meta.emoinfo.Properties.VarNames);
            inds = double(meta.emoinfo(:,inds));
            X = meta.auinfo.Muscle(ismember(meta.auinfo.Id,inds));
            Y = repmat(double(self.data),[1,length(X)]);
        else 
            error('Argument "data" was not properly specified.')
        end    
    
    
        end


%************************************************************************** 
        
function nimg = setbackground(self,img)
%
% SETBACKGROUND - Add values for the background of the image.
%
% SYNTAX:
%
% self.SETBACKGROUND(img)
%
% SETBACKGROUND is meant for internal use only.
%
% See also POLY2MASK, FEXWHDR, FEXWDRAWMASKUI.

nimg = img;
try
    dim   = self.template.hdr.imsize(1:2);
    coord = double(self.template.hdr.mask);
    inds  = poly2mask(coord(:,1),coord(:,2),dim(1),dim(2));
    inds  = repmat(inds,[1,1,size(img,3)]);
    nimg(inds == 1 & isnan(img)) = self.overlaydata.basecolor;
catch errorId
    warning(errorId.message);
end


end
        
%************************************************************************** 

function nimg = maskingo(self,img)
%
% MASKINGO - applies mask to current image.
%
% Internal use only.
%
% See also FEXWHDR, POLY2MASK.

nimg = img;
try
    dim   = self.template.hdr.imsize(1:2);
    coord = double(self.template.hdr.mask);
    inds = poly2mask(coord(:,1),coord(:,2),dim(1),dim(2));
    inds = repmat(inds,[1,1,size(img,3)]);
    nimg(inds == 0) = nan;
catch errorId
    warning(errorId.message);
end

end    

%************************************************************************** 

function imo = formato(self)
%
% FORMATO - formats the image according to specified parameters.
%
% INTERNAL use only.
    
% Colormap
if ischar(self.colmap)
    funmap = str2func(self.colmap);
    map = colormap(funmap(256));
else
    map = self.colmap;
end

% Combine images
if strcmp(self.combine,'max')
    funcomb = str2func(sprintf('%s',self.combine));
    imo = round(funcomb(self.overlaydata.OD,[],3));
else
    funcomb = str2func(sprintf('nan%s',self.combine));
    imo = round(funcomb(self.overlaydata.OD,3));
end

% Add background image
if self.background
    imo = self.setbackground(imo);
end

% Convert index image to rgb
imo = ind2rgb(imo,brighten(map,self.optlayers.brightness));
% Smoothing
switch self.smoothing.kernel
    case {'gaussian','log','motion'}
      KK = fspecial(self.smoothing.kernel,self.smoothing.size,self.smoothing.param);  
    case {'average','disk'}
      KK = fspecial(self.smoothing.kernel,self.smoothing.size);
    case 'laplacian'
      KK = fspecial(self.smoothing.kernel,self.smoothing.param);
    otherwise
    % no smoothing
      KK = 1;
end
% Apply smoothing & mask to image
imo = self.maskingo(imfilter(imo,KK));

end

%************************************************************************** 

end

    
end

