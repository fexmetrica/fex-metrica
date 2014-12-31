function [inds,M,td,h] = fex_timeroi(ts,ids,ntps,inspect)
% 
%
% FEX_TIMEROI identifies a segment of interest within long timeseries.
%
%
% SYNTAX:
%
% inds = FEX_TIMEROI(TS,IDS,NTSP)
% 
%
% FEX_TIMEROI Finds the center of activity in a set of events specified in
% IDS, from a T*K timeseries TS, given the length of the regions of
% interest NTSP. NOTE that FEX_TIMEROI was developped assuming that TS contain
% instantaneous power estimates at a specific frequency rather than raw
% time series. This implies that all values in TS are positive.
%
% The procedure used is the following:
%
%   1. Datapoints corresponding to 0 values in the vector IDS are set to 0;
%   2. TS is convolved with the vector: ones(NTSP,1);
%   3. for each of the unique values in IDS & each column of TS:
%           find maximum value of the convolution;
%   4. Generate INDTS.
%
%
% ARGUMENTS:
%
% TS - A matrix of timseries T*K, where T is the number of timepoints, and
%   K is the number of features. The K features are treated independently.
%   NOTE that FEX_TIMEROI was developped assuming that TS contain
%   instantaneous power estimates at a specific frequency rather than raw
%   time series.
%
% IDTS - A vector inidicating the full span of events of interest, number 1,
%   ...,Q, with Q being the number of events. IDTS has the same number of
%   rwas as TS.
%
% NTSP - Number of frames to be included. It is advisable to adjust NTSP
%   based on the period of the frequency band used to generate TS.
%
% INSPECT - [NOT IMPLEMENTED] Boolean values; when set to true, fex_timeroi
%   will generate an image (default: false).
%
% OUTPUT:
%
% INDS - a vector of the same size of TS with indices for centered events;
% STATS - statistics over the signal selected;
% H - handle for the image generated when inspect is set to true.
%   
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 1-Sep-2014.


% Argument check
if nargin < 3
    error('Not enough input arguments.');
elseif nargin == 3
    inspect = false;
end

% Get dummyvariables, events id
% and clean ts (nan off-events points (??)) -----> Make an optional
% argument: after/before coverage.
[eId,eOnset] = unique(ids);
eOnset = eOnset(eId >0);
eId = eId(eId >0);
DD = dummyvar(ids+1); DD = DD(:,2:end);
DD = DD(:,sum(DD)>0);
bts = ts;
bts(repmat(ids <= 0,[1,size(ts,2)])) = nan;

% Set up kernel and convolve
tskk = convn(bts,ones(ntps,1),'same');
tskk = repmat(reshape(tskk,size(ts,1),1,size(ts,2)),[1,length(eId),1]);

% Get indices for maximum values. Fix nan values.
[M,Midx] = max(tskk.*repmat(DD,[1,1,size(ts,2)]),[],1);
M = reshape(M,[length(eId),size(ts,2),1]);
Midx = reshape(Midx,[length(eId),size(ts,2),1]);
Midx(isnan(M)) = nan;

% Generate indices for the events, and adjust nans >> CHANGE LOOP
inds = zeros(size(ts));
indl = round(ntps/2);
for iev = 1:length(eId)
    for jfeat = 1:size(ts,2)
        if ntps < sum(ids == eId(iev)) %~isnan(Midx(iev,jfeat));
            tind = Midx(iev,jfeat)-indl:Midx(iev,jfeat)+indl;
            inds(tind,jfeat) = eId(iev);
        else
            inds(ids == eId(iev),jfeat) = eId(iev);
            M(iev,jfeat) = nanmean(ts(ids == eId(iev),jfeat));
        end
    end
end

% Get delayed time
td = Midx - repmat(eOnset,[1,size(ts,2)]);
td(td < 0) = 0;

% Make some Graphs
if inspect
    fprintf('Inspecting ... .\n');
    h = '';
else
    h = 'Set inspect to "true", to get the handle.\n';
end




