function [hp,ht,hl] = fexw_pie(data,hand,varargin)
%
% Wraps the pie function and handles naming, color assignment and
% expansions.
%
% data is a vector and :
%
% -- sum(data) <= 1 --> incomplete pie or full pie
% -- sum(data) > 1  --> normalize
%
% Negative elements in data are set to 0.
%
% hand [optional] is an handle to a figure axis where the pie chart is
% displayed.
%
% Optional arguments are:
%
% >> Color:     [matrix: length(data)*3]
% >> Alpha:     [0-1, (default: 0.3)]
% >> Strings:   [cell]
% >> isLegend:  [true,false, (default: false)]
% >> Expand:    [true,false, (default: true)]



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

end

