function [folds, index] = fex_nfoldscv(num_obs, num_folds)
%
% [folds, index] = nfoldscv(num_obs, num_folds)
%
% nfoldscv generates random indices (both integer labels and dummy labels)
% in order to divide a dataset for n folds coross validation.
%
% Input the number of observation in your dataset and the number of folds
% you want.
%
% Output:
%
%   folds = a matrix of dummy variable with a column for each fold, where 0
%           labels the training set and 1 labels the test set.
%   index = integer index between 1 and num_folds, indicating each of the
%   num_folds test set.
%


rperm = randperm(num_obs);
folds = zeros(num_obs, num_folds);
ind_1 = 1;
step = round(num_obs/num_folds);
for ifolds = 1:num_folds
    ind_2 = ind_1+step-1;
    if ind_2 > size(rperm,2)
        ind_2 = size(rperm,2);
    end
    tu = rperm(ind_1:ind_2);
    folds(tu,ifolds) = 1;
    ind_1 = ind_1 + step;
end

index = zeros(num_obs,1);
for ifolds = 1:num_folds
    index(folds(:,ifolds)==1)=ifolds;
end

fix = unidrnd(num_folds);
index(index == 0) = fix;
idx = sum(folds,2);
folds(idx == 0 ,fix) = 1;
