%% Example on Features Extraction from FACET Data
%
% This is a commented example for the analysis of FACET data from one
% participant playing 6 rounds of the Ultimatum Game. The video was
% acquired at 15 frames per second. Few strategies, that can be used to
% extract features from the raw FACET output.
%
%
% (1) Preprocessing;
% (2) Smoothing/Convolution and Features Extraction;
% (3) Morlet Wavelet features (Gabor filters);
%
% _________________________________________________________________________
%
%
% Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 04/10/14.

%% (1) Preprocessing 
%
% See note_1.m for a commented version of this section.

% Import data
clear all, close all
data = importdata('data.dat');

% False positive identification
ind_fp = fex_falsepositive(data.face_x,data.face_y,fex_zcoord(data.face_w),data.face_w,0.01);
ndata = double(data(:,19:end)); ndata(ind_fp,:) = nan;

% Interpolation
[ndata,ntsp,nfr,naninfo] = fex_interpolate(ndata,data.Time,15,Inf);
ndata_info = double(data(nfr,1:14));

% High-pass filter
ndata(:,5:end) = fex_bandpass(ndata(:,5:end),'hp',[1/5,7.5],round(4*(15/.1)),.25);


%% (2) Smoothing/Convolution and Features Extraction
%
% Once the signal has been preprocessed we need to obtain a summary value
% for the emotion timeseries during the relvant part of the trial (in this
% case "Joy"). There are several options. The simpler of which is taking
% the average signal. However, since the signal oscillates, it may be
% detrimental to average over all the frames. Additionally, in this
% particular dataset, the trial have different length, so the mean may not
% be representative. I am comparing four scores:
%
% (1) Mean over trials;
% (2) Median over trials;
% (3) Maximum value over trial;
% (4) Maximum value over trial from the smoothed timeseries.
%
% The last one imply thaking running means using a Gaussian Kernel.
% Therefore, the maximum value indicates the area of the largest Gaussian
% peak.
%
% DATASET: this dataset contains 6 trials where the participant played the
% role of Responder in the Ultimatrum Game. Column 13 of ndata_info
% contains the tag for the trials. Each trial is combined of three parts,
% column 14 contains indices for these three parts:
%
% -- Participant wait for an offer between $0-$5 (ndata_info(:,14)==1);
% -- Participant received an offer and can make a decision (ndata_info(:,14)==2);
% -- Participant receive a payoff based on his/her decision (ndata_info(:,14)==3):


close all
use_feat = 8; % 8th feature is "Joy."

% Convolution
kk = fex_kernel('Gaussian',15,'param',.5);
% kk = fex_kernel('Box',15);
% kk = fex_kernel('Gamma',30,'expand',length(ndata));
X1 = convn(ndata(:,use_feat),kk,'same');

% Get info for the size of the box
max(abs(ndata(ismember(ndata_info(:,14),1:6),use_feat)));
N = zeros(6,1);
for i = 1:6
    N(i) = sum(ndata_info(:,13) == i & ndata_info(:,14) == 2);
end

% Set up label for response
response = {'Reject','Accept'};

% Initialize image for display
close all
scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)],...
    'Name','Features Extraction (Joy)','NumberTitle','off')

