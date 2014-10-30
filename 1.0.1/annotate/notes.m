%% Notes on streaming a video

close all
videoFReader = vision.VideoFileReader('test.mov','AudioOutputPort',true);
videoPlayer = vision.VideoPlayer();
flag = true;
while flag
    try 
        [videoFrame,Audio] = step(videoFReader);
        step(videoPlayer, videoFrame);
    catch
        flag = false;
    end
end
release(videoPlayer);
release(videoFReader);

%% Test the example

addpath(genpath('~/Documents/code/GitHub/fex-metrica/1.0.1/'))
fexObj = importdata('/Users/filippo/Documents/code/GitHub/fex-metrica/1.0.1/examples/data/E002/fexObj.mat');
note = fexnotes(fexObj);

%% Some notes on frame reader


vr = VideoReader(fexObj.video);
tic;
F = read(vr,[1,100]);
t = toc;


%% Emotion Display function
%
% Notes on basic visualization (set up for basic A4 Printing): 
%
% Get a video, construct 
%
% 1. Non linear regularization;
% 2. Timestamps for X axis;
% 3. Lines and areas;


addpath(genpath('~/Documents/code/GitHub/fex-metrica/1.0.1/'))
fexObj = importdata('/Users/filippo/Documents/code/GitHub/fex-metrica/1.0.1/examples/data/E002/fexObj.mat');

close all
scrsz = get(0,'ScreenSize');
h = figure('Position',[1 scrsz(4) scrsz(3) scrsz(4)],...
    'Name','Emotions','NumberTitle','off','Visible','on');

% time = linspace(0,fexObj.videoInfo(2),fexObj.videoInfo(3));


subplot(8,1,1:2), hold on
% bar(time,fexObj.functional.joy,'r','LineWidth',2,'EdgeColor','r');
time = fexObj.time.TimeStamps-fexObj.time.TimeStamps(1);
time2 = (0:round(time(end)))';
y = interp1(time,fexObj.functional.negative,time2);

% bar(time2,y,'r','LineWidth',2,'EdgeColor','r')
% area(time2,y)
area(time,fexObj.functional.negative,'FaceColor','r','LineWidth',2,'EdgeColor','r')

alpha(.4)
ylim([-3,3])
xlim([time(1),time(end)])
set(gca,'box','on','LineWidth',2,'fontsize',18,'YTickLabel','')
ylabel('Negative','fontsize', 12)
set(gca,'XTickLabel','');
title('Emotions Profile','fontsize',20)

names = {'sadness','joy','anger','disgust','fear','surprise'};
col = {'b','c','m','g','y','k'};
k = 1; 
for i = 3:8
    subplot(8,1,i); hold on
    
    area(time,fexObj.functional.(names{k}),'FaceColor',col{k},'LineWidth',2,'EdgeColor',col{k})
    alpha(.4)
    
    ylim([-3,3])
    xlim([time(1),time(end)])
    set(gca,'box','on','LineWidth',2,'fontsize',18,'YTickLabel','')
    ylabel(names{k},'fontsize', 12)
    xlabel('Time','fontsize', 18)

    if i <= 7
       set(gca,'XTickLabel','');
       xlabel('','fontsize', 18)
    else
        t  = get(gca,'XTick');
        ts = fex_strtime(t);
        ts{1} = '';
        for j = 2:length(ts);
            i1 = find(ts{j} == ':',1,'first');
            i2 =  find(ts{j} == '.');
            ts{j} = ts{j}(i1+1:i2-1);
        end
        set(gca,'XTickLabel',ts,'fontsize',12);
    end

    k = k + 1;
end

print(h,'-dpdf','-r450','test_file.pdf')







