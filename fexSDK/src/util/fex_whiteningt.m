function WX = fex_whiteningt(X,varargin)
%
% FEX_WHITENINGT - Apply whitening transform to a set of timeseries.
%
% WX = FEX_WHITENINGT(X)
% WX = FEX_WHITENINGT(X,'epsilon',val)
%
% FEX_WHITENINGT is used to whiteningt the data. FEX_WHITENINGT transforms
% the maxtrix X into WX s.t. the variance covariance matrix of WX is the
% identity martix (all variables in WX are uncorreleted, they have variance
% set to 1, and mean set to 0).
%
% Input arguments include:
%
% X - is N*K matrix, where N is the number of observations, and K is the
%   number of random variables.
%
% 'epsilon' - a scalar used to adjust for negligeble eigenvalues. Default:
%   0.0001 (This argument is used to avoids complex results).
%
% Output argument:
%
% WX - matrix with whitened transformed data.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 20-Apr-2014.

% Handle 'epsilon' optional argument.
if isempty(varargin)
    epsilon = 0.0001;
else
    epsilon = varargin{end};
end

% Prepare the data (zero mean and get nans off)
X  = X - repmat(nanmean(X,1),[length(X),1]);
XX = X(~isnan(sum(X,2)),:);
WX = nan(size(X));

% Get singular values decomposition of varcovar matrix
VC = XX'*XX;
[U,S] = svd(VC);

% Whiten transformation (trans. matrix and implementation)
WM = sqrt(size(XX,1)-1)*U*sqrtm(inv(S + eye(size(S))*epsilon))*U';
WX(~isnan(sum(X,2)),:) = XX*WM;



