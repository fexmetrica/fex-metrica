classdef fexwimg < handle
%
% FEXWIMG - FEXW face image object.
%
%
% FEXWIMG Properties:
%
% name - Name of the .FEXW file.
% img - Image data.
% hdr - FEXWHDR object associated with IMG.
%
% 
% FEXWIMG Methods:
%
% FEXWIMG - Constructor function.
% DRAWMASK - opens a UI that helps to draw a mask of the face.
% GETMASK - returns a matrix of zeros and one with a face mask.
% TEST - show results of FEXWIMG creation.
%
%
% See also FEXWHDR, FEXWOVERLAY, FEXWDRAWMASKUI.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Sep-2014. 


properties
    % Name of the .FEXW file.
    name
    % Image data.
    img
    % FEXWHDR object associated with IMG.
    %
    % See also FEXWHDR.
    hdr
end
        

%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************    

methods
    
function self = fexwimg(varargin)
%
% FEXWIMG - Constructor function.
%
% SYNTAX:
% 
% self.FEXWIMG('ArgName1',ArgVal1,...);
%
% 
% Generates a FEXW image object that can be used by FEXWOVERLAY.
%
% Arguments:
%
% name - A string with the name for the template. When empty, the name follows the
%       syntax fexwtpl-dd:mmm:yy:HH:MM:SS.
% img - multidimensional matrix with the data from the image. When no IMG
%       is provided, the IMG property is set using PATH.
% path - A string with the path to the image used.
% landmarks - A dataset with landmarks.
% muscles - A matrix with muscle information. This will constitute the
%       HDR.MUSCLES field. If not provided, and LANDMARKS are provided,
%       MUSCLES location and texture are computed using texture.
% mask - A dataset with variables names X and Y defyining a k dimensional
%       ellypses. This can also be constructed using the method DRAWMASK.
%
% 
% See also FEXWHDR, FEXWOVERLAY, FEXWDRAWMASKUI.


% Initialize arguments and read varargin
args = struct('name','','img',[],'path','','landmarks',[],'muscles',[],'mask',[]);
fnames = fieldnames(args);
[~,inds] = ismember(fnames,varargin(1:2:end));
for i = 1:length(inds)
    if inds(i) ~= 0
        args.(fnames{i}) = varargin{inds(i)*2};
    end
end

% Set a name for the template (when empty, the name follows the
% syntax fexwtpl-dd:mmm:yy:HH:MM:SS).
self.name = args.name;
if isempty(self.name)
    self.name = sprintf('fexwtpl%s',datestr(now,'-dd:mmm:yy:HH:MM:SS'));
end

% Set img field for template image (you can either enter the image
% directly, or you can indicate the full path to the image).
if isempty(args.img) && ~isempty(args.path)
    self.img = imread(args.path);
elseif isa(args.img,'char')
    args.path = args.img; 
    self.img  = imread(args.img);
else
    self.img = args.img;
end

% This section sets the hdr fileds:
self.hdr = fexwhdr(args);

end
        
% *************************************************************************                    

function self = drawmask(self)
%
% DRAWMASK - open a UI that helps to draw a mask of the face.
%
% SYNTAX:
%
% self.DRAWMASK();
%
% When called, this methods sets the HDR.MASK argument as a 100*2 matrix
% with X and Y coordinates defining a double-elippses mask for the face. 
%
%
% See also FEXWDRAWMASKUI, FEXWHDR.


% use gui to draw a mask
xy = fexwdrawmaskui(self.img);
% convert coordinates to logicals
self.hdr.mask = xy;

end

% *************************************************************************

function IndsMask = getmask(self)
%
% GETMASK - returns a matrix of zeros and one with a face mask.
%
% SYNTAX:
%
% IndsMask = self.GETMASK();
%
% Converts coordinates of a mask specified by the dataset self.hdr.MASK
% into a matrix with same number of rows and columns as IMG.
%
% See also DRAWMASK, FEXWHDR.

IndsMask = [];
try
    dim   = self.hdr.imsize(1:2);
    coord = double(self.hdr.mask);
    IndsMask = poly2mask(coord(:,1),coord(:,2),dim(1),dim(2));
catch errorId
    warning(errorId.message);
end

end
        
% *************************************************************************

function self = test(self,showmarks,musc_names)
%
% TEST - show results of FEXWIMG creation.
%
% SYNTAX:
%
% self.TEST()
% self.TEST(SHOWMARKS)
% self.TEST(SHOWMARKS,MUSC_NAMES)
%
% TEST displaies the identified muscles and landmarks, to assure that
% coregistration and identification of muscles was correctly executed.
% 
% Arguments:
%
% SHOWMARKS - a truth value (default true). When set to true, landmarks are
%     displayed on the current image.
% MUSC_NAMES - a cell with string with names for the muscle of display.
%
% See also GETMASK.

% Set few defaults
showmarksVal = true;
namesVal = fieldnames(self.hdr.muscles);        

% Read arguments: "showmarks"
if exist('showmarks','var')
    showmarksVal = showmarks;
end
% Read arguments: "musc_names"
if exist('musc_names','var')
   if isa(musc_names,'char'), musc_names = {musc_names}; end
   inds = ismember(musc_names,namesVal);
   namesVal = musc_names(inds == 1);
end

% Initialize image
h0 = figure('Name',namesVal{1},'NumberTitle','off', 'Visible', 'on');
xlabel('Press any button to continue','fontsize',18,'fontname','Helvetica')
I1 = rgb2gray(self.img);  %  face image
indsm = self.getmask();   %  mask (this can be empty)

% Layer 1: Muscles
I2 = uint8(zeros(size(I1)));
I2(self.hdr.muscles.(namesVal{1}).idx) = self.hdr.muscles.(namesVal{1}).texture;
h1 = imshow(cat(3,zeros(size(I2,1),size(I2,2),2),I2));

% Layer 2: Face image and transparency
hold on
h2 = imshow(I1);
alpha = zeros(size(I1));
alpha(self.hdr.muscles.(namesVal{1}).idx) = 1;
alpha(indsm == 0) = 0;
set(h2,'AlphaData', 1-.3*(alpha))

% Layer 3: landmarks
if showmarksVal
    fun = @(a) strsplit(sprintf('%.2d\n',a));
    xy = double(self.hdr.landmarks);
    s = fun(1:size(xy,1));
    text(xy(:,1),xy(:,2),s(1:end-1)','fontsize',16,'EdgeColor','m');
end        
hold off
pause;

% Loop across several features
for i = 2:length(namesVal)
    % Create new data
    I2 = uint8(zeros(size(I1)));
    I2(self.hdr.muscles.(namesVal{i}).idx) = self.hdr.muscles.(namesVal{i}).texture;
    alpha = zeros(size(I1));
    alpha(self.hdr.muscles.(namesVal{i}).idx) = 1;
    alpha(indsm == 0) = 0;
    % Refresh data
    set(h1,'CData',cat(3,zeros(size(I2,1),size(I2,2),2),I2));
    set(h2,'AlphaData', 1-.5*(alpha))
    set(h0,'Name',namesVal{i})
    refreshdata 
    pause;
end

delate(h0);

end

% *************************************************************************

end

end

