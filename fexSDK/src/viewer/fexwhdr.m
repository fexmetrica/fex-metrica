classdef fexwhdr < handle
%
% FEXWHDR - Header for FEXWIMG image object. Internal use only.
%
% This object stores header information about a FEXWIMG information object.
% Note that the header require a FEXWIMG object, and it is called from
% within a FEXWIMG object.
%
% FEXWHDR Properties:
%
% path - string indicating the path to the original image;
% imsize - vector with image size, [Height, Width, Color Channels];
% format - string indicating the format of the image;
% landmarks - dataset with coordinates for face landmarks;
% muscles - structure with coordinates and texture of facial muscles;
% mask - dataset with X and Y data for the perimeter of the face mask.
%
%
% FEXWHDR Methods:
%
% FEXWHDR - constructor for the header (called from FEXWIMG).
%
%
% See also FEXWIMG, FEXWOVERLAY, FEXWDRAWMASKUI.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 19-Sep-2014.  
    
    
    
properties
    % PATH: String with the path to the image from the associated FEXWIMG
    % object.
    path        
    % IMSIZE: Vector with the size of the image from the associated FEXWIMG
    % object. This comprises:
    %
    % - Height;
    % - Width;
    % - NumberOfSamples.
    %
    % See also IMFINFO.
    imsize
    % FORMAT: string with the image format.
    format
    % LANDMARKS: is an instance of class dataset, and it is organized as
    % follow. The property 'VarNames' is {'X', 'Y'}; the property
    % 'ObsNames' is a cell with elements {'eyebrow_left_left',
    % 'eyebrow_left_right', ...}. There is no need to include all the
    % landmarks, but the naming has to follow the convention shown in the
    % figure.
    % 
    % More landmarks points usually guarantee more accurate localization of
    % the muscular fibers. Some of these landmarks can be computed using
    % the Emotient SDK, but at the moment, we didn?t implement an automated
    % procedure.
    landmarks
    % MUSCLES: This property is a structure s.t. each field is named after
    % a muscle. All fields contain two subfields, 'indx' and 'texture.' The
    % field 'indx' is a vector of linear indices with the location of a
    % muscle on the image. The field 'texture' is a vector with the texture
    % of the muscles at each pixel.
    %
    %
    % See also PROCRUSTES.
    muscles
    % MASK: parameters for a double ellipses used to define the location of
    % a mask of the face, or matrix inidicating in and out of face pixels.
    %
    % The property MASK is a dataset, with variable names X and Y. X and Y
    % are coordinates that describe an ellipsis or a double ellipsis, which
    % masks the face in the image. A mask can be defined using a set of six
    % parameters, two for the center of the face, two for the upper and
    % lower major semi-axes, one for the minor semi-axis, and one for the
    % rotation. When upper and lower semi-axes have the same value, the
    % mask is elliptical. Instead, when they have different value, the mask
    % is a double ellipsis.
    %
    % See also FEXWDRAWMASKUI, FEWIMG.DRAWMASK, FEWIMG.GETMASK.
    mask
end
    
properties (Access = private)
    % METADATA: muscles location and landmark list used in the basic
    % template.
    %
    % See also FEXWMETADATA.
    metadata
end
     
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************    

methods
function self = fexwhdr(varargin)
%
% FEXWHDR - creates the FEXWHDR object.
%
% SYNTAX:
%
% self = FEXWHDR('ArgName1', ArgVal1, ...);
% self = FEXWHDR(Arg_Struct);
%
% The argument provided can be specified using the syntax 'ArgName1',
% ArgVal1, ..., or it can be a structure. The field (or 'ArgName' strings)
% are:
%
% path - A string to the image. This field is not required, when 'img' is
%     provided.
% img  - A matrix with the image data.
% landmarks - a dataset with landmarks locations.
% muscles - Specify location and texture of muscles. If not specified, and
%   LANDMARKS are provided, this is directly computed.
% mask - This can be (1) a matrix of the same size of the image, in which
%   case "1" marks pixels in the face, and "nan" or "0" marks out-of-face
%   pixels. Alternatively, (2) mask can be a function handle, defyining a
%   single/double ellipses, which identifies the face in the template.
%
%
% See also SETHDR, FEXWIMG.

