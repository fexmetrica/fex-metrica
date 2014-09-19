function [inds,M,td,h] = fex_timeroi(ts,ids,ntps,inspect)
% 
% inds = fex_timeroi(ts,ids,ntps)
% 
% Finds center of activity in a set of events specified in ids, on a T*K
% timeseries ts, fixing the length of the region of interest within a roi
% to ntps.
%
% ts: matrix of timseries T*K, where T is the number of timepoints, and K
%    is the number of features. The K features are treated independently.
%    Note that "ts" is meant to contain instantaneous power estimates at a
%    specific frequency.
%
% idts: A vector inidicating the full span of events of interest, number 1,
%    ...,Q, with Q being the number of events.
%
% ntps: Number of frames to be included. Adjust ntps based on the period of
%    the frequency band used to generate ts.
%
% inspect: Boolean values; when set to true, fex_timeroi will generate an
%    image (default: false).
%
% Output:
%
% >> inds: a vector of the same size of ts with indices for centered
%          events;
% >> stats: statistics of the signal selected;
% >> h: handle for the image generated when inspect is set to true.
%   
%
% Algorithm:
%
% 1. off-events datapoints are set to 0;
% 2. "ts" is convolved with the vector: ones(ntps,1);
% 3. for each event & feature:
%        find maximum value of the convolution;
% 4.generate indts;

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




