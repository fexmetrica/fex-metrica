function col = fex_getcolors(chanels,colmap)
%
%
% ....

if isempty(nargin)
    error('Not enough input argument');
elseif nargin == 1
    colmap = jet(256);
else
    if ischar(colmap)
        colmap = eval(colmap);
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



