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
% X - 
% TIMETAG - 
% INCLUDE - 
%
% Methods for FEXDESIGNC:
%
% FEXDESIGNC - 
% RESET - 
% RENAME - 
% SELECT - 
%
%
% Copyright (c) - 2014 - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 1-Feb-2015.



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
% [...]
%
% design matrix/dataset or path
% 'timetag'
% 'include'


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
%  Look for timetag variable
% ----------------------------------------------
if isempty(self.timetag)
    opt_name = {'time','timestamp','timestamps','timetag'};
    ind = ismember(lower(self.X.Properties.VarNames),opt_name);
    if sum(ind) > 1
        warning('Multiple possible "timetag" found.');
        self.timetag = self.X.Properties.VarNames(ind == 1);
    elseif sum(ind) == 1
        self.timetag = self.X.Properties.VarNames{ind == 1};
    end
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
% Change name operation
% -----------------------------------------------------
map = containers.Map(lower(varargin(1:2:end)),varargin(2:2:end));
for i = 1:length(self.X.Properties.VarNames)
    if isKey(map,lower(self.X.Properties.VarNames{i}))
        self.X.Properties.VarNames{i} = map(lower(self.X.Properties.VarNames{i}));
    end
end
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
    % elseif sum(inds) ~= length(idx)
    %    warning('Not all variable names recognized.')
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

self.include = idx;

end
    
% ------------------------------------------------------
end
    

% -------------------------------------------------------
% Private methods    
% -------------------------------------------------------   
    
methods (Access = private)
%
% Private Methods for FEXDESIGNC:
% 
% IMPORTDESIGN - 
    
function self = importdesign(self,design) 
%
% IMPORTDESIGN - Helper function for design importer.
% 
% USAGE:
%
% self = self.IMPORTDESIGN();
%
% IMPORTDESIGN cast the design provided to a dataset class. The input
% argument DESIGN can be: ... 
%
% 

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
end
    
end

