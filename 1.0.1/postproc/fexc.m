classdef fexc < handle
%
% FEXC - FexMetrica 1.0.1 main analytics class.
%
% Creates a FEXC object for the analysis of facial expressions
% timeseries generated using Emotient Inc. facial expressions recognition
% system.
%
% FEXC Properties:
%
% name - String with the name of the participant;
% video - Path to a video file;
% videoInfo - Vector with information about a video;
% outdir - Path to output directory;
% functional - Dataset with facial expressions time series;
% structural - Dataset with face morphology information;
% sentiments - Inferred measures of positive or negative emotions;
% baseline - Vector with baseline for the functional time series;
% time - Dataset with frame by frame timestamps;
% naninfo - Dataset with diagnostic information about the video;
% diagnostics - Dataset diagnostic information about the video;
% design - Matrix or dataset with design information.
%
% FEXC Methods:
%
% CLASS UTILITIES:
% clone	- Make a copy of FEXC object(s), i.e. new handle.
% reinitialize - Reinitialize the FEXC object to construction stage. 
% update - Changes FEXC functional and structural datasets.
% nanset - Reset NaNs after INTERPOLATE or DOWNSAMPLE are used.
% getvideoInfo - Read general information about a video file. 
%
% get - Shortcut to get subset of variables from data and other properties. 
% getmatrix	- ...
% export2viewer	- ...
% showannotation - ...
%
% SPATIAL PROCESSING: 
% setbaseline - ...
% coregister - STACKED
% falsepositive	- ...
% motioncorrect	- STACKED
% normalize	- STACKED
% rectification	- STACKED
%
% TEMPORAL PROCESSING:
% interpolate - STACKED  
% downsample - ...
% smooth - ...
% temporalfilt - ...
% getband - ...
%
% STATISTICS & FEATURES:
% derivesentiments - STACKED
% descriptives - STACKED
% kernel - ...	 
% morlet - ...	 
%
% GRAPHIC PROPERTIES:
% viewer - 	...
% drawface - [REMOVE] ...
% showpreproc - [REMOVE]...
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 12-Dec-2014.
    

properties
    % NAME: a string containing a descriptive name for the video, e.g.
    % participant name. When the field is not specified, this is set to
    % the name (without extension) of the video file. If no videofile
    % was provided, this name is set to "John Doe."
    name
    % VIDEO: String containing the path to the video file currently
    % analyzed. This field can be left empty, however, some graphic
    % functionality are not available whithout a video file.
    video
    % VIDEOINFO: A four components vector with video's FrameRate, Duration,
    % Number of Frames, Width, and Height. This properties can be set
    % calling get('VideoInfo').
    %
    % See also GETVIDEOINFO.
    videoInfo
    % OUTDIR String with the output directory for storing images and output
    % files. This filed can be left empty, in which case, calls that try to
    % write files will prompt a gui asking to specify an output directory.
    outdir
    % FUNCTIONAL: Dataset object with as many rows as frames in the video
    % from FEXC.VIDEO, and 31 columns. The columns comprise seven basic
    % emotions (anger, contempt, joy, disgust, fear, sadness and surprise);
    % three direct estimates of sentiments (positive, negative and
    % neutral); two high level emotions (confusion and frustration), and 19
    % action units.
    functional
    % STRUCTURAL: Dataset object with as many rows as frames in the video
    % from FEXC.VIDEO, and 23 columns. This columns indicate number of
    % frame matrix rows and column, location of face box (top left X & Y
    % coordinates ,with,high). X and y coordinates for 7 face landmarks, 3
    % for each eye and 1 for the tip of the nose. fexc.structural also
    % include three measures of face pose in radiants: rool, pitch and yaw.
    structural
    % SENTIMENTS: Datset object with as many rows as not Nan rows in
    % FEXC.FUNCTIONAL. The property sentiments has 5 columns: WINNER, which
    % is a vector with value 1 - 3 indicating wich sentiments was prominent
    % between, respectively, positive, negative and neutral. columns two an
    % three contain the maximum score for POSITIVE and NEGATIVE. The fourth
    % column, COMBINED, combines scores from positive and negative frames
    % (-1*SENTIMENTS.NEGATIVE). The value for neutral frames is set to 0.
    % The sixt column contains time stamps.
    %
    % See also DERIVESENTIMENTS.
    sentiments
    % TIME: Dataset with timing information on a frame-by-frame basis. This
    % dataset has as many rows as FEXC.FUNCTIONAL, and three columns:
    %
    % 1. FrameNumber: frame numeric identifier;
    % 2. TimeStamps: timestamps;
    % 3. StrTime: string conversion of timestamps from double.
    %
    % See also FEX_STRTIME.
    time
    % NANINFO
    naninfo
    % DIAGNOSTICS
    diagnostics
    % DESIGN
    design
    % BASELINE
    baseline
end
    

properties (Access = protected)
    % HISTORY: Originally inputed data and record of the operations.
    history
    % TEMPKERNEL: kernel of temporal filters used internally.
    tempkernel
    % THRSEMO: thresholding value for deriving SENTIMENTS.
    thrsemo
    % DESCRSTATS: space to store descriptive statistics.
    descrstats
    % ANNOTATIONS: annotations from FEXC.VIEWER.
    annotations
    % COREGPARAM: coregistration parameters computed using COREGISTER
    % method.
    coregparam
end


%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

