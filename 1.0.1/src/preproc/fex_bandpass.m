function [filt_ts,filt_kr,sse] = fex_bandpass(data,type,ffi,filt_order,tw)
%
%
% This is a simple wrapper for firls and filtfilt, that apply either
% bandpass, low pass or high pass filtering to the data. For more complex
% filter, you should use filrs or fir1 directly.
%
% Input:
%
% (1) data: a N*K matrix with N datapoints, and K variables.
%
% (2) type: can be bandpass (or band, or bp) to implement a bandpass filter;
%     lowpass (lp,low) to implement a low pass filter; or it can be
%     highpass (hp,high) to implement a high pass filter.
%
% (3) ffi: frequency information. This is either a 3 components or a 2
%     components vector, depending on filter type:
%
%       - for bandpass: [low_frq,high_frq,nyquist];
%       - for highpass: [low_freq, nyquist]
%       - for lowpass:  [high_freq,nyquist]
%
%     Note that the last component is always the nyquist frequency
%     (sampling_rate/2).
%
% (4) filt_order: the order of the filter. In general, you want large
%     order. There is a lower and upper bound. The filter must be long
%     enough to contain one cycle for the lower frequency, therefore it
%     must be at least round(sampling_rate/lower_frequency). Also, the
%     filter must be at most long 1/3 of the data. So:
%
%     round(sampling_rate/lower_frequency) <= order <= round(N-1)/3).
%
%     In generat, 3-5 cycles is a good value.
%
% (5) tw is a transition window expressed in percentage. It prevents
%     artifacts, and should be between .1 and .25.
%
% Output:
%
%   filt_ts: a N*K matrix with the filtered data.
%   filt_kr: a structure with kernel information
%       filt_kr.kernel contains the kernel itselfe;
%       filt_kr.amplitude is a matrix, the first column indicates Hz, and
%       the second column contains amplitude of the signal at those Hz.
%   sse: sum of square between the filter and the ideal filter. This should
%       be use as diagnostic to assess the goodnes of fit of the filter.
%       Values must not exceed 1.
%
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
% Version: 03/15/14.



nyquist   = ffi(end);
% Check transition window
if nargin <= 4
    tw = 0;
else
    if tw < .1 || tw > .25
        warning('Transition window should be between .1 and .25.');
    end
end

% specify desired and ideal frequencies
switch type
    case {'band','bp','bandpass'}
        dfi = [0,(1-tw)*ffi(1) ffi(1) ffi(2) (1+tw)*ffi(2) nyquist];
        ifi = [0,0,1,1,0,0];
    case{'low','lowpass','lp'}
        dfi = [0,(1-tw)*ffi(1),ffi(1), nyquist];
        ifi = [1,1,0,0];
    case{'high','highpass','hp'}
        dfi = [0,(1-tw)*ffi(1),ffi(1), nyquist];
        ifi = [0,0,1,1];
end

% Compute the filter and apply to the data
filt_kr.kernel = firls(filt_order,dfi./nyquist,ifi);
% filt_kr.kernel = fir1(filt_order,ffi(1:2)./ffi(end));
filt_ts = filtfilt(filt_kr.kernel,1,data);

% Store information about the amplitude of the filter
hz = linspace(0,nyquist,1+floor(filt_order/2)+mod(filt_order,2));
amp = abs(fft(filt_kr.kernel))*2;
filt_kr.amplitude = [hz(:),amp(1:length(hz))'];

% Compute diagnostic for the filter
fi_idx = dsearchn(hz',dfi');
sse  = sum((ifi - amp(fi_idx)./max(filt_kr.amplitude(:,2))).^2); 


