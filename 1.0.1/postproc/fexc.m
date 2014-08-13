classdef fexc < handle
%
% FexObj = fexc('data', datafile);
% FexObj = fexc('data', datafile, 'ArgNam1',ArgVal1,...);
% FexObj = fexc(PpObj,'ArgNam1',ArgVal1,...)
%
% "fexc" creates a fex object for the postprocessing of a video.
%
% INITIALIZATION ---------------------------------------------------------|
%
%   ************************** Method 1 ***********************************
%
%   You can either call fexc and manually indicate arguments using
%   the combination 'ArgName1', 'ArgVal1'.
%
% > 'data' is the only MANDATORY argument, and it provides the results of
%   the analysis with the Emotient SDK. 'data' can be:
%
%       1. The path to a file;
%       2. A dataset;
%       3. A structure with fields "data", and "colheaders."
%
%   In any cases, the text information (the column header) must mach the
%   naming used by fexppc.m.
%
% > 'TimeStamps' is a HIGHLY RECCOMENDED argument to specify when creating
%   the fexc object, although it is not required. You have several options.
%
%       1. 'TimeStamp' may be a vector or dataset with one entry per frame,
%           indicating when each frame was collected.
%       2. 'TimeStamp' can be a number indicating how many frame were
%           collected per second (assuming that the framerate was constant).
%       3. 'TimeStamp' can be a string which indicates the name of variable
%           (i.e. column header) in 'data' which contain timestamps
%           (assuming that there is such column -- which is not produced by
%           the fexppc object.
%
%  If you don't specify this argument, it will be left empty.
%
%  Additional optional parameters that can be used during initialization
%  are:
%
%  > 'video': the path to the media file processed with the Emotient SDK.
%
%  > 'videoInfo': a vector with information about 'video', s.t.:
%
%        videoInfo(1) = FrameRate
%        videoInfo(2) = Duration
%        videoInfo(3) = NumberOfFrames
%        videoInfo(4) = Width
%        videoInfo(5) = Height.
%
%  > 'baseline':  ... ... ... 
%
%  > 'outdir': the path to a directory where the fexObj will be saved.
%
%
%  ************************** Method 2 ***********************************
%
%  This method is similar to the previous one, but the first argument to
%  fexc() is a fexppoc object. This will take care of 'video,' 'videoInfo'
%  (if included in the fexppoc object), and 'data.'
%
%  The remaining arguments -- ESPECIALLY 'TimeStamps' -- need to be
%  specified using the 'ArgName1', 'ArgValue1' ... logic explain above.
%
%
% METHODS ----------------------------------------------------------------|
%
%
%
%
%
%
%
%
%
%
%
%
%
%
%
% -------------------------------------------------------------------------
%
% "fexc" needs the functions in the "postproc" folder.
%
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 08/01/14.

%**************************************************************************
%**************************************************************************
%************************** PROPERTIES ************************************
%**************************************************************************
%**************************************************************************


    % Public properties
    properties
        % absolut path to video file
        video
        % Information about the video
        videoInfo
        % outpu directory for facet file
        outdir
        % dataset with data
        functional
        % dataset with structural info
        structural
        % dataset with time information
        time
        % coregistration parameters
        coregparam
        % nullobservation info
        naninfo
        % dataset with design info
%         design
        % baseline
        baseline
    end
    
    
    properties (Access = protected)
        % preprocess description/original dataset
        history
        % temporal filter kernel
        tempkernel
    end


%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

    methods
        function self = fexc(varargin)
        %
        % -----------------------------------------------------------------
        %
        % Initialization function for the class fexc. Type >> "help fexc"
        % for detailed instructions.
        % 
        % -----------------------------------------------------------------
        %
        
        % Create empty fex object (??)
        if isempty(varargin)
            varargin = {'video','','videoInfo',[],'data',''};
            warning('Creating empty fexc object.')
        end

        % function to handle "varargin"
        readarg = @(arg)find(strcmp(varargin,arg));

        % Test whether the first argument is fexppoc object and import
        % accordingly:
        if isa(varargin{1},'fexppoc')
            % Add file information and fexfacet history
            self.video = varargin{1}.video;
            self.videoInfo = varargin{1}.videoInfo;
            temp = importdata(varargin{1}.facetfile);
        else
            % Grab information from varargin
            list = {'video','videoInfo'};
            ind = cellfun(readarg,list,'UniformOutput',false);
            for i = 1:length(ind)
                if ~isempty(ind{i})
                    self.(list{i}) = varargin{ind{i}+1};
                else
                    self.(list{i}) = '';
                end
            end       
            % Import the dataset                
            try 
                ind = find(strcmp(varargin,'data'));
                if isa(varargin{ind+1},'dataset')
                    temp.data = double(varargin{ind+1});
                    temp.textdata = varargin{ind+1}.Properties.VarNames;
                elseif isa(varargin{ind+1},'char')
                    temp = importdata(varargin{ind+1});
                elseif isa(varargin{ind+1},'double')
                    error('Dataset must contain a column header.');
                end
            catch errorId
                % You didn't provide a dataset
                warning('No fexfacet file provided: %s.\n',errorId.message);
                temp.textdata = {'FrameNumber'};
                temp.data     = nan;
            end
        end

        % Add file data: Note that the heaeder needs to have the name
        % given by the fexfacet code (load a structure named 'hdrs')
        load('fexheaders.mat');
        if isfield(temp,'textdata');
            if ~iscell(temp.textdata)
                thdr = strsplit(temp.textdata{1});
            else
               thdr = temp.textdata;
            end
        else
          thdr = temp.colheaders(1,:);
        end

        % Add frames numbers & timestamps if provided (this get's added latter)
        self.time = [temp.data(:,ismember('FrameNumber',thdr)),nan(length(temp.data),1)];
        self.time = mat2dataset(self.time,'VarNames',{'FrameNumber','TimeStamps'});
        indts = find(strcmp(varargin,'TimeStamps'));
        if ~isempty(indts)
            t = varargin{indts+1};
            if length(t) == 1
                n = length(self.time.TimeStamps);
                t = linspace(1/t,n/t,n)';
            end
            self.time.TimeStamps = t;
            self.time(:,{'StrTime'}) = ...
                mat2dataset(fex_strtime(self.time.TimeStamps));
        else
            warning('No TimeStamps provided.');
        end

        % Add structural image information
        [~,ind] = ismember(hdrs.structural,thdr);
        if ~sum(ind)==0
            self.structural = mat2dataset(temp.data(:,ind),'VarNames',thdr(ind));
        else
            % Set an empty structural properties
            self.structural = [];
        end

        % Add functional image information
        [~,ind] = ismember(hdrs.functional,thdr);
        if ~sum(ind)==0
            self.functional = mat2dataset(temp.data(:,ind),'VarNames',thdr(ind));
        else
            % Set an empty dataset for functional when needed
            self.functional = [];    
        end

        
        % THIS NEEDS TO BE DELETED ====================
%         
%         % Add design information when provided as dataset
%         ind = find(strcmp(varargin,'design'));
%         if ~isempty(ind) && isa(varargin{ind+1},'dataset')
%             self.design = varargin{ind+1};
%         elseif ~isempty(ind) && ~isa(varargin{ind+1},'dataset')
%             % Add an header
%             vnames = {'Var01'};
%             for ivd = 2:size(varargin{ind+1},2)
%                 vnames = cat(2,vnames,sprintf('Var%.2d',ivd));
%             end
%             self.design = mat2dataset(varargin{ind+1},'VarNames',vnames);
%         else
%             self.design = [];
%         end

        % Add naninfo & Coregistration parameters
        self.naninfo = mat2dataset(zeros(size(self.functional,1),3),'VarNames',{'count','tag','falsepositive'});
        self.coregparam = [];

        % Add output matrix 
        ind = find(strcmp(varargin,'outdir'));
        if ~isempty(ind)
            self.outdir = varargin{ind+1};
        end

        % Add baseline information
        % BASELINE ADDED HERE
        
        % Initialize history
        self.history.original = [self.time,self.structural,self.functional];  

        end

% *************************************************************************
% *************************************************************************              

        
        function self = reinitialize(self,flag)
        %
        % -----------------------------------------------------------------  
        % 
        % Reinitialize fexObj. When flag is set to 'force', fexc object is
        % reset to the original data and info without warning. If flag is
        % missing, reinitialize asks for confirmation before executing the
        % comand.
        % 
        % -----------------------------------------------------------------   
        %
        if ~exists('flag','var')
            flag = 'coward';
        elseif ~ismember(flag,{'coward','force'})
            warning('I don''t know whar flag = %s means.',flag);
            warning('Cowardly exiting without actions.');
            return
        end

        % Safe check
        if strcmp(flag,'coward')
            result = input('Do you really want to revert to original [y/n]?');
            if ~strcmp(result,'y')
                fprintf('''reinitialize'' operation aborted.\n');
                return
            end
        end

        % Actual re-initialization
        load('fexheaders.mat');
        thdr = self.history.original.Properties.VarNames;
        [~,ind] = ismember(hdrs.functional,thdr);
        self.functional = self.history.original(:,ind);
        [~,ind] = ismember(hdrs.structural,thdr);
        self.structural = self.history.original(:,ind);
        self.coregparam = [];
        [~,ind] = ismember(hdrs.structural,{'FrameNumber','TimeStamps','StrTime'});
        self.time = self.history.original(:,ind);
        self.naninfo = mat2dataset(zeros(size(self.functional,1),3),...
            'VarNames',{'count','tag','falsepositive'});     
        end

% *************************************************************************
% *************************************************************************              

        function self = setbaseline(self,bzln)
        %
        % -----------------------------------------------------------------  
        % 
        %   "bzln" can be: 
        %   1. Another file;
        %   2. Indices on existing self.functional;
        %   3. Another PpObj;
        %   4. dataset.
        % 
        % ----------------------------------------------------------------- 
        %                
        switch class(bzln)
            case 'fexppoc'
                try
                    XX = dataset('File',bzln.facetfile);
                    [~,ind] = ismember(self.functional.Properties.VarNames,XX.Properties.VarNames);
                    XX = double(XX(:,ind));
                catch
                    XX = [];
                end
            case 'char'
                XX = dataset('File',bzln);
                [~,ind] = ismember(self.functional.Properties.VarNames,XX.Properties.VarNames);
                XX = double(XX(:,ind));
            case 'double'
                if min(size(bzln)) == 1
                    XX = double(self.functional(bzln,:));
                else
                    XX = bzln;
                end
            case 'dataset'
                [~,ind] = ismember(self.functional.Properties.VarNames,bxln.Properties.VarNames);
                XX = double(bzln(:,ind));
            otherwise
                warning('Couldn''t set baseline.');
                XX =  [];
        end
        self.baseline = XX;
        end

% *************************************************************************              
% *************************************************************************  

        function self = getvideoInfo(self)
        %
        % -----------------------------------------------------------------  
        % 
        % Gather video information: FrameRate; Duration; NumberOfFrames;
        % Width; Height. Note: not all video formats are supported by
        % Matlab VideoReader object.
        % 
        % ----------------------------------------------------------------- 
        %
        try
            vidObj = VideoReader(self.video);
            self.videoInfo = [vidObj.FrameRate,vidObj.Duration,...
                              vidObj.NumberOfFrames,...
                              vidObj.Width,vidObj.Height];
        catch errorID
            warning(errorID.message);
        end

        end

% *************************************************************************              
% *************************************************************************              

        function self = coregister(self,varargin)
        %
        % -----------------------------------------------------------------
        % 
        % Coregistration to the average face structural image. 
        %
        % Type > help fex_reallign for more information.
        % 
        % -----------------------------------------------------------------
        %

        % Handle optional arguments
        args = struct('steps',1,'scaling',true,...
                      'reflection',false,...
                      'threshold',3.5,'fp',false);            
        for i = 1:2:length(varargin)
            args.(varargin{i}) = varargin{i+1};
        end                                  
        % Run reallignment
        [~,P,~,R] = fex_reallign(self.structural,args);
        if args.fp
            % Exclude false positives
            VarNames = self.functional.Properties.VarNames;
            idx = nan(sum(R>=args.threshold),length(VarNames));
            self.functional(R>=args.threshold,:) = mat2dataset(idx,'VarNames',VarNames);
            self.naninfo.falsepositive = (R>=args.threshold);
        end
        self.coregparam = [R,P];
        if size(P,2) == 7;
           vname = {'ER','B','T1','T2','T3','T4','C1','C2'};
        else
           vname = {'ER','B','T1','T2','T3','T4',...
                    'T5','T6','T7','T8','T9','C1','C2','C3'};
        end
        self.coregparam = mat2dataset([R,P],'VarNames',vname);

        end


        function self = falsepositive(self,varargin)
        %
        % ---------------------------------------------------------------------  
        % 
        % .... 
        % 
        % --------------------------------------------------------------------- 
        %
        args = struct('method','size','threshold',3.5,'param',[]);
        for i = 1:2:length(varargin)
            if isfield(args,varargin{i});
                args.(varargin{i}) = varargin{i+1};
            end
        end
        if ~ismember(args.method,{'coreg','size','pca','kalman'});
            warning('Wrong method specified.')
            args.method = 'size';
        elseif ismember(args.method,{'pca','kalman'});
            warning('Method %s is not implemented yet.',args.method);
            args.method = 'size';
        end

        idx = zeros(length(self.structural.FaceBoxW),1);
        switch args.method
            case 'size'
                z = zscore(self.structural.FaceBoxW(~isnan(self.structural.FaceBoxW)).^2);
                idx(~isnan(self.structural.FaceBoxW)) = abs(z)>=args.threshold;                    
            case 'coreg'
                if isempty(self.coregparam)
                    self.coregister();
                end
                idx = self.coregparam.ER >= args.threshold; 
        end
        self.naninfo.falsepositive = idx;
        X = double(self.functional);
        X(repmat(idx,[1,size(X,2)])==1) = nan;
        self.functional = replacedata(self.functional,X);
        end

% *************************************************************************              
% *************************************************************************   
        
        function self = interpolate(self,varargin)
        %
        % -----------------------------------------------------------------  
        % 
        % .... 
        % 
        % -----------------------------------------------------------------
        %
        
        ind = find(strcmp(varargin,'rule'));
        if ~isempty(ind)
            arg.rule = varargin{ind +1};
        else
            arg.rule = Inf;
        end
        ind = find(strcmp(varargin,'fps'));
        if ~isempty(ind)
            arg.fps = varargin{ind +1};
        else
            arg.fps = 15;
        end
        
        % Interpolate
        [ndata,ntsp,nfr,nan_info] = ...
            fex_interpolate(self.functional,self.time.TimeStamps,...
            arg.fps,arg.rule);

        % Update functional and structural data
        self.structural = self.structural(nfr,:);
        self.functional = mat2dataset(ndata,'VarNames',...
            self.functional.Properties.VarNames);

        % Update timestamp information
        self.time = self.time(nfr,:);
        self.time(:,{'OldTime'}) = mat2dataset(self.time.TimeStamps);
        self.time.TimeStamps = ntsp;
        self.time.StrTime = fex_strtime(self.time.TimeStamps);

        % Update naninformation
        self.naninfo = mat2dataset(...
            [nan_info,self.naninfo.falsepositive(nfr)],...
            'VarNames',{'count','tag','falsepositive'});

        % Update coregparam if they exists
        if ~isempty(self.coregparam)
            self.coregparam = self.coregparam(nfr,:);
        end

        % Updare history
        self.history.interpolate = [self.time,self.naninfo,self.functional];  
        end
        
% *************************************************************************              
% *************************************************************************                  
        
        function self = temporalfilt(self,param,varargin)
        %
        % -----------------------------------------------------------------  
        % 
        % .... 
        % 
        % -----------------------------------------------------------------
        %
        
        % Make sure that parameters of the filter are provided
        if ~exist('param','var')
            error('You need to specify the filter shape.');
        elseif ~ismember(length(param),2:3)
            error('Filter shape can have eiter 2 or 3 components.');
        end
        args.param = param;
        
        % set filter order
        ind = find(strcmp('order',varargin));
        if ~isempty(ind)
            if varargin{ind+1} > floor((size(self.functional,1)-1)/3);
                warning('The filter order is to high.')
                args.order = floor((size(self.functional,1)-1)/3);
            elseif varargin{ind+1} < round(param(end)/param(1));
                warning('The filter must include at least a cycle of the lower frequency.')
                args.order = round(param(end)/param(1));
            else
               args.order =  varargin{ind+1};
            end
        else            
            args.order = round(4*param(end)/param(1));
            if args.order > floor((size(self.functional,1)-1)/3);
               args.order = floor((size(self.functional,1)-1)/3);
            end
        end
        
        % test whether parameters for order and type were provided:
        ind = find(strcmp('type',varargin));
        if ~isempty(ind)
            if strcmp(varargin{ind+1},'lp') && length(param) == 3
               args.type = 'lp';
               args.param = param([1,3]);
            elseif strcmp(varargin{ind+1},'hp') && length(param) == 3
               args.type = 'hp';
               args.param = param(2:3);
            elseif strcmp(varargin{ind+1},'bp') && length(param) == 2
               args.type = 'bp';
               args.param = [param(1),param(2)/2,param(2)];
            else
               args.type = varargin{ind+1};
            end
        else
            if length(param) == 2
                args.type = 'hp';
            else
                args.type = 'bp';
            end
        end

        % apply the filter
        [ts,kr] = fex_bandpass(double(self.functional),args.param,...
                               'order',args.order,...
                               'type',args.type);
        % Determine action
        ind = find(strcmp('action',varargin));
        if isempty(ind)
             args.action = 'apply';
        else
            args.action  = varargin{ind+1}; 
        end
        
        if strcmp(args.action,'inspect')
        % plot the filter shape, and the filter amplitude spectrum before
        % applying it.
            scrsz = get(0,'ScreenSize');
            figure('Position',[1 scrsz(4) scrsz(3)/1.5 scrsz(4)/1.5],...
                'Name','Temporal Filter','NumberTitle','off'); 
            subplot(2,2,1:2),hold on, box on
            x = (1:length(kr.kernel))./(1/param(end));
            x = (x-mean(x))';
            plot(x,kr.kernel,'--b','LineWidth',2);
            set(gca,'fontsize',14,'fontname','Helvetica');
            xlabel('time','fontsize',14,'fontname','Helvetica');
            title('Filter Shape','fontsize',18,'fontname','Helvetica');
            xlim([min(x),max(x)]);

            subplot(2,2,3),hold on, box on
            plot(kr.amplitude(:,1),kr.amplitude(:,2)./max(kr.amplitude(:,2)),'m','LineWidth',2);
            xlim([0,ceil(param(end)/2)]); ylim([0,1.2]);
            title('Filter Spectrum','fontsize',18,'fontname','Helvetica');
            xlabel('Frequency','fontsize',14,'fontname','Helvetica');
            ylabel('Amplitude','fontsize',14,'fontname','Helvetica');       
        else
        % update variables
            self.functional = mat2dataset(ts.real,'VarNames',self.functional.Properties.VarNames);
            self.tempkernel = kr;
        % Updare history
            self.history.temporal = [self.time,self.naninfo,self.functional];
        end

        end
        
        
% *************************************************************************
% *************************************************************************  


        function self = normalize(self)
            fprintf('something');
        end

        function self = downsample(self)
            fprintf('something');
        end
        
        function self = kernel(self)
            fprintf('something');
        end
        
        function self = morlet(self)
            fprintf('something');
        end

        
        function [self,h] = showpreproc(self,varargin)
        % Make an image of the preprocessing steps.    
        
        % Handle opptional arguments
        args.Visible = 'on';
        args.feature = 'anger';
        args.name    = '';
        args.sample  = 1;  % sampling in seconds
        names  = fieldnames(args);
        for i = 1:length(names)
            ind = find(strcmp(names{i},varargin));
            if ~isempty(ind)
                args.(names{i}) = varargin{ind+1};
            end
        end
        sr    = round(1/mode(diff(self.time.TimeStamps)));
        smp   = args.sample;
        steps = fieldnames(self.history);
        scrsz = get(0,'ScreenSize');
        
        titlefig = sprintf('Preprocessing (%s%s)',upper(args.feature(1)),args.feature(2:end));
        h = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.5 scrsz(4)],...
        'Name',titlefig,'NumberTitle','off', 'Visible',args.Visible);
    
        % Original image and false positive
        temp = [self.history.original.TimeStamps,...
                self.history.original.(args.feature)];
        temp(:,1) = temp(:,1) - temp(1,1);
            
        subplot(3,4,1:3), hold on, box on
        set(gca,'fontsize',12,'LineWidth',2);
        plot(temp(1:smp:end,1),temp(1:smp:end,2),'k','LineWidth',1)
        title('Original Signal','fontname','Helvetica','fontsize',16);
        xlim([0,temp(end,1)]);
        [~,fp] = unique(self.time.FrameNumber);
        fp = self.naninfo.falsepositive(fp);
        temp(repmat(fp ~= 1,[1,2])) = nan;
        plot(temp(1:smp:end,1),temp(1:smp:end,2),'m','LineWidth',2)
        ylabel(sprintf('Signal: %s',args.feature),'fontname','Helvetica','fontsize',14)
%         legend({args.feature,'FalsePositive'},'fontname','Helvetica','fontsize',12);
        
        if ismember('interpolate',steps);
            temp = [self.history.interpolate.TimeStamps,...
                self.history.interpolate.(args.feature)];
            nanind = self.naninfo.count;
            temp(:,1) = temp(:,1) - temp(1,1);

            % Interpolated Signal Plot
            subplot(3,4,5:7), hold on, box on
            set(gca,'fontsize',12,'LineWidth',2);
            temp1 = temp; temp1(repmat(nanind > 0,[1,2])) = nan;
            temp2 = temp; temp2(repmat(nanind < 1,[1,2])) = nan;
            plot(temp1(1:smp:end,1),temp1(1:smp:end,2),'k','LineWidth',1);
            plot(temp2(1:smp:end,1),temp2(1:smp:end,2),'m','LineWidth',2);
            title('Intepolated Signal','fontname','Helvetica','fontsize',16);
            ylabel(sprintf('Signal: %s',args.feature),'fontname','Helvetica','fontsize',14)
            xlim([0,temp(end,1)]);

            % Signal Frequency
            subplot(3,4,8),hold on, box on
            set(gca,'fontsize',12,'LineWidth',2);
            f  = fft(temp(:,2))./length(temp);
            hz = linspace(0,sr/2,1+floor(length(f)/2)+mod(length(f),2));
            f = abs(f(1:length(hz)))'*2.*hz;
            f = f./max(f);
            bar(hz,f,'k')
            xlim([0,sr/2])
            title('Amp.Spectrum','fontname','Helvetica','fontsize',14);
            xlabel('Frequency (Hz.)','fontname','Helvetica','fontsize',14);
        end
            
        if ismember('temporal',steps);   
            temp = [self.history.temporal.TimeStamps,...
                self.history.temporal.(args.feature)];
            nanind = self.naninfo.count;
            temp(:,1) = temp(:,1) - temp(1,1);

            % Plot signal filtered
            subplot(3,4,9:11), hold on, box on
            set(gca,'fontsize',12,'LineWidth',2);
            temp1 = temp; temp1(repmat(nanind > 0,[1,2])) = nan;
            temp2 = temp; temp2(repmat(nanind < 1,[1,2])) = nan;           
            plot(temp1(1:smp:end,1),temp1(1:smp:end,2),'k','LineWidth',1);
            plot(temp2(1:smp:end,1),temp2(1:smp:end,2),'m','LineWidth',2);
            title('Filtered Signal','fontname','Helvetica','fontsize',16);
            ylabel(sprintf('Signal: %s',args.feature),'fontname','Helvetica','fontsize',14)
            xlabel('Time (s)','fontname','Helvetica','fontsize',14);
            xlim([0,temp(end,1)]);
            
            % Filter kernel
            subplot(3,4,12),hold on, box on
            set(gca,'fontsize',12,'LineWidth',2);
            kr = self.tempkernel.amplitude;
            plot(kr(:,1),kr(:,2)./max(kr(:,2)),'m','LineWidth',2);
            xlim([-.1,sr/2]); ylim([0,1.1]);
            title('Filter Spectrum','fontsize',14,'fontname','Helvetica');
            xlabel('Frequency','fontsize',14,'fontname','Helvetica');
            ylabel('Amplitude','fontsize',14,'fontname','Helvetica'); 
        end
        end        

        
        function drawface(self,varargin)
            % save image with facebox draw on it
            % test whether you have a video            
            if isempty(self.video)
                [FileName,PathName] = uigetfile('*','DialogTitle','FexSelect');
                self.video = sprintf('%s%s',PathName,FileName);
            end
            try
                vidObj = VideoReader(self.video);
            catch errorID
                warning(errorID.message);
                return
            end
            % Select the frame to display
            ind = find(strcmp(varargin,'frames'));
            if isempty(ind)
                frames = 'all';
            else
                frames = varargin{ind+1};
            end
            % Select the destination directory
            ind = find(strcmp(varargin,'folder'));
            if isempty(ind)
                folder = sprintf('%s/temp_%s',pwd,datestr(now,'HHMMSSFFF'));
            else
                folder = varargin{ind+1};
            end
            
            % create folder
            if ~exist(folder,'dir')
                mkdir(folder);
            end
            
            % Change variable frame in a usable way
            if strcmp(frames,'all')
                frames = find(~isnan(self.structural.FaceBoxW));
            elseif strcmp(frames,'first')
                frames = find(~isnan(self.functional.anger),1,'first');
            end
            
            % Get selected frames
            [~,name] = fileparts(self.video);
            for f = frames(:)'
               clc
               fprintf('Printing frame %d (%d of %d).\n',...
                   f,find(frames==f),length(frames));
               FF = read(vidObj,f);
               % set as black and white
               if size(FF,3) > 1
                   FF = rgb2gray(FF);
               end
               [~,out] = fex_box2linidx(self.structural(f,:));
               FF(out) = nan;
               imwrite(FF,sprintf('%s/%s_%.8d.jpg',folder,name,f),'jpg');
            end
        end

    end % <<<-------------- END OF PUBLIC METHODS ------------------------| 
  
    
%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************     

    
    
end

