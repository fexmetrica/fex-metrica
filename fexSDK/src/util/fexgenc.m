classdef fexgenc < handle
%
% FEXGENC - FEXC constructor helper.
%
% FEXGENC handles the argument provided to FEXC from the command line or
% from the FEX_CONSTRUCTORUI user interface. FEXGENC is meant for internal
% use only.
%
% FEXGENC Properties:
%
% movies - paths to the movie files;
% files - paths to the FACET SDK files;
% timeinfo - paths to timestamps files or timestamp header name;
% design - paths to design files;
% targetdir - path to output directory;
% checklist - boolean value with file checklist;
% warnmsg - last warning reported.
%
% FEXC Methods:
%
% fexgenc - class constructor.
% set - update class properties.
% export - creates FEXC object.
% add - add a new video/file to the existing FEXGENC
%
%
% 
% See also FEXC, FEX_CONSTRUCTORUI.
%
% Copyright (c) - 2015 - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


%------------------------------------------------------------------
% Public Properties
%------------------------------------------------------------------

properties(Access='public')
    % MOVIE - inidicates where the movies are located. This property can be
    % a string with one path, a set of string, for multiple movies, or a
    % cell array of strings.
    movies
    % FILES - location of files containig the facial expressions timeseries
    % from Emotient Inc. Toolbox. This property can be a string with one
    % path, a set of strings for multiple files, or a cell array of
    % strings with multiple paths.
    files
    % TIMEINFO - information on how to handle FEXC.TIME property. This
    % property can be a string with one path, a set of strings for multiple
    % time files, or a cell array of paths. Alternatively, this propery can
    % be set to a string with the name of the variable in FILES which
    % indicates frame-wise timestamps.
    timeinfo
    % DESIGN - location of files containig the design specification. This
    % property can be a string with one path, a set of strings for multiple
    % files, or a cell array of strings with multiple paths.
    design
    % TARGETDIR - a string with the target directory. Data will be saved in
    % that directory, and FEXC.DIROUT property will be set to this
    % directory. Default: current working directory.
    targetdir
end

%------------------------------------------------------------------
% Hidden Public Properties
%------------------------------------------------------------------

properties(Access='public',Hidden)
    % CHECKLIST - a set of 4 boolean values inidcating the status of the
    % properies: MOVIES, FILES, DESIGN and TIMEINFO.
    %
    % See also EXPORT.
    checklist
    % WARNMSG - a string with a summary of reported error message.
    %
    % See also GET_ERROR.
    warnmsg
    % GEN2FEX - structure whith the preliminar version of the FEXC object
    % that will be generated.
    %
    % See also EXPORT, READ.
    gen2fex
end

%------------------------------------------------------------------
% Public methods
%------------------------------------------------------------------
methods(Access='public')
    

function self = fexgenc(varargin)
%
% FEXGENC - Initialization of FEXC constructor helper.
%
% FEXGENC handles the argument provided to FEXC from the command line
% or from the FEX_CONSTRUCTORUI user interface.
%
% USAGE:
%
% self.FEXGENC()
% self.FEXGENC('ui')
% self.FEXGENC('Arg1Name',Arg1Val,...)
%
% Without arguments, FEXGENC returns an empty FEXC constructor helper. With
% argument set to the string 'ui', FEXGENC opens the user interface
% FEX_CONSTRUCTORUI. Alternatively, you can manually specify input
% arguments using the 'Arg1Name',Arg1Val,... syntax.
%
% ARGUMENTS:
%
% MOVIES - path or paths to movies.
% FILES - path to results of Emotient toolbox face analysis.
% TIMEINFO - path to files with timing information, or strint with
%   timestamp header name in FILES.
% DESIGN - path to files with design information.
% TARGETDIR - path to output directory.
% 
% See also FEXC, FEX_CONSTRUCTORUI.

% Initialize and update
self.init();

if isempty(varargin)
% Generate empty object
    return
elseif ~isempty(varargin) && ~strcmpi(varargin{1},'ui')
% Initialize with provided arguments
    self.set(varargin);
elseif strcmpi(varargin{1},'ui')
% No argument provided - use the UI.
    fex_constructorui(self);
else
% Generate empty object
    return    
end

end
    
%------------------------------------------------------------------

function self = set(self,varargin)
%
% SET - updates or initialize FEXGENC object. 
%
% USAGE:
%
% self.SET('PropName')
% self.SET('PropName1',PropVal1, ...)
%
% When SET is called with only 'PropName' string argument, the property
% indicated by 'PropName' is reinitialize. Otherwise, property 'PropName1'
% is set to the value PropVal.
%
% See also FEXGENC, INIT, READ.

