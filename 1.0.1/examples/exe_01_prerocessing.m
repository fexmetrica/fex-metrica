%% Example on Preprocessing of FACET Data
%
%
% This is a commented example for the analysis of FACET data from one
% participant playing 6 rounds of the Ultimatum Game. The video was
% acquired at 15 frames per second. I am illustrating preprocesing
% pipeline. This code include:
%
% (1) Data description & import data;
% (2) Identify potential false positive;
% (3) Interpolation to fix frame rate;
% (4) High pass filter;
% (5) Temporal smoothing;
% (6) Normalization;
% (7) Notes on preprocessing.
%
% The script output is an image which shows the effect of each step in
% the preprocessing pipeline.
%
% _________________________________________________________________________
%
%
% Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 03/17/14.


%% (1) Data description


clear all, close all

% Data is a dataset object in Matlab. The dataset contains several
% variables -- you can looke at names and descriptive stats in "info." I
% added some details as I use them. Besides information on the experimental
% design, data contains "Time," that is timestamps for each frame;
% coordinates for the face box (data.face_x,...), frame-wise score for
% emotions, and for AUs.

data = importdata('data.dat');
info = summary(data);

% Make an image to display the various steps for prerpocessing -- I am
% showing the results for "Joy." Note that Joy is the 26th column in the
% original dataset, but since I am catting the matrix for preprocessing it
% becomes column: 8.
% Also, for ease I am plotting only the first 10 seconds.

scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)],...
    'Name','Preprocessing Example (Joy)','NumberTitle','off')
% Plot the original signal
subplot(4,4,1:3), hold on, box on
plot(data.Time,data.joy-nanmean(data.joy),'k','LineWidth',1)
xlabel('time (s)');
title('Original Joy Signal');
xlim([0,40])


%% (2) Identification of potential false positives


% Exclude false positive using PCA (Mahalanobis distance). This is a simple
% procedure that uses position of the lower left corner of the face box,
% and the euclidean distance between faces in adjacence frames in order to
% identify false positives. It returns indices for identified false
% positive and Mahalanobis distance for those points. Note that if you add
% as last argument [data.rows(1),data.cols(1)], fex_falsepositive will also
% output an image, which summarizes the results.

ind_fp = fex_falsepositive(data.face_x,data.face_y,fex_zcoord(data.face_w),data.face_w,0.01);

% Add to the plot the potential false positive
scatter(data.Time(ind_fp),data.joy(ind_fp)-nanmean(data.joy),10,'b','filled')
legend({'data','false positive'},'Location','NorthWest')

% Correct for false positive
ndata = double(data(:,19:end)); ndata(ind_fp,:) = nan;

% NOTE: It does not apply to this example, however if you have a timeseries with
% nan at the end, exrtapolation will likely lead to disastrous results. You
% should get rid of the nans at the end. Before running "fex_interpolate,"
% you can do something like.


%% (3) Interpolation over Time


