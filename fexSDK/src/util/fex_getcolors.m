function col = fex_getcolors(chanels,colmap)
%
% FEX_GETCOLORS - generates a matrix COL with RGB colors.
%
% SYNTAX: 
% 
% col = FEX_GETCOLORS(chanels)
% col = FEX_GETCOLORS(chanels,colmap)
%
% INPUT:
%
% CHANNELS - This argument can be a cell of strings or a scalar. When
%   CHANNEL is a cell, FEX_GETCOLORS generates as many colors as
%   length(CHANNELS), and the output COL is a stracture, with field named
%   after the string in CHANNELS. If CHANNELS is a scalar, COL is a matrix
%   with 3 columns (R,G,B), and size(COL,1) == CHANNELS.
%
% COLMAP - A colormap, specidied as a matrix of K colors and 3 columns.
%   Alternatively, COLMAP can be a string with one of MATLAB colormaps.
%   When COLMAP is left empty, the colors are selected from the colormap
%   'jet'.
%
% OUTPUT:
%
% COL: a CHANNELS * 3 matrix of colors when CHANNELS is a scalar, or a
% structure with fields CHANNELS, each containing a 1 * 3 color vector,
% when CHANNELS is a cell of strings.
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 09-Jan-2014.


if isempty(nargin)
    error('Not enough input argument');
elseif nargin == 1
    colmap = jet(256);
else
    if ischar(colmap)
        h = figure('Visible','off');
        colmap = eval(colmap);
        delete(h);
    end
end

if iscell(chanels) || ischar(chanels)
    idx = round(linspace(10,length(colmap)-10,length(chanels)));
    for k = 1:length(chanels)
        col.(chanels{k}) = colmap(idx(k),:);
    end
elseif isa(chanels,'double') && length(chanels) == 1
    idx = round(linspace(10,length(colmap)-10,chanels));
    col = zeros(chanels,3);
    for k = 1:chanels
        col(k,:) = colmap(idx(k),:);
    end
else
    error('Chanels can be a string, a cell or a double.');
end



