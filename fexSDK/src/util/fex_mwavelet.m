function filt = fex_mwavelet(varargin)
%
%
% FEX_MWAVELET generates a set of complex Morelet wavelets and uses them to
% convolve data.
%
% SYNTAX:
%
% filt = FEX_MWAVELET('ArgName1',argVal1,...)
% filt = FEX_MWAVELET('ArgName1',ArgVal1,...,'data',data)
% filt = FEX_MWAVELET(filt,'data',data)
%
% FEX_MWAVELET constructs a bank of complex Morelet wavelets and it applies
% them to a dataset, if a dataset is provided. You can use the function in
% three ways:
%
% 1) To create Morelet wavelets and filter the data, in which case you
%    need to specify parameters for the Morelet wavelets, and provide the
%    data.
% 2) To crete the Morelet wavelets only -- in this case you don't need to
%    provide data, but you still need to specify the wavelets properties.
% 3) To apply a the Morelet wavelet to a dataset when you have already
%    constructed the wavelet. In this case the first argument needs to be
%    the structure filt, and the second argument is: 'data',data, as in:
%
%    >> filt = fex_mwavelet(filt,'data',data)
%
% ARGUMENTS ('ArgName1',argVal1)
%   
% time - a vector with the support for the wavelets. It is important that:
%       time is set to the same sampling rate of the data; and time is long
%       enough for the wavelet to taper to zero.
%
% frequencies - a vector with the frequencies in Hz that you want to be
%       explored.
%
% bandwidth - a vector with the number of cycles for the Gaussian envelope.
%
% constant - a string, set to 'off' or 'on' (default). When it is set to
%       'on', FEX_MWAVELET constructs a wavelet for each combination of
%       frequency and bandwidth. When CONSTANT is set to 'off.' The vectors
%       'bandwidth' and 'frequency' need to have the same length, and the
%       function constructs a wavelet for each pair {bandwidth(i),
%       frequencies(i)}. Note that if the length of 'bandwith' is different
%       from the length of 'frequency', bandwidth is set to
%
%       >> linspace(min(bandwidth),max(bandwidth),length(frequencies)).
%
% hann - [NOT IMPLEMENTED] a string, set to either 'off' (default) or 'on'.
%       If it is set to on, the data are tepered.
%
% data - a N*K matrix, where N is time and K is the number of features
%       collected (i.e. each column of data is a separate variable).
%
% 
% OUTPUT:
%
% The output FILT is a structure which contains the arguments you specified
% to generate the filter, namely time, frequency, bandwidth, hann and
% constant. If you also enter the data, FILT includes a field with the
% data.
%
% Additionally, FILT contains a field labeled 'wavelets'. Wavelets is a
% structure which contains:
%   
% W  -  Matrix with the wavelets. It's dimension is time*frequency*cycles.
% A  -  Matrix with wavelets amplitude spectrum; it's dimension is
%       Hz*frequency*cycles.
% Hz -  A vector with the Hz corrispinding to each row of A.
%
% When the argument 'data' is specified, the FEX_MWAVELET convolves the
% data with the wavelets, and the output FILT will also contain a field
% labeled 'analytics.' ANALYTICS is a structure with fields:
%
% C - a N*F*K matrix with the data filtered with the wavelets. N is the
%       length of the data timeseries, F is the number of features
%       generated for each variable. If CONSTANT is set to 'on', F equals
%       length(bandwidth) times length(frequencies); otherwise, when
%       constant is set to 'off', F is equal to length(frequencies). K is
%       the number of variables (the number of columns in data).
% hdr - the header for the column in filt.analytics.C.
%
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Apr-2014.


% Handle optional arguments when the function is used to generate filters
if ~isstruct(varargin{1})
    % This is when you call the function for the first time to generate the
    % filter.
    filt = {'time',[],'bandwidth',[],'frequencies',[],'wavelets',...
        struct('W',[],'A',[],'Hz',[]),'data',[], 'hann','off','constant','on'};
    for i = 1:2:length(varargin)
        idx = strcmp(filt,varargin{i});
        idx = find(idx == 1);
        if idx
            filt{idx+1} = varargin{i+1};
        end
    end
    filt = struct(filt{:});
