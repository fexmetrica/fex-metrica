function M = fex_getmatrix(data,index,varargin)
%
% -----------------------------------------------------------------  
% 
% Generate a matrix from the timeseries. Index is a vector of the
% same length of self.functional, s.t. [0,0,1,1,0,0,2,2,...] would
% select 2 events, and return a matrix where the first row is the
% average of the signal from frames tagged "1", the second row is
% the average of frames tagged with "2," and so on. Note that -Inf
% ,..., 0 are not considered tags, and will be excluded.
%
% varargin include:
%
%   'method': ...
%   'size'  : ...
% 
% -----------------------------------------------------------------
%

% Set up event list
evlist = unique(index(index > 0));
index  = cat(2,index,zeros(size(index,1),1));
M = [];

        
% Set up method argument
ind = find(strcmp('method',varargin));
if isempty(ind)
    method = @nanmean;
elseif isa(varargin{ind+1},'function_handle')
    method = varargin{ind+1};
else
% try char that can be converted into an handle, otherwise give up.
    try
       method = eval(sprintf('@%s',varargin{ind+1}));
    catch errorID
        warning(errorID.message);
        return
    end
end
        
% Set up size argument
ind = find(strcmp('size',varargin));
if ~isempty(ind)
% get the position of the window
    val = varargin{ind+1};
    wps = find(val ~=0);
    if ~ismember(wps,1:2)
        warning('I couldn''t understand "size" parameter.');
        return
    end
    % Resize the events
    for i = evlist'
        nc = (1:sum(index(:,1) == i))';
        if wps == 1
        % Get the beginning of the event
            index(index(:,1) == i,2) = nc;
        else
        % Get the end of the event
            index(index(:,1) == i,2) = flipud(nc);
        end
    end
    index(index(:,2) > val(wps),1) = 0;
end
        
% Compile the matrix
temp = double(data);
for i = evlist'
    M = cat(1,M,method(temp(index(:,1) == i,:)));
end

% Add header if provided:
if isa(data,'dataset')
    M = mat2dataset([evlist,M],'VarNames',['NumEvent',data.Properties.VarNames]);
end

        
        