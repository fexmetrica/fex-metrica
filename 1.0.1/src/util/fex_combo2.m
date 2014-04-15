function combination = fex_combo2(vect1, vect2, repeat)
%
% combination = combo2(vect1, vect2, repeat)
%
% Combine two vectors exhausting the possible combinations.
% if you go for non repeated combinations (i.e. if you want to exclude the
% to have both [1, 2] and [2,1]) set repeat = 'triang'. In this case vect1
% vect 2 should have the same length.

col1 = [];
col2 = [];

vect1 = vect1(:); vect2 = vect2(:);

for iLen = 1:size(vect1,1)
    col1 = cat(1, col1, repmat(vect1(iLen),[size(vect2),1]));
    col2 = cat(1, col2, vect2);
end

combination = [col1 col2];

if nargin == 3
    if strcmp(repeat, 'triang')
        k = size(vect1,1); l = 1;
        filter = ones(length(combination),1);
        for i = 1:length(vect1)
            filter(k+1:k+l) = 0;
            k = k + length(vect1);
            l = l+1;
        end
    combination = combination(filter == 1, :);
    end
end
