function hand = fex_emographs(varargin)
%
% Usage 
% hand = fex_emographs(data)
% hand = fex_emographs('interactive')
% hand = fex_emographs('VarArgName1',VarArgVal1, ... )
%
%
% This function reads cvs files with the Emotient SDK readings or a fexc
% Object, and produces graphs with the timeseries for emotions. If time
% stamps are provided, the timeseries are interpolated to have a fixed fps.
% The time series displayed are all rectified (default lower boubd: -1) and
% shifted to have only positive values. When required, time series can be
% smoothed.
%
% Optional Arguments:
%
% 'data':   This provides the data to be plotted. The argument can be:
%           
%     (1) A string with the path to a .csv, .txt or .mat file. NOTE that
%         .mat files can only contain one (or multiple) fexc objects.
%     (2) A cell of string for paths as described above.
%     (3) A wilde card used to locate the file, e.g.: '/some/dir/*.txt'.
%
%     If you input <data> as first argument, you don't need to preceed it
%     with the argument string identifier 'data,' otherwise you do.


%
% 'type'
% 'fps'
% 'rectification'
% 'features'
% 'smoothing'
% 'output'
% 
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 10/30/14.


if isempty(varargin)
    % lunch the gui
    fprintf('Gui version for arguments');
    args = fexemographsg();
else
    args = handle_VarArg(varargin);
end

if isempty(args.data)
% Error when data are not provided
    error('You need to specify the data to plot (use the UI).');
end


for i = 1:length(args.data)
    fprintf('Creating image %d/%d',i,length(args.data)); 
    ts = tslightpreproc(args,i);
    h  = make_image(ts,args);
    print(h,'-dpdf','-r450',args.output{i});
end



% ------------------- Helper function for time series processing ----------
function ts = tslightpreproc(args,k)
% 
% Apply few preprocessing operation to emotions timeseries

    


% ------------------- Generate the required image image -------------------
function h = make_image(ts,args)
% 
% Create the current image.

% Start new axis (set to non visible)
col = repmat('crgykbm',[1,3]);
time = 1;                               % THIS IS NEEDED !!!!
scrsz = get(0,'ScreenSize');
h = figure('Position',[0 scrsz(4) scrsz(3) scrsz(4)],'Name','Emotions',...
            'NumberTitle','off','Visible','off');
hold on

