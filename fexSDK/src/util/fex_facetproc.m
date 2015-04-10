function [Y,cmd,h] = fex_facetproc(list,varargin)
%
% FEX_FACETPROC calls FACET SDK executable file to process videos
%
% SYNTAX:
%
% Y = FEX_FACETPROC(LIST);
% Y = FEX_FACETPROC(FEXC_OBJ);
% Y = FEX_FACETPROC(...,'ArgValName','ArgValVal');
%
% FEX_FACETPROC uses the executable video_2_json from src/facet/cppdir/osx.
% 
% LIST - Can be a char with path(s) to movie files, a cell with paths to
% movie files, or a FEXC object. When LIST is a FEXC object, the paths to
% the movies for the analysis are indicated in the field FEXC_OBJ.video.
%
% OPTIONAL ARGUMENTS:
%
% -s: minimum face box side size in pixels. This is used to reduce the
%     search space for a face. Default 50.
% -m: maximum number of frames to analyze. Default: Inf
% dir: directory where the .json file will be saved. By default, directory
%     is set to the current working directory, unless you enter a FEXOBJ
%     object as first argument. In this case, the output directory is set
%     to FEXOBJ.DIROUT, assuming that the property is not empty.
% 
% OUTPUT:
%
% Y - list of .json files;
% cmd - list of executed commands;
% h - list of error;
%
%
% See also FEXC, FEX_IMPUTIL, FEX_JSONPARSER.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


if nargin == 0
    error('LIST argument is required.');
end

% Locate executable file
% FACET_EXEC = which('fexfacetexec.cpp');
% if isempty(FACET_EXEC)
%     error('FACET executable not found.');
% else
%     FACET_EXEC = FACET_EXEC(1:end-4);
% end
info = importdata('fexinfo.dat');
FACET_EXEC = info.EXEC;

SAVE_TO = pwd;
if ~isempty(find(strcmpi('dir',varargin),1))
    SAVE_TO = varargin{find(strcmpi('dir',varargin)) + 1};
end

IS_PAR = 1;
if ~isempty(find(strcmpi('parallel',varargin),1))
    IS_PAR = varargin{find(strcmpi('parallel',varargin)) + 1};
end

% Read LIST argument, transform to cell, and add name for output files.
nlist = cell(1,2);
switch class(list)
    case 'fexc'
        for i = 1:length(list)
           nlist{i,1} = list(i).video;
           [~,name] = fileparts(list(i).video);
           nlist{i,2} = sprintf('%s/%s.json',SAVE_TO,name);
        end
    case 'char'
        for i = 1:size(list,1)
           nlist{i,1} = deblank(list(i,:));
           [d,name] = fileparts(nlist{i,1});
           if ~isempty(find(strcmpi('dir',varargin),1))
               SAVE_TO = varargin{find(strcmpi('dir',varargin)) + 1};
           else
               SAVE_TO = d;
           end
           nlist{i,2} = sprintf('%s/%s.json',SAVE_TO,name);
        end
    case 'cell'
        for i = 1:length(list)
           nlist{i,1} = list{i};
           [d,name] = fileparts(list{i});
           if ~isempty(find(strcmpi('dir',varargin),1))
               SAVE_TO = varargin{find(strcmpi('dir',varargin)) + 1};
           else
               SAVE_TO = d;
           end
           if ~exist(SAVE_TO,'dir') || isempty(SAVE_TO)
               warning('Directory provided does not exists. Using PWD');
               SAVE_TO = pwd;
           end
           nlist{i,2} = sprintf('%s/%s.json',SAVE_TO,name);
        end
    otherwise
        error('LIST argument not recognized.');
end
  
% Check whether all videos exist
ind = cellfun(@exist,nlist(:,1));
if sum(ind == 0) > 0
    warning('Movies not found:');
    indw = find(ind == 0);
    for i = indw(:)'
        fprintf('%s\n',nlist{i,1});
    end
end

% Select videos and run preprocessing
nlist = nlist(ind > 0,:);
Y = nlist(:,2);
h = cell(size(nlist,1),1);
cmd = cell(size(h));
for k = 1:size(nlist,1)
    cmd{k} = sprintf('%s -f %s -o %s',FACET_EXEC,nlist{k,1},Y{k});
end

% Update envirnoment (! temporararely)
env1 = getenv('DYLD_LIBRARY_PATH');
setenv('DYLD_LIBRARY_PATH','/usr/local/bin:/usr/bin:/usr/local/sbin');

base = pwd;
tpar = fileparts(FACET_EXEC);
cd(tpar);

% Run the preprocessing
if size(nlist,1) > 1 && IS_PAR
    % Add waitbar with cancel button
    % he = waitbar(0,sprintf('Processing %d Videos',size(nlist,1)),...
    %    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    % setappdata(he,'canceling',0)
    % fun = @(lf) double(exist(lf,'file')>0);
    parfor k = 1:size(nlist,1)
        % if getappdata(he,'canceling')
        % Allow to brake the processing loop
        %   warning('Can''t return yet ...')
        %   return
        % end
        h{k} = system(sprintf('%s',cmd{k}));
        % waitbar(mean(cellfun(fun,Y)),he);
    end
    % delete(he)
else
    for k = 1:size(nlist,1)
        h{k} = system(sprintf('%s',cmd{k}));
    end
end
% return to original environment setting
cd(base)
setenv('DYLD_LIBRARY_PATH',env1);
cmd = char(cmd);







