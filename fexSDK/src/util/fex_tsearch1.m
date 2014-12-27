function idx = fex_tsearch1(T,Ti)
% 
% FEX_TSEARCH1 returns indices from closest point between T and Ti
%
% SYNTAX:
%
% idx = FEX_TSEARCH1(T,Ti)
%
% T   - a K*1 matrix of values.
% Ti  - a Q*1 matrix of values.
% idx - A Q*1 matrix of indices s.t. T(idx) -Ti is minimized.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 1-Jan-2014.

[~,idx] = min(abs(repmat(Ti,[1,length(T)]) - repmat(T',[length(Ti),1])),[],2);



