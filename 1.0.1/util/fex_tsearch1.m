function idx = fex_tsearch1(T,Ti)
% 
% Fix time from data and frame timestamps.

[~,idx] = min(abs(repmat(Ti,[1,length(T)]) - repmat(T',[length(Ti),1])),[],2);