switch args.type
    case 1
    % Time Series Plot
        % Plot geometry
        plot_cols = 2;
        if length(args.features)< 6
            plot_row = 2 + length(args.features);
            ind_end  = 5 + (length(args.features)-1)*2;
            plot_ind = [5:2:ind_end+mod(ind_end,2);6:2:ind_end+mod(ind_end,2)];
        else
            plot_row = 2 + ceil(length(args.features)/2);
            plot_ind = 5:5+length(args.features)-1;
        end
        % Get boundaries
        yplotmax = max(reshape(ts(:,2:end),1,numel(ts(:,2:end))));
        % Positive/Negative Plot
        subplot(plot_row,plot_cols,1:4),hold on
        yy = repmat(ts(:,1),[1,2]); yy(yy(:,1) > 0,1) = 0; yy(yy(:,2) <=0,2) = 0;
        area(time,yy(:,1),'FaceColor','m','LineWidth',2,'EdgeColor','m')
        area(time,yy(:,2),'FaceColor','b','LineWidth',2,'EdgeColor','b')
        alpha(.4); ylim([min(ts(:,1)),max(ts(:,1))]); xlim([time(1),time(end)])
        x = get(gca,'XTick'); str = fex_strtime(x,'short');
        set(gca,'XTick',x(2:end-1),'XTickLabel',str(2:end-1))
        title('Emotions Profile','fontsize',20)
        set(gca,'box','on','LineWidth',2,'fontsize',18)
        set(gca,'YTick',[-2,2],'YTickLabel',{'Neg.','Pos.'},'fontsize',12)    
        for k = 2:size(ts,2)
            subplot(plot_row,plot_cols,plot_ind(:,k-1)'),hold on    
            area(time,ts(:,k),'FaceColor',col(k-1),'LineWidth',2,'EdgeColor',col(k-1))
            alpha(.4)
            plot(time,ones(length(time),1)+.1,'--k');
            ylim([0,yplotmax]);
            xlim([time(1),time(end)])
            set(gca,'box','on','LineWidth',2,'fontsize',12,'YTickLabel','');
            ylabel(args.features{k-1},'fontsize', 12)
            x   = get(gca,'XTick'); str = fex_strtime(x,'short');
            set(gca,'XTick',x(2:2:end-1),'XTickLabel',str(2:2:end-1))
        end
    case 2
    % Heat map (Only basic emotions included)
        % Interpolate time to 1 second interval (THIS WILL BE A PARAM).
        time2 = (0:1:time(end))';
        YY = interp1(time,ts(:,2:end),time2);
        YYY = [];
        for i = 1:size(YY,2)
        % This should also be parametrized
            YYY = cat(1,YYY,repmat(YY(:,i)',[20,1]));
        end
        % Cast image to uint8 format
        YYY = (255*YYY./max(reshape(YYY,1,numel(YYY))));
        img = imfilter(YYY,fspecial('gaussian',15,3.5),'replicate');
        pcolor(img);
        shading interp, colormap jet,
        % Generate Y Label with emotions names
        y_inc = size(img,1)/size(YY,2);
        y = y_inc-y_inc/2:y_inc:y_inc*size(YY,2);
        set(gca,'fontsize',18,'YTick',y,'YTickLabel',args.features,'box','on','LineWidth',3);
        % Generate X label with time info
        t  = get(gca,'XTick');
        st = fex_strtime(t,'short');
        set(gca,'XTick',t,'XTickLabel',st,'PlotBoxAspectRatio',[1.5,.75,1],'YDir','reverse');
        % Add Title
        title('Emotion Heat Map','fontsize',20);
        % Add colorbar
        h1 = colorbar;
        y1_t = get(h1,'YTick');
        val_y   = unique(reshape(YY,1,numel(YY)));
        val_col = linspace(min(val_y),max(val_y),256)';
        strcol  = {''};
        for k = 2:length(y1_t)-1
            strcol{k-1} = sprintf('%.2f',val_col(y1_t(k)));
        end
        set(h1,'YTick',y1_t(2:end-1),'YTickLabel',strcol,'fontsize',16,'LineWidth',2,'box','on');
    otherwise
        error('Modality not implemented.');
end
        



% ------------------- Helper function for argument reading ----------------
function args = handle_VarArg(argsIn)
% 
% Read variable arguments in.

% Set defaults arguments
feat_names = {'sadness','joy','anger','disgust','fear','surprise'};
args = struct('data','','fps',15,'smoothing',struct('kernel','Gaussian','size',15),...
              'rectification',-1,'features',{feat_names},...
              'type',1,'outdir',pwd);

if mode(length(argsIn),2) == 1
% Check whether data where entered
    args.data = handle_data(argsIn{1});
    argsIn = argsIn(2:end);
end

for i = 1:2:length(argsIn)
% Read other arguments
    if isfield(args,argsIn{i})
        args.(argsIn{i}) = argsIn{i} + 1;
    else
        warning('Unknown argument %s.',argsIn{i});
    end
end

% NEED TO ADD SAFE CHECKS HERE!!!!


% ------------------- Helper function for data argument reading -----------
function data = handle_data(data_in)
% 
% Read data argument

if isa(data_in,'char')
% Test string input
    data = import_string(string);
elseif isa(data_in,'fexc') || isa(data_in,'dataset')
% Import directly fexc objects or dataset objects
    data = data_in;
elseif isa(data_in,'cell')
% Test the content of the cell -- note that all members of the cell should
% be string, each string shoould contain a path to the same kind of object
% (fexc, txt, or csv).
    data = struct('file',[]);
    for i = 1:length(data_in);
        data(i).file = import_string(data_in{i});
    end
end
    
    
 % ------------------- Helper function for file extension checking --------   
function data = import_string(string) 

[~,~,ext] = fileparts(string);
switch ext
    case {'.txt'}
    % Try to import txt dataset
        data = dataset('File',string);
    case {'.cvs'}
    % Try to import csv dataset
        data = dataset('File',string,'Delimiter',',');
    case {'.mat'}
    % This needs to be a fexc object
        data = importdata(string);
        if ~isa(data,'fexc')
            error('".mat" files should contain fexc objects.');
        end
    otherwise
    % Needs to be {.txt,.csv, or .mat}
        error('I didn''t recognize data type.');
end

    
              