k = 1; F = []; AS = [];
for i = 1:6
    subplot(6,5,k:k+2)
    hold on, grid on, box on
    % find index for begin-end of decision part of the trial
    ind1  = find(ndata_info(:,13) == i & ndata_info(:,14)==2,1,'first');
    ind2  = find(ndata_info(:,13) == i & ndata_info(:,14)==2,1,'last');
    ind3  = find(ndata_info(:,13) == i & ndata_info(:,14)==3,1,'last');
    
    % Plot original data
    plot(ntsp(ind1-30:end)-ntsp(ind1),ndata(ind1-30:end,use_feat),'--k');
    % Plot smoothed data 
    plot(ntsp(ind1-30:end)-ntsp(ind1),X1(ind1-30:end),'b');
    % Mark onsets
    plot(zeros(1,19),-1:1/9:1,'--k', 'LineWidth',2)
    plot((ntsp(ind2)-ntsp(ind1))*ones(1,19),-1:1/9:1,'--k', 'LineWidth',2)
    
    xlim([-1,9])
    ylim([-1,1])
    
    % Get Summary information (offer, decision, mean, median,gaussian-peack)    
    F = cat(1,F, [ndata_info(ind1,10),ndata_info(ind1,11),...
        mean(ndata(ind1:ind2,use_feat)),...
        median(ndata(ind1:ind2,use_feat)),...
        max(ndata(ind1:ind2,use_feat)),...
        max(X1(ind1:ind2))]);
    
    % Get data for average event:
    AS = cat(1,AS,zscore(X1(ind2-max(N):ind2)'));    

    % Add info to subplot
    title(sprintf('Trial %d',i));
    ylabel(response{F(end,2)+1});
    text(.1,-.5,sprintf('Offer: $%d',F(end,1)))
    text(ntsp(ind2)-ntsp(ind1)+.1,-.5,sprintf('Payoff: $%d',F(end,1).*F(end,2)))
    k = k+5;
end
xlabel('Time (s)')

% Plot the end of the average response
subplot(6,5,[4:5,9:10])
hold all, grid on, box on
plot(linspace(0,length(AS)/15,length(AS))-length(AS)/15,mean(AS(F(:,2)==0,:)),'--b','LineWidth',1)
plot(linspace(0,length(AS)/15,length(AS))-length(AS)/15,mean(AS(F(:,2)==1,:)),'--k','LineWidth',1)
xlim([-1.5,0])
legend({'Reject','Accept'}, 'Location', 'NorthEastOutside');
title('Average Response (last 1.5s)')
ylabel('Signal (zscore)')

% Plot summary values for score and offered amount
subplot(6,5,[14:15,19:20,])
hold all, grid on, box on
scatter(F(:,1),F(:,3),50,'k','LineWidth',2)
scatter(F(:,1),F(:,4),50,'b','LineWidth',2)
scatter(F(:,1),F(:,5),50,'g','LineWidth',2)
scatter(F(:,1),F(:,6),50,'m','LineWidth',2)
legend({'Mean','Median','Max', 'Max-G'},'Location','NorthEastOutside')
title('Offer Amount ($)')
set(gca,'XTickLabel', {'$2','$3','$4','$5'}, 'XTick',2:5)
ylabel('Features Score')
xlim([1.5,5.5])

% Plot summary values for score and decisions
subplot(6,5,[24:25,29:30])
hold all, grid on, box on,colormap gray
bar([mean(F(F(:,2)== 0,3:6)); mean(F(F(:,2)== 1,3:6))]',1)
set(gca,'XTickLabel', {'Mean','Median','Max','GMax'}, 'XTick',1:4)
legend({'Reject','Accept'}, 'Location', 'NorthEastOutside');
ylabel('Features Score')


%% (3.1) Morlet Wavelet features (Gabor filters);
% 
% An alternative to average/median from smoothed-non-smoothed time-series,
% you can focus on the analytic properties of the signal, and in
% particular you can construct a bank of Morlet (Gabor) complex wavelet and
% extract istantaneous estimates of power at different frequencies. You can
% then use these features as signal.
%
% Signal is collected at 15fps, so nyquist frequency is 7.5. We can
% construct families of wavelet with Gaussian cycles 3-7 in 2 cycle
% increments and frequency spanning 1 to 6hz (resulting in 18 features per
% face channell).
%
% "time" is the support for the kernels. It is important that:
%
% (1) time is set to the same sampling rate of the data;
% (2) time is long enough for the wavelet to taper to zero.

fps  = 15;
time = (-2.5:1/fps:2.5)';

% First construct the bank of filters, and make sure that they have the
% expected shape.
filt = fex_mwavelet('time',time,'frequencies', 1:6,'bandwidth',3:2:7);

% Display the filter you created
close all
scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/1.5 scrsz(4)/1.5],...
    'Name','Wavelet filters','NumberTitle','off')

k = 1;
for bw = 1:size(filt.bandwidth,1)
    subplot(size(filt.bandwidth,1),3,k:k+1);
    hold all, grid on, box on
    plot(filt.time,real(filt.wavelets.W(:,:,bw)),'--','LineWidth',1);
    xlabel('Time (s)')
    title(sprintf('Wavelets (%d cycles)',filt.bandwidth(bw)));
    
    subplot(size(filt.bandwidth,1),3,k+2);
    hold all, grid on, box on
    plot(filt.wavelets.Hz,real(filt.wavelets.A(:,:,bw)),'--','LineWidth',2);
    xlabel('Frequency (Hz.)')
    title('Amplitude Spectra');
    xlim([0,max(filt.wavelets.Hz)]);
    k = k + 3;
end

%% (3.2) Use variable number of cylce (Gabors as bandpass filters)
%
% A Morlet wavelet can work as a bandpass filter, howevr different
% frequencies need different number of cycles for the Gaussian envelope to
% obtain comparable (although shifted) frequency spectra.
%
% For example the spectra for 3 and 7 cycles are given below for
% frequencies 1,2,3,...,6Hz. the Amplitude spectra are very different.


filt = fex_mwavelet('time',time,'frequencies', 1:6,'bandwidth',[3,7,9]);

% Initialize image
close all
figure('Position',[1 scrsz(4)/2 scrsz(3)/1.5 scrsz(4)/1.5],...
    'Name','Effect of Number of Cycles','NumberTitle','off')

% Plot 3 and 7 cycles
subplot(3,2,1)
hold all, grid on, box on
plot(filt.wavelets.Hz,filt.wavelets.A(:,:,1),'LineWidth',2)
title('3 cycles','fontsize',16);
ylabel('Amplitude','fontsize',16)
xlim([0,max(filt.wavelets.Hz)]);
subplot(3,2,2)
hold all, grid on, box on
plot(filt.time,real(filt.wavelets.W(:,:,1)),'LineWidth',1);
ylabel('Wavelets','fontsize',16)
xlim([-2,2])

subplot(3,2,3)
hold all, grid on, box on
plot(filt.wavelets.Hz,filt.wavelets.A(:,:,2),'LineWidth',2)
title('7 cycles','fontsize',16);
ylabel('Amplitude','fontsize',16)
xlim([0,max(filt.wavelets.Hz)]);
subplot(3,2,4)
hold all, grid on, box on
plot(filt.time,real(filt.wavelets.W(:,:,2)),'LineWidth',1);
ylabel('Wavelets','fontsize',16)
xlim([-2,2])

% If you adjust the number of cycles as a function of the target Hz, you
% can construct much better bandwidth filters using the complx Morlet
% wavelet.

filt = fex_mwavelet('time',time,'frequencies', 1:6,'bandwidth',2:2:12,'constant','off');
% Plot results
subplot(3,2,5)
hold all, grid on, box on
plot(filt.wavelets.Hz,filt.wavelets.A,'LineWidth',2)
title('Variable cycles','fontsize',16);
ylabel('Amplitude','fontsize',16)
xlabel('Frequency (Hz.)','fontsize',16)
xlim([0,max(filt.wavelets.Hz)]);

subplot(3,2,6)
hold all, grid on, box on
plot(filt.time,real(filt.wavelets.W),'LineWidth',1);
xlim([-2,2])
xlabel('Time (s)','fontsize',16)
ylabel('Wavelets','fontsize',16)

set(findobj('type','axes'),'fontsize',16)


% NOTE: the first line in the image shows that 3 cycle are not sufficient
% in order to select the high frequency component. The second line shows
% that with 7 cycles the 1Hz wavelets doesn't tapper to zero, so it is
% poorly constructed. You could make the vector for 'time' longer, or you
% can have variable number of cycles per frequency. The last line shows how
% to adjust number of cycles as a function of frequencies in order to
% obtain better bandpass results fromcomplex Morlet wavelets convolution.


%% (3.3) Apply filter to the data


% Then apply the filter to the signal (I am using the variable verison).
signal = ndata(:,5:end);
filt = fex_mwavelet(filt,'data',signal);


% Note that once you are sure that the wavelets have the desired shape, you
% can run the above operation in a single step:
%
% filt = fex_mwavelet('time',-2.5:1/fps:2.5,'frequencies',1:6,'bandwidth',2:2:12,'constant','off','data',ndata(:,5:end));
%
% The matrix filt.analytic.C contains the data filtered by the wavelet. In
% particular the matrix shape is:
%
% size(signal,1)*(length(filt.frequencies)*size(filt.bandwidth,1))*size(signal,2)
%
% From filt.analytic.C, you can extract three types of signal in order to
% construct the facia features:
%
% 1) Smoothed data:                             smth = real(filt.analytic.C);
% 2) Instatntaneous est. of power:              pow = abs(filt.analytic.C).^2;
% 3) Instatntaneous est. of phase angle:        phan = angle(filt.analytic.C);
%
% In this case, power (or amplitude, abs(filt.analytic.C)*2), is probably
% the most interesting feature.
%
% Plot the results for joy. For simplicity, I am showing only the firts 30
% seconds, frequencies: 1,3 Hz.

