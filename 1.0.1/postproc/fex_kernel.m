function [kk,tvrg,Q] = fex_kernel(type,window_size,varargin)
%
% Usage:
%   kk = fex_kernel(type,window_size)
%   kk = fex_kernel(type,window_size,varargin_name, vargin_val,...)
%   [kk,tvrg] = fex_kernel(...)
%   [kk,tvrg,Q] = fex_kernel(...)
%
% This function computes kernel specified in "type," of length specified in
% "window_size."
%
% Input:
% (1) type: a string that specify the shape of the kernel. Implemented
%     shapes are: Box, hrf (double-gamma), e-decay (exponential decay),
%     Gamma, Gaussian, Linear, Sigmoid and U-shaped.
%
% (2) window_size: a scalar which indicates the size of the kernel in
%     datapooints. Alternative window_size is a vector with components
%     [sampling_rate,sec], and that the number of points in the kernel is
%     set to sampling_rate*sec. NOTE: for some function, the parameters
%     will affect winodw size, so window_size is accomodated to adjust the
%     required shape.
%
% Optional Arguments:
%   -- param: this is a vector specifing optional parameters for the shape.
%      Note that different shapes have different parameterization. A list
%      is giveb below:
%
%      Box: No extra parameters besides the size of the box.
%      Hrf: This is a double gamma, analogous to the hemodimanimc response
%           function used in fMRI. Not properly parameterized.
%      e-decay: Exponential decay. Not properly parameterized.
%      Gamma: gamma pdf function. Not properly parameterized.
%      Gaussian: one parameter for standard deviation (default is 1).
%      Linear: one patameter for the slope (default is 1). Note that if the
%              parameter is different from +-1, the size of the window is
%              modify accordingly: namely window_size =
%              round(window_size/abs(param))
%      Sigmoid: sigmoid function. Not properly parameterized.
%      U-shaped: 1 parameter (default set to 1) for the curvature of teh
%              kernel. window_size is affected.
%
%   -- center: 0 or 1. If 1 the kernel is centered. Namely, after computing
%      kk, the function output is kk - mean(kk). By default center = 0, and
%      the kernel are constructded so that sum(kk) = 1, which makes the
%      kernel suitable for computnig running means.
%
%   -- expand: 0 or N. If expand is set to N, fex_kernel compiles the
%      output Q. Q is a (N + length(kk)-1) *  N matrix, compiled in such a way
%      that each column contains zeros and a copy of kk. Furthermore the
%      position of kk is shifted down of one place in each column. So
%      Q(:,1) = [kk; 0; ...] and Q(:,2) = [0; kk; 0; ...], where dots
%      indicate more zeros. If you set N to be the length of your signal
%      timeseries S (N*1), then the full convolution (in matlab:
%      conv(S,kk,'full')) is given by: 
%   
%      conv_signal = Q*S;
%
% Output:
%   kk: the kernel;
%   tvrg: parameters used to construct the kernel.
%   Q:  the (N + length(kk)-1) *  N matrix, s.t. Q*S returns the full
%       convolution of the signal S and the kernel kk.
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 03/15/14.


tvrg = {'param',[],'center',0,'expand',0};
for i = 1:2:length(varargin)
    idx = strcmp(tvrg,varargin{i});
    idx = find(idx == 1);
    if idx
        tvrg{idx+1} = varargin{i+1};
    end
end
tvrg = struct(tvrg{:});

if numel(window_size) == 2
    window_size = round(prod(window_size));
end


% Define kernel types
switch type
    case {'Box','box','b'}
        tvrg.center  = 0;
        kk = padarray(ones(window_size,1)./window_size, round(window_size/2));
    case {'Linear','linear','l'}
        if isempty(tvrg.param)
            tvrg.param = 1;
        elseif ~ismember(tvrg.param,[-1,1])
        % correct for winodw size to represent different slopes
            window_size = round(window_size/abs(tvrg.param));
        end
        kk = 0:tvrg.param/(window_size-1):tvrg.param;
        kk = kk + abs(min(kk));
        kk = kk./sum(kk);
    case {'u','U','u-shaped'}
        warning('U-shaped should be re-parameterized!')
        if isempty(tvrg.param)
            tvrg.param = 1;
        elseif ~ismember(tvrg.param,[-1,1])
        % correct for winodw size to represent different slopes
            window_size = round(window_size/abs(tvrg.param));
        end
        t = (0:window_size-1) - (window_size-1)/2;
        kk = (tvrg.param*t).^2;
        kk = kk./sum(kk);
    case {'e-decay','ed'}
        warning('Exponential decay should be re-parameterized!')
        if isempty(tvrg.param)
            tvrg.param = [1,.5];
        end
        t = 0:window_size-1;
        kk = tvrg.param(1)*exp(-tvrg.param(2)*t);      
    case {'Gaussian','gaussian','g'}
    % I want to change this to one parameter for FWHM. Note that FWHM =
    % 2*sqrt(2*log(2))*sigma. default is sigma = 1 (i.e. FWHM =
    % 2*sqrt(2*log(2))).
        if isempty(tvrg.param)
            tvrg.param = 1; %(2*sqrt(2*log(2)));
        end
        t = -2.5:5/(window_size-1):2.5;
        s  = tvrg.param; %tvrg.param./(2*sqrt(2*log(2)));
        kk = exp((-t(:).^2)./(2*s^2));
        kk = kk./sum(kk);
        
    case {'Gamma','gamma','gm'}
        warning('Gamma should be re-parameterized!')
        if isempty(tvrg.param)
            tvrg.param = [2,3];
        end
        kk = gampdf(0:window_size-1,tvrg.param(1),tvrg.param(2));
    case {'Sigmoid','sigmoid','s'}
        warning('Sigmoid should be re-parameterized!')        
        if isempty(tvrg.param)
            tvrg.param = 1;
        end
        t = -1:2/(window_size-1):1;
        kk = 1./(1 + exp(-tvrg.param(1)*t));
    case {'hrf','Hrf','dgm'}
        warning('Hemodinamic response function should be re-parameterized!')
        % Parameters here are to be interpreted as:
        % 1) Delay of response
        % 2) Delay of undershoot
        % 3) Dispersion of response
        % 4) Dispersion of undershoot
        % 5) Ratio of response to undershoot
        % 6) onset (seconds)
        % 7) length of kernel in seconds
        % 8) sampling rate
        if isempty(tvrg.param)
            tvrg.param = [6 16 1 1 6 0 32 1/15];
        end
        % This is modified from spm_hrf.m
        dt = tvrg.param(8);
        t  =  0:((tvrg.param(7))/dt) - tvrg.param(6)/dt;
        kk = gampdf(t,tvrg.param(1)/tvrg.param(3),tvrg.param(3)/dt) ...
            - gampdf(t,tvrg.param(2)/tvrg.param(4),tvrg.param(4)/dt)/tvrg.param(5);
        kk = kk(1:end-1)./sum(kk(1:end-1));
    otherwise
        error('No kernel named ''%s'' is implemented.\n',type)
end

% Centering
kk = kk(:) - tvrg.center*mean(kk);

% Matrix for convolution.
if tvrg.expand > 0
    Q = zeros(tvrg.expand + (window_size-1),tvrg.expand);
    for k = 1:tvrg.expand
        Q(k:k+window_size-1,k) = kk(:);
    end
end





