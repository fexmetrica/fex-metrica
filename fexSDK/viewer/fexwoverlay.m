classdef fexwoverlay < handle
%
%
% FEXWOVERLAY - Generate overlay for FEXWIMG object
%
% FEXWOVERLAY Properties:
%
% data - 
% template - 
% handles - 
% side - 
% bounds - 
% combine - 
% smoothing - 
% colmap - 
% colbar - 
% background - 
% optlayers - 
% 
% FEXWOVERLAY Methods:
% 
% fexwoverlay - 
% update - 
% makeoverlay - 
% coldataidx - 
% show - 
% saveo - 
% list - 
% maskingo - 
%
%
%
% See also FEXWHDR, FEXWIMG, FEXWDRAWMASKUI.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Sep-2014. 

    
    properties
        % dataset with VarNames and scores
        data
        % template to be used
        template
        % handles for the image
        handles
        % side (for each entry in data)
        side
        % limits for the colormap (color normalization)
        bounds
        % combination method
        combine
        % kernel for smoothing
        smoothing
        % colormap setting
        colmap
        % colorbar
        colbar
        % Base color image
        background
        % layers transparency options (overlay,fibers,brightness)
        optlayers
    end
    
    properties (Access = private)
        % Handle for the figure
        fig
        % Type information 
        typech
        % Overlay information
        overlaydata
    end
    
    
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************

    methods
        function self = fexwoverlay(data,varargin)
        %
        % -----------------------------------------------------------------
        %
        % Initialization function for overlay. See >> help fexwoverlay for
        % instructions
        %
        % -----------------------------------------------------------------
        %
        
        % Determine whether data is present, and which type of variable it
        % is.        
        if exist('data','var')
            self.update('data',data);
        else
            self.data = [];
        end    
        % Variabe arguments in: set defaults, insert provided values, and
        % use the function "check" to make sure that the arguments are
        % properily specified.
        args  = struct('template','template_01','side','both',...
            'combine','median','bounds',[],'background',false,...
            'smoothing',struct('kernel','gaussian','size',10,'param',2.5),...
            'colmap','jet','colbar',true,...
            'optlayers',struct('overlay',.1,'fibers',.7,'brightness',0));
        fnames = fieldnames(args);
        [~,inds] = ismember(fnames,varargin(1:2:end));
        for i = 1:length(inds)
            if inds(i) ~= 0
                % Set/Test that arguments are properly specified
                args.(fnames{i}) = varargin{inds(i)*2};
            end
            self.update(fnames{i},args.(fnames{i}));
        end
                
        end
        
%**************************************************************************

        function self = update(self,varargin)
        %
        % -----------------------------------------------------------------
        %
        % set overlay arguments -- note that the arguments are handled one
        % by one from the internal method "setoi." When you already have an
        % image, this procedure also updates the image. 
        %
        % -----------------------------------------------------------------
        %

        % Handle arguments in
        numargs = length(varargin);
        if mod(numargs,2) ~= 0
            error('wrong number of arguments in.');
        else
            for i = 1:2:length(varargin)
                self.setoi(varargin{i},varargin{i+1});
            end
        end
        % Test whether you need to update any image based on existence of
        % handles, and based on the type of argument.
        if ~isempty(self.fig)
        % Change only if there are handles to update
            if ~isempty(intersect(varargin(1:2:end),{'data','template','bounds'}))
            % When you change "data" or "template," you need to recompute
            % the overlay.
                self.makeoverlay();
                self.show();
            else
            % For all other properties, you can simply update the image.
                self.show();
            end
        end
        
        end

