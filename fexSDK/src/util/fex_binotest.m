function [test,h] = fex_binotest(x,n,p,tails)
%
% FEX_BINOTEST - binomial test
%
% X - Outcome Number of Success;
% N - Number of Trial;
% P - H0 binomial parameter;
% TAILS - tails for the test.
%
% FIXME - This works for P = 0.05.
%
% ... 



% Test Arguments
% ==============================
if nargin < 2
    error('Wrong number of arguments.');
elseif nargin < 3
    p = 0.5;
    tails = 'both';
elseif nargin < 4
    tails = 'both';
end
    
% Fix argument length / x format
% ==============================
x = x(:);
if size(x,2) == 2
    x = round(x(:,1).*x(:,2));
end

n = n(:);
if length(n) == 1
    n = repmat(n,[size(x,1),1]);
end

% Check expected probability
% ==============================
if p < 0 || p > 1
    p = p./n;
end

% Check argument tails
% ==============================
tails = lower(tails);
if ~ismember(tails,{'left','right','both'})
    warning('Mispecified "tails" argument, using "both"');
end

    
% Get CI success from binofit
% ==============================
% [~, tci] = binofit(x,n,0.05);
% tci = round(tci.*repmat(n,[1,2]));



% Perform the actual test on larger number of outcomes
% ==============================
[val,sval] = max([x,n-x],[],2);
sval(sval == 2) = -1;


% Prob larger than expected;
yh = 1 - binocdf(val-1,n,p);
yh = yh + binocdf(n-val,n,p);
% FIXME: Assuming p = 0.5
yh(yh > 1) = .5;

% Output
% ==============================
test = [yh < 0.025,x,yh,abs(norminv(yh,0,1)).*sval];
test = array2table(test,'VariableNames',{'Pass','hP','PVal','Z'});


% Figure Output -- Histogram
% ==============================
if nargout == 2
    h = make_his();
end


% ==============================
% Graphing function
% ==============================
function h = make_his()

h = test ;




end
% ==============================
end

















