function [Y,P,M,R] = fex_reallign(XX,varargin)
%
% FEX_REALIGN Reallignment of frame-wise faces to mean/
%
% Y = FEX_REALIGN(XX)
% Y = FEX_REALIGN(XX,'ArgName1',ArgVal1)
% [Y,T,M,R] = FEX_REALIGN(...)
%
%
% FEX_REALIGN reallign images to their mean using procrustes analysis of
% face landmarks.
%
% XX: a dataset of landmarks with variable names consistent with
%   convenction from FEXC.structural.
%
% 'steps': 1 or 2 (default is 1). When it is set to 2, coregistration is
%       done once for all data, then the error in the coregistration is
%       used to infer false positives, and coregistration is done a second
%       time using the average position of non false positives.
%
% 'scaling': true or false (default is true). Determine whether 'scaling'
%       is used for coregistration.
%
% 'reflection': true or false (default is false). Determine whether
%       'reflection' is used for coregistration.
%
% 'threshold': a scalar between 0 and Inf (default is 3.5). It indicates
%       the number or standard deviation above the mean of the residual sum
%       of square error of the coregistration. When threshold is set to a
%       number larger than 0, this is used to identify false positive. Note
%       that this option has an effect only when the number of steps is set
%       to 2.
%
%_______________________________________________________________________
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 23-July-2014.


% Handle optional arguments
args = struct('steps',1,'scaling',true,'reflection',false,'threshold',3.5);
fld  = fieldnames(args);
if length(varargin) > 1
    for i = 1:2:length(varargin)
        args.(varargin{i}) = varargin{i+1};
    end
end
args = rmfield(args,setdiff(fieldnames(args),fld));

% Run first round and get zscored error
[Y,P,M,R] = coregstep(XX,args);
R(~isnan(R)) = zscore(R(~isnan(R)));
R(R < 0) = 0;

if args.steps == 2 && sum(R>=args.threshold)>0
    % Add extra step without using false positives
    idx = nan(sum(R>=args.threshold),size(XX,2));
    XX(R>=args.threshold,:) = mat2dataset(idx,'VarNames',XX.Properties.VarNames);
    [Y,P,M] = coregstep(XX,args);
end
    
function [Y,P,M,R] = coregstep(XX,args)

% Function for the actual coregistration of the images.

R = nan(size(XX,1),1);
LL = getlandmarks(XX);
M = nanmean(LL,3);
P = nan(size(XX,1),round(1+size(LL,2)+size(LL,2).^2));
Y = nan(size(XX,1),numel(M));
for i = 1:size(LL,3)
    if ~isnan(LL(1,1,i))       
        [d,Z,t]= procrustes(M,LL(:,:,i),'scaling',args.scaling,'reflection',args.reflection);
        R(i)   = d;
        P(i,:) = [t.b,reshape(t.T,1,numel(t.T)),t.c(1,:)];
        Y(i,:) = reshape(Z',1,numel(Z));
    end
end




function LL = getlandmarks(XX)

% Get landmarks names (Note that I am assuming that you have all of them
% and that the first 4 are define the box

load('fexheaders.mat');
lnames = hdrs.structural(3:end-3);

L  = double(XX(:,ismember(XX.Properties.VarNames,lnames)));
LL = [];
for i = 1:size(XX,1)
    LL = cat(3,LL,[L(i,1:2:end)',L(i,2:2:end)']);
end
LL(2,:,:) = LL(1,:,:) + LL(2,:,:);


