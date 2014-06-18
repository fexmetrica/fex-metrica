function [X,y, selected] = fex_balance(X,y)
%
% This function takes the data in (X, y) and outputs a subset of the data matrix
% with balanced labels by randomply sampling from the pool of data in the
% most frequent class.
%
% The output comprise the data matrix balanced, the corrisponding targets,
% and the index of the selected datapoints.


if sum(y == 0) > 0; y(y == 0) = -1; do_me = 'yes';
else do_me = 'no'; end

% if nargin == 3
%     if strcmp(intelligent, 'intelligent')
%         ref = mean(X);
%         rref = repmat(ref, size(X,1), 1);
%         crit = sum(sqrt((X - rref).^2), 2);
%         [~, idx] = sort(crit, 'descend');
%         X = X(idx, :);
%     end
% end

data = cat(2,X,y);

if sum(y == -1) > sum(y ==1)
    list = randperm(sum(y == -1));
    n = sum(y == 1);
    temp = data(y == -1,:);
    extract = temp(list(1:n),:);
    balance = cat(1,extract, data(y == 1,:));

else
    list = randperm(sum(y == 1));
    n = sum(y == - 1);
    temp = data(y == 1,:);
    extract = temp(list(1:n),:);
    balance = cat(1,extract, data(y == -1, :));
    r = randperm(size(balance,1));
    balance = balance(r,:);
end

X = balance(:,1:end-1);
if strcmp(do_me, 'yes'); balance(balance(:,end)==-1,end) = 0; end    
y = balance(:,end);

selected = list(1:n);