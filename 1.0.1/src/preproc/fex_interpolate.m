function [ndata,ntsp,nfr,nan_info] = fex_interpolate(data,tsp,dps,rule)
%
% Usage:
%
% [ndata, tsp] = fex_interpolate(data,tsp,dsp)
% [ndata, tsp] = fex_interpolate(data,tsp,dsp,rule)
%
% This function interpolate a time-series with datapoint acquired at a
% variable frequency, so to obtain a constant frequency timeseries.
% Additionally, the function recover missing values in the time series
% using the interpolation.
%
% Input arguments:
%
%   -- data: [matrix or vector, required] a matrix N*K, with K = number of
%            timeseries, and N = numeber of observations. Null observations
%            should me marked as nan.
%   -- tsp:  [vector,required] time stamps in seconds (size = N*1),
%            indicating when each datapoint was acquired.
%   -- dps:  [vector,required] number of datapoints per second, a.k.a fixed
%            frequency used for the new timestamps, s.t. the new timeseries
%            will have timestamps tsp(1):1/dps:tsp(end); size: N*1.
%   -- rule: [scalar,optional] rule used for handling null observation.
%            That is, maximum number of consecutive null observations that
%            will be interpolated. If this number is exceeded, the value
%            returned is nan. Default is Inf (namely all datapoints are
%            recovered).
%
% Output arguments:
%
%   -- ndata: [matrix or vector] new datamatrix.
%   -- ntsp:  [vector] new vector of timestamps.
%   -- nfr:   [vector] since the new matrix may be longer than
%             the original dataset, there will be more datapoints than the
%             one originally acquired (i.e. 1:length(data)). nfr indicates a
%             correspondence between rows in data and rows in ndata.
%   -- nan_info: information about number and duration of null events.
%             It's a N*2 matrix, the first column tags adjacent null
%             obesrvations and the second column indicate how many adjacent
%             Nans ther are.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 03/21/14.


if nargin < 3
    error('Wrong number of arguments. You need at least data, tsp, dps.\n');
elseif nargin == 3
    rule = Inf;
end
fprintf('Interpolating timeseries.\n')

% original frames
fr = (1:size(data,1))';

% new timestamps
ntsp = tsp(1):1/dps:tsp(end); ntsp = ntsp';

% old frames to new frames index and new nans
[~,nfr]  = min((repmat(tsp',[length(ntsp),1]) - repmat(ntsp,[1,length(tsp)])).^2,[],2);
nan_0    = fr(isnan(sum(data,2)));
nanidx   = zeros(size(nfr));
nanidx(ismember(nfr,nan_0)) = 1; 

% interpolate (and extrapolate for out of bound vals)
ndata = interp1(tsp(~isnan(sum(data,2))),data(~isnan(sum(data,2)),:),ntsp,'pchip','extrap');

% Reintrocuce null observation according to "rule"
fprintf('cleaning up ... \n')
nanidx2 = zeros(size(nanidx));
bwidx   = bwlabel(nanidx);
nan_info = zeros(length(bwidx),1);
for i = 1:max(bwidx)
    nan_info(bwidx == i) = sum(bwidx == i);
    if sum(bwidx == i) >= rule
       nanidx2(bwidx == i)  = 1;
    end
end
nan_info = cat(2,bwidx,nan_info);
ndata(repmat(nanidx2,[1,size(ndata,2)]) == 1) = nan;


