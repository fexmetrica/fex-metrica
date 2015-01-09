function [hp,ht,hl] = fexw_pie(data,hand,varargin)
%
% FEXW_PIE - Create pie chart.
%
% SYNTAX:
% 
% FEXW_PIE(data)
% FEXW_PIE(data,hand)
% FEXW_PIE(data,hand,'Arg1Name',Arg1Val,...)
% [hp] = FEXW_PIE(...)
% [hp,ht] = FEXW_PIE(...)
% [hp,ht,hl] = FEXW_PIE(...)
%
% FEXW_PIE wraps MATLAB function to create a pie chart.
%
% ARGUMENTS:
%
% DATA: a vector with values for each slice of the chart. When sum(data)
%   ~=1, the data are normalized.
% HAND: handles of an existing figure whete the pie chart is displayed.
%   When HAND is empty, a new image is generated.
%
% OPTIONAL ARGUMENTS:
%
% COLOR: a matrix of size [length(data),3]. You can use FEX_GETCOLORS to
%   obtain this matrix. When left empty, FEXW_PIE uses equally spaced
%   colors from the colormap 'jet.'
% ALPHA: a sacal between 0 and 1 with face color transparency. Default:
%   0.03.
% STRINGS: A cell with labels for each slice of the pie.
% ISLEGEND: A boolean value. When set to true, the text associated with
%   each slice is used as legend. Default: false.
% EXPAND: A boolean value. When set to true, the slice are separeted.
%   Otherwise, no gap is left between the slices. Default: true.
%
% OUTPUT:
%
% The output includes handles for the patches, i.e. the slices of the  pie
% chart, saved in HP; the handles for the text in HT, and the handles for
% the legend stored in HL (if ISLEGEND==false, this last output is empty).
%
%
% See also FEX_GETCOLORS, PIE.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 09-Jan-2014.



if isempty(nargin)
    error('Not enough input arguments.');
end

numclass = length(data);
args = struct('color',fex_getcolors(numclass),...
              'alpha',0.5,... 
              'text',false,...
              'islegend',false,...
              'expand',true);


% You can provide an handle to append the image. Otherwise a figure is
% created.
if exist('hand','var') && ~isa(hand,'handle')
    varargin = [hand,varargin];
%     hand = figure; hold on
end


% Read optional arguments:
for i = 1:2:length(varargin)
    if ismember(lower(varargin{i}),fieldnames(args))
        args.(lower(varargin{i})) = varargin{i+1};
    else
        warning('Unrecognized argument: %s.',varargin{i});
    end
end


% Handle data (e.g. not all features > 0)
ind = data > 0;

% Expand argument
args.expand = ones(1,sum(ind))*args.expand;

% Text argument
try
    args.text = args.text(ind);
catch errorId
    args.text = '';
    warning(errorId.message);
end

% Color argument
try 
    args.color = args.color(ind,:);
catch errorId
    args.color = fex_getcolors(numclass);
    warning(errorId.message);
end   

% Alpha argumen
if args.alpha <0 || args.alpha > 1
    args.alpha = 0.5;
    warning('Alpha argument out of bound.')
end


% Extract correct handles
% axes(hand);
hs = pie(data(ind),args.expand);
hp = findobj(hs,'Type','Patch'); %hs(1:2:end);
ht = findobj(hs,'Type','Text'); %hs(2:2:end);

% Adjust patch properties
for i = 1:length(hp)
    set(hp(i),'EdgeColor',args.color(i,:),'FaceAlpha',args.alpha,...
        'FaceColor',args.color(i,:));
end

% Adjust text properties
% ex_string = {''};
if args.islegend
    ex_string = cell(length(ht),1);
    for i = 1:length(ht)
        ex_string{i} = get(ht(i),'String');
        set(ht(i),'String','');
    end
    if isempty(args.text)
        args.text = ex_string;
    end
    hl = legend(args.text,'Location','NorthWest');
    set(hl,'box','off')
elseif ~args.islegend && ~isempty(args.text)
    for i = 1:length(ht)
        set(ht(i),'String',args.text{i});
    end
end

if ~exist('hl','var')
    hl = [];
end


end