else
    % You generated the filter kernels already, and want to compute the
    % convolution.The first argument in is the filt structure.
    filt = varargin{1}; 
    % the last argument needs to be the data matrix. everything in between
    % is ignored.
    filt.data = varargin{end};
end

% Handle wrong number of arguments
if isempty(filt.time) || isempty(filt.frequencies) || isempty(filt.bandwidth)
    error('myApp:argChk','You need to specify at least time, frequencies and bandwidth.');
end


% handle the 'constant' argument: filt.bandwidth first dimension determine
% the size in the third dimension of the wavelets matrix W. the second
% dimension is always of the same size of the frequency vector (this is
% handled automatically).
if strcmp(filt.constant,'off')
    if length(filt.bandwidth) ~= length(filt.frequencies)
        warning('With constant set to ''off'', frequency and bandwidth should have the same number of elements.');
        % Fix, using minimum number of cycle, and maximum number of cycles
        % as boundaries
        filt.bandwidth = linspace(min(filt.bandwidth),max(filt.bandwidth),length(filt.frequencies));
    else
        % make sure that size(filt.bandwidth ,1) = 1.
        filt.bandwidth = filt.bandwidth(:)';
    end
else
    filt.bandwidth = repmat(filt.bandwidth(:),[1,length(filt.frequencies)]);
end

% Gather some information for analytics on the filter matrix
sampling_rate = 1/mode(diff(filt.time));
nyquist       = sampling_rate/2;
hz_kernel     = linspace(0,nyquist,1+floor(length(filt.time)/2)+mod(length(filt.time),2));

sigma    = @(f,n) n/(2*pi*f); % Standard deviation Gaussian envelope
gaussenv = @(t,f,n) (1/sqrt(sigma(f,n)*sqrt(pi)))*exp(-t.^2/(2*sigma(f,n)^2)); % Gaussian envelope
cmw_func = @(t,f,n) gaussenv(t,f,n).*exp(1i*2*pi*f*t); % Compelex Morlet filter

% Compile the wavelet matrix when needed
if isempty(filt.wavelets.W)
    W = zeros(length(filt.time),length(filt.frequencies),size(filt.bandwidth,1));
    A = zeros(length(hz_kernel),length(filt.frequencies),size(filt.bandwidth,1));
    for bw = 1:size(W,3)
        for fi = 1:size(W,2)
            W(:,fi,bw) = cmw_func(filt.time(:),filt.frequencies(fi),filt.bandwidth(bw,fi));
            ampl = abs(fft(W(:,fi,bw)))*2;
            A(:,fi,bw) = ampl(1:length(hz_kernel));
        end
    end   
    filt.wavelets.W  = W;
    filt.wavelets.A  = A;
    filt.wavelets.Hz = hz_kernel(:);  
end

% Filter the data (get smooth ts, amplitude, phase angle)
if ~isempty(filt.data)
    size_conv = size(filt.data,1) + length(filt.time) - 1;
    Y = []; header = {};
    % Furier transform for the data
    signal = fft(filt.data,size_conv);
    for bw = 1:size(filt.wavelets.W,3)
        for fi = 1:size(filt.wavelets.W,2)
            % Convolution
            x = ifft(signal.*repmat(fft(filt.wavelets.W(:,fi,bw),size_conv),[1,size(signal,2)]));
            % Adjust the size of the convolution from full to same size.
            ind = floor((length(filt.time)-1)/2) + mod(length(filt.time),2);
            Y = cat(2,Y,x(ind:ind+(size(filt.data,1)-1),:));
            if length(header) < length(filt.bandwidth)*length(filt.frequencies)
                % Compile an header for the convolution matrix
                header = cat(1,header,sprintf('bw_%.1f_fr_%.1f',filt.bandwidth(bw,fi),filt.frequencies(fi)));
            end
        end
    end    
    % Reshape Y so that the convolution matrix shape is
    % datapoints*(frequency*bandwidth)*features
    filt.analytic.hdr = header;
    filt.analytic.C   = [];
    for nft = 1:size(filt.data,2)
        filt.analytic.C  = cat(3,filt.analytic.C,Y(:,nft:size(filt.data,2):end));
    end
end


