function [filt_ts,filt_kr] = fex_bandpass(data,ffi,varargin)
%
% Usage:
%
% filt_ts = fex_bandpass(data,ffi)
% filt_ts = fex_bandpass(data,ffi,'OptName','OptVale',...)
% [filt_ts,filt_kr] = fex_bandpass(...)
%
% This is a simple wrapper for firls/fir1 and filtfilt, that apply either
% bandpass, low pass or high pass filtering to the data. For more complex
% filter, you should use filrs or fir1 directly.
%
% Input:
%
% (1) data: a N*K matrix with N datapoints, and K variables.
%
% (2) ffi: frequency information. This is either a 3 components or a 2
%     components vector, depending on filter type:
%
%       - for bandpass: [low_frq,high_frq,nyquist];
%       - for highpass: [low_freq, nyquist]
%       - for lowpass:  [high_freq,nyquist]
%
%     Note that the last component is always the nyquist frequency
%     (sampling_rate/2).
%
%
% Optional Arguments:
%
% (3) "type": can be bandpass (or band, or bp) to implement a bandpass filter;
%     lowpass (lp,low) to implement a low pass filter; or it can be
%     highpass (hp,high) to implement a high pass filter. bandpass filter
%     is implemented using firls, while low and high pass filter is
%     implemented using fir1. If you don't specify this argument and
%     length(ffi)==2, type is set to 'highpass.' If length(ffi)==3 type is
%     set to 'bandpass'
%
% (4) "order": the order of the filter. In general, you want large
%     order. There is a lower and upper bound. The filter must be long
%     enough to contain one cycle for the lower frequency, therefore it
%     must be at least round(sampling_rate/lower_frequency). Also, the
%     filter must be at most long 1/3 of the data. So:
%
%     round(sampling_rate/lower_frequency) <= order <= round(N-1)/3).
%
%     In generat, 3-5 cycles is a good value. Default for this argument is
%     1/3 the length of the dataset.
%
% (5) "tw": is a transition window expressed in percentage. It prevents
%     artifacts, and should be between .1 and .25. This arguments applies
%     for bandpass filters only. Default is .1. It can't be larger than 1.
%
% Output:
%
%   filt_ts: a structure with fields:
%       > filt_ts.real: a N*K matrix with the filtered data.
%       > filt_ts.analytic: a N*K matrix with the analytic signal (i.e,
%         hilbert(filt_ts.real)).
%
%   filt_kr: a structure with kernel information
%       > filt_kr.kernel: contains the kernel itselfe;
%       > filt_kr.amplitude is a matrix, the first column indicates Hz, and
%         the second column contains amplitude of the signal at those Hz.
%       > filt_kr.sse: sum of square between the filter and the ideal
%         filter. This should be use as diagnostic to assess the goodnes of
%         fit of the filter. Values must not exceed 1.
%
% NOTE: guidinglines for parameters specification were taken from:
% M.X.Cohen, Analyzing Neural Time Series Data, MIT Press, 2014.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 04/17/14.


% Check arguments entered
if nargin < 2
    error('You need to enter at least data, and filter parameters.');
elseif nargin > 2 && ~ismember(length(ffi),2:3)
    error('The argument ''ffi'' can be either 2 (hp,lp) or 3 (bp) component vector.');
end

% Assign optional argument
opt_arg = {'type','','order',[],'tw',.1};
for i = 1:2:length(varargin)
    idx = strcmp(opt_arg,varargin{i});
    idx = find(idx == 1);
    opt_arg{idx+1} = varargin{i+1};
end
opt_arg = struct(opt_arg{:});


% Check optional arguments values: "type"
if isempty(opt_arg.type) && length(ffi) == 2
    type = 'hp';
elseif isempty(opt_arg.type) && length(ffi) == 3
    type = 'bp';
else
    type = opt_arg.type;
end
    
% Check optional arguments values: "order"
if isempty(opt_arg.order)
    filt_order = floor(size(data,1)/3)-1;
    filt_order = filt_order-mod(filt_order,2);
else
    if (opt_arg.order+mod(opt_arg.order,2))*3 >= size(data,1);
        warning('Your filter is too long. It was changed to be 1/3 of data length.')
        filt_order = floor(size(data,1)/3)-1;
        filt_order = filt_order-mod(filt_order,2);
    elseif opt_arg.order < (ffi(end)*2)/ffi(1)
        warning('Your filter is too short. It was changed to include 1 cycle for lower Hz.')
        filt_order = round((ffi(end)*2)/ffi(1));
    else
        filt_order=opt_arg.order;
    end
end


% Check optional arguments values: "tw"
if (opt_arg.tw < .1 || opt_arg.tw > .25) && opt_arg.tw <=1
    warning('Transition window usually is set between .1 and .25.');
elseif opt_arg.tw > 1
    warning('tw must be between 0 and 1 (usually .1 and .25); it was set to .1.');
    opt_arg.tw = .1;
end 
tw = opt_arg.tw;


nyquist   = ffi(end);

% Specify desired and ideal frequencies and generate the filter
switch type
    case {'band','bp','bandpass'}
        dfi = [0,(1-tw)*ffi(1) ffi(1) ffi(2) (1+tw)*ffi(2) nyquist];
        ifi = [0,0,1,1,0,0];
        filt_kr.kernel = firls(filt_order,dfi./nyquist,ifi);
    case{'low','lowpass','lp'}
        dfi = [0,(1-tw)*ffi(1),ffi(1), nyquist];
        ifi = [1,1,0,0];
        filt_kr.kernel = fir1(filt_order,ffi(1)./nyquist);
    case{'high','highpass','hp'}
        dfi = [0,(1-tw)*ffi(1),ffi(1), nyquist];
        ifi = [0,0,1,1];
        filt_kr.kernel = fir1(filt_order,ffi(1)./nyquist,'high');
    otherwise
        error('No known method: %s\n',type);
end

% Amplitude of the filter
hz = linspace(0,nyquist,1+floor(filt_order/2)+mod(filt_order,2));
amp = abs(fft(filt_kr.kernel))*2;
filt_kr.amplitude = [hz(:),amp(1:length(hz))'];
% Compute diagnostics
fi_idx = dsearchn(hz',dfi');
filt_kr.sse  = sum((ifi - amp(fi_idx)./max(filt_kr.amplitude(:,2))).^2); 

% Apply filter to the data
filt_ts.real = filtfilt(filt_kr.kernel,1,data);
% Get the analytic signal
% Note that real(hilbert(filt_ts)) = filt_ts. You can use the hilber
% transform to obtain inst. estimate of power, and of fase angle.
filt_ts.analytic = hilbert(filt_ts.real);



