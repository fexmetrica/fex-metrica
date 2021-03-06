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
% demographics - demographic information;
% video - Path to a video file;
% videoInfo - Vector with information about a video;
% functional - Dataset with facial expressions time series;
% structural - Dataset with face morphology information;
% sentiments - Inferred measures of positive or negative emotions;
% time - Dataset with frame by frame timestamps;
% design - Matrix or dataset with design information.
%
% FEXC Methods:
% 
% FEXC - FEXC constructor method.
%
% UTILITIES:
% summary - Print information about current FEXC object.
% fsave - Save FEXC objects to OUTDIR directory.
% clone	- Make a copy of FEXC object(s), i.e. new handle.
% reinitialize - Reinitialize the FEXC object to construction stage. 
% update - Changes FEXC fields.
% undo - retvert FEXC to previou state.
% nanset - Reset NaNs after INTERPOLATE or DOWNSAMPLE are used.
% get - Shortcut to get subset of FEXC variables or properties.
% listf - List variables names.
% fexport - Export FEXC data or notes to .CSV file.
% matrix - [... ...]
% 
% VIDEO UTILITIES:
% getvideoInfo - Read general information about a video file. 
% videoutil - Some implemented video transformation with ffmpeg.
%
% SPATIAL PROCESSING: 
% coregister - Register face boxes to average face video location.
% falsepositive	- Detect false alarms in FEXC.functional.
% motioncorrect	- Remove motion related artifact using regression.
%
% TEMPORAL PROCESSING:
% interpolate - Interpolate timeseries & manages NaNs.  
% downsample - Reduced functional sampling rate to desired fps.
% smooth - Smooth time series using standard or costume kernel.
% temporalfilt - Apply low, high, or bandpass filter to FEXC.functional.
% getband - [... ...]
%
% NORMALIZATION:
% rectification	- Set a lower value for FEXC.functional time series.
% setbaseline - Set the BASELINE property (private), and normalize data.
% normalize	- normalizes the dataset.
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
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 23-Apr-2015.

    
properties
    % NAME: a string containing a descriptive name for the video, e.g.
    % participant name. When the field is not specified, this is set to
    % the name (without extension) of the video file. If no videofile
    % was provided, this name is set to "John Doe."
    name
    % DEMOGRAPHICS: field contaning demographic information. For now, the
    % only field in DEMOGRAPHICS is "isMale", a real vlaue score, which is
    % positive for male, and negative for female.
    %
    % See also GET.
    demographics
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
    % VERSION: version of the SDK used (default: unknown).
    version
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
    % DESIGN: Dataset with design information. NOTE: DESIGN property is
    % only partially implemented.
    %
    % See also FEXDESIGNC.
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
    % VERBOSE: Verbosity level. When set to false, operation will not
    % generate a waiting bar. Default: True. This property can be changed
    % using the method UBDATE.
    %
    % See also UPDATE.
    verbose
    % ENGINE: Emotient analytic engine: this is a structure with fields:
    %   isapi
    %   issdk
    %
    % NOTE: Not implemented yet.
    engine
end


%**************************************************************************
%**************************************************************************
%************************** PUBLIC METHODS ********************************
%**************************************************************************
%**************************************************************************    

methods
function self = fexc(varargin)
%
% FEXC - constructor routine.
%
% USAGE:
%
% fexObj = FEXC()
% fexObj = FEXC('ui')
% fexObj = FEXC('load',filepath)
% fexObj = FEXC('data', datafile)
% fexObj = FEXC('data', datafile,'ArgNam1',ArgVal1,...)
% fexObj = FEXC('video',videolist)
% fexObj = FEXC('video',videolist,'ArgNam1',ArgVal1,...)
%
% Creates a FEXC object. There are four main methods to create a FEXC
% object using this constructor:
%
% (1) FEXC() creates an empty FEXC object. You can add data and information
%     using the method UPDATE.
% (2) FEXC('ui') opens a UI that assists in generating the object. 
% (3) FEXC('load',filepath, ...)
% (4) FEXC('data', datafile) or FEXC('data',datafile,'ArNam',ArVal,..)
%     creates a FEXC object that was already processed with the FACET SDK.
% (5) FEXC('video',videolist) or FEXC('video',videolist,'ArNam',ArVal,...),
%     creates the FEXC object when you have th videos, but you don't have
%     them processed with FACET SDK yet. This method is only triggered when
%     you enter 'video', but you don't enter 'data.'
%    
%
% ARGUMENTS:
%
% data         - dataset used to specify FUNCTIONAL and STRUCTURAL
%                properties.
% video        - Path to a video file.
% TimeStamps   - Vector of time stamps. This argument is not required. When
%                it is not specified and it is not included in 'data,' it
%                is left empty. Alternative, TimeStamps can be a scalar,
%                which indicates the number of frames per second.
% design       - Dataset with design information.
% outdir       - Output directory for the results.
%
%
% See also FEXGENC, FEX_CONSTRUCTORUI, UPDATE, FEX_FACETPROC, FEX_IMPUTIL,
% FEXWSEARCHG.


% handle function to read "varargin"
% readarg = @(arg)find(strcmp(varargin,arg));

if isempty(varargin)
% -----------------------------------------------------------
% Generate empty FEXC object
% -----------------------------------------------------------
    self = self.init();
    return 
elseif strcmpi(varargin{1},'ui')
% -----------------------------------------------------------
% Import using UI
% -----------------------------------------------------------
    h = fex_constructorui();
    if isempty(h)
        return
    else
    he = waitbar(0,sprintf('FEXC: 1 / %d',length(h.files)));
    self = h.export(1);
    % Propagare the timetag
    temp_des = self.design;
    for k = 2:length(h.files)
        self = cat(1,self,h.export(k,temp_des));
        waitbar(k/length(h.files),he,sprintf('FEXC: %d / %d',k,length(h.files)));
    end
    delete(he);
    self.update('name',h.name);
    self.update('outdir',h.targetdir);
    end
    return
elseif strcmpi(varargin{1},'load')
% -----------------------------------------------------------
% Reload a FEXC Object
% -----------------------------------------------------------   
    fids = {'*.fex','Fex File'; '*.mat','Mat File'};
    if length(varargin) < 2
        [FileName,PathName]= uigetfile(fids,'Select Files','MultiSelect','on');
        if ischar(FileName)
            name_file{1} = sprintf('%s/%s',PathName,FileName);
        else
            name_file = cell(length(FileName));
            for k = 1:length(name_file)
                name_file{k} = sprintf('%s/%s',PathName,FileName{k});
            end
        end
    else ischar(varargin{2})
        name_file{1} = varargin{2};
    end
    % Load fexc objects
    try
        h = importdata(name_file{1});
    catch 
        error('%s not found.',name_file{1});
    end
    if isa(h,'cell')
        name_file = h;
    end
    self = importdata(name_file{1});
    for k = 2:length(name_file)
        self = cat(1,self,importdata(name_file{k}));
    end
    return
elseif isa(varargin{1},'struct')
% -----------------------------------------------------------
% Structure with arguments (FEXGEN.EXPORT)
% -----------------------------------------------------------
    warning('off','stats:dataset:subsasgn:DefaultValuesAdded');
    args = varargin{1};
    O = [];
    for k = 1:length(args)
        obj = self.init();
        obj.video = args(k).video;
        obj.checkargs(args(k));
        obj.derivesentiments();
        obj.descriptives();
        obj.history.original = obj.clone();  
        O = cat(1,O,obj);
    end    
    self = O;
    warning('on','stats:dataset:subsasgn:DefaultValuesAdded');
    return 
else
% --------------------------------------------------------------
% Cell argument with data provided
% --------------------------------------------------------------
    h = fexgenc(varargin);
    he = waitbar(0,sprintf('FEXC: 1 / %d',length(h.files)));
    self = h.export(1);
    for k = 2:length(h.movies)
        self = cat(1,self,h.export(k));
        waitbar(k/length(h.files),he,sprintf('FEXC: %d / %d',k,length(h.files)));
    end
    delete(he);
    self.update('name',h.name);
    self.update('outdir',h.targetdir);
    return
end

end

% ================================================================
% CLASS UTILITIES
% ================================================================

function varargout = summary(self)
%
% SUMMARY - print information about current FEXC object.
%
% USAGE:
%
% self.summary();
%
% See also GET.

tabinfo.Id       = [];
tabinfo.Name     = self.get('names');
tabinfo.Gender   = self.get('gender');
tabinfo.Duration = [];
tabinfo.Fps      = [];
tabinfo.NullObs  = [];
tabinfo.Positive = [];
tabinfo.Negative = [];

for k = 1:length(self)
    tabinfo.Id = cat(1,tabinfo.Id,k);
    tabinfo.Duration = cat(1,tabinfo.Duration,self(k).time.TimeStamps(end));
    tabinfo.Fps      = cat(1,tabinfo.Fps,1/mean(diff(self(k).time.TimeStamps)));
    fp = sum(isnan(sum(self(k).get('emotions','double'),2)));
    fp = round(100*fp./size(self(k).functional,1));
    tabinfo.NullObs = cat(1,tabinfo.NullObs,fp);
    tabinfo.Positive = cat(1,tabinfo.Positive,mean(self(k).sentiments.Winner == 1));
    tabinfo.Negative = cat(1,tabinfo.Negative,mean(self(k).sentiments.Winner == 2));
end
tabinfo.Duration = char(fex_strtime(tabinfo.Duration,'short'));

fprintf('\n%d-dimension FEXC object with the following properties:\n\n',length(self));
tabinfo = struct2table(tabinfo);

if nargout == 0;
    disp(tabinfo);
else
    varargout{1} = tabinfo;
end
    
    
end

% *************************************************************************

function self = merge(self,nefx)
%
% MERGE - add variables from the FEXC object nefx not included in self.
%
% Usage: 
%
% self.merge(nefx)

