function [S,H,L,R] = fex_opticon(x1,x2,ffi,varargin)
%
% FEX_OPTICON -- Power based connetivtity analysis between channels.
%
%
% ...
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 02/06/16.



% FIXME: VALUE:
%
% Sperman
% Granger
% Mutual information


% Read input arguments
% ==========================================================
args = struct('transform','power',...
              'value','sperman',...
              'overlap',false,...
              'time',[],...
              'trials',[],...
              'lags',5,...
              'box',20); 
          
if nargin < 3
    error('Not enough input arguments.');
end
for j = 1:2:length(varargin)
    if isfield(args,lower(varargin{j}))
        args.(lower(varargin{j})) = varargin{j+1};
    end
end

% Check lag / box ratio
% ==========================================================
if args.box/args.lags < 2
    warning('Maximum lag is 1/2 the size of the box.');
    args.lags = floor(args.box/2);
end

% Set-up windows / trials
% ==========================================================
% FIXME: Add matrix for trials method
if isempty(args.trials)
    T = make_dummy(args.box,size(x1,1),args.overlap);
else
    T = dummyvar(args.trials);
end


% Call bandpass filtering method to get power estimate
% ==========================================================
if ~strcmpi(args.transform,'none')
    % FIXME: get power or phase
    X = fex_bandpass([x1,x2],ffi);
    X = abs(X.analytic).^2;
end


% Compute correlations
% ===========================================================
% FIXME: this is supposed to happen separately for each trial 
R = [];
for k = 1:size(T,2)
    r = xcov(tiedrank(X(T(:,k)==1,1)),tiedrank(X(T(:,k)==1,2)),args.lags,'coeff');
    R = cat(2,R,r);
end

% Find largest correlation value across lags & get median score
% ===========================================================
[S,L] = max(R);
H = median(R);


function T = make_dummy(box,n,over)
%
% MAKE_DUMMY - helper function for trial-wise dummy set up.

if over
    T = zeros(n,n-box);
    k = 1;
    % FIXME -- 
    for i = 1:n-box
        T(k:k+box-1,i) = 1;
        k = k + 1;
    end
    % Use only valid segments
else
   nb = ceil(n/box);
   T = [];
   for i = 1:nb
       T = cat(1,T,repmat(i,[box,1]));
   end
   T = dummyvar(T(1:n,:));   
end
    