%**************************************************************************

        function self = makeoverlay(self,imgnum)
        %
        % -----------------------------------------------------------------
        %
        % Generate overlay data (in case you provide multiple data, you use
        % imgnum to select the row in Y).
        %
        % -----------------------------------------------------------------
        % 
        
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
        if isa(self.colmap,'char')
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
                maxVal = max(abs([min(min(ytest),0),max(ytest)]));
                self.bounds = [-maxVal,maxVal];
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

        function self = show(self)
        %
        % -----------------------------------------------------------------
        %
        % Display data based on the existing information, and
        % generate/update the figure handles.
        %
        % -----------------------------------------------------------------
        %
        
        if isempty(self.fig)
        % Initialize handle for the image
            self.fig = figure('Name','FexView','NumberTitle','off', 'Visible', 'on');        
        end
        
        % Test whether the overlay exists, and generate one, if required.
        if isempty(self.overlaydata)
            self.makeoverlay();
        end
                
        % Fig. Handle for muscles (use mean value)
        self.handles.muscles = imshow(uint8(self.overlaydata.OT));
        
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

        % Fig. Handles for overlay and background image
        hold on
        self.handles.overlay = imshow(imo);

        % Fig. Handles for colorbar
        if ~strcmp(self.colbar,'off') && ~isempty(self.bounds)
        % You need to freeze the colorbar here. Otherwise it will be
        % updated, and won't reflect the overlay colormap.
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
        self.handles.face = imshow(rgb2gray(self.template.img));
        hold off

        % Generate transparency data for overlay
        INDS   = ~isnan(nanmean(self.overlaydata.OT,3));
        alpha1 = ones(size(INDS,1),size(INDS,2));
        alpha1(INDS) = self.optlayers.fibers;
        alpha1 = imfilter(alpha1,fspecial('disk',5),'replicate');

        % Generate transparency data for fibers
        if self.background
            INDS = self.template.getmask();
        end
        alpha2 = ones(size(alpha1));
        alpha2(INDS) = self.optlayers.overlay;
        alpha2 = imfilter(alpha2,fspecial('disk',5),'replicate');

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

        % Set Transparency
        set(self.handles.overlay,'AlphaData',alpha1);
        set(self.handles.face,   'AlphaData',alpha2);
        
        end
        
%**************************************************************************         
        
        function self = saveo(self,varargin)
        %
        % -----------------------------------------------------------------
        %
        % Save image or hdr.
        %
        % -----------------------------------------------------------------
        %
        
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
        % -----------------------------------------------------------------
        %
        % Make a list of available channels.
        %
        % -----------------------------------------------------------------
        %    
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
                warning('Not recognized option: %s.',type);
        end 
        end 
    
        
%**************************************************************************        
        
        
        function nimg = maskingo(self,img)
        %
        % -----------------------------------------------------------------
        %
        % Apply masking to the data.
        %
        % -----------------------------------------------------------------
        % 
        
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

    end
    

%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
  
    
    methods (Access = private)           
        function self = setoi(self,names,args)
        %
        % -----------------------------------------------------------------
        %
        % Manage arguments. See >> help fexwoverlay for instructions.
        %
        % -----------------------------------------------------------------
        %

        % Import metadata 
        load('fexwmetadata');
        meta = fexwmetadata;
        
        % Switch across properties
        switch lower(names)
            case 'data'
            % Read the data argument.
                self.data = self.read_data(args);            
            case 'template'
            % Manage template selection -- > template can be a path to a
            % template (in case you are entering one that is not between
            % the 8 basic one. Otherwise it refers to a template in the
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
                elseif ismember(args,1:8)
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
                    warning('Combination method "%s" not recognized. Using "median."',args);
                    self.combine = 'median';
                end
            case 'bounds'
            % This sets up the bounds for color. It is used only if you        TO DO LIST!!!! 
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
                self.colmap = args;
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
        % -----------------------------------------------------------------
        %
        % read data: (it can be a string,a cell,or a dataset).
        %
        % -----------------------------------------------------------------
        %       
        
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
            otherwise
                error('"data" argument can be a cell, a char, or a dataset.');
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
        if ~isempty(unrecog)
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
        % -----------------------------------------------------------------
        %
        % Add values for the background of the image.
        %
        % -----------------------------------------------------------------
        %       
        
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

    end

    
end