for prop =  {'structural','functional'};
    hdr1 = nefx(1).(prop{1}).Properties.VarNames;
    hdr2 = self(1).(prop{1}).Properties.VarNames;
    [nhd,ind] = setdiff(hdr1,hdr2);
    
    for k = 1:length(self)
        s1 = size(self(k).(prop{1}),1);
        s2 = size(nefx(k).(prop{1}),1);
        d = s1 - s2;
        if d == 0
            self(k).(prop{1}) = [self(k).(prop{1}), nefx(k).(prop{1})(:,ind')];
        elseif d > 0
        % FIXME: ADD WORNING FOR SIZE ISSUE
            add_var = double(nefx(k).(prop{1})(:,ind'));
            add_var = cat(1,add_var,nan(d,size(add_var,2)));
            add_var = mat2dataset(add_var,'VarNames',nhd(:)');
            self(k).(prop{1}) = [self(k).(prop{1}), add_var];
        end
    end
end

end

% *************************************************************************

function fsave(self,is_compact,dir_out,name_used)
%
% SAVE saves the current FEXC handle.
%
% SYNTAX:
% self.SAVE()
% self.SAVE(IS_COMPACT)
%
% Save saves a FEXC object to the directory specified in SELF.OUTDIR. The
% flafg IS_COMPACT determines whether each of the FEXC object in a stuck
% are saved together (IS_COMPACT = true), or whether they are saved as
% separate files (IS_CONPACT = false). Default is IS_COMPACT = 1.
%
% NAME_USED is a string used for the name of the saved file. Default is
% "FexObj," s.t. FEXC will be saved to:
%
%  [SELF.OUTDIR]/[NAME_USED].fex
%
% Note that if there are multiple objects within a FEXC stack, and each
% object is saved independently, the name of each object k will be the
% string SELF(k).name. A [NAME_USED].fex file will also be generted, which
% contains a list of the new .fex files.
% 
% NOTE: If previous versions where saved, those versions will be
% overwritten.

% TODO: Add safety check for param specification, and for overwriting.

if ~exist('is_compact','var')
    is_compact = 1;
end

if ~exist('name_used','var')
    name_used = 'FexObj';
end

if ~exist('dir_out','var')
    dir_out = self(1).outdir;
elseif ~exist(dir_out,'dir')
    mkdir(dir_out);
end

% Save FEXC
if is_compact || length(self) == 1
    save_as = sprintf('%s/%s.fex',dir_out,name_used);
    save(save_as,'self');
else
    save_as = cell(length(self),1);
    for k = 1:length(self)
        if isa(self(k).name,'double')
            save_as{k} = sprintf('%s/%d.fex',dir_out,self(k).name);
        else
            save_as{k} = sprintf('%s/%s.fex',dir_out,self(k).name);
        end
        temp = self(k);
        save(save_as{k},'temp');
        clear temp
    end
    % Store the list for loading
    save(sprintf('%s/%s.fex',dir_out,name_used),'save_as');
end

end



% *************************************************************************

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

newself = [];  
p = properties(self(1));
for k = 1:length(self)
newself = cat(1,newself,fexc());
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
newself(k).naninfo     = self(k).naninfo;

end

end

% *************************************************************************

function self = undo(self)
%    
% UNDO revert to previous version of FEXC.
% 
% SYNTAX
% self.UNDO()
%
% DESCRIPTION
% UNDO can be use to revert to the version of FEXC before the last
% operation.
%
% Note that ANNOTATIONS can NOT be undone. Additionally, note REDO can be
% achieved calling UNDO again:
%
%   > self.UNDO(self.UNDO())
%
%
% See also CLONE, GET, ANNOTATIONS, REINITIALIZE.

for k = 1:length(self)
    if ~isempty(self(k).history.prev)
    h = self(k).clone();
    % Overwrite public properies
    for p = [properties(self(k))','descrstats','naninfo'];
        self(k).(p{1}) = self(k).history.prev.(p{1});
    end
    % Overwrite private properties
    self(k).tempkernel  = self(k).history.prev.tempkernel;
    self(k).thrsemo     = self(k).history.prev.thrsemo;
    self(k).coregparam  = self(k).history.prev.coregparam;
    self(k).descrstats  = self(k).history.prev.descrstats;
    self(k).naninfo     = self(k).history.prev.naninfo;
    % Allow REDO - Now Prev is set to the FEXC object after the operation
    % that was just undone.
    self(k).history.prev = h;
    else
    warning('Nothing to undo ... ');
    end
end

end

% *************************************************************************

function self = update(self,arg,val)
%
% UPDATE - changes FEXC properties values.
% 
% SYNTAX:
%
% self(k).UPDATE(PropName,PropVal)
%
%
% PROPNAME: Name of the property affected by UPDATE. Properties supported
% by UPDATE are:
%
%
% 1. 'design': Add the design, or adjust the size of the design to match the
%    size of the functional timeseries. In this case, VAL can be:
%       
%    - A string set to 'ui', which opens a User Interface for design file
%      import and editing if design were not imported at the time of
%      construction. If design were imported already, the UI allows to make
%      modification to the design matrix. You can indicate the modification
%      with the UI on the frist design matrix, and the changes are
%      propagated to all the FEXC istances in the stack.
%
%    - A string or cell with a list of design files that will be imported.
%      If you want to make changes to the design files, you can call UPDATE
%      again, with the argument 'ui';
%
%    - VAL can be left empty, in which case UPDATE will simply ALIGN the
%      design to reflect the current size of FUNCTIONAL (e.g., you
%      interpolated or downsampled the timeseries and you want the design
%      to have the proper size. NOTE: this is done done automatically by
%      other methods.
%    
%
% 1. 'functional' ... 
% 2. 'outdir' ... 
% 3. 'name' ...
% 4. 'structural' ... 
% 5. 'video' ... 
% 6. 'design' ...
% 7. 'verbose' ... 
% 8. 'baseline' ... 
%
%
% NOTE that UPDATE for 'functional' and 'structural' don't work on stacks
% of FEXC. So, if length(FEXC) > 1, UPDATE needs to be called several
% times.
%
%
% See also FEXC, FEXDESIGNC.


% ---------------------------
% Add backup for undo
% ---------------------------
self.beckupfex();


% ---------------------------
% Change Selected field
% ---------------------------
switch lower(arg)
case {'functional','structural'}
    if length(self) > 1
        warning('UPDATE does not operate on stacked FEXC for this field.');
        return
    elseif size(val,2) == size(self.(arg),2)
        self.(arg) = replacedata(self.(arg),val);
    else
        error('Size mismatch.')
    end
case {'name','video'}
    if length(self) ~= size(val,1)
        error('Not enough "%s" provided.',arg);
    else
        for k = 1:length(self)
            try
                % FIXME:
                % self(k).(arg) = deblank(char(val(k,:)));
                self(k).(arg) = val{k};
            catch
                self(k).(arg) = val(k,:);
            end
        end
    end
case 'outdir'
    if isa(val,'char')
        val = cellstr(val);
    end
    if length(self) == size(val,1)
        for k = 1:length(self)
            self(k).outdir = val{k};
        end
    elseif size(val,1) == 1
        for k = 1:length(self)
            self(k).outdir = val{1};
        end
    end
case 'design'
    % Design update option
    % --------------------
    % Default is to reallign the design matrix with the facial expression
    % matrix.
    if ~exist('val','var')
        for k = 1:length(self)
            self(k).design.align(self(k).time);
        end
    % --------------------
    % Open the UI to update the design: This option allows:
    %
    % - Add/Modify the existing design;
    % - Replace existing design with a new one;
    % - Add new information to the existing design.
    elseif strcmpi(val,'ui')
        if isempty(self(1).design)
            list = fexwsearchg('Select Design Files');
            for k = 1:length(self)
                self(k).design = deblank(list(k,:));
            end
        end
        self(1).design = feximportdg('file',self(1).design);
        self(1).design.align(self(1).time);
        for k = 2:length(self)
            self(k).design = self(1).design.convert(self(k).design);
            self(k).design.align(self(k).time);
        end
    % --------------------
    % Provide a list of files which will be used as design.
    elseif isa(val,'char') || isa(val,'cell')
        val = char(val);
        for k = 1:length(self)
            self(k).design = fexdesignc(val(k,:));
            self(k).design.align(self(k).time);
        end
    else
        error('Mispecified design argument.');                
    end
case 'verbose'
    for k = 1:length(self)
        if val
            self(k).verbose = val;
        else
            self(k).verbose = false;
        end
    end
case {'demographics','demo'}
    % FIXME: This has no safty check & It won't work with EMOTIENT
    opt  = fieldnames(self(1).demographics);
    dict = containers.Map({'gender','ismale','male', 'age', 'race'},[1,1,1,2,3]);
    for j = fieldnames(val)
        if isKey(dict,lower(j{1}));
            for k = 1:length(self)
                if dict(lower(j{1})) == 1 && isa(val.(j{1}),'cell')
                    if strcmpi(val.(j{1}){k}(1),'m')
                        self(k).demographics.isMale = 1;
                    else
                        self(k).demographics.isMale = -1;
                    end
                else
                    self(k).demographics.(opt{dict(lower(j{1}))}) = val.(j{1})(k);
                end
            end
        end
    end
case 'baseline'
    % New videos or image files to be processed
    % New set of FEXC objects already processed
    % New set of text / csv files 
    % FIXME: Only the mean is used right now
    
    
case 'time'
% FIXME: this is a special case for the AB data
%     for k = 1:size(val,1)
%         nt = linspace(0,val(k),size(self(k).functional,1));
%         self(k).time.TimeStamps = nt';
%         self(k).time.StrTime = fex_strtime(nt');
%     end
% FIXME: VAL is a list of 
    for k = 1:length(val)
        T = importdata(val{k});
        if size(T,1) == size(self(k).functional,1)
            nt = T.Time;
        elseif (size(T,1) - size(self(k).functional,1)) >= -10
            del = size(self(k).functional,1) - size(T,1);
            del = cumsum(mean(diff(T.Time))*ones(del,1));
            nt  = [T.Time; T.Time(end)+del];
        elseif (size(T,1) - size(self(k).functional,1)) < -10
            nt = linspace(mean(diff(T.Time)),T.Time(end),size(self(k).functional,1));
        else
            error('Dimension Mismatch.');
        end
        self(k).time.TimeStamps = nt(:);
        self(k).time.StrTime = fex_strtime(nt(:));
        % Update videoinfo
        self(k).videoInfo(1:3) = [1/mean(diff(self(k).time.TimeStamps)),...
            self(k).time.TimeStamps(end),...
            size(self(k).time,1)];
    end
otherwise
    error('Unrecognized field "%s".',arg);
    
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
% consecutie NaN which will be considered reset to NaN. Default for RULE is
% 15 frames.
% 
% See also INTERPOLATE, DOWNSAMPLE.

% Add backup for undo
self.beckupfex();

if ~exist('rule','var')
    rule = 15;
end

hdr = self(1).functional.Properties.VarNames;
for k = 1:length(self)
    X   = double(self(k).functional);
    X(repmat(self(k).naninfo.count >= rule,[1,size(X,2)])) = nan;
    self(k).functional = mat2dataset(X,'VarNames',hdr);
end
self.derivesentiments();
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
% Note that ANNOTATIONS are NOT reinitialized. 
%
% See also CLONE, GET, ANNOTATIONS.


% Add backup for undo
self.beckupfex();

if ~exist('flag','var')
    flag = 'coward';
end
% Ask for confirmation
if ~strcmpi(flag,'force')
result = input('Do you really want to revert to original? y/n [y]: ','s');
if isempty(result) || ~strcmpi(result,'y')
    fprintf('''Reinitialize'' aborted.\n');
    return
end
end

% Reinitialization loop
for k = 1:length(self)
    % Overwrite public properies
    for p = [properties(self(k))','descrstats','naninfo'];
        self(k).(p{1}) = self(k).history.original.(p{1});
    end
    % Overwrite private properties
    self(k).tempkernel  = [];
    self(k).thrsemo     = 0;
    self(k).coregparam  = [];
    % Fixme: not properly implemented.
    self(k).naninfo     = [];
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
% Note: GETVIDEOINFO tries to use ffmpeg instead of matlab VIDEOREADER,
% because it saves time. When it fails, it will attempt to use VIDEOREADER
% instead. If all fails, the property VIDEOINFO is left empty.
% 
% See also VIDEOINFO.

prop = {'FrameRate','Duration','NumberOfFrames','Width','Height'};

for k = 1:length(self)
% -----------------
% TRY WITH FFMPEG
% -----------------
try
    cmd   = sprintf('ffmpeg -i %s 2>&1 | grep "Duration"',self(k).video);
    [~,o] = unix(sprintf('source ~/.bashrc && %s',cmd));
    s = strsplit(o,' ');
    % FIXME:  This makes the assumption that it is always in 3rd position.
    VI(2) = fex_strtime(s{3}(1:end-1));
    cmd   = sprintf('ffmpeg -i %s 2>&1 | grep "fps"',self(k).video);
    [~,o] = unix(sprintf('source ~/.bashrc && %s',cmd));
    s = strsplit(o,' ');
    VI(1) = str2double(s{find(strcmp(s,'fps,'))-1});
    % FIXME:  This makes the assumption that it is always in 11th position.
    VI(4:5) = cellfun(@str2double,strsplit(s{11},'x'));
    % FIXME: This is an approximation
    VI(3) = round(VI(2)*VI(1));
    self(k).videoInfo = VI;
catch
% -----------------
% TRY WITH MATLAB     
% -----------------
    try
        self(k).videoInfo = cell2mat(get(VideoReader(self(k).video),prop));
    catch errorID
        warning(errorID.message);
    end
end

end

end

% *************************************************************************

function self = videoutil(self,crop_frame,change_fexc)
%
% VIDEOUTIL - Shortcut to video utility actions with ffmpeg.
%
% SYNTAX:
% self.VIDEOUTIL()
% self.VIDEOUTIL(CROP_FRAME)
% self.VIDEOUTIL(CROP_FRAME,APPLY)
%
% VIDEOUTIL methods wraps few functionality from ffmpeg, and allows to
% apply selected operation to the video file. VIDEOUTIL will create a new
% video with the same name of the original one in a subfolder named
% FEXSTREAMERMEDIA located in the current directory. If a video already
% exists, the user is asked to give confirmation on the command line. The
% default action of VIDEOUTIL is to save each video to uncompressed AVI
% format. This is required by FEXW_STREAMERUI UI. Default: true.
%
% ARGUMENTS:
% 
% CROP_FRAME - Used to reduce the frame size to a box of given size. The
%   user can set CROP_FRAME to true. VIDEOUTIL will use the method GET to
%   obtain a box that contains the face boxes from each frame. This facebox
%   is then used to crop the video. Alternatively, the user can enter a
%   vector [X_0, Y_0, Width, Hight] with a custome face box. Default:
%   false.
% CHANGE_FEXC - Boolean value. When set to true, it applies the changes to
%   the FEXC object. In the case of UNCOMP = 1, APPLY will set self.VIDEO
%   to the new video file. When CROP = 1, APPLY will adjust the coordinates
%   of the STRUCTURAL field to account for the new frame size. Default:
%   false.
%
%
% NOTE: to use this method you need to have a video and to have ffmpeg
% installed.
%
%
% See also FEXW_STREAMERUI, GET, STRUCTURAL.


% Add backup for undo
% ----------------
self.beckupfex();


% Get Executable 
% ----------------
if strcmpi(computer,'glnxa64')
    EXEC = 'avconv';
else
    EXEC = 'ffmpeg';
end

% Read arguments in
% ----------------
if ~exist('crop_frame','var')
    crop_frame = false;
end
if ~exist('change_fexc','var')
    change_fexc = false;
end

% Detect Crop options
% ------------------
if ~isa(crop_frame,'logical') && ~ismember(4,size(crop_frame))
    error('CROP_FRAME option mispecification.');
elseif isa(crop_frame,'logical')
    B = get(self,'facebox','double');
elseif length(self) == size(crop_frame,1)
    B = crop_frame;
    crop_frame = true;
elseif length(self) > 1 && size(crop_frame,1) == 1
    B = repmat(crop_frame,[length(self),1]);
    crop_frame = true;
else
    error('CROP_FRAME option mispecification.');
end

% Create directory for new videos in the current directory
if ~exist('fexwstreamermedia','dir')
    mkdir('fexwstreamermedia');
end

% Apply operations
for k = 1:length(self)
self(k).video = deblank(self(k).video);
if exist(self(k).video,'file')
    strc = ' ';
    if crop_frame
    % Add crop string [W:H:X:Y];
        [~,fname] = fileparts(self(k).video);
        new_name  = sprintf('%s/fexwstreamermedia/c%s.avi',pwd,fname);
        strc = sprintf('crop=%d:%d:%d:%d',round(B(k,[3,4,1,2])));
    else
        [~,fname] = fileparts(self(k).video);
        new_name  = sprintf('%s/fexwstreamermedia/%s.avi',pwd,fname);
    end
    % Execute (-s 960x540 -vcodec libx264 -vpre medium)
    cmd = sprintf('ffmpeg -i %s -vcodec mjpeg -an -q 0 -filter:v "%s" %s',self(k).video,strc,new_name);
    if exist('~/.bashrc','file')
        cmd = sprintf('source ~/.bashrc && %s',cmd);
    end
    [isError,output] = system(cmd,'-echo');
    % [isError,output] = unix(sprintf('%s',cmd),'-echo');
    % Something went wrong: print error and escape
    if isError ~= 0 
        warning(output);
    end
    % Apply transformations to FEXC object
    if change_fexc
        warning('CHANGE_FEXC is not implemented yet.');
    end 
else
    warning('Missing video (%d): %s.',k,self(k).video);
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
% D  Infornation on null observation ('naninfo'). When length(self) == 1, X
%    is a dataset, with as many rows as frames in FUNCTIONAL, and variables
%    'count', 'tag' and 'falsepositive' (see NANINFO). When length(self) >
%    1, X is a matrix with as many rows length(self). Columns indicate:
%    overall number of Nans, Number of clusters of nans, and number of
%    falsepositive identified.
% E. coordinates for a facebox which include all face boxes in the video
%    (string set to 'facebox').
%
% SPEC options depend on the value of REGARG.
%
% A. SPEC is a string which indicates the format of the data outputed. SPEC
%    can be 'dataset,' in which case a dataset is outputed; it can be
%    'struct.' Alternatively, 'type' can be set to 'double,' in which case
%    the output is a matrix without column names. Default: 'dataset.'
% B. SPEC is a string set to '-global' when you want to compute a
%    statistics across all FEXC objects in self. Default: '-local'.
% C. SPEC is used as in A.
% D. SPEC has no effect on this call.
%
%
% See also: DESCRIPTIVES, VIEWER, NANINFO, FALSEPOSITIVE.

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
    case 'design'
        for k = 1:length(self)
            X = cat(1,X,self(k).design.align(self(k).time));
        end
    case 'sentiments'
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,{'positive','negative','neutral'}));
        end
    case 'dsentiments' % Derived sentiments
        for k = 1:length(self)
            idn  = sum(~isnan(double(self(k).functional)),2);
            idn(idn == 0)    = nan;
            idn(~isnan(idn)) = self(k).sentiments.Combined;
            X = cat(1,X,mat2dataset(idn,'VarNames',{'SentimentsDrived'}));
        end
    case {'au','aus','actionunits'}
        ind = strncmpi('au',self(1).functional.Properties.VarNames,2);
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,ind));
        end
    case 'emotions'
        list = self.listf('primary');
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,list));
        end
    case {'advanced_emotions','secondary'};
        list = self.listf('secondary');
        for k = 1:length(self)
            X  = cat(1,X,self(k).functional(:,list));
        end
    case 'landmarks'
        list = self.listf('land');
        for k = 1:length(self)
            try
                X = cat(1,X,self(k).structural(:,list));
            catch
                X = cat(1,X,nan(size(self(k).structural,1),1));
            end
        end
    case 'face'
        ind = cellfun(@isempty,strfind(self.structural.Properties.VarNames, 'Face'));
        for k = 1:length(self)
            X   = cat(1,X,self(k).structural(:,ind==0));
        end
    case 'facebox'
        facehdr = {'FaceBoxX','FaceBoxY','FaceBoxW','FaceBoxH'};
        for k = 1:length(self)
            try
                B = double(self(k).structural(:,facehdr));
                B = B(sum(B,2) ~= 0,:);
                B(:,3:4) = B(:,1:2) + B(:,3:4);
                B = [min(B(:,1:2)), max(B(:,3:4)) - min(B(:,1:2))];
            catch
                B = nan(1,4);
            end
            X = cat(1,X,B);
        end
        X = mat2dataset(X,'VarNames',facehdr);
    case 'pose'
        for k = 1:length(self)
            X  = cat(1,X,self(k).structural(:,{'Roll','Pitch','Yaw'})); 
        end
    case {'name','names'}
        X = {};
        for k = 1:length(self)
            X = cat(1,X,self(k).name);
        end
        if ischar(X{1})
            X = strtrim(X);
        else
            X = cell2mat(X);
        end
    case {'video','videos','movie','movies'}
        X = {};
        for k = 1:length(self)
            X = cat(1,X,self(k).video);
        end
        X = strtrim(X);  
    case fieldnames(self(1).descrstats)
        self.descriptives();
        % look for global or local varibles.
        if strcmpi(Spec,'-global')
            k = strcmpi(ReqArg,self(1).descrstats.glob.Properties.ObsNames);
            X = double(self(1).descrstats.glob(k,:));
        else        
            for k = 1:length(self)
                X = cat(1,X,self(k).descrstats.(ReqArg));
            end
            % add headers
            if strcmpi(ReqArg,'perc')
                X = mat2dataset(X,'VarNames',self(k).descrstats.hdrs{2}{1});
            else
                X = mat2dataset(X,'VarNames',self(k).descrstats.hdrs{1}{1});
            end
            n = self.get('names');
            X.Properties.ObsNames = char(n);
        end
    case {'naninfo','nan'}
    % Read naninfo private property
        if length(self) == 1
            X = self.naninfo;
        else
            VarNames = self(1).naninfo.Properties.VarNames;
            for k = 1:length(self)
                X = cat(1,X,nansum(double(self(k).naninfo)));
                X(end,2) = max(self(k).naninfo.tag);
            end
            X = mat2dataset(X,'VarNames',VarNames);
        end 
    case {'notes','annotations'}
        for k = 1:length(self)
            nnts = self(k).showannotation;
            X = cat(1,X,nnts);
        end
    case {'dirout','outdir'}
        for k = 1:length(self)
            X = cat(1,X,{self(k).outdir});
        end
        if length(X) == 1
            X = char(X);
        end
    case 'gender'
        X = {};
        for k = 1:length(self)
            if ischar(self(k).demographics.isMale)
                X = cat(1,X,{self(k).demographics.isMale});
            elseif isa(self(k).demographics.isMale,'cell')
                X = cat(1,X,self(k).demographics.isMale);
            elseif self(k).demographics.isMale > 0
                X = cat(1,X,{'Male'});
            else
                X = cat(1,X,{'Female'});
            end
            X = char(X);
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

function n = listf(self,type)
%
% self.LIST - list variables names.
%
% SYNTAX:
%
% se;f.LIST()
% self.LIST(TYPE)
%
% TYPE is a string set to:
%
%  |  String      | Shortcut   |            Output              |
%  | ============ | ========   | ============================== |
%  | 'primary'    | 'p','pe'   | 7 Primary emotions names       |
%  | 'secondary'  | 'se','cf'  | Confusion and frustration      |
%  | 'emotions'   | 'e'        | Primary and secondary emotions |
%  | 'aus'        | 'a'        | Action Units                   |
%  | 'face'       | 'f'        | Face box (X,Y,W,H)             |
%  | 'landmarks'  | 'land','l' | Landmarks coordinates          |
%  | 'sentiments' | 's','sent' | Sentiments                     |
%  | 'pose'       | 'ps'       | Pose                           |
%  | ============ | ========   | ============================== |
%
%
% When TYPE is empty, the output cell "n" contains all available features.
% Otherwise, "n" is a cell with the features name. NOTE that these features
% are not necessarely included in the current FEXC object.
%
% 
% See also GET

if ~exist('type','var')
    type = 'all';
end

% Fixme: use dictionary instead.
c = dataset('File','fexchannels.txt');
switch lower(type)
    case {'primary','p','pe'}
      target = 'emo1';
    case {'secondary','se','cf'}
      target = 'emo2';
    case {'emotion','emotions','e'}
      target = {'emo1','emo2'};
    case {'aus','au','a'}
      target = 'au';
    case {'face','f'}
      target = 'face';
    case {'landmarks','landmark','land','l'}
       target = 'land';
    case {'sentiments','sentiment','s','sent'}
       target = 'sent1';
    case {'pose','ps'}
       target = 'pose';
    case 'all'
       target = unique(c.Class);
    otherwise
       warning('TYPE not recognized: %s.', type);
end
   
n = deblank(c.Name(ismember(c.Class,target)));

end


% *************************************************************************

function flist = fexport(self,Spec,dirname)
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
% - 'UI': Opens a gui for selecting the variables to save.
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
% See also GET, VIEWER, FEXCHANNELSG.


% ---------------------------------------
% Check Spec / Start UI if needed
% ---------------------------------------
if ~exist('Spec','var')
    Spec = 'ui';
end
if strcmpi(Spec,'ui')
    ui_rules = fexchannelsg(self(1));
    dirname  = ui_rules.select_dir;
    save_extension = ui_rules.save_extension;
    if ~ismember(save_extension,{'.csv','.mat'})
        save_extension = '.csv';
    end
    ui_rules = rmfield(ui_rules,{'save_extension','select_dir'});
    if isempty(ui_rules)
        error('No saving parameters specified.');
    end
end

% ---------------------------------------
% Select output directory
% ---------------------------------------
if exist('dirname','var')
    SAVE_TO = repmat(dirname,[length(self),1]);
elseif ~iesmpty(self(1).dirout)
    SAVE_TO = self.get('dirout');
else
    SAVE_TO = repmat(pwd,[length(self),1]);
end
SAVE_TO = [SAVE_TO,repmat('/fexport/',[length(self),1])];

% ---------------------------------------
% Select output name
% ---------------------------------------
if ~exist('save_extension','var')
    save_extension = '.csv';
end
NAME_TO = char(self.get('name'));

% ---------------------------------------
% Initiate loop / waitbar
% ---------------------------------------
h = waitbar(0,sprintf('Exporting %s ... ',Spec));
flist = cell(length(self),1);
for k = 1:length(self)
    if ~exist(SAVE_TO(k,:),'dir')
        mkdir(SAVE_TO(k,:));
    end
% ---------------------------------------
% Select / Generate output directory
% ---------------------------------------
%     if isempty(self(k).outdir)
%         SAVE_TO = sprintf('%s/fexexport',pwd); 
%     else
%         SAVE_TO = sprintf('%s/fexexport',self(k).outdir);
%     end
%     if ~exist(SAVE_TO,'dir')
%         mkdir(SAVE_TO);
%     end
% ---------------------------------------
% Set up a filename
% ---------------------------------------  
%     if ~isempty(self(k).name)
%         bname = self(k).name; 
%     elseif ~isempty(self(k).video)
%         [~,bname] = fileparts(self(k).video);
%     else
%         bname = sprintf('fexexport_%s',datestr(now,'HH_MM_SS'));   
%     end
% ---------------------------------------
% Switch across options
% ---------------------------------------     
    % Save the data
    switch lower(Spec)
        case 'ui'
            ds = self(k).time(:,2);
            for j = {'design','emotions','secondary','sentiments','dsentiments','actionunits','structural'};
                if ui_rules.(j{1}) == 1
                    ds = cat(2,ds,self(k).get(j{1}));
                end
            end
            flist{k} = [SAVE_TO(k,:),NAME_TO(k,:),save_extension];
            % FIXME: This allows only ".mat" files and ".csv" files
            if strcmp(save_extension,'.mat')
                save(flist{k},'ds');
            elseif strcmp(save_extension,'.csv')
                export(ds,'file',flist{k},'Delimiter',',');
            end
        case {'data','data1'}
        % Export all the datasets
            flist{k} = [SAVE_TO(k,:),NAME_TO(k,:)];
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
            % X.location_x = self(k).structural.FaceBoxX;
            % X.location_y = self(k).structural.FaceBoxY;
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
% DERIVESENTIMENTS computes sentiments using max poopling.
%
% SYNTAX:
%
% self.DERIVESENTIMENTS()
% self.DERIVESENTIMENTS(margin)
% self.DERIVESENTIMENTS(margin,correction)
%
% 
% For each frame, DERIVESENTIMENTS sets a negative score N* to the maximum
% between the negative evidence scores (anger, contempt, disgust, sadness
% and fear). Additionally, it also computes a positive score P* as the
% frame-wise maximum between joy and surprise. Each frame is then tagged as
% positive, negative or neutral based on the following procedure:
% 
% S_{f} = argmax(P_{f}*,N_{f}*,m)
%
% The variable "m" is a margin used to define neutral frames. A
% frame is considered neutral if: max(P_{f}*,N_{f}*) <= m.
%
% Scores for positive and negative frames are set, respectively, to P*,N*
% or m, based on which sentiments is more expressed.
%
% ARGUMENTS:
%
% M: a double indicating the margin that defines "neutral" sentiment.
%    Default value: 0. NOTE THAT if you used DERIVESENTIMENTS with the
%    argument M, the default value of M is set to whatever value you
%    specifeid before, whithout need to enter it again.
%
% EMOCORRECT: upper bound use for emotion timeseries correction**.
%
%
% ** EMOTIONS CORRECTION: This step is conducted only when the argument
% EMOCORRECT is provided. Whenever a frame is labeled Positive (or
% Negative), all Negative (or Positive) emotion scores larger than
% EMOCORRECT are set to EMOCORRECT (Note that EMOCORRECT <= M).
%
%
% See also SENTIMENTS. 

if isempty(self(1).functional)
    return
end

% Add backup for undo
self.beckupfex();

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
ValS    = cat(2,ValS,max(ValS,[],2) <= m);
neutVal = abs(mean(self(k).get('emotions','double'),2));
neutVal(ValS(:,3) == 0) = 0; 

% Set to zero N/P for Neutal frames
% FIXME: Why am I doing this??
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
self(k).sentiments = mat2dataset([ValS(:,1:3),neutVal,ValS(:,5)],'VarNames',{'Winner','Positive','Negative','Neutral','Combined'});
self(k).sentiments.TimeStamps = self(k).time.TimeStamps;
% FIXME: THIS WILL HAVE A CASCADE EFFECT
I = ~isnan(sum(double(self(k).functional),2));

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
% FIXME: THIS WILL HAVE A CASCADE EFFECT
% self(k).sentiments = self(k).sentiments(I,:);

% FIXME: This overwrite the native positive, negative and neutral (assuming
% they are there).
% FIXME: This was taken out
% for sn = {'Positive','Negative','Neutral'}
%     self(k).functional.(lower(sn{1})) = self(k).sentiments.(sn{1});
% end

% FIXME: THIS WILL HAVE A CASCADE EFFECT
self(k).sentiments = self(k).sentiments(I,:);

end

end

% *************************************************************************
% ************************************************************************* 

function self = downsample(self,fps,rule)
%    
% DOWNSAMPLE reduces sampling rate to desired frame rate.
%
% SYNTAX:
%
% self.DOWNSAMPLE(FPS)
% self.DOWNSAMPLE(FPS,RULE)
%
%
% DOWNSAMPLE uses convolution with a box function and uses the center of
% the convolutions as new datapoints. Before executing the convolution, the
% timeseries are set to a constant frame rate using the method INTERPOLATE.
% Note that when you use downsample with FPS larger than the modal FPS in
% the data, the method INTERPOLATE is used instead.
%
% If you want to reduce the sampling rate, but don't want to use averages,
% use INTERPOLATE instead.
%
% - FPS is an integer indicating the desired frame per second. Note that
%   FPS cannot be larger than modal FPS in the data (use INTERPOLATE
%   instead of DOWNSAMPLE when this happen). FPS canot be smaller than 1.
%
% - RULE a number between 0 and 1, which indicates when to keep the a
%   resulting datapoint. Suppose that the desired framerate is 2 and the
%   actual framerate is 30, then the new frames will be computed taking
%   averages of 15 frames. RULE indicates which percentage of missing frames
%   within the 15 frames segment is consider a null observation. For
%   example, RULE = 0.5 imply that if there are more than 7.5 missing
%   frames. Default: 0.
%
% This method derives SENTIMENTS, DESCRIPTIVES, and it updates NANINFO.
%
% See also INTERPOLATE, NANSET.


% Add backup for undo
self.beckupfex();


% Check that FPS is provided
if ~exist('fps','var')
    error('DOWNSAMPLE needs argument FPS.\n');
end
% Check that RULE is provided
if ~exist('rule','var')
    rule = 0;
elseif 0 > rule || rule > 1
    warning('RULE argument should be between 0 and 1 (set to 0).');
    rule = 0;
end

h = waitbar(0,'Downsampling ...');

for k = 1:length(self)
    % set up parameters: modal frame rate
    mfps = round(1/mode(diff(self(k).time.TimeStamps)));
    % size of the box used for convolution (Note: this is forced to be odd
    % I NEED TO UPDATE THE CODE).
    nfps = round(mfps/fps);
    nfps = nfps + 1-mod(nfps,2);
    waitbar(k/length(self),h);
    fprintf('Downsampling fexc onject: %d of %d.\n',k,length(self));
    if nfps < 2
    % Switch to INTERPOLATE (RULE is transformed in number of acceptable
    % NaN-frames per second).
        warning('Actual (%.2f fps) <= Required (%.2f fps). Using method INTERPOLATE.',mfps,fps);
        self(k).interpolate('fps',fps,'rule',max(round(nfps*(1-rule)),1),'verbose',false);
    else
    % Set up the kernel (box kernel).
        kk2 = ones(nfps,1)./nfps;
        % Interpolate data first to mfps & Convolve
        self(k).interpolate('fps',mfps,'rule',inf,'verbose',false);
        % Set up a set of indices for nans
        I = conv(double(self(k).naninfo.count > 0),kk2,'same');
        % Grab indices for the center of the convolution (CHECK THIS);
        idx = ceil(nfps/2):nfps-1:size(I,1);
        % Convolve functional data and Pose -- YOU NEED TO FIX THE POSE
        % ARGUMENT.
        kk1 = normpdf(linspace(-2,2,nfps),0,.5)';
        kk1 = kk1./sum(kk1);
        % Fixme: gaussian should be optional -- also implement with singel
        % convolution step.
        U = convn(convn(double(self(k).functional),kk1,'same'),kk2,'same');
        self(k).update('functional',U);
        % self(k).update('functional',convn(double(self(k).functional),kk2,'same'));
        Pose  = self(k).get('pose');
        PoseName = Pose.Properties.VarNames;
        self(k).structural(:,PoseName) = mat2dataset(convn(double(Pose),kk2,'same'),'VarNames',PoseName);

        % Update matrix shapes
        % Fixme: I DON'T WANT TO CHANGE STRUCTURAL and COREGPARAM.
        PropNames = {'functional','time','structural','coregparam','diagnostics'};
        for j = PropNames
        % Check that the fields exist.
            if ~isempty(self(k).(j{1}))
                self(k).(j{1}) = self(k).(j{1})(idx,:);
            end
        end
        self(k).time.StrTime = fex_strtime(self(k).time.TimeStamps);
        % Update naninfo and apply naninfo rule [TO BE TESTED]
        tempnaninfo = round(nfps*I(idx));
        tempnaninfo = cat(2,tempnaninfo,bwlabel(tempnaninfo));
        fp = conv(self(k).naninfo.falsepositive,(kk2*nfps));
        tempnaninfo = cat(2,tempnaninfo,fp(idx));
        self(k).naninfo = mat2dataset(tempnaninfo,'VarNames',{'count','tag','falsepositive'});
        % Apply new nans based on argument RULE
        if rule > 0
            self(k).nanset(max(round(nfps*(1-rule)),1));
        end
        % Update design when provided
        if isa(self(k).design,'fexdesignc')
            self(k).design.align(self(k).time);
        end
    end
    self(k).derivesentiments();
    self(k).descriptives();
end
delete(h);
end

% *************************************************************************
% *************************************************************************          
       

function self = setbaseline(self,StatName,StatSource,renew,duration)
%
% SETBASELINE normalizes the data using a BASELINE.
%
% SYNTAX:
%
% self.SETBASELINE(StatName)
% self.SETBASELINE(StatName,'-global',renew)
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
% STATSOURCE: [optional] This string determines the source of the
% descriptive statistic use for normalization. Options are:
%
% '-local': [default] Statistics are computed on FUNCTIONAL data from the
% current FEXC object.
%
% '-global': Statistics are computed over all FEXC
% objects in self.
%
%
% RENEW: a boolean value, which indicates whether to recompute descriptive
% statistics use for baselining. Default: true.
%
% NOTE: THIS METHODS NEEDS TO INCLUDE AN OPTION TO IMPORT BASELINE DATA
% FROM A DIFFERENT DATA OR FEXC OBJECT.
%
%
% See also NORMALIZE, DESCRIPTIVES.


% Add backup for undo
self.beckupfex();

% Check StatName argument
optstats = {'mean','median','q25','q75','neutral'};
if ~exist('StatName','var')
    error('You need to specify baseline statistics.');
elseif sum(strcmpi(StatName,optstats)) == 0;
    error('Not recognized descriptive: %d.\n',StatName);
end

% Refresh descriptive statistics -- default is refresh
if ~exist('renew','var') && ~isempty(self(1).descrstats)
    renew = true;
end
if renew
    self.descriptives();
end

if ~exist('duration','var')
    duration = '00:00:01.000';
end
    

if ~exist('StatSource','var')
   StatSource = '-local';
end

% Apply baseline
if strcmpi(StatSource,'-local') && ~strcmpi(StatName,'neutral')
% Local version computed on the current FEXC object from self.
    h = waitbar(0,'Set Baseline ... ');
    for k = 1:length(self)
        Y = double(self(k).functional);
        NormVal = double(self(k).get(lower(StatName)));
        self(k).baseline = NormVal;
        NormVal = repmat(NormVal,[size(Y,1),1]);
        self(k).update('functional',Y -NormVal);
        self(k).baseline = NormVal;
        waitbar(k/length(self),h);
    end 
elseif strcmpi(StatSource,'-local') && strcmpi(StatName,'neutral')
    h = waitbar(0,'Set Baseline ...');
    for k = 1:length(self)
        n = ceil(fex_strtime(duration)/mode(diff(self(k).time.TimeStamps)));
        Y = double(self(k).functional);
        N = self(k).functional.neutral;
        N(isnan(N)) = -10000;
        [~,ind] = sort(N,'descend');
        NormVal = nanmean(double(self(k).functional(ind(1:n),:)),1);
        self(k).baseline = NormVal;
        NormVal = repmat(NormVal,[size(Y,1),1]);
        self(k).update('functional',Y -NormVal);
    end
elseif strcmpi(StatSource,'-global') && ~strcmpi(StatName,'neutral')
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

if isempty(self(1).functional)
    return
end

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
    [~,emoidx] = ismember(emonames,vnamesX);
    self(k).descrstats.perc   = mean(X(self(k).sentiments.Winner < 3,emoidx)>self(k).thrsemo);
    d = [];
    for i = 1:3
        d = cat(2,d,self(k).sentiments.Winner == i);
    end
    % d = dummyvar([self(k).sentiments.Winner;3]);
    % self(k).descrstats.perc = [mean(d(1:end-1,:)),self(k).descrstats.perc];
    self(k).descrstats.perc = [mean(d),self(k).descrstats.perc];
    % Combine data for global statistics
    XX = cat(1,XX,X);
    PP = cat(1,PP,d);
end

% Add Global results
G1 = [mean(XX);std(XX);median(XX);quantile(XX,.25);quantile(XX,.75)];
G2 = [mean(PP),mean(XX(PP(:,end) == 0,emoidx) > self(1).thrsemo)];
G2(isnan(G2)) = 0;
% if sum(PP(:,end)) == 0
%     G2 = [zeros(1,7),mean(PP(:,end-2:end))];
% else
%     G2 = [mean(PP(:,end-2:end)),mean(XX(PP(:,end) == 0,emoidx) > self(1).thrsemo)];
% end
OBnames = {'mean','std','median','q25','q75'};
for k = 1:length(self)
    self(k).descrstats.glob  = mat2dataset(G1,'VarNames',vnamesX,'ObsNames',OBnames);
    self(k).descrstats.globp = mat2dataset(G2(:,1:3),'VarNames',vnamesP(1:3));
end

% Output
Desc = self(1).descrstats.glob;
Prob = self(1).descrstats.globp;

end

% *************************************************************************                          
% *************************************************************************   

function self = motioncorrect(self,varargin)
%
% MOTIONCORRECT identifies and removes pose related artifacts.
%
% SYNTAX:
%
% self.MOTIONCORRECT()
% self.MOTIONCORRECT(thrs,'-whiten')
%
% MOTIONCORRECT uses regression to remove artifacts due to motion. The
% absolute value from the three POSE variables (roll, pitch, and yaw) and a
% constant term are used as independent variables in the regression. A set
% of coefficients is estimated for each emotion and action unit
% independently. The residuals from the regression are used as new emotion
% variables.
%
% OPTIONAL ARGUMENTS:
%
% -  THRS: a scalar, indicating the absolute Pearson correlation
%    coefficient used to select the independent variables to use in the
%    regression. No pose feature with absolute PCC smaller than the
%    provided threshold is included**. Default |r| = 0.00.
%
% - '-WHITHEN': a string indicating whether the POSE features are
%   gonna be pre-whitened before running the regression. Default: '-none'.
%   Option for whithening is '-whithen'.
%
%
% [**] Regardless of the magnitude, no variable is included if it does not
% correlates significantly with the emotion/au in processed.
%
%
% See also FEX_WHITENING, UPDATE, DERIVESENTIMENTS.
%
% NOTE: this method is underconstruction, and a motion correction object is
% under development.


% Add backup for undo
self.beckupfex();

args = struct('thrs',0.00,'normalize','-none');
if ~isempty(varargin)
    ind1 = cellfun(@isnumeric,varargin);
    ind2 = cellfun(@ischar,varargin);
    % Pearcon correlation threshold
    if sum(ind1) == 1
        args.thrs = abs(varargin{ind1});
    end
    % Whitening the data ?
    if sum(ind2) == 1
        args.normalize = varargin{ind2};
    end
end
        
   
h = waitbar(0,'Motion correction...');

for k = 1:length(self)
fprintf('Correcting fexc %d/%d for motion artifacts.\n',k,length(self));
% Get Pose info
X = self(k).get('pose','double');
ind  = ~isnan(sum(double(self(k).functional),2)) & ~isnan(sum(X,2));
Y = double(self(k).functional(ind,:));

% Add constant, use pose absolute values, and make pose components
% indepependent if required.
switch lower(args.normalize)
    case {'-whiten','whiten'}
        X = [ones(sum(ind),1), fex_whiteningt(abs(X(ind,1:3)))];
    otherwise
        X = [ones(sum(ind),1), abs(X(ind,1:3))];
end

% Set space for new data
R = nan(length(ind),size(Y,2));

% Residual method
for i = 1:size(Y,2);
% Include only features significantly correlated
    [rind,pind] = corr(X(:,2:end),Y(:,i));
    idxpose  = [true,pind'<= 0.05 & abs(rind') >= args.thrs];
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


% Add backup for undo
self.beckupfex();

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
if ~ismember(lower(args.method),{'coreg','size','pca','kalman','position'});
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
    switch lower(args.method)
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


% Add backup for undo
self.beckupfex();

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


% Add backup for undo
self.beckupfex();
% Read rule
ind = find(strcmp(varargin,'rule'));
if ~isempty(ind)
    arg.rule = varargin{ind +1};
else
    arg.rule = Inf;
end
% Read fps
ind = find(strcmp(varargin,'fps'));
if ~isempty(ind)
    arg.fps = varargin{ind +1};
else
    arg.fps = 15;
end
% Verbose option 
ind = find(strcmpi(varargin,'verbose'));
if ~isempty(ind)
    v = varargin{ind +1};
else
    v = true;
end

VarNames = self(1).functional.Properties.VarNames;

if v
    % Add waitbar when verbose is set to true
    h = waitbar(0,'Interpolation ...');
end

for k = 1:length(self)
fprintf('Interpolating timeseries from fexc %d/%d.\n',k,length(self));
if v
    waitbar(k/length(self),h);
end
% Interpolate: safe check for number of nans
NofNans = mean(isnan(sum(double(self(k).functional),2)));
if NofNans < 0.90
    [ndata,ntsp,nfr,nan_info] = ...
        fex_interpolate(self(k).functional,self(k).time.TimeStamps,...
        arg.fps,arg.rule);
    % Update functional
    self(k).functional = mat2dataset(ndata,'VarNames',VarNames);
    % Update structural
    % self(k).structural = self(k).structural(nfr,:);
    ndata = fex_interpolate(self(k).structural,self(k).time.TimeStamps,...
        arg.fps,arg.rule);
    self(k).structural = mat2dataset(ndata,'VarNames',self(k).structural.Properties.VarNames);
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
    % Update design when provided
    if isa(self(k).design,'fexdesignc')
        self(k).design.align(self(k).time);
    end
    % Update diagnostocs if present
    if ~isempty(self(k).diagnostics)
        self(k).diagnostics = self(k).diagnostics(nfr,:);
    end
    % Update history
    self(k).history.interpolate = [self(k).time,self(k).naninfo,self(k).functional];
else
    warning('Fexc object %d does not contain data.',k);
end

end
self.derivesentiments();
if v
    delete(h);
end
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

% Add backup for undo
self.beckupfex();

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

function [Y,M] = matrix2(self,varargin)
%    
% MATRIX2 - Genrates matrix for data analysis using FEXGRABC constructor.
%
% USAGE:
%
% X = self.MATRIX2(GrabObj)
% X = self.MATRIX2('ArgName','ArgVal', ...)
%
% See also FEXGRABC

% FIXME: Add safety procedures (in FEXGRABC);
% =================
if isa(varargin{1},'fexgrabc')
    M = varargin{1};
else
    M = fexgrabc(varargin{:});
end

% Add FEXC data
% =================
if isempty(M.fex)
    M = M.set('fex',self);
end

% Create Matrix output
% =================
Y = M.grab();

end


% *************************************************************************
% *************************************************************************

function M = matrix(self,index,varargin)
%
% MATRIX - Generates a matrix of the data for analysis. 
%
% Usage:
%
% M = self.MATRIX(IDX);
% M = self.MATRIX(IDX,'ArgName1','ArgVal1',...)
%
% The method MATRIX generates a matrix from the timeseries, which can
% be used for the analysis.
%
% Arguments:
%
% IDX can be:
%
%   - A string with the name of a variable in self.DESIGN - In this
%   case the list of "events" is defied by unique(self.DESIGN.('IDX')).
%
%   - A string with a transformation of a variable in DESIGN, such as
%   'VarName = 2', s.t. IDX = eval('self.design.VarName == 2'). Or a cell,
%   in case there are multiple transformations.
%
%   - A vector of indices or of 1s and 0s of the same length of
%    self.FUNCTIONAL. This option works only for un-stuck object, and it
%    is deprecated.
%
%
% METHOD : 
% SIZE :
%
% 
%
% See also FEXDESIGNC.


% ----------------------------
% Set some Initial values
% ----------------------------
k = 1; cmd = ''; M = [];

% ----------------------------
% Interprete IDX
% ----------------------------
if ~exist('index','var')
    error('You need to enter the INDEX argument.');
elseif isa(index,'char') && ismember(index,self(1).design.X.Properties.VarNames)
% Name of one variable
    flag1 = 1;
elseif isa(index,'char')
% One string with one command
    flag1 = 2;
    try
        cmd = sprintf('self(k).design.X.%s',index);
        index = eval(cmd);
    catch errorid
        error(errorid.message);
    end
elseif isa(index,'cell')
% Set of command -- one per each cell
    flag1 = 3;
    cmd = sprintf('self(k).design.X.%s',index{1});
    for i = 2:length(index)
        cmd = cat(2,cmd,sprintf(' && self(k).design.X.%s',index{i}));
    end
    try
        index = eval(cmd);
    catch errorid
        error(errorid.message);
    end
% elseif isa(index,'double')
% % Enter a vector argument ... This is deprecated.
%     flag1 = 3;
%     if length(self) > 1
%         error('You can enter a vector when FEXOBJ length is 1');
%     elseif length(index) ~= size(self.functional,1)
%         error('Index and FUNCTIONAL must have same number of raws');
%     end
else
    error('Unrecognized INDEX argument.');
end
    
vals = unique(index);
if ismembetr([0,1],vals','rows')
    flag2 = 1;
else
    flag2 = 2;
end
% 
%     
% evlist = unique(index(index > 0));
% index  = cat(2,index,zeros(size(index,1),1));
% M = [];

% ----------------------------
% Interprete METHOD
% ----------------------------
ind = find(strcmp('method',varargin));
if isempty(ind)
    method = @nanmean;
elseif isa(varargin{ind+1},'function_handle')
    method = varargin{ind+1};
else
% Try char that can be converted into an handle, otherwise give up.
    try
        method = eval(sprintf('@%s',varargin{ind+1}));
    catch errorID
        warning(errorID.message);
        return
    end
end

% ----------------------------
% Set up SIZE
% ----------------------------
% ind = find(strcmp('size',varargin));
% if ~isempty(ind)
%     val = varargin{ind+1};
%     wps = find(val ~=0);
%     if ~ismember(wps,1:2)
%         warning('I couldn''t understand "size" parameter.');
%         return
%     end
%     for i = evlist'
%         nc = (1:sum(index(:,1) == i))';
%         if wps == 1
%         % Get the beginning of the event
%             index(index(:,1) == i,2) = nc;
%         else
%         % Get the end of the event
%             index(index(:,1) == i,2) = flipud(nc);
%         end
%     end
%     index(index(:,2) > val(wps),1) = 0;
% end


% ----------------------------
% Create event matrix
% ----------------------------

for k = 1:length(self)
    X = double(self.functional);
    

    % [ .... ]

end

temp = double(self.functional);
for i = evlist'
    M = cat(1,M,method(temp(index(:,1) == i,:)));
end
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
    
% Add backup for undo
self.beckupfex();

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
    fprintf('Temporal filtering FEXC: %d/%d.\n',k,length(self));
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
    self.derivesentiments();
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
                  'matrix','off',...
                  'update',false);
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
    elseif strcmp(args.output,'energy')
        TS = sqrt(imag(ts.analytic).^2 + ts.real.^2);
    else
        error('Unknwon output type.');
    end
    
    % Add update
    if args.update
        self.update('functional',TS);
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
% NORMALIZE normalizes the dataset.
%
% SYNTAX
% 
% self.NORMALIZE()
% self.NORMALIZE('ArgName1',ArgVal,...)
%
%
% NORMALIZE normalizes the dataset. Optional arguments include:
%
% method - a string with one of the following methods: 'zscore', 'center',
%    '0:1', or '-1:1'. default set to 'center.'
% outliers - a string set to 'on' or 'off' (default). When set to 'on',
%    outlier values are identified using zscores, and are set to the
%    maximum acceppted value.
% threshold - a double that indicates which values from FUNCTIONAL are set
%    considered outliers. This argument is ignored if 'outliers' is set to
%    'off'. Default: 2.5.
%
%
%
% See also FEX_NORMALIZE.

% ---------------------------------------
% Add backup for undo
% ---------------------------------------
self.beckupfex();

% ---------------------------------------
% Read arguments
% ---------------------------------------
% init_args = varargin;
% args = fex_varargutil(init_args);


% ---------------------------------------
% Read arguments
% ---------------------------------------

if isempty(varargin)
    % Case 0: not enough input arguments
    error('Not enough input argument.');
elseif isa(varargin{1},'dataset') || isa(varargin{1},'double')
    % Case 1: dataset, vector or matrix provided
    flag = 1;
    if isa(varargin{1},'dataset') 
        [~,ind] = ismember(self(1).functional.Properties.VarNames,...
               varargin{1}.Properties.VarNames);
        B = double(varargin{1}(:,ind));
    end
    % Test number of columns
    if size(B,2) ~= size(self(1).functional,2)
        error('Baseline column size mispecification.');
    end
    % Test number of rows
    if size(B,1) == 1
        B = repmat(B,[length(self),1]);
    elseif size(B,1) > 1 && size(B,1) ~= length(self)
        error('Baseline row size mispecification.');
    end
elseif sum(strcmpi(varargin{1},{'mean','median','q25','q75'})) > 0    
    % Case 2: Use SETBASELINE method
    flag = 2;
    StatName = varargin{1};
    try
        StatSource = varargin{2};
    catch
        StatSource = '-local';
    end
else
    % Case 3: fex_normalize
    flag = 3;
    % Set defaults
    scale = {'method','c','outliers','off','threshold',2.5};
    for i = 1:2:length(varargin)
        idx = strcmpi(scale,varargin{i});
        idx = find(idx == 1);
        if idx
            scale{idx+1} = varargin{i+1};
        end
    end
end

% ---------------------------------------
% Execute normalization 
% ---------------------------------------

switch flag
   case 1
       h = waitbar(0,'Normalization ... ');
       bvn = self(1).functional.Properties.VarNames;
       for k = 1:length(self)
           fprintf('Normalizing fexc %d of %d.\n',k,length(self));
           BB = repmat(B(k,:),[length(self(k).functional),1]);
           self(k).update('functional', double(self(k).functional) - BB);
           self(k).baseline = mat2dataset(B(k,:),'VarNames',bvn);
           waitbar(k/length(self));
       end
       self.derivesentiments(StatName,StatSource);
       delete(h);
   case 2
       self.setbaseline()
   case 3
       h = waitbar(0,'Normalization ... ');
       for k = 1:length(self)
           fprintf('Normalizing fexc %d of %d.\n',k,length(self));
           self(k).update('functional',fex_normalize(double(self(k).functional),scale{:}));
           waitbar(k/length(self));
       end
       self.derivesentiments();
       delete(h);
   otherwise
       error('Unable to normalize the data.');
end

%    if strcmpi(varargin{1},'baseline')
%    % Baseline normalization: this is only partially implemented.
%        X = repmat(mean(double(self(k).baseline),1),[length(self(k).functional),1]);
%        self(k).update('functional', double(self(k).functional) - X);
%    elseif isa(varargin{1},'dataset')
%        % Provide a vector
%        X = repmat(double(varargin{1}),[length(self(k).functional),1]);
%        self(k).update('functional', double(self(k).functional) - X);
%    else
%        self(k).update('functional',fex_normalize(double(self(k).functional),scale{:}));
%    end
%    waitbar(k/length(self));
% end
% delete(h);
% 
% end

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

% Add backup for undo
self.beckupfex();

% Read arguments
if isempty(varargin)
    kk = [];
elseif length(varargin) == 1 && length(varargin{1}) == 1
    kk = ones(varargin{1},1)./varargin{1};
elseif length(varargin) == 1 && length(varargin{1}) > 1
    kk = varargin{1}./sum(varargin{1});
elseif length(varargin) == 2
    pars = cell2mat(varargin);
    kk = normpdf(linspace(-2.5,2.5,round(max(pars))),0,min(pars));
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

function self = morlet(self,s,f,c)
%
% S - Support in seconds;
% F - vector of frequencies (Hz.);
% C - vecror with Gaussian cycles;
% ACTION - string ... 

sr = mode(diff(self(1).time.TimeStamps));
s  = linspace(-s/2,s/2,sr*s);

filt = fex_mwavelet('time',s,'frequencies',f,'bandwidth',c,'constant','off');

for k = 1:length(self)
    
    
end
    






end 

    

% *************************************************************************
% *************************************************************************  
    
    function self = kernel(self)
        fprintf('something');
    end

% *************************************************************************

% ---------------------------------------------
% GRAPHIC METHODS 
% ---------------------------------------------

function self = viewer(self,varargin)
% 
% VIEWER display the video and related statistics.
%
% SYNTAX:
%
% self.VIEWER()
% self.VIEWER('VIEWER_TYPE')
%
%
% The VIEWER method opens a user interface generated by FEXW_STREAMERUI or
% FEXW_OVERLAYUI to display the video with related timeseries and summary
% statistics on the current video. For more information on the UI see
% FEXW_STREAMERUI, FEXW_OVERLAYUI and related documentation.
%
% NOTE that the method VIEWER cannot be called on a stacked FEXC directly.
% That is, if length(SELF) > 1, the call self.VIEWER will return an error.
% Use self(k).VIEWER instead -- for 1 >= k <= length(SELF).
%
% Not all video formats are readable in MATLAB. Moreover, efficient
% compressions are slow to unwrap from MATLAB. Therefore, videos that are
% difficult to read using VIDEOREADER are converted to motion jpeg avi
% files using ffmpeg (http://ffmpeg.org)**. The new videofiles are saved in
% a subdirectory named 'FEXWSTREAMERMEDIA' in the current directory.
%
% ARGUMENTS:
%
% VIEWER_TYPE - a string set to 'STREAMER' (default) or 'OVERLAY', which
%   determines the UI that will be used.
%
% OUTPUT:
%
% NOTE that self.VIEWER does not return any output. However, annotations
% taken within VIEWER (FEXW_STREAMERUI only) are stored in the current FEXC
% object, they can be accessed using GET method, and they can be saved to a
% csv file using the FEXPORT method.
%
%
% **You can install ffmpeg using HOMEBREW (http://brew.sh) on OSX or using
% apt-get on Ubuntu.
%
%
% See also FEXW_STREAMERUI, FEXW_OVERLAYUI, GET, FEXPORT, VIDEOUTIL,
% VIDEOREADER.


% Check that (1) you have the video, and that (2) the video has the
% correct estension:
if ~exist(self(1).video,'file')
    error('No video provided for streaming.');
else
% check video formats
    format = VideoReader.getFileFormats();
    format = get(format, 'Extension');
    [~,~,cew] = fileparts(self(1).video);
    if ~ismember(cew(2:end),format)
        error('Unsupported format. Use "VideoReader.getFileFormats" to see supported formats.');
    end
end

if isempty(varargin) || strcmpi(char(varargin),'streamer')
    use_ui = 1;
elseif strcmpi(char(varargin),'overlay')
    use_ui = 2;
else
    warning('Unrecognized option: using STREAMER.')
    use_ui = 1;
end

% Select and lunch UI
if use_ui == 1
    % Start FEXW_VIDEOSTREAMERUI
    N = fexw_streamerui(self.clone());
    % Add annotations when provided;
    for k = 1:length(N)
        self(k).annotations = cat(1,self(k).annotations,N{k});
    end
else
    % Start FEXW_OVERLAYUI
    fexw_overlayui(self.clone());
end

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
% TYPE is a string, which specifies what you want to plot. Options include:
%
% 'timeplot' - Timeseries of emotions (default);
% 'summaryplot' - Distribution of emotions and median values;
% 'all' - Both 'timeplots' and 'summary.'
%
% SAVEFLAG is a boolean value. When set to true, the image is saved, when
% set to false, the image is displayed instead. When the image is
% displaied, you can press any keyboard value to delete it. When TYPE is
% set to 'all,' SAVEFLAG is set to false
%
% When SELF is a single FEXC object, self.SHOW displays the image on the
% screen. Otherwise, self.SHOW will save the images in a subfolder in the
% main directory (or in the SELF.DIROUT directory).
%
%
% See also FEXW_TIMEPLOT, FEXW_SUMMARYPLOT, FEX_GETCOLORS, FEX_STRTIME

% Controll that one input variable is provided.
if ~exist('type','var')
    type = 'timeplot';
elseif sum(strcmpi(type,{'timeplot','summaryplot','all'})) ~=1
    warning('Unrecognized TYPE: %s. Using "timeplot".');
    type = 'timeplot';
end

% Save/Don't save when handling single file.
if ~exist('saveflag','var')
    saveflag = false;
end

% Swicth across plots type.
switch lower(type)
    case {'timeplot','summaryplot'}
        if length(self) > 1
            hb = waitbar(0,'Printing images ... ');
            h = cell(length(self),1);
            for k = 1:length(self)
                if strcmpi(type,'tymeplot')
                    h{k} = fexw_timeplot(self(k),'-save');
                else
                    h{k} = fexw_summaryplot(self(k),'save',true,'show',false);
                end
                waitbar(k/length(self),hb);
            end
            delete(hb);
        else
            if strcmpi(type,'timeplot')
                h = fexw_timeplot(self);
            else
                [~,h] = fexw_summaryplot(self,'save',false,'show',true);
            end
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
    case 'all'
       hb = waitbar(0,'Printing images ... ');
       h = cell(length(self),3);
       for k = 1:length(self)
           % Create images
           h{k,1} = fexw_timeplot(self(k),'-save');
           waitbar((k-.5)/length(self),hb);
           h{k,2} = fexw_summaryplot(self(k),'save',true,'show',false);
           waitbar(k/length(self),hb);
           % Combine and clean images
           new_name = [h{k,1}(1:end-9),'.pdf'];
           append_pdfs(new_name,h{k,[2,1]});
           [flag,out] = system(sprintf('rm %s && rm %s',h{k,1},h{k,2}));
           if flag ~=0
               warning(out);
           end
       end
       delete(hb);
       h = h(:,3); 
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
% init - initial constructor.
% checkargs - check input arguments.
% export2viewer - save data to .CSV file.
% swhoannotations - display annotation.
% beckupfex - creates a backup copy of current fexc.object.
    
function self = init(self)
%
% INIT - initial constructor.
%
% USAGE:
%
% self = INIT()
%
% Generates an empty FEXC object.

% mat2dataset(nan(1,length(hdrs.functional)),'VarNames',hdrs.functional')
% Set default arguments
load('fexheaders.mat');
arg_init = struct('name','','video','','videoInfo',[],...
       'version','unknown',...
       'functional',dataset([],'VarNames',{'AU1'}),...
       'structural',dataset([],'VarNames',{'FrameRows'}),...
       'sentiments',dataset([],[],[],[],'VarNames',{'Winner','Positive','Negative','Combined'}),...
       'time',dataset([],[],[],'VarNames',{'FrameNumber','TimeStamps','StrTime'}),...
       'design',[],'outdir','','history',[],'tempkernel',[],...
       'thrsemo',0,'descrstats',[],'annotations',[],'coregparam',[],...
       'naninfo',dataset([],[],[],'VarNames',{'count','tag','falsepositive'}),...
       'diagnostics',dataset([],'VarNames',{'track_id'}),'baseline',[],'verbose',true,...
       'demographics',struct('isMale',[],'Age',[],'Race',[]));   
% Initialization of FEXC object
fld = fieldnames(arg_init);
for n = fld'
    self.(n{1}) = arg_init.(n{1});
end

end

%**************************************************************************

function self = checkargs(self,args)
%
% CHECKARGS - checks input arguments.
%
% USAGE:
%
% self.CHECKARGS()
%
% Handles properties during construction.

% --------------------------------------
% Functional, Structural & Diagnostics
% --------------------------------------
load('fexheaders2.mat') 
% FIXME: Wired Emotient Analytics thing
% FIXME: all dataset should be table instead
if isa(args.data,'table')
    args.data = table2dataset(args.data);
end

fun = @(s)str2double(s(2:end-1));
if ~isempty(args.data)
for j = args.data.Properties.VarNames;
try
    str = hdrs.map2(lower(j{1}));
    % FIXME: Wired Emotient Analytics thing
    if iscell(args.data.(j{1}));
        args.data.(j{1}) = cellfun(fun,args.data.(j{1}),'UniformOutput',1);
    end
    self.(hdrs.map1(lower(j{1}))).(str) = args.data.(j{1});
catch
    fprintf('Ignored variable: %s.\n',j{1});
end
end
end

% -------------------------------------
% Add version
% -------------------------------------
if ismember('version',args.data.Properties.VarNames)
    self.version = args.data.version{1};
end

% -------------------------------------
% Fix Demographic information: Gender
% -------------------------------------
if ~isempty(self.demographics.isMale)
    I = nanmean(self.demographics.isMale(self.demographics.isMale ~=0));
    self.demographics.isMale = I;
end

% -------------------------------------
% Fix Demographic information: Age
% -------------------------------------
agev = {'age_18','age_25','age_35', 'age_45','age_55','age_65','age_100'};
agen = [18,25,35,45,55,65,100];
for i = 1:length(agev)
    if ismember(agev{i},fieldnames(self.demographics));
        self.demographics.Age = cat(1,self.demographics.Age,[agen(i),nanmean(self.demographics.(agev{i}))]);
        self.demographics = rmfield(self.demographics,agev{i});
    end
end

% -------------------------------------
% Fix Demographic information: Ethnic.
% -------------------------------------
etnv = {'asian','black','hispanic','indian','white'};
for i = 1:length(etnv)
    fn = sprintf('ethnicity_%s',etnv{i});
    if ismember(fn,fieldnames(self.demographics));
        self.demographics.Race.(etnv{i}) = nanmean(self.demographics.(fn));
        self.demographics = rmfield(self.demographics,fn);
    end
end

% --------------------------------------
% Grab video information 
% --------------------------------------
if ~isempty(self.video)
    self.getvideoInfo();
end

% --------------------------------------
% Set Time argument
% --------------------------------------
if isempty(self.time.TimeStamps) && isempty(self.videoInfo)
    warning('No timestamp information provided. Use "UPDATE" method.');
    t = 0:size(self.functional,1);
    self.time.TimeStamps = t';
elseif isempty(self.time.TimeStamps) && ~isempty(self.videoInfo)
    t = linspace(1/self.videoInfo(1),self.videoInfo(2),self.videoInfo(3));
    self.time.TimeStamps = t';
elseif ~isempty(self.time.TimeStamps) && ~isempty(self.videoInfo)
    % Test timestamps consistency
    % FIXME: This assumes that you have only one face per frame.
    [self.time.TimeStamps,indT]  = sort(self.time.TimeStamps);
    tt = unique(self.time.TimeStamps);
    if length(tt) < length(self.time.TimeStamps)
        self.time.TimeStamps = linspace(1/self.videoInfo(1),self.videoInfo(2),length(indT))';
    end
end

% --------------------------------------
% Check for repeated frames
% --------------------------------------
% FIXME -- MAY CREATE N of FRAME ISSUES
% indrep  = [diff(self.time.TimeStamps) < 10e-4; 0];
% self.time.FrameNumber = zeros(size(self.time,1),1);
% self.time.FrameNumber(indrep == 0) = (1:sum(indrep == 0))';
% self.time.FrameNumber(indrep ~= 0) = nan;
% [bl,bn] = bwlabel(isnan(self.time.FrameNumber));
% for i = 1:bn
%     nfnind = find(bl == i,1,'first');
%     self.time.FrameNumber(bl == i) = self.time.FrameNumber(nfnind+1);
% end
% 
% if ~isempty(self.functional) && ~isempty(self.structural)
% ind = (isnan(sum(double(self.functional),2)) | sum(double(self.functional),2) == 0) & bl(:) > 0;
% self.functional = self.functional(ind == 0,:);
% self.structural = self.structural(ind == 0,:);
% self.time = self.time(ind == 0,:);
% end

% FIXME: commented this
% for p = {'functional','structural','diagnostics'}
%     if ~isempty(self.(p{1}))
%         self.(p{1}) = self.(p{1})(ind,:);
%       % self.(p{1}) = self.(p{1})(ind2,:);
%     end
% end

self.time.FrameNumber = (1:size(self.time,1))';
self.time.StrTime = fex_strtime(self.time.TimeStamps);

% --------------------------------------
% Nan Information
% --------------------------------------
if ~isempty(self.functional)
X = self.get('emotions','double');
bwidx = bwlabel(sum(X,2) == 0 | isnan(sum(X,2)));
self.naninfo = mat2dataset(zeros(size(X,1),3),'VarNames',{'count','tag','falsepositive'});
self.naninfo.tag = bwidx;
for i = 1:max(bwidx)
    self.naninfo.count(bwidx == i) = sum(bwidx == i);
end
% make sure that nans are nans and not 0s.
self.nanset(1);
end

% --------------------------------------
% Diagnostics
% --------------------------------------
if isempty(self.diagnostics) && ~isempty(self.functional)
    self.diagnostics.track_id = zeros(size(X,1),1) - self.naninfo.tag > 0;
else
    self.diagnostics = [];%self.diagnostics(ind == 0,:);
end
    
% --------------------------------------
% Import / Allign Design
% --------------------------------------
self.design = args.design;
if isa(self.design,'fexdesignc')
    self.design.align(self.time);
end

end

%**************************************************************************

function self = export2viewer(self,filename)
%
% EXPORT2VIEWER utility function to save data as .CSV file.
% 
% SYNTAX:
%
% self.EXPORT2VIEWER(filename)
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
% Fixme: use headers files (REMOVE?)
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

%**************************************************************************

function self = beckupfex(self)
%
% BECKUPFEX
%
% Saves the current copy of FEXC to self.HISTORY.PREV so that the last
% operation can be undone.
%
%
% See also UNDO, CLONE.

for k = 1:length(self)
    self(k).history.prev = self(k).clone();
end

end

%**************************************************************************

end

%**************************************************************************
%**************************************************************************

end

