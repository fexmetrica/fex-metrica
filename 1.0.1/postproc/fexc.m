classdef fexc < handle
%
% FEXC - FexMetrica 1.0.1 main analytics class.
%
% Creates a FEXC object for the analysis of facial expressions timeseries
% generated using Emotient Inc. (http://www.emotient.com) facial
% expressions recognition system.
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
% FEXC - FEXC constructor method.
%
% UTILITIES:
% clone	- Make a copy of FEXC object(s), i.e. new handle.
% reinitialize - Reinitialize the FEXC object to construction stage. 
% update - Changes FEXC functional and structural datasets.
% nanset - Reset NaNs after INTERPOLATE or DOWNSAMPLE are used.
% getvideoInfo - Read general information about a video file. 
% get - Shortcut to get subset of FEXC variables or properties [... ...].
% fexport - Export FEXC data or notes to .CSV file.
% getmatrix	- [... ...]
%
% SPATIAL PROCESSING: 
% coregister - Register face boxes to average face video location.
% falsepositive	- Detect false alarms in FEXC.functional.
% motioncorrect	- [STACKED][... ...]
%
% TEMPORAL PROCESSING:
% interpolate - Interpolate timeseries & manages NaNs.  
% downsample - [... ...]
% smooth - Smooth time series using standard or costume kernel.
% temporalfilt - Apply low, high, or bandpass filter to FEXC.functional.
% getband - [... ...]
%
% NORMALIZATION:
% rectification	- Set a lower value for FEXC.functional time series.
% setbaseline - Set the BASELINE property (private), and normalize data.
% normalize	- [STACKED][... ...]
%
% STATISTICS & FEATURES:
% derivesentiments - [STACKED][... ...]
% descriptives - [STACKED][... ...]
% kernel - [... ...][INTEGRATE]	 
% morlet - [... ...][INTEGRATE]	 
%
% GRAPHIC PROPERTIES:
% show - Generate images for the FEXC data.
% viewer - Interactive display of FEXC video and associated data.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 16-Dec-2014.
    

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
    % DESIGN: Dataset with design information. Design must have the same
    % number of rows as FUNCTIONAL. If entered with FEXC constructor, and
    % the dimensions are consistent, the size of DESIGN will be updated by
    % methods that change FUNCTIONAL numebr of rows.
    %
    % NOTE: DESIGN property is only partially implemented.
    design
end
    

properties (Access = protected)
    % OUTDIR String with the output directory for storing images and output
    % files. This filed can be left empty, in which case, calls that try to
    % write files will prompt a gui asking to specify an output directory.
    outdir
    % HISTORY: Originally imputed data and record of the operations. This
    % property is not accessible, but the original FEXC status can be
    % obtain using REINITIALIZE.
    %
    % See also REINITIALIZE.
    history
    % TEMPKERNEL: kernel of temporal filters used internally. This is
    % generated by method TEMPORALFILT.
    %
    % See also TEMPORALFILT.
    tempkernel
    % THRSEMO: thresholding value for deriving SENTIMENTS. This value can
    % be specified as argument to method DERIVESENTIMENTS.
    %
    % See also DERIVESENTIMENTS.
    thrsemo
    % DESCRSTATS: space to store descriptive statistics. Descriptive
    % statistics can be access using GET.
    %
    % See also DESCRIPTIVES, GET.
    descrstats
    % ANNOTATIONS: annotations from VIEWER. ANNOTATIONS can be access using
    % GET, and can be saved using FEXPORT method.
    %
    % See also VIEWER, GET, FEXPORT.
    annotations
    % COREGPARAM: coregistration parameters computed using COREGISTER
    % method.
    %
    % See also COREGISTER.
    coregparam
    % NANINFO: A dataset generated using INTERPOLATE method. The dataset
    % comprises three variables: 
    % 
    % count - Numer of NaN frames within a cluster;
    % tag -  ID for cluster of NaNs (i.e. first, ..., Kth cluster).
    % falsepositive - frames tagged as false positive by methods.
    %
    % Falsepositive is computed by FALSEPOSITIVE or COREGISTER.
    %
    % See also GET, INTERPOLATE, FEX_INTERPOLATE, FALSEPOSITIVE, COREGISTER.
    naninfo
    % DYAGNOSTIC: A dataset with variable "track_id," which indicates the
    % face id outputed by the Emotient Inc. toolbox.
    %
    % See also GET.
    diagnostics
    % BASELINE: vector or dataset using SETBASELINE. This is used to
    % normalize the data.
    %
    % See also SETBASELINE.
    baseline
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
%
% NOTE: THIS IS WORK IN PROGRESS.

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
    if ~isempty(self.diagnostics)
        self.diagnostics = self.diagnostics(ind == 0,:);
    end
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

% CLASS UTILITIES**********************************************************
% ---------------**********************************************************          

function newself = clone(self)
%    
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
result = input('Do you really want to revert to original? Y/N [Y]: ');
if ~isempty(result) % ~strcmp(result,'y')
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

function X = get(self,ReqArg,Spec)
%
% GET extract properties values or subset of variables from FEXC.
%
% SYNTAX X = self.get('ReqArg','OutputType',...)
% SYNTAX X = self.get(STATNAME)
% SYNTAX X = self.get(STATNAME,'-global')
% 
% GET extract relevant features from the FEXC datasets and formats them as
% requested. GET also provide access to descriptive statistics.
% 
% REQARG: a string which can be:
%
% A  One of the datasets ('emotions,''sentiments,' 'aus,' 'landmarks,' and
%   'face.')
% B  One of the descriptive statistics ('mean','std','median','q25','q75').
% C  The annotations -- 'Annotations.'
%
% SPEC options depend on the value of REGARG.
%
% A. SPEC is a string which indicates the format of the data outputed. SPEC
%    can be 'dataset,' in which case a dataset is outputed; it can be
%    'struct.' Alternatively, 'type' can be set to 'double,' in which case
%    the output is a matrix without column names. Default: 'dataset.'
% B. SPEC is a string set to '-global' when you want to compute a
%    statistics across all FEXC objects in self.
% C. SPEC is used as in A.
%
%
% See also: DESCRIPTIVES, VIEWER.

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
        % look for global or local varibles.
        if strcmpi(Spec,'-global')
            k = strcmpi(ReqArg,self(1).descrstats.glob.Properties.ObsNames);
            X = double(self(1).descrstats.glob(k,:));
        else        
            for k = 1:length(self)
                X = cat(1,X,self(k).descrstats.(ReqArg));
            end
        end
        % FIX HEADER OF THIS
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

function flist = fexport(self,Spec)
%
% self.FEXPORT saves selected data to CSV file.
%
% SYNTAX:
%
% self.FEXPORT(Spec)
% self.FEXPORT(Spec,'ArgName1',ArgVal1, ... )
%
% FEXPORT saves the requested data to a csv file. If an self.OUTDIRE was
% provided at the time of FEXC creation, the data is saved to that
% directory. Otherwise, the data file is saved in the current directory.
%
% ARGUMENT:
%
% SPEC: a string, indicating what to save. This argument is required.
% Recognized string for SPEC are:
%
% - 'Data1': saves all the data (functional, structural, time and
%   diagnostics). This format can be read back as a FEXC object using
%   FEX_INPUTIL with AZDATA flag. This format is meant to be read by
%   Emotient Inc. online viewer (http://www.emotient.com).
%
% - 'Data2': same as 'Data2' but with a different naming convection, and
%   without few variables (Advertized csv file from Emotient Inc.). This
%   format can be read back as a FEXC object using FEX_INPUTIL with FFDATA
%   flag.
%
% - 'Annotations': saves the annotations to a csv file.
%
%
% OPTIONAL ARGUMENTS:
%
% - DIRNAME: A string with a custom name for the saved file.
%
% See also GET, VIEWER.


% Controll Spec argument
if ~exist('Spec','var')
    error('SPEC input needed. Options: ''Data1'',''Data2'',''Annotations''.');
elseif sum(strcmpi(Spec,{'Data','Data1','Data2','Annotations','Notes'})) == 0;
    error('SPEC options: ''Data'',''Annotations''.');
end

% Store flist
h = waitbar(0,sprintf('Exporting %s ... ',Spec));

flist = cell(length(self),1);
for k = 1:length(self)
    if isempty(self(k).outdir)
        SAVE_TO = sprintf('%s/fexexport',pwd); 
    else
        SAVE_TO = sprintf('%s/fexexport',self(k).outdir);
    end
    % Generate output directory
    if ~exist(SAVE_TO,'dir')
        mkdir(SAVE_TO);
    end
    
    % Set up a filename
    if ~isempty(self(k).video)
        [~,bname] = fileparts(self(k).video);
    elseif ~isempty(self(k).name)
        bname = self(k).name; 
    else
        bname = sprintf('fexexport_%s',datestr(now,'HH_MM_SS'));   
    end
    
    % Save the data
    switch lower(Spec)
        case {'data','data1'}
        % Export all the datasets
            flist{k} = sprintf('%s/%s.csv',SAVE_TO,bname);
            self(k).export2viewer(flist{k});
        case {'data2'}
        % Cleaner csv file following Emotient Inc. 
            flist{k} = sprintf('%s/%s.csv',SAVE_TO,bname);
            X = mat2dataset(nan(size(self(k).functional,1),1),'VarNames','Id');
            n = size(X,1);
            % Add Id
            if ~isempty(self(k).name)
                X.Id = cellstr(repmat(self(k).name,[n,1]));
            end
            % Add file name
            if ~isempty(self(k).video)
                [~,s1,s2] = fileparts(deblank(self(k).video));
                sval = sprintf('%s%s',s1,s2);
                X.Filename = cellstr(repmat(sval,[n,1]));
            else
                X.Filename = nan(n,1);
            end
            X.Duration = repmat(fex_strtime(self(k).time.TimeStamps(end),'short'),[n,1]);
            X.Frames = repmat(n,[n,1]);
            X.FrameId = self(k).time.FrameNumber;
            % Add track id
            try
                X.track_id = self(k).diagnostics.track_id;
            catch
                X.track_id = zeros(n,1);
            end
            X.Timestamp = self(k).time.TimeStamps;
            % GENDER NEEDS TO BE IMPLEMENTED
            X.Is_male = ones(n,1);
            % Face X,Y coordinates
            X.location_x = self(k).structural.FaceBoxX;
            X.location_y = self(k).structural.FaceBoxY;
            % Add pose
            X = cat(2,X,self(k).get('Pose'), self(k).functional(:,{'positive','negative','neutral'}));
            X = cat(2,X,self(k).get('Emotions'),self(k).get('AUs'));
            X = X(~isnan(X.anger),:);
            export(X,'file',flist{k},'delimiter',',');
        case {'annotations','notes'}
        % Export annotations when present
            flist{k} = sprintf('%s/notes_%s.csv',SAVE_TO,bname);
            ds = self(k).get('annotations');
            if isempty(ds)
                fprintf('No annotation provided for FEXC %d.\n',k);
                flist{k} = '';
            else
                ds = self(k).get('annotations');
                export(ds,'file',flist{k},'Delimiter',',');
            end                
        otherwise
            error('Unrecognized SPEC argument: %s.',Spec);
    end  
    waitbar(k/length(self),h);
end
delete(h);
flist = cellstr(flist);

end

% *************************************************************************



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

    % Set some shared information
    pos_names = {'joy','surprise'};
    neg_names = {'anger','disgust','sadness','fear','contempt'};
    VarNames = self(1).functional.Properties.VarNames;
    [~,indP] = ismember(pos_names,VarNames);
    [~,indN] = ismember(neg_names,VarNames);        

    for k = 1:length(self)
    % Set margin/adjust if not called
    if exist('m','var') 
        self(k).thrsemo = m;
    else
        m = self(k).thrsemo;
    end
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
       

function self = setbaseline(self,StatName,StatSource)
%
% SETBASELINE normalizes the data using a BASELINE.
%
% SYNTAX:
%
% self.SETBASELINE(StatName)
% self.SETBASELINE(StatName,'-global')
%
% 
% SETBASELINE is an alternative to NORMALIZE to normalize the data. This
% method extract the information required for the normalization, and ALSO
% execute the normalization.
%
% ARGUMENTS:
%
% STATNAME: a string that can be set to one of the descriptive statistics
% computed using DESCRIPTIVES (options: 'mean', 'median','q25' (25th
% quantile),'q75' (75th quantile). The requested statistic is computed
% using DESCRIPTIVES and normalization is performed by subtracting the
% statistics to variables in self.FUNCTIONAL.
%
% STATSOURCE: [optiona] This string determines the source of the
% descriptive statistic use for normalization. Options are:
%
% '-local': [default] Statistics are computed on FUNCTIONAL data from the
% current FEXC object.
%
% '-global': Statistics are computed over all FEXC
% objects in self.
%
%
% NOTE: THIS METHODS NEEDS TO INCLUDE AN OPTION TO IMPORT BASELINE DATA
% FROM A DIFFERENT DATA OR FEXC OBJECT.
%
%
% See also NORMALIZE, DESCRIPTIVES.


% Check StatName argument
optstats = {'mean','median','q25','q75'};
if ~exist('StatName','var')
    error('You need to specify baseline statistics.');
elseif sum(strcmpi(StatName,optstats)) == 0;
    error('Not recognized descriptive: %d.\n',StatName);
end

% Refresh descriptive statistics
self.descriptives();

if ~exist('StatSource','var')
   StatSource = '-local';
end

% Apply baseline
if strcmpi(StatSource,'-local')
% Local version computed on the current FEXC object from self.
    h = waitbar(0,'Set Baseline ...');
    for k = 1:length(self)
        Y = double(self(k).functional);
        NormVal = double(self(k).get(lower(StatName)));
        self(k).baseline = NormVal;
        NormVal = repmat(NormVal,[size(Y,1),1]);
        self(k).update('functional',Y -NormVal);
        self(k).baseline = NormVal;
        waitbar(k/length(self),h);
    end
elseif strcmpi(StatSource,'-global')
% Global baseline computed on all FEXC object from self.
    h = waitbar(0,'Set Baseline ...');
    NormVal = self(1).get(StatName,'-global');
    for k = 1:length(self)
       self(k).baseline = NormVal;
       Y = double(self(k).functional);
       self(k).baseline = NormVal;
       self(k).update('functional',Y -repmat(NormVal,[size(Y,1),1]));
       waitbar(k/length(self),h);
    end
else 
    error('Not recognized source: %s.',StatSource);
end

self.derivesentiments();
delete(h);

end


% *************************************************************************

function [Desc,Prob] = descriptives(self,varargin)
%
% DESCRIPTIVES computes descriptive statistics on the dataset.
%
% SYNTAX:
%
% Y = self.DESCRIPTIVES(self)
% Y = self.DESCRIPTIVES(self,Stat1,Stat2,...,StatN)
%
% DESCRIPTIVES computes descriptive statistics on the current FEXC
% object. The values can be required as an output of DESCRIPTIVES, or
% they can be obtain using GET and the name of the descriptive.
% DESCRIPTIVES computes:
%
% mean - GET('mean');
% mediab - GET('median');
% 25th quantile - GET('q25');
% 75th quantile - GET('q75');
% distribution over emotions - GET('perc').
%
% DESCRIPTIVES computes statistics for each self FEXC object and across all
% FEXC object.
%
% See also GET.

if ~isempty(varargin)
    warning('Sorry ... no arguments implemented.');
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
    emonames = {'anger','contempt','disgust','joy','fear','sadness','surprise'};
    vnamesX = [self(k).functional.Properties.VarNames];
    vnamesP = ['Positive','Negative','Neutral',emonames];
    X = double(self(k).functional);
    I = ~isnan(sum(X,2)); X = X(I,:);
    
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
    [~,emoidx] = ismember(emonames,vnamesX);
    self(k).descrstats.perc   = mean(X(self(k).sentiments.Winner < 3,emoidx)>self(k).thrsemo); 
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
    G2 = [mean(PP(:,end-2:end)),mean(XX(PP(:,end) == 0,emoidx) > self(1).thrsemo)];
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
    fprintf('Correcting fexc %d/%d for motion artifacts.\n',k,length(self));
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
% FALSEPOSITIVE identifies patch of pixels mislead for a face.
%
% SYNTAX:
% self.FALSEPOSITIVE(method) 
% self.FALSEPOSITIVE('method',MethodName) 
% self.FALSEPOSITIVE(method,'Arg1Name','Arg1Val',...) 
%
% FALSEPOSITIVE identifies false alarm for face boxes in a video. Three
% methods (string) are currently implemented, which have to be spefidfied
% using the first argument, 'method.'
%
% METHOD:
%
% - 'size' uses the area of the face box as a indirect way of identifing
%    false alarm -- i.e. face areas thar are more than Z standartd
%    deviation away from the average face area will be discarded.
% - 'position' uses the average location of the face box to assess how
%    likely a face will appear in a certain location. Face boxes identified
%    in patches of pixels associated with low probability will be
%    discarded.
% - 'coreg' uses the output of the coregistration procedure. COREGISTRATION
%    uses procrustes analysis to register faces from each frame to the
%    average of the face boxes and landmarks position. Frames with a
%    coregistration error larger than Z are discarded. The 'coreg' method
%    can be called directly with COREGISTETR.
% 
% OPTIONAL ARGUMENT:
%
% - 'threshold': the criterion use to identify outliers, expressed in
%    standard deviations. Default: 2.50.
%
%
%
% See also COREGISTER, PROCRUSTES.

% Read arguments
args = struct('method','size','threshold',2.50,'param',[]);
if ~strcmpi(varargin{1},'method')
    varargin = ['method',varargin];
end
% Assign custome args.
for i = 1:2:length(varargin)
    if isfield(args,varargin{i});
        args.(varargin{i}) = varargin{i+1};
    end
end

% Not all methods are implemented
if ~ismember(args.method,{'coreg','size','pca','kalman','position'});
    warning('Wrong method specified.')
    return
elseif ismember(args.method,{'pca','kalman'});
    warning('Method %s is not implemented yet.',args.method);
    return
end

% Run FALSEPOSITIVE identification
h = waitbar(0,'False alarm identification ... ');
for k = 1:length(self)
	% Initialize index
    idx = zeros(length(self(k).structural.FaceBoxW),1);
    I = ~isnan(self(k).structural.FaceBoxW);
    switch args.method
        case 'size'
            z = zscore(self(k).structural.FaceBoxW(I).^2);
            idx(I) = abs(z)>=args.threshold;        
        case 'position'
            F = get(self(k),'Face','double');
            FF = repmat(mean(F(I,:)),[sum(I),1]);
            F = zscore(sum((F(I,:)-FF).^2,2));
            idx(I) = abs(F)>=args.threshold;        
        case 'coreg'
            if isempty(self(k).coregparam)
                self(k).coregister();
            end
            idx = self(k).coregparam.ER >= args.threshold; 
    end
    self(k).naninfo.falsepositive = (self(k).naninfo.falsepositive + idx) >= 1;
    % Update functional
    X = double(self(k).functional);
    BIDX = repmat(self(k).naninfo.falsepositive,[1,size(X,2)])==1;
    X(BIDX) = nan;
    self(k).update('functional',X);
    % update structural
    X = double(self(k).structural);
    BIDX = repmat(self(k).naninfo.falsepositive,[1,size(X,2)])==1;
    X(BIDX) = nan;
    self(k).update('structural',X);
    waitbar(k/length(self),h);
end

% Update sentiments
self.derivesentiments();
delete(h);
end

% *************************************************************************

function self = coregister(self,varargin)
%
% COREGISTER register face boxes to average face video location
%
% SYNTAX:
%
% self.COREGISTER()
% self.COREGISTER('ArgName1',ArgVale1, ... )
%
% COREGISTER uses procrustes analysis to register a face box and the
% associated face landmarks to a standardized face in the current video.
%
% OPTIONAL ARGUMENTS:
%
% 'steps' - a scalar value of 1 or 2 (default is 1). When it is set to 2,
%  coregistration is done once for all data, then the error in the
%  coregistration is used to infer false positives, and coregistration is
%  done a second time using the average position of non false positives.
%
% 'scaling' - true or false (default: true). Determines whether 'scaling'
%  is used for coregistration.
%
% 'reflection' - true or false (default: false). Determine whether
%  argument 'reflection' is used for coregistration.
%
% 'fp' - a truth value (default: false), which determine whether the error
%  from coregistration will be used to identify false positive. This false
%  alarm identification method can also be called using FALSEPOSITIVE.
%
% 'threshold' - a scalar between 0 and Inf (default is 2.50). It indicates
%  the number or standard deviation above the mean of the residual sum of
%  square error of the coregistration. When threshold is set to a number
%  larger than 0, this is used to identify false positive.
%
%  NOTE that the 'threshold' option has an effect only when the number of
%  steps is set to 2, or when 'fp' is set to true.
%
%
% COREGISTER does not produce any output. Coregistration parameter can be
% used using self.GET('coreg').
%
%
% See also FEX_REALLIGN, GET, PROCRUSTES, FALSEPOSITIVE.



% Handle optional arguments
args = struct('steps',1,'scaling',true,...
              'reflection',false,...
              'threshold',2.5,'fp',false);            

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
    self(k).derivesentiments();
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

function self = interpolate(self,varargin)
%
% INTERPOLATE interpolates functional data.
% 
% SYNTAX:
% self.INTERPOLATE()
% self.INTERPOLATE('ArgName1',ArgVal1,...)
%
% INTERPOLATE can be used to have timeseries with equally spaced
% datapoints, and it can be used to recover NaN observations. This method
% uses FEX_INTERPOLATE.
%
% ARGUMENTS:
%
% fps: Desired frame per second. This will be the new frame rate [Default
% is 15].
% rule: an integer between 0 and Inf. It indicates the number of
% consecutive NaNs that will be recovered [Default Inf -- i.e. no NaN is
% left].
%
% Since INTERPOLATE changes the size of FEXC.functional, all other
% properties are updated accordingly. Timing information, and list of old
% frames can be obtained from FEXC.TIME. This method also initializes (or
% update) self.NANINFO.
%
%
% See also FEX_INTERPOLATE, NANINFO.

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
% RECTIFICATION sets a lower bound for functional timeseries.
%
% SYNTAX:
%
% self.RECTIFICATION()
% self.RECTIFICATION(thrs)
%
% The signal to noise ration for evidence with large negative value is very
% low. For this reason, it is convenient to set a lower bound for the data
% in self.FUNCTIONAL.
%
% THRS: a scalar indicating the lower bound, s.t. all self.FUNCTIONAL
% values smaller than THRS are set to THRS. Default is -1.

if ~exist('thrs','var')
    thrs = -1;
end

for k = 1:length(self)
    temp = double(self(k).functional);
    temp(temp < thrs) = thrs;
    update(self(k),'functional',temp);            
end
% Derive sentiments from new data.
self.derivesentiments();


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

function self = temporalfilt(self,param,varargin)
%
% TEMPORALFILT performs temporal filter on functional data.
%
% SYNTAX:
%
% self.TEMPORALFILT(param)
% self.TEMPORALFILT(param,'VarName1','VarVal1',...)
% self.TEMPORALFILT(param,'VarName1','VarVal1',...,'-showonly')
%
% TEMPORALFILT use FEX_BANDPASS, which wraps FIR1. Some safety check for
% prameter sopecification are also implemented following guidinglines from:
% M.X.Cohen, "Analyzing Neural Time Series Data", MIT Press, 2014. Note
% that use the TEMPORALFILT, your data need to have a constant frame rate.
% Additionally, NaNs need to be excluded. If the data includes NaNs they
% will be temorarely interpolated out.
%
% self.TEMPORALFILT applies the filter to the functional timeseries, unless
% you specifie the flag '-show'. In this case a plot summarizing filer
% information is displayed, but NOT APPLIED. You need to call the function
% without the '-showonly' option.
% 
% REQUIRED ARGUMENT:
%
% PARAM is a double or a 2-component vector with boundaries frequency for
% the filter:
%
% - for bandpass: [low_frq,high_frq]; - for highpass: [low_freq]; - for
% lowpass:  [high_freq].
%
% OPTIONAL ARGUMENTS:
%
% type: can be 'bandpass' [or 'band', or 'bp'] to implement a bandpass
% filter. This is the default when length(param) == 2. Use 'lowpass'
% ['lp','low'] to implement a low pass filter; or it can be Use 'highpass'
% ['hp','high'] to implement a high pass filter. This is the default when
% length(param) == 1. Use 'lowpass' ['lp','low'] to implement a low pass
% filter.
% 
% order: is a scalar indicating the length of the filter vector. There is a
% lower and upper bound. The filter must be long enough to contain one
% cycle for the lower frequency considered. Also, the filter must be at
% most long 1/3 of the data. That is:
% 
% > round(SamplingRate/LowerFrequency) <= order <= round(N-1)/3).
% 
% Generally, 3-5 cycles is a good value. BY default, this argument is set
% to 1/3rd the length of the functional timeseries.
% 
% dc: A string set to true or false. When set to true [DEFAULT], the
% resulting timeseries are dc-balanced -- i.e. the data is zero mean. When
% set to false, the filtered timeseries maintain their original mean
% value.
%
%
% EXAMPLE:
%
% self.TEMPORALFILT([.5,4],'order',60,'dc',false)   % bandpass 0.5Hz-4Hz.
% self.TEMPORALFILT(4,'order',60,'type','lp')       % low pass, 4Hz.
%
% self.TEMPORALFILT([.5,4],'order',60,'-showonly')  % display the filter. 
%
% See Also FEX_BANDPASS, FIR1, FEXW_FILTPLOT.
    

% Set default flags
flagdc   = true;
ind = find(strcmpi('dc',varargin));
if ~isempty(ind)
    flagdc = varargin{ind+1};
end
% Add flags for -showonly
flagshow = false;
if find(strcmpi('-showonly',varargin)) > 0
    flagshow = true;
end

% Make sure that param is provided
if ~exist('param','var')
    error('You need to specify the filter shape.');
end
shared_param = sort(param(1:min(2,length(param))));
args.param = [];

% Add filter type information
ind = find(strcmpi('type',varargin));
if isempty(ind) && length(shared_param) == 1
    args.type = 'hp';
elseif isempty(ind) && length(shared_param) == 2
    args.type = 'bp';
else
    args.type = varargin{ind+1};
end

% You need to gather length and fps information to assess whether order was
% properly specified (also adding Sampling frequency as the last element of
% param.
aargs = [];
ind = find(strcmpi('order',varargin));
for k = 1:length(self)
    args.param = [shared_param,1/mode(diff(self(k).time.TimeStamps))];
    k1 = size(self(k).functional,1)/3;
    k2 = 3*(args.param(end)/args.param(1));
    if isempty(ind)
        args.order = floor(min(k1,k2));
    else
        args.order = max(varargin{ind+1},param(end)/param(1));
        args.order = min(args.order,k1);
        if round(varargin{ind+1}) ~= args.order
        % Send a warning when order was changed 
            warning('Order was change (%.2d) from: %d to %d.\n',k,varargin{ind+1},args.order);
        end
    end
    % stack arguments
    args.order = round(args.order);
    aargs = cat(1,aargs,args);
end

% Compute filter from first FEXC
nyquist = ones(size(aargs(1).param)); nyquist(end) = 0.5;
X = double(self(1).functional);
T = self(1).time.TimeStamps;
I = ~isnan(sum(X,2));
X = interp1(T(I),X(I,:),T);
[ts,kr] = fex_bandpass(X,nyquist.*aargs(1).param,'order',aargs(1).order,'type',aargs(1).type);
if flagshow
% Run the function in display mode
    h = fexw_filtplot(kr,aargs(1).param(end));
    pause(); delete(h);
    return
else
% Apply temporal filtering
    h = waitbar(0,'Temporal filtering ... ');
    X = ts.real; X(repmat(I,[1,size(X,2)] == 0)) = nan;
    if ~flagdc
        X = X + repmat(nanmean(double(self(k).functional)),[size(X,1),1]);
    end
    self(1).update('functional',X);
    self(1).tempkernel = kr;
    for k = 2:length(self)
    % Proceed to stacked FEXC    
    X = double(self(k).functional);
    T = self(k).time.TimeStamps;
    I = ~isnan(sum(X,2));
    X = interp1(T(I),X(I,:),T);
    [ts,kr] = fex_bandpass(X,nyquist.*aargs(k).param,'order',aargs(k).order,'type',aargs(k).type);
    X = ts.real; X(repmat(I,[1,size(X,2)] == 0)) = nan;
    if ~flagdc
        X = X + repmat(nanmean(double(self(k).functional)),[size(X,1),1]);
    end
    self(k).update('functional',X);
    self(k).tempkernel = kr;
    waitbar(k/length(self),h);
    end
    delete(h)
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
       

function self = smooth(self,varargin)
%
% SMOOTH applies smoothing to the functional timeseries.
%
% SYNTAX: self.SMOOTH() self.SMOOTH(kk) self.SMOOTH(length)
% slef.SMOOTH(length,gpar)
%
% SMOOTH apply smoothing to the functional timeseries. SMOOTH can receive
% 0-2 input argument:
% 
% 0. If SMOOTH receives 0 arguments, the resulting functional data is a
%    running average over a second of video.
% 1. If SMOOTH receives 1 argument, and that argument is a scalar, SMOOTH
%    computes a running average over frames specified by the user.
% 1. If SMOOTH receives 1 argument, and that argument is a vector, the data
%    are convolved with that vector.
% 2. If SMOOTH receives 2 arguments, SMOOTH use a Gaussian kernel of
%    length indicated by the first argument, and standard deviation
%    inicated by the second argument.
%
% See also FEX_KERNEL.

% Read arguments
if isempty(varargin)
    kk = [];
elseif length(varargin) == 1 && length(varargin{1}) == 1
    kk = ones(varargin{1},1)./varargin{1};
elseif length(varargin) == 1 && length(varargin{1}) > 1
    kk = varargin{1}./sum(varargin{1});
elseif length(varargin) == 2
    pars = cell2mat(varargin);
    kk = normpdf(linspace(-2,2,round(max(pars))),0,min(pars));
    kk = kk./sum(kk);
else
    error('Wrong arguments specification.');
end

h = waitbar(0, 'Smoothing ... ');
% Smooth dataset using kernell kk
for k = 1:length(self)
    fprintf('Smoothing FEXC %d/%d.\n',k,length(self));
    if isempty(kk)
        fps = round(1/mode(diff(self(k).time.TimeStamps)));
        kk  = ones(fps,1)./fps;
    end
    
    % Remove/Insert NANS
    X = double(self(k).functional);
    T = self(k).time.TimeStamps;
    I = ~isnan(sum(X,2));
    if 1-mean(I) < 0.90
        X = convn(interp1(T(I),X(I,:),T),kk(:),'same');
        X(repmat(I,[1,size(X,2)])==0) = nan;
        self(k).update('functional',X);
        waitbar(k/length(self),h);
    else
        warning('Too few datapoints for FEXC %d.',k);
    end
end

self.derivesentiments();
delete(h);
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


% GRAPHIC METHODS *********************************************************
% ---------------********************************************************** 


function self = viewer(self)
% 
% VIEWER display the video and related statistics.
%
% SYNTAX:
%
% self.VIEWER()
%
%
% The VIEWER open a user interface generated by FEXW_STREAMERUI to display
% the video with related timeseries. It also displys summary statistics on
% the proportion of sentiments displayed in the video.
%
% For information on VIEWER UI see FEXW_STREAMERUI and related docs:
% 
% >> help FEXW_STREAMERUI
%
% NOTE that the method VIEWER cannot be called on a stacked FEXC directly.
% That is, if length(SELF) > 1, the call self.VIEWER will return an error.
% Use self(k).VIEWER instead -- for 1 >= k <= length(SELF).
%
% Not all video formats are readable in MATLAB. Moreover, efficient
% compressions are slow to unwrap from MATLAB. Therefore, videos that are
% difficult to read using VIDEOREADER are converted to motion jpeg files
% using ffmpeg (http://ffmpeg.org)**. The new videofile are saved in a
% subdirectory named 'fexwstreamermedia' in the current directory.
%
% OUTPUT:
%
% NOTE that self.VIEWER does not return any output. However, annotations
% taken within VIEWER are stored in the current FEXC object, they can be
% accessed using GET method, and they can be saved to a csv file using the
% FEXPORT method.
%
%
% **You can install ffmpeg using HOMEBREW (http://brew.sh) on OSX or using
% apt-get on Ubuntu.
%
%
% See also FEXW_STREAMERUI, GET, FEXPORT, VIDEOREADER.


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


end

    
% *************************************************************************  


function h = show(self,type,saveflag)
%
% self.SHOW generates the image spefified by TYPE.
%
% SYNTAX:
%
% h = self.SHOW()
% h = self.SHOW(type)
% h = self.SHOW(type,saveflag)
%
% TYPE is a string, which specifies what you want to plot.
%
% SAVEFLAG is a boolean value. When set to true, the image is svaed, when
% set to false, the image is displayed instead. When the image is
% displaied, you can press any keyboard value to delete it.
%
% When self is a single FEXC object, self.SHOW
% displays the image on the screen. Otherwise, self.SHOW will save the
% images in a subfolder in the main directory.
%
% NOTE: RIGHT NOW THE ONLY IMPLEMENTED PLOT IS A TIMESERIES OF EMOTIONS, SO
% TYPE IS IGNORED.
%
%
% See also FEXW_TIMEPLOT, FEX_GETCOLORS, FEX_STRTIME.

% Controll that one input variable is provided.
if ~exist('type','var')
    type = 'emotions';
end

% Save/Don't save when handling single file.
if ~exist('saveflag','var')
    saveflag = false;
end

% Only one option is implemented for now.
if ~strcmpi(type,'emotions')
    warning('Only emotion plots are implemeted.');
    type = 'emotions';
end

% Swicth across plots type.
switch lower(type)
    case 'emotions'
        if length(self) > 1
            hb = waitbar(0,'Printing images ... ');
            h = cell(length(self),1);
            for k = 1:length(self)
                h{k} = fexw_timeplot(self(k),'-save');
                waitbar(k/length(self),hb);
            end
            delete(hb);
        else
            h = fexw_timeplot(self);
            set(h,'Name','Press any key to exit');
            fprintf('Press any key to exit.\n')
            pause();
            if exist('h','var')
                delete(h);
            end
            if saveflag
                fexw_timeplot(self,'-save');
            end
        end
    otherwise
        error('Unrecognized argument: %s.',upper(type));
end
    
end


% *************************************************************************  

end % <<<-------------- END OF PUBLIC METHODS ------------------------| 


%**************************************************************************
%**************************************************************************
%************************** PRIVATE METHODS *******************************
%**************************************************************************
%**************************************************************************     

methods (Access = private)
%
% Private Methods:
%
% export2viewer - save data to .CSV file.
% swhoannotations - display annotation.
    
function self = export2viewer(self,filename)
%
% EXPORT2VIEWER utility function to save data as .CSV file.
% 
% SYNTAX:
%
% EXPORT2VIEWER(filename)
%
% This function exports the data to a comma separated file. The naming
% convetion follow Emotient Inc., so this data can be open using Emotient
% Inc. viewer. 
%
% This method cannot be access directly. Instead, use EXPORT.
%
% filename is the path where the file will be saved.
%
% See also FEXPORT, GET.


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
X = cat(2,X,zeros(size(X,1),1));

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


% Write the data to csv

% Create output directory
dirout = fileparts(filename);
if ~exist(dirout,'dir')
    mkdir(dirout);
end

% Create header
header_string = dict.Viewerhdr{1};
for i = 2:length(dict.Viewerhdr)
    header_string = sprintf('%s,%s',header_string,dict.Viewerhdr{i});
    % header_string = [header_string,',',dict.Viewerhdr{i}];
end

% Write csv file with header 
fid = fopen(filename,'w');
fprintf(fid,'%s\r\n',header_string);    
fclose(fid);
dlmwrite(filename,X,'-append','delimiter',',');

end   
 
%**************************************************************************

function ds = showannotation(self)
% 
% SHOWANNOTATION
%
% Converts to dataset and order the notes using each note starting
% time. When called without argument, the dataset with annotations
% is displayed on the console.
%
% This method cannot be access directly. Use GET or FEXPORT instead.
%
% See also GET. FEXPORT.

ds = [];
if ~isempty(self.annotations)
% Transform to dataset
    ds = struct2dataset(self.annotations);
    [~,ind] = sort(fex_strtime(ds.Start),'ascend');
    ds = ds(ind,:);
else
% You need to have notes
    fprintf('No annotation available.\n');
    return
end

end    

end


%**************************************************************************
%**************************************************************************

end

