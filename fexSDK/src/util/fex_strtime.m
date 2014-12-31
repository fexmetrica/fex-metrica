function str = fex_strtime(sec,formatt)
%
%
% FEX_STRTIME converts double to string for time and viceversa.
%
% SYNTAX:
%
% str = FEX_STRTIME(SEC)
% str = FEX_STRTIME(SEC,FORMATT)
%
%
% SEC - If SEC is a double, FEX_STRTIME transforms the double SEC into a
%   string "hh:mm:ss.msc." Alternatively, if SEC is a string, FEX_STRTIME
%   converts the string "hh:mm:ss.msc" to a double.  SEC can be of class
%   char, a cell, a double, or a vector.
%
% FORMAT - a string set to 'long' (default), or 'short.' When FORMAT is set
%   to 'short,' the resulting output STR do not include hours or
%   milliseconds -- i.e. str has the form "mm:ss."
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 14-Jun-2014.


if nargin == 1
    formatt = 'long';
end

if isa(sec,'char')
    str = str2double(strsplit(sec,':'))*[60^2,60,1]';
elseif isa(sec,'cell')
    conrt = @(t)str2double(strsplit(t,':'));
    st = cellfun(conrt,sec,'UniformOutput',false);
    str = cell2mat(st)*[60^2,60,1]';
elseif isa(sec,'double') && strcmp(formatt,'long')
    conrt = @(t) sprintf('%.2d:%.2d:%.2d.%.3d',...
        floor(t/3600),floor(mod(t/60,60)),floor(mod(t,60)),...
        round(1000*(mod(t,60)-floor(mod(t,60)))));
    str = cellfun(conrt,num2cell(sec),'UniformOutput',false);
elseif isa(sec,'double') && strcmp(formatt,'short')
    conrt = @(t) sprintf('%.2d:%.2d',floor(mod(t/60,60)),round(mod(t,60)));
    str = cellfun(conrt,num2cell(sec),'UniformOutput',false);
end
         
