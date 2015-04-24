classdef fexdesignc < handle
%
% FEXDESIGNC - Helper class to handle design matrix
%
% desObj = fexdesignc;
% desObj = fexdesignc(design);
% desObj = fexdesignc(design,ArgName1,ArgVal1,...);
%
%
% Design object -- this class uses fex objects and data provided by the
% user to create a matrix suitable for classification, regression, and,
% more in general, statistical analysis.
%
% Properties for FEXDESIGNC:
% 
% X - Current matrix.
% TIMETAG - Name of the time-tag variable.
% INCLUDE - Indices of variables to include w.r.t. original data.
%
% Methods for FEXDESIGNC:
%
% FEXDESIGNC - Constructor metod for FEXDESIGNC.
% RESET - Reinitialize FEXDESIGNC.
% RENAME - Change variables names.
% SELECT - Select variables to be used.
% CONVERT - Converts a file using the transformations applied to SELF.
%
%
% Copyright (c) - 2014 - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 23-Apr-2015.
%
% Fixme: Add safe check which won't allow to exclude Time.

properties
    % X: a dataset with the design. The name of the variables are specified
    % by the user or generaric "Var1", ... , "VarJ" names are added. The
    % number or rows in X, N may be smaller or equal to the number of
    % frames acquired.
    %
    % See also IMPORTDESIGN.
    X 
    % TIMETAG: a string with the name of the variable in X with the time
    % information. This is used for alligning the dataset to the video
    % data from a FEXC object.
    timetag
    % INCLUDE: a set of indices of variables that will be included in the
    % final design.
    include
end

properties (Access = protected)
    % INIT: original version of the imported design used to reset
    % operations performed on X.
    %
    % See also RESET.
    init
    % FEXTIME: target timestamps from the video used to alligne the
    % design matrix with the video data. This is the variable
    % TIME.TIMESTAMPS from the relevant FEXC object.
    %
    % See also FEXC.TIME.
    fextime
    % DICT: object of containers.Map class which converts current names
    % from self.X in indices for self.INIT.
    %
    % See also RENAME, SELECT, INCLUDE.
    dict
    % TIDX: Indices for allignment of design matrix and matrix and facial
    % expressions timeseries.
    %
    % See also ALLIGN,FEXTIME.
    tidx
end


% -------------------------------------------------------
% Public methods    
% -------------------------------------------------------
methods

function self = fexdesignc(design,varargin)
%
% FEXDESIGNC - Constructor for the design object.
%
% USAGE:
%
% self = FEXDESIGNC(design);
% self = FEXDESIGNC(design,'ArgName1',ArgVal1, ... );
%
% FEXDESIGNC is a helper class for handling a matrix with design
% information associated with a FEXC object. The only required argument is
% DESIGN.
%
% Arguments:
%
% DESIGN: This can be the path to file (in which case it will be imported),
% a matrix, or a dataset.
%
% TIMETAG: A string with the name of the variable with timing information.
% If this variable is not provided, FEXDESIGNC looks for possible
% candidaes, such as variables labeled "time", "timestamps" etc. If one of
% these variables names if fund, it will be used as timetag. Otherwise,
% this property is left empty. TIMETAG is required when alligning the
% design matrix with the facial expressions timeseries.
%
% INCLUDE: a list of indices, indicating which variables to include, with
% respect to the origianl dataset imported.
% 
% See also FEXIMPORTDG, FEXC. 


% ----------------------------------------------
% Import DESIGN dataset
% ----------------------------------------------
if ~exist('design','var')
% Construct empty object
    return
else
% Call import design to read the data
    self.importdesign(design);
end

% ----------------------------------------------
%  Read extra optional arguments
% ----------------------------------------------
for i = 1:2:length(varargin)
    try
        self.(lower(varargin{i})) = varargin{i+1};
    catch
        warning('Property %s not recognized.',varargin{i});
    end
end

% ----------------------------------------------
%  Add dictionary
% ----------------------------------------------
VarNames  = self.X.Properties.VarNames;
self.dict = containers.Map(lower(VarNames),1:length(VarNames));

% ----------------------------------------------
%  Apply / Convert include
% ----------------------------------------------
if ~isempty(self.include)
    self.select(self.include);
end
% ----------------------------------------------
%  Look for timetag variable
% ----------------------------------------------
if isempty(self.timetag)
    self.seaktime();
end

end

% ------------------------------------------------------

function self = reset(self)
%
% RESET - reset the property X to it's original imported value.
%
% USAGE:
%
% self.RESET()
%
% RESET method reset the datset in X to the dataset imported using
% IMPORTDATASET method.
%
% See also IMPORTDATASET.

self.X = self.init;
VarNames  = self.X.Properties.VarNames;
self.dict = containers.Map(lower(VarNames),1:length(VarNames));
self.seaktime();
self.include = [];
   

end

% ------------------------------------------------------

