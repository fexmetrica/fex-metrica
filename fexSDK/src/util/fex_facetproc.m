function [Y,cmd,h] = fex_facetproc(list,varargin)
%
% FEX_FACETPROC calls FACET SDK executable file to process videos
%
% SYNTAX:
%
% Y = FEX_FACETPROC(LIST);
% Y = FEX_FACETPROC(FEXC_OBJ);
% Y = FEX_FACETPROC(...,'-VarArgVal');
%
% FEX_FACETPROC uses the executable video_2_json from src/facet/cppdir/osx.
% 
% LIST - Can be a char with path(s) to movie files, a cell with paths to
% movie files, or a FEXC object. When LIST is a FEXC object, the paths to
% the movies for the analysis are indicated in the field FEXC_OBJ.video.
%
% VARARGVAL - a string which modifies the output of FEX_FACETPROC.
%
%
% ...
%
% 
% See also FEXC, FEX_IMPUTIL, FEX_JSONPARSER.
%
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 29-Dec-2014.


if nargin == 0
    error('LIST argument is required.');
end

% Locate executable file
FACET_EXEC = which('fexfacetexec.cpp');
if isempty(FACET_EXEC)
    error('FACET executable not found.');
else
    FACET_EXEC = FACET_EXEC(1:end-4);
end


% Read LIST argument, transform to cell, and add name for output files.
nlist = cell(1,2);
switch class(list)
    case 'fexc'
        for i = 1:length(list)
           nlist{i,1} = list(i).video;
           [~,name] = fileparts(list(i).video);
           nlist{i,2} = sprintf('%s.json',name);
        end
    case 'char'
        for i = 1:size(list,1)
           nlist{i,1} = deblank(list(i,:));
           [~,name] = fileparts(nlist{i,1});
           nlist{i,2} = sprintf('%s.json',name);
        end
    case 'cell'
        for i = 1:length(list)
           nlist{i,1} = list{i};
           [~,name] = fileparts(list(i,:));
           nlist{i,2} = sprintf('%s.json',name);
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
% Run the preprocessing
parfor k = 1:size(nlist,1)
    h{k} = system(cmd{k});
end
cmd = char(cmd);







