function [list,lname] = fex_find(varargin)
%
% FEX_FIND - uses unix comand "find" to make a list of files.
%
% Usage:
%
% list = fex_find();
% list = fex_find(dir);
% list = fex_find(dir,ext);
%
% Example:
%
% list = fex_find(pwd,'*.csv');
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 23-Apr-2015.
%
%
% See also FEXWSEARCHG.m.

% Use UI
% ====================
if isempty(varargin)
    list = fexwsearchg();
    return
end

% Assign arguments
% ====================
if length(varargin) == 1;
    dirp = varargin{1};
    extf = '*';
elseif length(varargin) >= 2;
    dirp = varargin{1};
    extf = varargin{2};
end
    
% Issue unix command
% ====================
cmd = sprintf('find "%s" -name %s|sort',dirp,extf);
[h,o] = system(cmd);

% Output list
% ====================
if h ~= 0
    error('Error code: %d.\n',h);
else
    list = cellstr(strsplit(o(1:end-1),'\n'))';
end

% Output list with name only
% ====================
[~,lname] = cellfun(@fileparts,list,'UniformOutput',0);