close all
scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/1.5 scrsz(4)],...
    'Name','Wavelet Filter and Joy Channell','NumberTitle','off')

% Specify what you want to show
ufrq = [1,3];
t1 = 0;  [~,ind1] = min((ntsp-t1).^2);  % Start time to display
t2 = 30; [~,ind2] = min((ntsp-t2).^2);  % End time to display


subplot(4,3,1:3)
hold all, grid on, box on
plot(ntsp,ndata(:,8),'--k');
title('Original Signal','fontsize',16);

subplot(4,3,4:6)
hold all, grid on, box on
plot(ntsp,real(filt.analytic.C(:,ufrq)));
legend({sprintf('%d Hz.',ufrq(1)),sprintf('%d Hz.',ufrq(2))})
title('Smoothed Signal','fontsize',16);

subplot(4,3,7:9)
hold all, grid on, box on
% Plot normalized amplitude (I am using power law for normalization).
A = (abs(filt.analytic.C(:,ufrq)).^2);
plot(ntsp,A.*repmat(ufrq,[size(A,1),1]));
title('Inst. Power Spectrum (power law norm.)','fontsize',16);
subplot(4,3,10:12)
hold all, grid on, box on
plot(ntsp,angle(filt.analytic.C(:,ufrq)));
title('Inst. Phase Angle','fontsize',16);

