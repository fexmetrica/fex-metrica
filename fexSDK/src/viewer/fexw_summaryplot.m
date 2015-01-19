function [paths,hands] = fexw_summaryplot(fexobj,varargin)
%
% FEXW_SUMMARYPLOT - displays or save summary plots for FEXC object.
%
% SYNTAX:
%
% hand = FEXW_SUMMARYPLOT(fexobj)
% hand = FEXW_SUMMARYPLOT(fexobj,'Arg1Name',Arg1Val)
%
% Generate a plot with three panels:
%
% 1. Pie chart with distribution of sentiments (currently derived
%    sentiments are used);
% 2. Pie chart with distribution of Emotions -- Note that the distribution
%    is conditional on frames being NOT NEUTRAL.
% 3. Bar graph with Median value per each emotion and 75th quantile.
%
% ARGUMENTS:
%
% THRS: a threshold between 0.00 and 0.99, s.t. only emotions and
%   sentiments larger than THRS are displayed. Default: 0.01.
% COLOR: a string with one of Matlab colormap, which is used to assign
%   colors. Default: 'jet.'
% SAVE: a boolean value. When set to true, the image is saved. Default:
%   false when length(fexobj) == 1, true otherwise.
% SHOW: a boolean value. When set to true, the image is displayed.Default:
%   true when length(fexobj) == 1, false otherwise. 
%
% OUTPUT:
%
% HANDS: handles to the images;
% PATHS: Cell with paths to the saved images.
%
% See also FEXC.DERIVESENTIMENTS, FEXC.DESCRIPTIVES, FEX_GETCOLORS
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 09-Jan-2014.

paths = [];
hands = [];

% Set defaults
args = struct('thrs',0.01,'color','jet','save',true,'show',false,...
       'position',[0,0, 8.27 11.69]);
if nargin == 0
    error('A FEXC object must be provied');
else
    if length(fexobj) == 1
        args.show = true;
        args.save = false;
    end
end

% Read arguments
for i = 1:2:length(varargin)
    if ismember(varargin{i},fieldnames(args))
        args.(varargin{i}) = varargin{i+1};
    else
        warning('Unrecognized argument: %s.',char(varargin{i}));
    end
end

% Set up shared arguments:
c = dataset('File','fexchannels.txt');
emos = deblank(c.Name(ismember(c.Class,{'emo1','emo2'})));
col = fex_getcolors(9,args.color);

% Make the plot here
for k = 1:length(fexobj)
    % Initialize images
    h = figure('Units','inches','Position',args.position,'Visible','off');
    set(h,'Name','Emotions','NumberTitle','off');
    % Gather descriptives statistics
    [D,P] = fexobj(k).descriptives();
    D = double(D(:,emos));
    
    % pie 1 - Sentiments
    h1 = subplot(3,2,[1,3]);
    S   = P.Properties.VarNames(1:3);
    ind = double(P(1,S)) > args.thrs;
    fexw_pie(double(P(1,ind)),h1,'text',S(ind),'isLegend',false);
    t = title('Distribution of Sentiments','fontsize',18);
    set(t,'Position',[0,1.5,1]);

    % pie 2 - Emotions
    h2 = subplot(3,2,[2,4]);
    P   = double(P(:,4:end));
    ind = P > args.thrs;
    % safety-check, when no emotion is above percentage threshold.
    if sum(ind) > 0
        fexw_pie(P(ind),h2,'color',col(ind,:),'text',emos(ind),'isLegend',false);
        t = title('Emotions Activation','fontsize',18);
    else
        hp = pie(1,{''});
        set(hp(1),'FaceColor',[.85,.85,.85],'EdgeColor',[0,0,0])
        t = title('No Active Emotion','fontsize',18,'LineWidth',2);    
    end
    set(t,'Position',[0,1.5,1]);
    
    % Bar Graph
    subplot(3,2,5:6); hold on
    xlab = [1:7,8.25,9.5];
    for j = 1:length(xlab)
        bar(xlab(j),D(3,j),'FaceColor',col(j,:),'basevalue',-1);
        errorbar(xlab(j),D(3,j),0,D(5,j)-D(3,j),'x','LineWidth',2,'Color',col(j,:))
    end
    set(gca,'box','on','linewidth',2,'XTick',xlab,'XTickLabel',emos,'fontsize',12);
    xlim([.5,10.25]);
    ylim([-1,max(1,max(D(3,:)+D(5,:)))]); 
    title('Emotions (Median & 3rd quartile)','fontsize',18);
    ylabel('Log-Evidence','fontsize',14)
    plot(0:10,zeros(1,11),'--k');
    hold off
    
    % Saving the video 
    current_path = '';
    if args.save
        % Get name for the image
        if isempty(fexobj(k).video)
            if isempty(fexobj(k).name)
                name = sprintf('plot_%s',datestr(now,'HHMMSS'));
            else
                name  = fexobj(k).name;
            end
        else
            [~,name] = fileparts(fexobj(k).video);
        end
        % Get path for saved image
        if isempty(fexobj(k).get('dirout'))
            SAVE_TO = pwd;
        else
            SAVE_TO = char(fexobj(k).get('dirout'));
        end
        % Create directory
        if ~exist([SAVE_TO,'/fexwplots'],'dir')
            mkdir([SAVE_TO,'/fexwplots']);
        end
        current_path = sprintf('%s/fexwplots/%s_i',SAVE_TO,name); q=1;
        while exist(sprintf('%s%.3d.pdf',current_path,q),'file')
            q = q + 1;
        end
        current_path = sprintf('%s%.3d.pdf',current_path,q);
        fprintf('Saving image %s ... ',current_path);
        print(h,'-dpdf','-r350',current_path);
        fprintf('\n');    
    end
    
    % Show when asked -- and move one if there are multiple file to
    % display.
    if args.show
        set(h,'Visible','on');
        if length(fexobj) > 1 && k < length(fexobj)
            pause
            if exist('h','var')
                delete(h)
            end
        end
    end
    
    % Add saved string to path
    paths = cat(1,paths,{current_path});
    hands = cat(1,hands,h); 
end
       
if length(paths) == 1
    paths = char(paths);
end
        
        
        
        