methods
function self = fexc(varargin)
%
% FEXC constructor routine.
%
% USAGE:
%
% fexObj = fexc('data', datafile);
% fexObj = fexc('data', datafile, 'ArgNam1',ArgVal1,...);
% fexObj = fexc(PpObj,'ArgNam1',ArgVal1,...)
%
% See also FEX_IMPUTIL, FEXWSEARCHG.

% Create empty fex object
if isempty(varargin)
   return 
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
    % Try to read video information
    if ~isempty(self.video) && isempty(self.videoInfo)
        self.getvideoInfo();
    end

    % Import the dataset                
    try 
        ind = find(strcmp(varargin,'data'));
        if isa(varargin{ind+1},'dataset')
            ttt = varargin{ind+1};
            temp.colheaders = ttt.Properties.VarNames;
            temp.data = double(ttt);
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
    if length(temp.textdata) == 1
        thdr = strsplit(temp.textdata{1});
    else
       thdr = temp.textdata;
    end
else
  thdr = temp.colheaders(1,:);
end
% Add frames numbers & timestamps if provided (this get's added latter)
self.time = mat2dataset(nan(size(temp.data,1),2),'VarNames',{'FrameNumber','TimeStamps'});
if ismember(thdr,'FrameNumber')
    self.time.FrameNumber = temp.data(:,ismember(thdr,'FrameNumber'));
end        
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
    ind = ind(ind > 0);
    self.structural = mat2dataset(temp.data(:,ind),'VarNames',thdr(ind));
end
% Add functional image information
[~,ind] = ismember(hdrs.functional,thdr);
if ~sum(ind)==0
    self.functional = mat2dataset(temp.data(:,ind(ind > 0)),'VarNames',thdr(ind(ind > 0)));   
end

% THIS NEEDS TO BE Updated ========================================
% Add design information when provided as dataset
ind = find(strcmp(varargin,'design'));
if ~isempty(ind) && isa(varargin{ind+1},'dataset')
    self.design = varargin{ind+1};
elseif ~isempty(ind) && ~isa(varargin{ind+1},'dataset')
    % Add an header
    vnames = {'Var01'};
    for ivd = 2:size(varargin{ind+1},2)
        vnames = cat(2,vnames,sprintf('Var%.2d',ivd));
    end
    self.design = mat2dataset(varargin{ind+1},'VarNames',vnames);
else
    self.design = [];
end

% Add diagnostic information
ind = find(strcmp(varargin,'diagnostics'));
if ~isempty(ind)
    self.diagnostics = varargin{ind+1};
end
% Setup naninfo
self.naninfo = mat2dataset(zeros(size(self.functional,1),3),'VarNames',{'count','tag','falsepositive'});

% Add output matrix 
ind = find(strcmp(varargin,'outdir'));
if ~isempty(ind)
    self.outdir = varargin{ind+1};
end

% Add frame size when it is not included in the data file
if ~isfield(self.structural,'FrameRows') && ~isempty(self.videoInfo)
    fsinfo = repmat(self.videoInfo([5,4]),[size(self.structural,1),1]);
    fsinfo = mat2dataset(fsinfo,'VarNames',{'FrameRows','FrameCols'});
    self.structural = [fsinfo,self.structural];
end

% 2. THERE ARE FRAMES THAT CONTAIN MULTIPLE FACES -- THE INPUT DOES
% NOT CONTAIN FRAMES NUMBER, BUT TIMESTAMPS WHERE PROVIDED
if ~isnan(self.time.TimeStamps(1)) && isnan(self.time.FrameNumber(1))
% Find repeated frames (there is gonna be some error in the
% timestamp, so I am setting 10e-4 as threshold (... which would
% imply 1000 frames per second.
    indrep  = [diff(self.time.TimeStamps) < 10e-4;0];
    self.time.FrameNumber(indrep == 0) = (1:sum(indrep == 0))';
    [bl,bn] = bwlabel(isnan(self.time.FrameNumber));
    for i = 1:bn
        nfnind = find(bl == i,1,'first');
        self.time.FrameNumber(bl == i) = self.time.FrameNumber(nfnind+1);
    end
% If a frames repeats and there are nans in there, remove them.
ind = isnan(sum(double(self.functional),2)) & bl > 0;
self.functional = self.functional(ind == 0,:);
self.structural = self.structural(ind == 0,:);
self.naninfo    = self.naninfo(ind == 0,:);
self.diagnostics = self.diagnostics(ind == 0,:);
self.time = self.time(ind == 0,:);
end

% set emotions threshold
self.thrsemo = 0;
% Space for descriptive statistics: this can be access using get.
self.descriptives();
% self.descrstats = struct('hdrs',[],'N',[],'mean',[],'std',[],...
%     'median',[],'q25',[],'q75',[],'glob',[],'globp',[]);


% Initialize history
self.history.original = self.clone();  

end

% *************************************************************************
% *************************************************************************          

function newself = clone(self)
% CLONE makes a copy of the existing handles.
% 
% SYNTAX
% newself = self.CLONE()
%
% DESCRIPTION
% Clone can be used to modify properties of a FEXC object without
% overwriting the existing data.

newself = repmat(feval(class(self)),[length(self),1]);   
p = properties(newself(1));
for k = 1:length(self)
% Copy all non-hidden properties.
for i = 1:length(p)
    newself(k).(p{i}) = self(k).(p{i});
end

% Add hidden properties
newself(k).tempkernel  = self(k).tempkernel;
newself(k).thrsemo     = self(k).thrsemo;
newself(k).descrstats  = self(k).descrstats;
newself(k).annotations = self(k).annotations;
newself(k).coregparam  = self(k).coregparam;

end

end

% *************************************************************************
% ************************************************************************* 

function self = update(self,arg,val)
%
% UPDATE changes FEXC functional and structural datasets.
% 
% SYNTAX:
% self(k).UPDATE('functional',X)
% self(k).UPDATE('structural',X)
%
% X must have the same size of the matrix from the dataset it replaces.
% Otherwise, UPDATE won't make the substitution.
%
% NOTE that UPDATE don't work on stacks of FEXC. So, if length(FEXC) > 1,
% UPDATE needs to be called several times.

% UPDATE only operates on functional and structural properties.
if ~ismember(arg,{'functional','structural'})
    error('Unknown field to update');
end
% UPDATE does not operate on stacks.
if length(self) > 1
    warning('UPDATE does not operate on stacked FEXC.');
    return
end
% Check the provided value, and update the field
if size(val,2) == size(self.(arg),2)
    self.(arg) = replacedata(self.(arg),val);
else
    error('Size mismatch.')
end

end

% *************************************************************************
% *************************************************************************  

function self = nanset(self,rule)
%
% NANSET sets frame as null observations.
%
% SYNTAX
% self.NANSET(rule)
% 
% NANSET Reintroduces null observation in FEXC.functional using
% information from self.naninfo. This is used in case all nans where
% interpolated out for preprocessing. RULE is a scalar the number of
% consecutie NaN which will be considered reset to NaN.
% 
% See also INTERPOLATE, DOWNSAMPLE.

if ~exist('rule','var')
    rule = 15;
end

hdr = self(1).functional.Properties.VarNames;
for k = 1:length(self)
X   = double(self(k).functional);

X(repmat(self(k).naninfo.count >= rule,[1,size(X,2)])) = nan;
self(k).functional = mat2dataset(X,'VarNames',hdr);
end
end

% *************************************************************************
% *************************************************************************  

function self = reinitialize(self,flag)
%
% REINITIALIZE resets the FEXC object to construction stage.
% 
% SYNTAX:
% self.REINITIALIZE(flag)
%
% Reinitialize FEXC to a clone of FEXC generated by the constructor.
% When FLAG is set to 'force', FEXC objects are reset to the original
% data without warning. If FLAG is missing, reinitialize asks for
% confirmation before executing the comand. NOTE that REINITIALIZE will
% ask for confirmation only once. After that, REINITIALIZE will reset
% all FEXC objects in the current stack.
%
% See also CLONE.

if ~exist('flag','var')
    flag = 'coward';
end
% Ask for confirmation
if ~strcmpi(flag,'force')
result = input('Do you really want to revert to original [y/n]?');
if ~strcmp(result,'y')
    fprintf('''Reinitialize'' aborted.\n');
    return
end
end 
% Reinitialization loop
for k = 1:length(self)
    self(k) = self(k).history.original;
end

end
    
% *************************************************************************
% *************************************************************************      

function self = getvideoInfo(self)
%
% GETVIDEOINFO read general information about a video file.
%
% SYNTAX
% self.GETVIDEOINFO()
% 
% Gather video information and store them in FEXC.VIDEOINFO. This is a five
% component vector, composed of: FrameRate; Duration; NumberOfFrames;
% Width; Height.
% 
% See also VIDEOINFO.

prop = {'FrameRate','Duration','NumberOfFrames','Width','Height'};

for k = 1:length(self)
try
    self(k).videoInfo = cell2mat(get(VideoReader(self(k).video),prop));
catch errorID
    warning(errorID.message);
end

end

end

% *************************************************************************              
% *************************************************************************



    function self = viewer(self)
    % 
    % Stream the video using fexw_streamerui gui. See docs there for
    % information on the Gui options.

    % Check that (1) you have the video, and that (2) the video has the
    % correct estension:
    if ~exist(self.video,'file')
        error('No video provided for streaming.');
    else
    % check video formats
        format = VideoReader.getFileFormats();
        format = get(format, 'Extension');
        [~,~,cew] = fileparts(self.video);
        if ~ismember(cew(2:end),format)
            error('Unsupported format. Use "VideoReader.getFileFormats" to see supported formats.');
        end
    end

    % Start video streamer gui
    N = fexw_streamerui(self.clone());
    % Add annotations when provided;
    self.annotations = cat(1,self.annotations,N);
%     if ~isempty(N)
%         self.annotations = cat(1,self.annotations,N);
%         self.annotations = N;
%     end    


    end


% *************************************************************************
% ************************************************************************* 

    function self = derivesentiments(self,m,emotrect)
    %
    % -----------------------------------------------------------------
    %
    % Max-pooling for derivation of sentiments from primary emotion
    % scores.
    %
    % -----------------------------------------------------------------
    %


    if ~exist('m','var')
        m = 0;
    end
    % Set some shared information
    pos_names = {'joy','surprise'};
    neg_names = {'anger','disgust','sadness','fear','contempt'};
    VarNames = self(1).functional.Properties.VarNames;
    [~,indP] = ismember(pos_names,VarNames);
    [~,indN] = ismember(neg_names,VarNames);        


    for k = 1:length(self)
    % Set margin
    self(k).thrsemo = m;
    % Get within Maximum value
    ValS = [max(double(self(k).functional(:,indP)),[],2),...
            max(double(self(k).functional(:,indN)),[],2)];   
    % Neutral is defined as all features <= m (default is 0)
    ValS = cat(2,ValS,max(ValS,[],2) <= m);

    % Set to zero N/P for Neutal frames
    ValS(:,1:2) = ValS(:,1:2).*repmat(1-ValS(:,3),[1,2]);

    % Set to zero N/P loosing frames
    [mv,ind] = max(ValS(:,1:2),[],2);
    ValS(ind == 2,1) = 0;
    ValS(ind == 1,2) = 0;

    % Get Class (P,Ng,Nu);
    [~,idxW] = max(ValS,[],2);
    idxW(isnan(self(k).functional.anger)) = nan;
    ValS = cat(2,idxW,ValS);

    % Get (P/N Feature)
    ValS(:,5) = mv;
    ValS(ValS(:,1) == 2,5) = -ValS(ValS(:,1) == 2,5);
    ValS(ValS(:,1) == 3,5) = 0;

    % NOTE: Sentiments do not include nans
    self(k).sentiments = mat2dataset(ValS(:,[1:3,5]),'VarNames',{'Winner','Positive','Negative','Combined'});
    self(k).sentiments.TimeStamps = self(k).time.TimeStamps;
    self(k).sentiments = self(k).sentiments(~isnan(self(k).sentiments.Winner),:);

    if exist('emotrect','var')
    % Clean up emotions dataset
        % Positive
        for i = pos_names
            temp = self(k).functional.(i{1});
            temp(self(k).sentiments.Winner ~= 1 & temp > emotrect) = emotrect;
            self(k).functional.(i{1}) = temp;
        end
        % Negative
        for i = [neg_names,'confusion','frustration']
            temp = self(k).functional.(i{1});
            temp(self(k).sentiments.Winner ~=2 & temp > emotrect) = emotrect;
            self(k).functional.(i{1}) = temp;
        end
    end

    end

    end

% *************************************************************************
% ************************************************************************* 

    function self = downsample(self,fps)
    %
    % Downsample data << sub fps sampling with averaging ... WORKING
    % PROGRESS (fps is an integer and mode can be gaussian or
    % average ... );        

    % Get mode fps, set kernel, and set indices
    mfps = round(1/mode(diff(self.time.TimeStamps)));
    nfps = round(mfps/fps);
    nfps = nfps + 1-mod(nfps,2);
    if nfps < 2
        error('Downsampling with base: %.2f --> desired %.2f',mfps,fps);
    end
%     kk1 = normpdf(linspace(-2,2,mfps)',0,.5); kk1 = kk1./sum(kk1);
    kk2 = ones(nfps,1)./nfps;

    % Interpolate data first to mfps & Convolve
    [ndata,ntsp,nfr,nan_info] = fex_interpolate(self.functional,self.time.TimeStamps,mfps,Inf);
    idx = ceil(nfps/2):ceil(nfps/2):size(ndata,1);
    % ndata  = convn(ndata,kk1,'same');
    ndata    = convn(ndata,kk2,'same');

    % Grab datapoints
    ndata    = ndata(idx,:);
    ntsp     = ntsp(idx,:);
    nfr      = nfr(idx,:);
    nan_info = nan_info(idx,:);

    % Interpolate structural data <-- Pose
    Pose = self.get('pose');
    [nsd,~,~] = fex_interpolate(Pose,self.time.TimeStamps,mfps,Inf);
    Pose = mat2dataset(nsd,'VarNames',Pose.Properties.VarNames);
%         % nsd    = convn(nsd,kk1,'same');
%         nsd     = convn(nsd,kk2,'same');
%         nsd(:,1:end-3) = round(nsd(:,1:end-3));


    % Update functional and structural data
    self.structural = self.structural(nfr,:);
    for i = Pose.Properties.VarNames
        self.structural.(i{1}) = Pose.(i{1})(idx);
    end
%         self.structural = mat2dataset(nsd(idx,:),'VarNames',...
%             self.structural.Properties.VarNames);
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

    % Update design if it exists
    if ~isempty(self.design)
        self.design = self.design(nfr,:);
    end 

    % Update Sentiments
    self.derivesentiments();

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
            [~,ind] = ismember(self.functional.Properties.VarNames,bzln.Properties.VarNames);
            XX = double(bzln(:,ind));
        otherwise
            warning('Couldn''t set baseline.');
            XX =  [];
    end
    self.baseline = XX;
    end

% *************************************************************************              
% *************************************************************************  

function X = get(self,ReqArg,Spec)
%
% GET extract properties values or subset of variables from FEXC.
%
% SYNTAX X = self.get('ReqArg','OutputType',...)
% 
% GET extract relevant features from the FEXC datasets and formats them as
% requested. GET also provide access to descriptive statistics.
% 
% REQARG: a string between 'emotions,' 'sentiments,' 'aus,' 'landmarks,'
% and 'face.' Also, REQARG can be one of the provided descriptive
% statistics ('mean','std','median','q25','q75').
%
% SPEC: a string which indicates the format of the data outputed. SPEC can
% be 'dataset,' in which case a dataset is outputed; it can be 'struct.'
% Alternatively, 'type' can be set to 'double,' in which case the output is
% a matrix without column names. Default: 'dataset'
%
% See also: DESCRIPTIVES.

% Read arguments: ReqArg
if ~exist('ReqArg','var')
    warning('You need to enter a required argumen.');
    return
end
% Read arguments: type
if ~exist('Spec','var')
    Spec = 'dataset';
end

% Space for the output argument
X = [];

% Select variables for output
switch lower(ReqArg)
    % Getting Variables
    case 'sentiments'
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,{'positive','negative','neutral'}));
        end
    case {'au','aus'}
        ind = strncmpi('au',self(1).functional.Properties.VarNames,2);
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,ind));
        end
    case 'emotions'
        list = {'anger','contempt','disgust','joy','fear','sadness',...
                'surprise','confusion','frustration'};
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,list));
        end
    case 'landmarks'
        k1 = cellfun(@isempty,strfind(self(1).structural.Properties.VarNames, '_x'));
        k2 = cellfun(@isempty,strfind(self(1).structural.Properties.VarNames, '_y'));
        for k = 1:length(self)
            X = cat(1,X,self(k).structural(:,k1==0|k2==0));
        end
    case 'face'
        ind = cellfun(@isempty,strfind(self.structural.Properties.VarNames, 'Face'));
        for k = 1:length(self)
            X   = cat(1,X,self(k).structural(:,ind==0));
        end
    case 'pose'
        for k = 1:length(self)
            X  = cat(1,X,self(k).structural(:,{'Roll','Pitch','Yaw'})); 
        end
    case fieldnames(self(1).descrstats)
        if isempty(self(1).descrstats.(ReqArg))
        % Compute descriptives if they are missing. Note that the
        % computation here is applied to self(1), ... , self(K).
            self.descriptives();
        end

        for k = 1:length(self)
            X = cat(1,X,self(k).descrstats.(ReqArg));
        end 
        % FIX HEADER OF THIS
        % X = mat2dataset(X,'VarNames',self(1).functional.Properties.VarNames);                
    % Getting Stats
    case {'notes','annotations'}
        for k = 1:length(self)
            nnts = self(k).showannotation;
            X = cat(1,X,nnts);
        end
    otherwise
    % Error message
        warning('Unrecognized argument %s.',ReqArg);
        return
end

% Change output type: this part of the code applies only to variables
% request of ReqArg: emotions, sentiments, au, landmarks, face and pose. 
if strcmpi(Spec,'double')
    X = double(X);
elseif strcmpi(Spec,'struct')
    X = dataset2struct(X,'AsScalar',true);
end


end


% *************************************************************************              
% *************************************************************************

    function [Desc,Prob] = descriptives(self,varargin)
    %
    % Usage
    % Y = descriptives(self)
    % Y = descriptives(self,Stat1,Stat2,...,StatN)
    %
    % The function computes descriptive statistics on the current fex
    % objecect(s).
    %
    % descriptives can compute mean, standard deviation, median, 25th
    % and 75th quantile.
    %
    % When no optional argument is requested, the function computes all
    % the statistics. When varargin is requested, the function only
    % computes the required statistics. 
    %
    % Optional argument can be one or more strings between:
    % 'mean,' 'std,' 'median,' 'q75,' 'q25' and 'perc.'

    if ~isempty(varargin)
        warning('Sorry ... no arguments yet.');
    end

    % Space for globals
    XX = []; PP = [];

    % Conpute the actual statistics
    for k = 1:length(self)
        % Fix sentiments in case they are needed
        if isempty(self(k).sentiments)
            self(k).derivesentiments();
        end        
        % Set up info
        X = [self(k).get('emotions'), self(k).get('au')];
        vnamesX = [X.Properties.VarNames,'Sentiments'];
        vnamesP = ['Positive','Negative','Neutral',vnamesX(1:7)];
        X = double(X);
        X = [X(~isnan(sum(X,2)),:),self(k).sentiments.Combined];

        % Get General Stats (emotions and action units)
        self(k).descrstats.hdrs = {{vnamesX},{vnamesP}};
        self(k).descrstats.N      = size(X,1);
        self(k).descrstats.mean   = mean(X);
        self(k).descrstats.std    = std(X);
        self(k).descrstats.median = median(X);
        self(k).descrstats.q25    = quantile(X,.25);
        self(k).descrstats.q75    = quantile(X,.75);

        % Get Conditional probabilities
        % NOTE that X(:,1:7) are the 7 basic emotions.
        self(k).descrstats.perc   = mean(X(self(k).sentiments.Winner < 3,1:7)>self(k).thrsemo); 
        d = dummyvar([self(k).sentiments.Winner;3]);
        self(k).descrstats.perc = [mean(d(1:end-1,:)),self(k).descrstats.perc];

        % Combine data for global statistics
        XX = cat(1,XX,X);
        PP = cat(1,PP,d(1:end-1,:));
    end

    % Add Global results
    G1 = [mean(XX);std(XX);median(XX);quantile(XX,.25);quantile(XX,.75)];
    if sum(PP(:,end)) == 0
        G2 = [zeros(1,7),mean(PP(:,end-2:end))];
    else
        G2 = [mean(PP(:,end-2:end)),mean(XX(PP(:,end) == 0,1:7) > self(1).thrsemo)];
    end
    OBnames = {'mean','std','median','q25','q75'};
    for k = 1:length(self)
        self(k).descrstats.glob  = mat2dataset(G1,'VarNames',vnamesX,'ObsNames',OBnames);
        self(k).descrstats.globp = mat2dataset(G2,'VarNames',vnamesP);
    end

    % Output
    Desc = self(1).descrstats.glob;
    Prob = self(1).descrstats.globp;

    end

% *************************************************************************              
% ************************************************************************* 
    
    function ds = showannotation(self)
    % 
    % SHOWANNOTATION
    %
    % Converts to dataset and order the notes using each note starting
    % time. When called without argument, the dataset with annotations
    % is displayed on the console.

    ds = [];
    if ~isempty(self.annotations)
    % Transform to dataset
        ds = struct2dataset(self.annotations);
        [~,ind] = sort(fex_strtime(ds.Start),'ascend');
        ds = ds(ind,:);
    else
    % You need to have notes
        warning('No annotation available');
        return
    end

    % Controll output
    if nargout == 0
    % when no argument is provided, the notes are displayed on the
    % command window.
        display(ds);
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
    VarNames = self(1).functional.Properties.VarNames;
    h = waitbar(0,'Coregistration...');

    % Run reallignment
    for k = 1:length(self)
    fprintf('Coregistering fexc object %d/%d.\n',k,length(self));
    [~,P,~,R] = fex_reallign(self(k).structural,args);
    if args.fp
        % Exclude false positives
        idx = nan(sum(R>=args.threshold),length(VarNames));
        self(k).functional(R>=args.threshold,:) = mat2dataset(idx,'VarNames',VarNames);
        self(k).naninfo.falsepositive = (R>=args.threshold);
    end
    self(k).coregparam = [R,P];
    if size(P,2) == 7;
       vname = {'ER','B','T1','T2','T3','T4','C1','C2'};
    else
       vname = {'ER','B','T1','T2','T3','T4',...
                'T5','T6','T7','T8','T9','C1','C2','C3'};
    end
    self(k).coregparam = mat2dataset([R,P],'VarNames',vname);
    waitbar(k/length(self),h);
    end
    delete(h);
    end

% *************************************************************************              
% *************************************************************************   

    function self = motioncorrect(self)
    %
    % -----------------------------------------------------------------
    % 
    % Correction for artifacts due to motion.
    % 
    % -----------------------------------------------------------------
    %

    h = waitbar(0,'Motion correction...');

    for k = 1:length(self)
    fptintf('Correcting fexc %d/%d for motion artifacts.\n',k,length(self));
    % Get Pose info
    X = self(k).get('pose','double');
    ind  = ~isnan(sum(double(self(k).functional),2)) & ~isnan(sum(X,2));
    Y = double(self(k).functional(ind,:));

    % Add constant, use pose absolute values, and make pose components
    % indepependent.
    X = [ones(sum(ind),1), fex_whiteningt(abs(X(ind,1:3)))];

    % Set space for new data
    R = nan(length(ind),size(Y,2));

    % Residual method
    for i = 1:size(Y,2);
    % Include only features significantly correlated
        [rind,pind] = corr(X(:,2:end),Y(:,i));
        idxpose  = [true,pind'<= 0.05 & abs(rind') >= 0.5];
        [b,~,r] = regress(Y(:,i),X(:,idxpose));
        % Add constant back
        R(ind == 1,i) = r + b(1);
    end

    % Update functional field and re-derive sentiments from new data in
    % case you had a sentiment field.
    R(ind == 0,:) = nan;
    self(k).update('functional',R);
    if ~isempty(self(k).sentiments)
        self(k).derivesentiments();
    end

    waitbar(k/length(self),h);
    end

    delete(h);
    end

% *************************************************************************              
% *************************************************************************   

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

    VarNames = self(1).functional.Properties.VarNames;
    h = waitbar(0,'Interpolation ...');

    for k = 1:length(self)
    fprintf('Interpolating timeseries from fexc %d/%d.\n',k,length(self));
    waitbar(k/length(self),h);
    % Interpolate: safe check for number of nans
    NofNans = mean(isnan(sum(double(self(k).functional),2)));
    if NofNans < 0.90
        [ndata,ntsp,nfr,nan_info] = ...
            fex_interpolate(self(k).functional,self(k).time.TimeStamps,...
            arg.fps,arg.rule);
        % Update functional and structural data
        self(k).structural = self(k).structural(nfr,:);
        self(k).functional = mat2dataset(ndata,'VarNames',VarNames);
        % Update timestamp information
        self(k).time = self(k).time(nfr,:);
        self(k).time(:,{'OldTime'}) = mat2dataset(self(k).time.TimeStamps);
        self(k).time.TimeStamps = ntsp;
        self(k).time.StrTime = fex_strtime(self(k).time.TimeStamps);
        % Update naninformation
        self(k).naninfo = mat2dataset(...
            [nan_info,self(k).naninfo.falsepositive(nfr)],...
            'VarNames',{'count','tag','falsepositive'});
        % Update coregparam if they exists
        if ~isempty(self(k).coregparam)
            self(k).coregparam = self(k).coregparam(nfr,:);
        end
        % Update design if it exists
        if ~isempty(self(k).design)
            self(k).design = self(k).design(nfr,:);
        end
        % Update diagnostocs if present
        if ~isempty(self(k).diagnostics)
            self(k).diagnostics = self(k).diagnostics(nfr,:);
        end
        % Updare history
        self(k).history.interpolate = [self(k).time,self(k).naninfo,self(k).functional];
    else
        warning('Fexc object %d does not contain data.',k);
    end

    end

    delete(h);
    end


% *************************************************************************              
% *************************************************************************         


    function self = rectification(self,thrs)
    % 
    % Lower bound on smaller values
    if ~exist('thrs','var')
        thrs = -1;
    end

    for k = 1:length(self)
    temp = double(self(k).functional);
    temp(temp < thrs) = thrs;
    self(k).functional = mat2dataset(temp,'VarNames',self(k).functional.Properties.VarNames);            
    end

    end

% *************************************************************************
% *************************************************************************        


    function M = getmatrix(self,index,varargin)
    %
    % -----------------------------------------------------------------  
    % 
    % Generate a matrix from the timeseries. Index is a vector of the
    % same length of self.functional, s.t. [0,0,1,1,0,0,2,2,...] would
    % select 2 events, and return a matrix where the first row is the
    % average of the signal from frames tagged "1", the second row is
    % the average of frames tagged with "2," and so on. Note that -Inf
    % ,..., 0 are not considered tags, and will be excluded.
    %
    % varargin include:
    %
    %   'method': ...
    %   'size'  : ...
    % 
    % -----------------------------------------------------------------
    %

    % Set up event list
    evlist = unique(index(index > 0));
    index  = cat(2,index,zeros(size(index,1),1));
    M = [];


    % Set up method argument
    ind = find(strcmp('method',varargin));
    if isempty(ind)
        method = @nanmean;
    elseif isa(varargin{ind+1},'function_handle')
        method = varargin{ind+1};
    else
    % try char that can be converted into an handle, otherwise give up.
        try
           method = eval(sprintf('@%s',varargin{ind+1}));
        catch errorID
            warning(errorID.message);
            return
        end
    end

    % Set up size argument
    ind = find(strcmp('size',varargin));
    if ~isempty(ind)
    % get the position of the window
        val = varargin{ind+1};
        wps = find(val ~=0);
        if ~ismember(wps,1:2)
            warning('I couldn''t understand "size" parameter.');
            return
        end
        % Resize the events
        for i = evlist'
            nc = (1:sum(index(:,1) == i))';
            if wps == 1
            % Get the beginning of the event
                index(index(:,1) == i,2) = nc;
            else
            % Get the end of the event
                index(index(:,1) == i,2) = flipud(nc);
            end
        end
        index(index(:,2) > val(wps),1) = 0;
    end

    % Compile the matrix
    temp = double(self.functional);
    for i = evlist'
        M = cat(1,M,method(temp(index(:,1) == i,:)));
    end

    % Add header
    M = mat2dataset([evlist,M],'VarNames',['NumEvent',self.functional.Properties.VarNames]);

    end

% *************************************************************************
% *************************************************************************         

    function self = export2viewer(self,filename)
    %
    %
    % Write a csv file for Emotient viewer.

    % Get the helper dictionrary
    dict = dataset('XLSFile','eviewerhdrs.xlsx');

    % Add action units (set the correct order)
    AUs = self.get('au');
    X   = zeros(size(AUs));
    for k = 1:size(AUs,2)
        ind = strcmpi(AUs.Properties.VarNames{k},dict.Fexchdr);
        X(:,ind) = double(AUs(:,k));
    end

    % Anomaly Score
    X = cat(2,X,nan(size(X,1),1));
    % Add Gender
    X = cat(2,X,3*ones(size(X,1),1));

    % Add Emotions
    emos = {'anger','confusion','contempt','disgust','fear','frustration',...
        'joy','negative','neutral','positive','sadness','surprise'};
    Y = [];
    for k = 1:length(emos)
        Y = cat(2,Y,self.functional.(emos{k}));
    end

    % Add sentiments ('Neutral is actually a combined version')
    Y(~isnan(Y(:,1)),strcmpi('positive',emos))  = self.sentiments.Positive;
    Y(~isnan(Y(:,1)),strcmpi('negative',emos))  = self.sentiments.Negative;
    Y(~isnan(Y(:,1)),strcmpi('neutral' ,emos))  = self.sentiments.Combined;

    % Normalize Y to get Intensities
    Y2(:,[1:7,11:12]) = exp(Y(:,[1:7,11:12]))./repmat(exp(sum(Y(:,[1:7,11:12]),2)),[1,9]);
    temp_s = [self.functional.positive,self.functional.negative,self.functional.neutral];
    Y2(:,8:10) = exp(temp_s)./repmat(exp(sum(temp_s,2)),[1,3]);
    X = cat(2,X,[Y,Y2]);

    % Add face location
    F = self.get('Face');
    X = cat(2,X,[F.FaceBoxH,F.FaceBoxW,F.FaceBoxX,F.FaceBoxY]);

    % Add face quality
    X = cat(2,X,repmat(~isnan(sum(Y,2)),[1,2]));

    % Add filepath (this needs to change)
    X = cat(2,X,nan(length(X),1));

    % Add landmarks
    X = cat(2,X,self.get('Landmarks','double'));

    % Add pose
    P = self.get('Pose','double');
    X = cat(2,X,P(:,[2,1,3]));

    % TimeStamps + track_id: THIS needs to be updated
    track_id = ~isnan(sum(Y,2))-1;
    X = cat(2,X,self.time.TimeStamps,track_id);

    % Stack nan at the end/convert nans to 0
    N = X(track_id == -1,:);
    N(isnan(N)) = 0;
    X = cat(1,X(track_id ~= -1,:),N);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Write the data to csv


    % Create output directory
    dirout = fileparts(filename);
    if ~exist(dirout,'dir')
        mkdir(dirout);
    end

    % Create header
    header_string = dict.Viewerhdr{1};
    for i = 2:length(dict.Viewerhdr)
        header_string = [header_string,',',dict.Viewerhdr{i}];
    end

    % Write csv file with header 
    fid = fopen(filename,'w');
    fprintf(fid,'%s\r\n',header_string);    
    fclose(fid);
    dlmwrite(filename,X,'-append','delimiter',',');

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


    % THIS NEEDS TO BE CHECKED -- BUT PARAM END SHOULD BE nyquist!!
    args.param(end) = args.param(end)/2;

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

    function M = getband(self,param,varargin)
    %
    % -----------------------------------------------------------------  
    % 
    % Return analytic signal for a specific frequency, in a matrix:
    %
    %   'type'  :
    %   'order' :
    %   'output':
    %   'show'  :
    % 
    % -----------------------------------------------------------------
    %

    % Set default:
    type = {'','hp','bp'};
    args = struct('order',round(4*param(end)/param(1)),...
                  'type' , type{length(param)},...
                  'output','real',...
                  'show',false,...
                  'matrix','off');
    % Read varargin
    argsn = fieldnames(args);
    for i = 1:length(argsn)
        ind = find(strcmp(argsn{i},varargin));
        if ~isempty(ind)
            args.(argsn{i}) = varargin{ind+1};
        end
    end

    % Test 'matrix' argumen:
    eM = 'matrix is a structure with fields: events, method, and size.';
    if ~strcmp(args.matrix,'off')
        % Handle event list
        if ~isfield(args.matrix,'events')
            error(eM);
        end
        % Handle method
        if ~isfield(args.matrix,'method')
            args.matrix.method = @nanmean;
        end

        % Handle size
        if ~isfield(args.matrix,'size')
            args.matrix.size = [Inf,0];
        end
    end

    % Apply filter
    ts = fex_bandpass(double(self.functional),param,...
                           'order',args.order,...
                           'type',args.type);

    % Select output signal ('real','imag','power','analytic')
    if strcmp(args.output,'real')
        TS = ts.real;
    elseif strcmp(args.output,'imag')
        TS = imag(ts.analytic);
    elseif strcmp(args.output,'power')
        TS = abs(ts.analytic).^2;
    elseif strcmp(args.output,'analytic')
        TS = ts.analytic;
    else
        error('Unknwon output type.');
    end

    if isa(args.matrix,'struct')
        M = fex_getmatrix(TS,args.matrix.events,'method',args.matrix.method,'size',args.matrix.size);
    else
        M = TS;
    end

    % Display animation of the filtering process
    if args.show
        scrsz = get(0,'ScreenSize');
        figure('Position',[1 scrsz(4) scrsz(3)/1.5 scrsz(4)/1.5],...
            'Name','Frequency Specific Signal','NumberTitle','off','Visible','off');

        ax(1) = subplot(3,3,1:3); hold on
        bar(self.time.TimeStamps,self.functional.anger-nanmean(self.functional.anger));
        ylim([min(self.functional.anger-nanmean(self.functional.anger)),max(self.functional.anger-nanmean(self.functional.anger))]);
        title('Original Signal (centered)','fontname','Helvetica','fontsize',14);

        ax(2) = subplot(3,3,4:6); hold on
        bar(self.time.TimeStamps,ts.real(:,1));
        ylim([min(ts.real(:,1)),max(ts.real(:,1))]);
        title('Filtered Signal (real)','fontname','Helvetica','fontsize',14);

        ax(3) = subplot(3,3,7:9); hold on
        bar(self.time.TimeStamps,abs(ts.analytic(:,1)).^2);
        ylim([min(abs(ts.analytic(:,1)).^2),max(abs(ts.analytic(:,1)).^2)]);
        title('Inst. Power Estimate','fontname','Helvetica','fontsize',14);
        xlabel('Time (sec.)','fontname','Helvetica','fontsize',14);

        % Movie style progression:
        linkaxes([ax(3) ax(2) ax(1)],'x');
        k1 = 101;
        set(ax(1),'xlim',[self.time.TimeStamps(k1-100),self.time.TimeStamps(k1)]);
        set(gcf,'Visible','on');
        for i = 1:length(self.time.TimeStamps)-1
            set(ax(1),'xlim',[self.time.TimeStamps(k1-100),self.time.TimeStamps(k1)]);
            pause(.05)
            k1 = k1+1;
        end              
    end


    end  

% *************************************************************************
% *************************************************************************  


    function self = normalize(self,varargin)
    %
    % -----------------------------------------------------------------  
    % 
    % Normalize the functional field
    %
    % -----------------------------------------------------------------
    %

    % Set defaults
    scale = {'method','c',...
             'outliers','off',...
             'threshold',2.5};

    % Read optional arguments
    for i = 1:2:length(varargin)
        idx = strcmpi(scale,varargin{i});
        idx = find(idx == 1);
        if idx
            scale{idx+1} = varargin{i+1};
        end
    end

    h = waitbar(0,'Normalization ... ');
    % Execute normalization method
    for k = 1:length(self)
       fprintf('Normalizing fexc %d of %d.\n',k,length(self));
       if strcmpi(varargin{1},'baseline')
       % Baseline normalization: this is only partially implemented.
           X = repmat(mean(double(self(k).baseline),1),[length(self(k).functional),1]);
           self(k).update('functional', double(self(k).functional) - X);
       else
           self(k).update('functional',fex_normalize(double(self(k).functional),scale{:}));
       end
       waitbar(k/length(self));
    end
    delete(h);

    end

% *************************************************************************
% *************************************************************************  
       

    function self = smooth(self,kk)
    %
    % Smoothing providing kernell kk

    temp = convn(self.functional,kk(:),'same');
    self.functional = mat2dataset(temp,'VarNames',self.functional.Properties.VarNames); 

    end

% *************************************************************************
% *************************************************************************   

    function self = kernel(self)
        fprintf('something');
    end

    function self = morlet(self)
        fprintf('something');
    end

% *************************************************************************
% *************************************************************************  

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

% *************************************************************************
% *************************************************************************  

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
        [~,namef] = fileparts(self.video);
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
           imwrite(FF,sprintf('%s/%s_%.8d.jpg',folder,namef,f),'jpg');
        end
    end

end % <<<-------------- END OF PUBLIC METHODS ------------------------| 


%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************     



%**************************************************************************
%**************************************************************************

end