% Determine whether varargin is a cell or a structure. If it's a
% cell, it is converted to a structure.
if isstruct(varargin{1})
    varargin = varargin{1};
else
    try
        varargin = cell2struct(varargin(2:2:end)',varargin(1:2:end));
    catch errorID
        warning(errorID.messageID);
        return
    end
end

% Set args structure & read varargin
args = struct('path','','img',[],'landmarks',[],'muscles',[],'mask',[]);
fnames = fieldnames(varargin);
for i = 1:length(fnames)
    if isfield(args,fnames{i})
        args.(fnames{i}) = varargin.(fnames{i});
    end
end

% Get size information about the image (the self.path substitution
% makes sure that you have an absolute path).
self.path = args.path;
if ~isempty(args.path)
    info = imfinfo(self.path);
    self.path   = info.Filename;
    self.imsize = [info.Height,info.Width,info.NumberOfSamples];
else
% if image is empty, this will be [0,0]
    self.imsize = size(args.img);
end

% Set metadata (private)
load('fexwmetadata');
self.metadata = fexwmetadata;

% Get/Set other information private methods: "setlandmarks,"
% "setmuscles," and "setmask."
self.sethdr('landmarks',args.landmarks);
self.sethdr('muscles',args.muscles);
self.sethdr('mask',args.mask);

end

%**************************************************************************

end

%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************

methods (Access = private)
    
function self = sethdr(self,type,arg)
%
% SETHDR reads FEXWHDR arguments.
%            
% See also LANDMARKS, MUSCLES, MASK.

switch type
    case 'landmarks'
    % Specify the landmarks on the template.
        if nargin == 1
            warning('No landmarks provided.');
            self.landmarks = [];
        else
            if strcmp(arg,'ui')
                warning('Sorry, no gui implemented yet.');
            else
            % Add some testing here
                self.landmarks = arg;
            end
        end
    case 'muscles'
    % Specify location/texture on muscles: this uses procrustes
    % analysis and needs landmarks to be already specified.
        if isempty(self.landmarks)
            warning('I need landmarks in order to define the muscles');
            self.muscles = [];
        else
            if isempty(arg)
                sourcel = self.metadata.sourceimg.landmarks.Properties.ObsNames;
                X       = double(self.metadata.sourceimg.landmarks);
                imgl    = self.landmarks.Properties.ObsNames;
                [~,ind] = ismember(imgl,sourcel);
                [~,~,t] = procrustes(double(self.landmarks),X(ind,:));
                names   = fieldnames(self.metadata.sourceimg.muscles);
                dim     = self.imsize([1,2]);

                for imsc = 1:length(names)
                % Convert the muscles coordinates (and exclude illegal coordinates)
                    [Y_0,X_0] = ind2sub(X(end,[2,1]),self.metadata.sourceimg.muscles.(names{imsc}).idx);
                    mapidx = ceil(t.b*[X_0,Y_0]*t.T + repmat(t.c(1,:),[length(self.metadata.sourceimg.muscles.(names{imsc}).idx),1]));
                    ind1 = mapidx(:,1)>=1 & mapidx(:,2)>=1;
                    ind2 = mapidx(:,1)<=dim(2) & mapidx(:,2)<=dim(1);
                    mapidx = mapidx(ind1 == 1  & ind2 == 1,:);
                    self.muscles.(names{imsc}).idx = sub2ind(dim, mapidx(:,2), mapidx(:,1));
                    self.muscles.(names{imsc}).texture = self.metadata.sourceimg.muscles.(names{imsc}).texture(ind1 == 1 & ind2 == 1,:);
                end                                                   
            else
            % Add some testing here
                self.muscles = arg;
            end
        end
    case 'mask'
    % This can be (1) a matrix of the same size of the image, in
    % which case "1" marks pixels in the face, and "nan" or "0"
    % marks out-of-face pixels. Alternatively, (2) mask can be a function
    % handle, defyining a single/double ellipses, which identifies
    % the face in the template.
        if strcmp(arg,'ui')
            warning('Sorry, no gui implemented yet.');
            self.mask = [];
        else
        % set mask
            self.mask = arg;
        end
    otherwise
        error('Unknow property %s.',type);
end

end

%**************************************************************************
%**************************************************************************        

end
     
end