% Interpolate and recover nans. I have timestamps for when each frame was
% acquired (data.Time), however, as with most webcam, the frame rate is not
% constant. In this case it oscillates around 15fps. I am using
% interpolation to obtain a fixed framerate. I re-sample the
% signal at 15. Additionally, I am recovering missing observations
% (namely frames for which I don't have face data).

[ndata,ntsp,nfr,nan_info] = fex_interpolate(ndata,data.Time,15,Inf);
ndata_info = double(data(nfr,1:14));

% In this case, setting the last argument to Inf means that I will recover
% all the observation. In general, it is better to be more restrictive. For
% example, you could recover null observation only if there are at most 15
% consecutive frames (i.e. 1s) of missing observation. To do so, replace
% Inf with 15.

subplot(4,4,5:7), hold on, box on
plot(ntsp,ndata(:,8)-nanmean(ndata(:,8)),'k','LineWidth',1);
xlabel('time (s)');
title('Interpolated Signal');
xlim([0,40])

% Decompose signal to show frequencies
f  = fft(ndata(:,8)-nanmean(ndata(:,8)))./length(ndata);
hz = linspace(0,15/2,1+floor(length(f)/2)+mod(length(f),2));
% power low normalization
f = abs(f(1:length(hz)))'*2.*hz;
f = f./max(f);
subplot(4,4,8),hold on, box on
bar(hz,f,'k')
xlim([0,15/2])
title('Signal Amplitude Spectrum (PL norm.)')
xlabel('Frequency (Hz.)')
ylabel('Amplitude*Frequency')

%% (4) High-pass filter

% This is a judgment call, and it depends on which time
% scale you are interested in. In this dataset, there are 6 short events,
% but from the timeseries of activation, you can see low frequency
% components. I get rid of them (e.g. periods longer than 5 seconds). If
% you type "help fex_bandpass", there are some suggestions on setting the
% parameters.

min_win = round(4*(15/.1));
[ndata(:,5:end),filt_kr,sse] = fex_bandpass(ndata(:,5:end),'hp',[1/5,7.5],min_win,.25);

subplot(4,4,9:11), hold on, box on
plot(ntsp,ndata(:,8)-nanmean(ndata(:,8)),'k','LineWidth',1);
xlabel('time (s)');
title('High-pass filtered Signal');
xlim([0,40])

% Plot frequency spectrum for the filter
subplot(4,4,12),hold on, box on
plot(filt_kr.amplitude(:,1),filt_kr.amplitude(:,2)./2,'k','LineWidth',2);
xlim([0,15/2])
title('HighPass filter')
xlabel('Frequency (Hz.)')
ylabel('Amplitude (norm.)')

% Note that you should check the filter before you apply it to all the
% dataset. filter_kr.amplitude is a vector with hz and amplitude for the
% filter. You can plot it and make sure that it looks the way you expect.
% Also the output sse is the sum of square deviation from the ideal filter
% shape. That should not be larger than 1 (it should be much smaller!).
%
% plot(filt_kr.amplitude(:,1),filt_kr.amplitude(:,2)./2,'LineWidth',2);
% xlabel('Frequency (Hz)'); ylabel('Amplitude (norm.)');
% title(sprintf('Filter Amplitude (SSE = %.4f)',sse));


%% (5) Smoothing the timeseries

% If you analyze means, it may be a good idea to smooth the
% timeseries in order to get rid of the noise. To do so, construct a kernel
% ( in order to be a running mean, the kernel needs to sum to 1), and then
% convolve the data with that kernel. fex_kernel helps you set up some
% shapes. In the example below, I am using Gaussian kernel, that covers 30
% timepoints (i.e. frames) and with one parameter for the distpersion set
% to .5 (so in fact about 1 sec. is used).

kk = fex_kernel('Gaussian',30,'param',.5);

% An alternative may be to use a box instead:
%
% kk = fex_kernel('Box',15);
% kk = fex_kernel('Gamma',30);
%
%
% Note that most of the function implemented in fex_kernel should be
% reparametreize. A worning is outputed when you use the shapes that are
% not properly parameterized.

ndata(:,5:end) = convn(ndata(:,5:end),kk,'same');

subplot(4,4,13:15), hold all, box on
plot(ntsp,ndata(:,8)-nanmean(ndata(:,8)),'k','LineWidth',1);
xlabel('time (s)');
title('Smoothed Signal');
xlim([0,40])

subplot(4,4,16), hold all, box on
plot((1:length(kk))-(1+length(kk))/2,kk,'k')
title('Smoothing Kernel')
xlabel('frame number')

%% (6) Normalization


% I normalize each timeseries independently. There are various way, but
% since I will do some filtering next, I simply center each variable. I
% included a function called fex_normalize that implements few
% alternatives, and it is described in a different example file.

ndata(:,23:end) = ndata(:,23:end) - repmat(nanmean(ndata(:,23:end)),[size(ndata,1),1]);


%% (7) Further Notes on Preprocessing

% -------------------------------------------------------------------------

% NOTE: There is another step -- which also may or may not be beneficial,
% dependently on the analysis you are running  -- which is motion
% correction. Basically you regress out of each variable the values for
% motion estimates outputed by cert -- roll, pitch, and yaw, x, y and z
% translation. In this dataset, I don't have values for roll pitch and yaw,
% and I am skipping this step. In general, make sure that you have enough
% signal to proceed once you run this regression.

