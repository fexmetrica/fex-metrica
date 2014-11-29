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

idx = round(linspace(10,length(colmap)-10,length(chanels)));
for k = 1:length(chanels)
    col.(chanels{k}) = colmap(idx(k),:);
end