function self = rename(self,varargin)
%
% RENAME - changes variables names.
%
% USAGE:
%
% self.RENAME('OldName1','NewName1',OldName2,NewName2, ... )
%
% 'OldName' is a string with a variable name in X, and 'NewName' is the new
% variable name that will be used. If the "timetag" variable name is
% changed, the property TIMETAG is automatically updated.
%
% See also DICT.


% -----------------------------------------------------
% Check arguments provided
% -----------------------------------------------------
if isempty(varargin)
    warning('No names entered for changes.');
    return
elseif mod(length(varargin),2) ~=0
    error('Mismatch between old and new names');
end
% -----------------------------------------------------
% Change name operation / Update internal dictionary
% -----------------------------------------------------
keys1 = self.dict.keys;
vals1 = self.dict.values;
map = containers.Map(lower(varargin(1:2:end)),varargin(2:2:end));
for i = 1:length(self.X.Properties.VarNames)
    if isKey(map,lower(self.X.Properties.VarNames{i}))
        [~,ind] = ismember(lower(self.X.Properties.VarNames{i}),keys1);
        keys1{ind} = lower(map(lower(self.X.Properties.VarNames{i})));
        self.X.Properties.VarNames{i} = map(lower(self.X.Properties.VarNames{i}));
    end
end
self.dict = containers.Map(keys1,vals1);
% -----------------------------------------------------
% Check whether the timetag variable name was changed 
% -----------------------------------------------------
if isKey(map,lower(self.timetag))
    self.timetag = map(lower(self.timetag));
end
    
end

% ------------------------------------------------------

function self = select(self,idx,flag)
%
% SELECT - Helper function for selection of variables.
%
% USAGE:
%
% self.SELECT(IDX);
% self.SELECT(IDX,FLAG);
%
% SELECT selects a subsample of variables from X.
%
% IDX - this indicates a subset of variables. The argument IDX is required,
% and it can be:
%
%   * A cell (or a string) with variables names from X;
%   * A vector of indices for the column in X;
%   * A vector of size 1 * size(self.X,2) with boolean values.
%
% FLAG - A scalar set to either 0 or 1. When set to 0, the variables
% selected by IDX are excluded. When set to 1, they are included. Default
% is 1 (i.e. variable are included).
%
% NOTE: the argument IDX applies to the current version of the design,
% namely the property X. However, the property INCLUDE applies to the
% original design matrix imported.


% -------------------------------------
% Check argument: IDX
% -------------------------------------
if ~exist('idx','var')
    warning('No selection made.');
    return
elseif isa(idx,'cell') || isa(idx,'char')
    inds = ismember(lower(self.X.Properties.VarNames),lower(idx));
    if sum(inds) == 0  
        error('No variable recognized.');
    end
    idx = inds;
elseif length(idx) == size(self.X,2)
    idx = idx >= 1;
elseif length(idx) < size(self.X,2)
    inds = zeros(1,size(self.X,2));
    inds(idx) = 1; idx = inds;
else
    error('Mispecified IDX argument.');
end
% -------------------------------------
% Check argument: FLAG & Select
% -------------------------------------
if ~exist('flag','var')
    self.X = self.X(:,idx == 1);
elseif ~ismember(flag,0:1)
    warning('Unrecognized flag. Using 1.');
    self.X = self.X(:,idx == 1);
elseif flag == 1
    self.X = self.X(:,idx == 1);
else
    self.X = self.X(:,idx == 0);
end

self.convinclude();
% self.include = idx;

end

% ------------------------------------------------------

function newobj = convert(self,new_design)
%
% CONVERT - Converts a file using the transformations applied to SELF.
%
% Usage:
%
% self.CONVERT(new_design);
%
% NEW_DESIGN is a design file or design argument that can be read using the
% constructor syntax:
%
% self.FEXDESIGNC(new_design);
%
%
% See also FEXDESIGNC.

if ~exist('new_design','var')
    error('You need to enter a FEXDESIGNC object as template.');
end

% --------------------------------------------
% Generate new FEXDESIGNC
% --------------------------------------------
if isa(new_design,'fexdesignc')
    newobj = new_design;
else
    newobj = fexdesignc(new_design);
end

% --------------------------------------------
% Variables Selection
% --------------------------------------------
if ~isempty(self.include)
    newobj.select(self.include);
end
% --------------------------------------------
% Rename Variables
% --------------------------------------------
NewVarNames = self.X.Properties.VarNames;
OldVarNames = newobj.X.Properties.VarNames;
for i = 1:size(newobj.X,2)
    newobj.rename(OldVarNames{i},NewVarNames{i});
end
% --------------------------------------------
% TimeTag Property
% --------------------------------------------
newobj.timetag = self.timetag;  
end

% ------------------------------------------------------

% ------------------------------------------------------