if length(varargin) < 1
    error('Not enough input arguments.');
elseif length(varargin) > 1 &&  mod(length(varargin),2) == 1
    error('Unbalanced "PropName" and "PropVal" input.');
elseif length(varargin) == 1
% Reinitialize property 
    self.init(varargin{1});
else
% Update properies / check for errors
    varargin = lower(varargin);
    for i = 1:2:length(varargin)
        [flag,arg] = self.read(varargin{i},varargin{i+1});
        if flag == 0
            self.(varargin{i}) = arg;
        else
            warning(self.get_error(flag));
        end
    end
end
    
end

%------------------------------------------------------------------

function [obj,name] = export(self)
%
% EXPORT - creates FEXC object.
%
% USAGE:
%
% self.EXPORT()
%
% EXPORT generates the output OBJ of class FEXC.
%
% See also FEXC.

% empty space for fexobj & saving name
obj = [];
name = sprintf('%s/fexobj.mat',self.targetdir);

% Export the data -- check the flags
if ~(self.checklist.file || self.checklist.file)
% No files, nor movies -- generate empty FEXC object.
    obj = fexc();
    name = 'not saved.';
    return
elseif slef.checklist.movie && ~self.checklist.files
% Movies provided, but not files - ask permission to use FEX_FACETPROC: 
    act = questdlg('Do you want to use FACET SDK to process the videos?', ...
                   'Fex-Facet Processing', ...
                   'Yes','No','No');
    if strcmpi(act,'yes')
    % Run preprocessing with FEX_FACETPROC
        self.set('files',fex_facetproc(self.movies));
    end
end 

% Compile and save the FEXC object
for k = 1:max(length(self.movies),length(self.files))
    obj = cat(1,obj,fexc(self.gen2fex(k)));
end
save(name,'obj');


end

%------------------------------------------------------------------

function self = add(self,varargin)
%
% ADD - add a new video/file to the existing FEXGENC

fprintf('TODO')



end

%------------------------------------------------------------------

end

%------------------------------------------------------------------
% Private methods
%------------------------------------------------------------------

methods(Access = 'private')
%
% Private Methods:
%
% INIT - initialization function for FEXGENC object.    
% GET_ERROR - convert error Id code from READ into a message.
% READ - helper function to parse and check provided arguments.

function self = init(self,varargin)
%
% INIT - Initialization function for FEXGENC object.

% Default values
initvals = struct('movies','','files','','design','','timeinfo','','targetdir',pwd,...
    'checklist',struct('movies',0,'files',0,'design',0,'timeinfo',0),'warnmsg','');   
    
% Check arguments
if isempty(varargin)
    list_init = fieldnames(initvals);
else
    list_init = lower(varargin);
end

% Reinitialize selected
for i = 1:length(list_init)
    self.(list_init{i}) = initvals.(list_init{i});
end
    
end
    
%------------------------------------------------------------------

function msg = get_error(id)
% 
% GET_ERROR - convert error Id code from READ into a message.

% No error to report
msg = '';
if ~exist('id','var')
    return
elseif id == 0
    return
end

% Parse error code
switch id
    case 1
        msg = 'ErrorId:1';
    case 2
        msg = 'ErrorId:1';
    case 3
        msg = 'ErrorId:1';
    otherwise
        msg = sprintf('Generic error message\n: %s',id);
end
        
end

%------------------------------------------------------------------

function [flag,X] = read(propname,propval)
%
% READ - Helper function to parse and check provided arguments.
%
% USAGE:
%
% self.READ(propname,propval)
%
% INPUT:
%
% PROPNAME - name of one of the properties of FEXGENC.
% PROPVAL  - value for that property.
%
% OUTPUT:
%
% FLAG - scalar with error ID if any.
% X - formatted argument for field PROPNAME.
%
% See also SET.

if nargin < 2
    error('READ requires "propname" and "propval" arguments.');
end

flag = 0;
X    = propval;

switch lower(propname)
    case 'movies'
        fprintf('TODO'); 
    case 'files'
        fprintf('TODO'); 
    case 'timeinfo'
        fprintf('TODO'); 
    case 'design'
        fprintf('TODO'); 
    case 'targetdir'
        fprintf('TODO'); 
    otherwise 
        error('Unrecognized property: %s.',propname);
end


end

%------------------------------------------------------------------

end

%------------------------------------------------------------------

end