set(findobj('type','axes'),'fontsize',16, 'xlim',[t1,t2])


% -------------------------------------------------------------------------
%
% Few notes on parameters specification from M.X.Cohen, Analyzing Neural
% Time Series Data, MIT Press, 2014:
%
% The epoch length should contain more than 1 cycle (say 3) for the lower
% frequency. So for 1Hz signal you neeed 3 seconds epochs. Which is an
% issue here. The minimum length is 1 cycle -- so 1 s. would be ok for 1Hz
% signal. But the signal to noise ration will be low.
%
% The Nyquist frequency is the upper bound for frequency. However, having
% several point per cycle increase signal to noise ratio (e.g. Mike's
% suggests half the Nysquit frequency).
%
% Cycles of Gaussian envelope sets a trade of between time and frequency
% precision. 3-4 cycles will highlight transient activity, while 6-7 cycle
% are better suited to identify prolonged activtity in a specific frequency
% band.




%% (temp) Features Generation from Gabor Filter Amplitude


close all
use_feat = 8; % Joy (4Th feature is "Joy" in the Convolved matrix).


% Get amplitude from Joy
X1 = ((abs(filt.analytic.C(:,2,4))*2));
X1 = X1./max(abs(X1(ismember(ndata_info(:,13),1:6) & ismember(ndata_info(:,14),2))));

% Get info for the size of the box
max(abs(ndata(ismember(ndata_info(:,14),1:6),use_feat)));
N = zeros(6,1);
for i = 1:6
    N(i) = sum(ndata_info(:,13) == i & ndata_info(:,14) == 2);