function self = align(self,ti)
%
% ALIGN - repeats rows of X in order to match FEXC timeseries size.
%
% Usage:
%
% self.ALIGN(ti);
%
% TI is the most recent timeseries from FEXC (i.e. FEXC.TIME.TIMESTAMPS).
%
% NOTE that in order for ALIGN to work you need to have self.TIMETAG
% variable set up, and you need to enter TI. If the TIMETAG attribut is not
% set up, a UI will pop up.


% -----------------------------------
% Check arguments
% -----------------------------------
if isempty(self.timetag) && ~exist('ti','var')
    error('Not enough timing information provided.');
elseif isempty(self.timetag)
% Start the UI to add information 
    feximportdg('file',self);
end

if isa(ti,'dataset')
    ti = double(ti.TimeStamps);
end

% -----------------------------------
% Alignment process
% -----------------------------------
t = double(self.X.(self.timetag));
[~,idx] = min(abs(repmat(ti,[1,length(t)]) - repmat(t',[length(ti),1])),[],2);

% -----------------------------------
% Update fields
% -----------------------------------
% self.X = self.X(idx,:); % This is not needed and it occupies space.
self.fextime = ti;
self.tidx = idx;

end


end


% -------------------------------------------------------
% Private methods    
% -------------------------------------------------------   
    
methods (Access = private)
%
% Private Methods for FEXDESIGNC:
% 
% IMPORTDESIGN - Robust import procedure for design.
% SEAKTIME - Find candidates for TIMETAG property.
% CONVINCLUDE - convert include property to indices.
    
function self = importdesign(self,design) 
%
% IMPORTDESIGN - Helper function for design importer.
% 
% USAGE:
%
% self = self.IMPORTDESIGN();
%
% IMPORTDESIGN cast the design provided to a dataset class. The input
% argument DESIGN can be:
%  
% 1. The path to a file (.mat,.txt,.csv);
% 2. A dataset;
% 3. A matrix;
% 4. A structure with one field per variable;
% 5. A structure with .data and .colheaders fields.
%
% See also FEXDESIGNC.

% DESIGN argument is required
if ~exist('design','var')
    error('Nothing to import.');
end

% -------------------------------------------
% Case in which design is the path of a file
% -------------------------------------------
if isa(design,'cell') || isa(design,'char')
design = deblank(char(design));
if ~exist(design,'file')
    error('Design file not found.')
end
[~,~,ext] = fileparts(design);
% -------------------------------------------
% Switch across possible file extensions
% -------------------------------------------
switch ext
    case '.mat'
        design = importdata(design);
    case '.txt'
        design = dataset('File',design,'Delimiter','\t');
    case '.csv'
        design = dataset('File',design,'Delimiter',',');
    case {'.xlsx','.xls'}
        design = dataset('XLSFile',design);
    otherwise
        warning('File extension "%s" not recognized.', ext);
        design = importdata(design);
end
end
% -------------------------------------------
% Cast design into dataset
% -------------------------------------------
switch class(design)
    case 'dataset'
        self.X = design;
        self.init = design;
    case 'double'
        self.X = mat2dataset(design);
        self.init = self.X; 
    case 'struct'
    % This can have several options
        fn = fieldnames(design);
        if sum(ismember({'data','colheader'},fn)) == 2
            self.X = mat2dataset(design.data,'VarNames',design.colheader);
        else
            self.X = struct2dataset(design);
        end
        self.init = self.X; 
    otherwise
        error('Failed to import the design matrix.');
end
        
end

% -------------------------------------------------------------------------

function self = seaktime(self)
%
% SEAKTIME - looks for possible candidates for time-variables.
%
% Usage:
%
% self.seaktime()
%
% When the variable timetag is not specified, SEAKTIME uses the most
% updated version of the names, and looks for possible candidates, such as
% variables named "time," "timestamps", etc. If non of the candidate is
% found, the variable is left empty.
%
% See also TIMETAG.

opt_name = {'time','timestamp','timestamps','timetag'};
ind = ismember(lower(self.X.Properties.VarNames),opt_name);

if sum(ind) > 1
    warning('Multiple possible "timetag" found.');
    self.timetag = self.X.Properties.VarNames(ind == 1);
elseif sum(ind) == 1
    self.timetag = self.X.Properties.VarNames{ind == 1};
else
    self.timetag = '';
end
    
end

% -------------------------------------------------------------------------

function self = convinclude(self)
%
% CONVINCLUDE - finds absolute indices for variables in INIT.
%
% Usage:
%
% self.CONVINCLUDE();
%
% CONVINCLUDE use the property DICT to identify which variables from the
% original dataset are included in X.
%
% See also INCLUDE.

VarNames = lower(self.X.Properties.VarNames);
idx = [];
for i = VarNames
    idx = cat(2,idx,self.dict(i{1}));
end
self.include = idx;
 
end

% -------------------------------------------------------------------------

end
    
end

