function h = fexw_filtplot(kr,sr)
%
% FEXW_FILTPLOT displays.
%
% SYNTAX:
% h = FEXW_FILTPLOT(kr,sr)
%
% Generates an image with a temporal filter prepared for data collected at
% sampling rate sr.
%
% KR is a structure with kernel information compute with FEX_BANDPASS.
% Fields include:
%  - filt_kr.kernel: the kernel itselfe;
%  - filt_kr.amplitude is a matrix, the first column indicates Hz, and
%    the second column contains amplitude of the signal at those Hz.
%  - filt_kr.sse: sum of square between the filter and the ideal
%     filter.
%
% SR: scalar indicating data sampling rate;
%
% See also FEX_BANDPASS.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 14-Dec-2014.

if nargin < 1
    error('Not enough input arguments.');
elseif nargin < 2
    sr = 15;
end

% Initialize image
scrsz = get(0,'ScreenSize');
posit = [1 scrsz(4) scrsz(3)/1.5 scrsz(4)/1.5];
h = figure('Position',posit,'Name','Temporal Filter','NumberTitle','off'); 

% Plot Filter Shape
subplot(2,2,1:2),hold on, box on
x = (1:length(kr.kernel))./inv(sr); x = (x-mean(x))';
plot(x,kr.kernel,'--b','LineWidth',2);
xlabel('time','fontsize',14,'fontname','Helvetica','Color',[1,1,1]);
title('Filter Shape','fontsize',20,'fontname','Helvetica','Color',[1,1,1]);
xlim([min(x),max(x)]);

% Plot Filter Spectrum
subplot(2,2,3),hold on, box on
plot(kr.amplitude(:,1),kr.amplitude(:,2)./max(kr.amplitude(:,2)),'m','LineWidth',2);
xlim([0,ceil(sr/2)]);
ylim([0,1.2]);
title('Filter Spectrum','fontsize',20,'fontname','Helvetica','Color',[1,1,1]);
xlabel('Frequency','fontsize',16,'fontname','Helvetica','Color',[1,1,1]);
ylabel('Amplitude','fontsize',16,'fontname','Helvetica','Color',[1,1,1]);  

% Set some image properties
set(get(h,'Children'),'fontsize',14,'fontname','Helvetica','LineWidth',2,'Color',[0,0,0]);
set(get(h,'Children'),'XColor',[1,1,1],'YColor',[1,1,1],'LineWidth',3)
set(h,'ToolBar','none','MenuBar','none','Color',[0,0,0]);



