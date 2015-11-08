function D = fex_dummyvar(V,prune,incl)
%
% FEX_DUMMYVAR - Code for generating dummyvariables from a vector.
%
% Usage:
%
% ...
%
% V - A vector or matrixl
% PRUNE - boolean (default = false): indicates whether to drop columns of
% zeros;
% INCL -  boolean (default = false): indicates whether values < 0 are a
% category.


prune = true;
incl  = false;

lv = min(V);
if lv <= 0
    lv = abs(lv) + 1;
else
    lv = 0;
end
NV = V + lv;

D = dummyvar(NV);

if ~incl && lv > 0
    D = D(:,abs(lv)+1:end);
end

if prune
    D = D(:,sum(D) > 0);
end