end

% Set up label for response
response = {'Reject','Accept'};

% Initialize image for display
close all
scrsz = get(0,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)],...
    'Name','Features Extraction (Joy)','NumberTitle','off')


k = 1; F = []; AS = [];
for i = 1:6
    subplot(6,5,k:k+2)
    hold on, grid on, box on
    % find index for begin-end of decision part of the trial
    ind1  = find(ndata_info(:,13) == i & ndata_info(:,14)==2,1,'first');
    ind2  = find(ndata_info(:,13) == i & ndata_info(:,14)==2,1,'last');
    ind3  = find(ndata_info(:,13) == i & ndata_info(:,14)==3,1,'last');
    
    % Plot original data
    plot(ntsp(ind1-30:end)-ntsp(ind1),ndata(ind1-30:end,use_feat),'--k');
    % Plot smoothed data 
    plot(ntsp(ind1-30:end)-ntsp(ind1),X1(ind1-30:end,1),'b');
    % Mark onsets
    plot(zeros(1,19),-1:1/9:1,'--k', 'LineWidth',2)
    plot((ntsp(ind2)-ntsp(ind1))*ones(1,19),-1:1/9:1,'--k', 'LineWidth',2)
    
    xlim([-1,9])
    ylim([-1,1])
    
    
    % Get Summary information (offer, decision, mean, median,gaussian-peack)    
    F = cat(1,F, [ndata_info(ind1,10),ndata_info(ind1,11),...
        mean(ndata(ind1:ind2,use_feat)),...
        mean(X1(ind1:ind2)),...
        median(X1(ind1:ind2)),...
        max(X1(ind1:ind2))]);
   
    
    % Get data for average event:
    AS = cat(1,AS,(X1(ind2-max(N):ind2)'));
%     AS = cat(1,AS,zscore(ndata(ind2-max(N):ind2,use_feat)'));    
    

    % Add info to subplot
    title(sprintf('Trial %d',i));
    ylabel(response{F(end,2)+1});
    text(.1,-.5,sprintf('Offer: $%d',F(end,1)))
    text(ntsp(ind2)-ntsp(ind1)+.1,-.5,sprintf('Payoff: $%d',F(end,1).*F(end,2)))

    k = k+5;
end
xlabel('Time (s)')

% Plot the end of the average response
subplot(6,5,[4:5,9:10])
hold all, grid on, box on
plot(linspace(0,length(AS)/15,length(AS))-length(AS)/15,mean(AS(F(:,2)==0,:)),'--b','LineWidth',1)
plot(linspace(0,length(AS)/15,length(AS))-length(AS)/15,mean(AS(F(:,2)==1,:)),'--k','LineWidth',1)
xlim([-1.5,0])
legend({'Reject','Accept'}, 'Location', 'NorthEastOutside');
title('Average Response (last 1.5s)')
ylabel('Signal (zscore)')


% Plot summary values for score and offered amount
subplot(6,5,[14:15,19:20])
hold all, grid on, box on
scatter(F(:,1),F(:,3),50,'k','LineWidth',2)
scatter(F(:,1),F(:,4),50,'b','LineWidth',2)
scatter(F(:,1),F(:,5),50,'g','LineWidth',2)
scatter(F(:,1),F(:,6),50,'m','LineWidth',2)
legend({'Mean','Mean-W','Median-W', 'Max-W'},'Location','NorthEastOutside')
title('Offer Amount ($)')
set(gca,'XTickLabel', {'$2','$3','$4','$5'}, 'XTick',2:5)
ylabel('Features Score')
xlim([1.5,5.5])


% Plot summary values for score and decisions
subplot(6,5,[24:25,29:30])
hold all, grid on, box on,colormap gray
bar([mean(F(F(:,2)== 0,3:6)); mean(F(F(:,2)== 1,3:6))]',1)
set(gca,'XTickLabel',{'Mean','Mean-W','Median-W', 'Max-W'}, 'XTick',1:4)
legend({'Reject','Accept'}, 'Location', 'NorthEastOutside');
ylabel('Features Score')




