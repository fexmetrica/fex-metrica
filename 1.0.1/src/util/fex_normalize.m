function [N,scale] = fex_normalize(data,varargin)
%
% Usage:
% N = fex_normalize(data)
% N = fex_normalize(data,ArgName,ArgVal,...)
% [N,scale] = = fex_normalize(...)
%
% input a datamatrix data, and fex_normalize output the matrix N normalized
% along the 1st dimension. the structure 'scale,' contains information
% about the scaling operation.
%
% Optional arguments:
%
%  'method': a string, between 'zscore' (default), 'center', '0:1', and
%       '-1:1'. The functon either zscore the data, center them, or it
%       scales them between the 0 and 1, or between -1 and 1.
%
%  'folds': A vector of the same length of data, with index marking
%       different folds. Data will be scaled independently for each fold.
%
%  'outliers': a string that can be set to 'off' (default), or 'on'. When
%       set to 'on', fex_normalize zscores the data, and identifies
%       outliers. The values for the outliers is set to the maximum (or
%       minimum) value of the remaining data. In case of zscore, maximum
%       and minimum are set to the maximum (minimum) stand. deviations in
%       the remamining data.
%
%  'threshold': a (positive) integer used as criterion to define outliers.
%       Default is 2.5 standard deviations above/below the mean.
%
%
% Note that scale.outliers contains indices for the outliers.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 04/14/14.


% Handle parameters
scale = {'method','zscore','folds',ones(size(data,1),1),'outliers','off','threshold',2.5};
for i = 1:2:length(varargin)
    idx = strcmp(scale,varargin{i});
    idx = find(idx == 1);
    if idx
        scale{idx+1} = varargin{i+1};
    end
end
% Argument and info to be outputed
scale = struct(scale{:});

% Handy formula for zscore when there are nans in the matrix
nanz = @(x)(x - repmat(nanmean(x,1),[size(x,1),1]))./repmat(nanstd(x,1),[size(x,1),1]);

% Space for Z scores and indices for outliers
NZ = []; IDX = [];
if strcmp(scale.outliers,'on')
    for ifolds = unique(scale.folds)'
        z = nanz(data(scale.folds == ifolds,:));
        o = zeros(size(z));
        o(z > abs(scale.threshold))  =  1;
        o(z < -abs(scale.threshold)) = -1;
        NZ  = cat(1,NZ, z);
        IDX = cat(1,IDX,o);
    end
    data(IDX ~=0) = nan;
end


% Space for the matrix with scaled data
N   = []; 
switch scale.method
    case {'zscore','z','center','c'}
        param = '';
        for ifolds = unique(scale.folds)'
            if ismember(scale.method,{'zscore','z'})
                z = nanz(data(scale.folds == ifolds,:));
            else
                z = data(scale.folds == ifolds,:) - repmat(nanmean(data(scale.folds == ifolds,:)),...
                    [sum(scale.folds == ifolds),1]);
            end
            if strcmp(scale.outliers,'on')
                m = repmat(min(z,[],1),[size(z,1),1]);
                M = repmat(max(z,[],1),[size(z,1),1]);
                z(IDX(scale.folds == ifolds,:) == -1) = m(IDX(scale.folds == ifolds,:) == -1);
                z(IDX(scale.folds == ifolds,:) ==  1) = M(IDX(scale.folds == ifolds,:) ==  1);
            end
            N = cat(1,N,z);
        end
    case {'0:1','-1:1'}
        param = struct('max', {}, 'min', {});
        for ifolds = unique(scale.folds)'
            temp = data(scale.folds == ifolds,:);
            M = max(temp);
            m = min(temp);
            R = M-m;
            n = (temp - repmat(m, [size(temp,1),1]))./repmat(R, [size(temp,1),1]);
            if strcmp(scale.method,'-1:1')
                n = n.*2-1;
            end
            N = cat(1,N,n);
            param(ifolds).max = M;
            param(ifolds).min = m;
        end
        % Put outliers back in if required
        if strcmp(scale.outliers,'on')
            val = str2double(strsplit(scale.method,':'));
            N(IDX == -1) = val(1);
            N(IDX ==  1) = 1;
        end   
    otherwise
        error('myApp:argChk', 'Unknown method: %s',scale.method); 
end

% Store information
scale.outliersidx = IDX;
scale.bound = param;
