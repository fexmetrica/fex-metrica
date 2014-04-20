function WX = fex_whiteningt(X,varargin)
%
% Usage:
%
% WX = fex_whiteningt(X)
% WX = fex_whiteningt(X,'epsilon',val)
%
% Whiteningt the data, that is transform the maxtrix X into WX s.t. the
% variance covariance matrix of WX is the identity martix (all variables in
% WX are uncorreleted, and they have variance set to 1).
%
% Input:
%
% X is N*K matrix, where N is the number of observations, and K is the
%   number of random variables.
%
% 'epsilon': a scalar used to adjust for negligeble eigenvalues. Default is
%   0.0001 (it avoids complex results).
%
% Output:
%
% WX: matrix with whitened transformed data.
%
% Note: I am implementing thsi with PCA next.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 04/20/14.


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



