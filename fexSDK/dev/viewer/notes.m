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
h = figure('Position',[0 scrsz(4) scrsz(3) scrsz(4)],...
    'Name','Emotions','NumberTitle','off','Visible','on');
% h = figure('Name','Emotions','NumberTitle','off','Visible','on');
% set(h, 'Units','centimeters')
% height = 29;
% width = 21;
% set(h, 'Position',[0 scrsz(4), scrsz(3) scrsz(4)],...
%        'PaperSize',[scrsz(3) scrsz(4)]);


% set(gca,'units','centimeters')
% pos = get(gca,'Position');
% ti = get(gca,'TightInset');

% time = linspace(0,fexObj.videoInfo(2),fexObj.videoInfo(3));


subplot(10,1,1:2), hold on
% bar(time,fexObj.functional.joy,'r','LineWidth',2,'EdgeColor','r');
time  = fexObj.time.TimeStamps-fexObj.time.TimeStamps(1);
time2 = (0:round(time(end)))';
y = interp1(time,fexObj.functional.negative,time2);

% bar(time2,y,'r','LineWidth',2,'EdgeColor','r')
% area(time2,y)

[Y,ind] = max([fexObj.functional.negative,fexObj.functional.positive],[],2);
Y(ind == 1) = -1*Y(ind == 1);
kk  = normpdf(linspace(-2,2,10),0,1)'; kk = kk./sum(kk);
Y = conv(Y,kk,'same');


Y = repmat(Y,[1,2]);
Y(Y(:,1) > 0,1) = 0;
Y(Y(:,2) <=0,2) = 0;

area(time,Y(:,1),'FaceColor','r','LineWidth',2,'EdgeColor','r')
area(time,Y(:,2),'FaceColor','b','LineWidth',2,'EdgeColor','b')

alpha(.4)
ylim([min(Y(:,1)),max(Y(:,2))])
xlim([time(1),time(end)])
set(gca,'box','on','LineWidth',2,'fontsize',18,'YTickLabel','')
% ylabel('Negative','fontsize', 12)
set(gca,'YTick',[-2,2],'YTickLabel',{'Neg.','Pos.'},'fontsize',12)
set(gca,'XTickLabel','');
title('Emotions Profile','fontsize',20)

names = {'sadness','joy','anger','disgust','fear','surprise','confusion','frustration'};
col = {'c','m','g','y','k','b','c','m'};
% col = {'r','b','r','r','r','b'};

YY = [];
for k = 1:8
    y = fexObj.functional.(names{k});
    y(y < -1) = -1;
    y = y + 1;
    y = conv(y+1,kk,'same');
    YY = cat(2,YY,y);
end


y_b = max(reshape(YY,1,numel(YY)));
k = 1; 
for i = 3:10
    subplot(10,1,i); hold on
    
    area(time,YY(:,k),'FaceColor',col{k},'LineWidth',2,'EdgeColor',col{k})
    alpha(.4)
    plot(time,ones(length(time),1)+.1,'--k');
    
    ylim([0,y_b]);
    xlim([time(1),time(end)])
    set(gca,'box','on','LineWidth',2,'fontsize',18,'YTickLabel','')
    ylabel(names{k},'fontsize', 12)
    xlabel('Time','fontsize', 18)

    if i <= 9
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
% 
% 
% set(h, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
% set(h, 'PaperPositionMode', 'manual');
% set(h, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);


print(h,'-dpdf','-r450','test_file.pdf')



%% Notes on figure

clear all, close all
addpath(genpath('~/Documents/code/GitHub/fex-metrica/1.0.1/'))
fexObj = importdata('/Users/filippo/Documents/code/GitHub/fex-metrica/1.0.1/examples/data/E002/fexObj.mat');


feat_names = {'sadness','joy','anger','disgust', 'fear', 'surprise','confusion','frustration'};
data = fexObj.functional;
args = struct('fps',15,'smoothing',15,'rectification',-1,'features',{feat_names});



% Set subplot information
plot_cols = 2;
if length(args.features)< 6
    plot_row = 2 + length(args.features);
    ind_end  = 5 + (length(args.features)-1)*2;
    plot_ind = [5:2:ind_end+mod(ind_end,2);...
                6:2:ind_end+mod(ind_end,2)];
else
    plot_row = 2 + ceil(length(args.features)/2);
    plot_ind = 5:5+length(args.features)-1;
end
    

% Initialize image
scrsz = get(0,'ScreenSize');
h = figure('Position',[0 scrsz(4) scrsz(3) scrsz(4)],...
    'Name','Emotions','NumberTitle','off','Visible','on');

col = repmat('crgykbm',[1,3]);
time  = fexObj.time.TimeStamps-fexObj.time.TimeStamps(1);

% Set up kernel for smoothing
if args.smoothing > 1
    kk  = normpdf(linspace(-2,2,args.smoothing),0,1)';
    kk = kk./sum(kk);
else
    kk = 1;
end

% Get data for the positive/negative panel
[Y,ind] = max([data.negative,data.positive],[],2);
Y(ind == 1) = -1*Y(ind == 1);
Y = conv(Y,kk,'same');


% y = double(data(:,ismember(data.Properties.VarNames,args.features)));
% y(y < args.rectification) = args.rectification;
% Y = cat(2,Y,convn(y+1,kk,'same'));
% Get data for the other features
for k = 1:length(args.features)
    y = data.(args.features{k});
    y(y < args.rectification) = args.rectification;
    y = conv(y+1,kk,'same');
    Y = cat(2,Y,y);
end
yplotmax = max(reshape(Y(:,2:end),1,numel(Y(:,2:end))));

% Draw Combined Negative/Positive Plot
subplot(plot_row,plot_cols,1:4),hold on
yy = repmat(Y(:,1),[1,2]);
yy(yy(:,1) > 0,1) = 0; yy(yy(:,2) <=0,2) = 0;
area(time,yy(:,1),'FaceColor','m','LineWidth',2,'EdgeColor','m')
area(time,yy(:,2),'FaceColor','b','LineWidth',2,'EdgeColor','b')
alpha(.4)
ylim([min(Y(:,1)),max(Y(:,1))])
xlim([time(1),time(end)])
x   = get(gca,'XTick'); str = fex_strtime(x,'short');
set(gca,'XTick',x(2:end-1),'XTickLabel',str(2:end-1))
title('Emotions Profile','fontsize',20)
set(gca,'box','on','LineWidth',2,'fontsize',18)
set(gca,'YTick',[-2,2],'YTickLabel',{'Neg.','Pos.'},'fontsize',12)    

for k = 2:size(Y,2)
    subplot(plot_row,plot_cols,plot_ind(:,k-1)'),hold on    
    area(time,Y(:,k),'FaceColor',col(k-1),'LineWidth',2,'EdgeColor',col(k-1))
    alpha(.4)
    plot(time,ones(length(time),1)+.1,'--k');
    ylim([0,yplotmax]);
    xlim([time(1),time(end)])
    set(gca,'box','on','LineWidth',2,'fontsize',12,'YTickLabel','') %,'XTickLabel',''
    ylabel(args.features{k-1},'fontsize', 12)
    x   = get(gca,'XTick'); str = fex_strtime(x,'short');
    set(gca,'XTick',x(2:2:end-1),'XTickLabel',str(2:2:end-1))
end
    
print(h,'-dpdf','-r450','test_file.pdf')

% for emotions:
% ADD "Evidence", add units.
% For positive

% >> Call it "test" subjects

%% STACK AREA VERSION (NOT WORKING/DON'T UNDERTSAND IT) 

% close all
% YY = [Y(:,3),Y(:,[2,4:end])];
% r = corr(YY(:,2:end),YY(:,1));
% [~,ind] = sort(r,'ascend');
% YY = YY(:,ind);
% names = args.features(ind);

% YY  = Y(:,2:end);
% [~,ind] = sort(mean(YY(:,1:end)),'descend');
% YY = YY(:,ind);
% names = args.features(ind);
% 
% figure, hold all
% for i = 1:size(YY,2)
%     area(time,YY(:,i),'LineWidth',2,'FaceColor',col(i),'EdgeColor','k')
% end

% names = args.features;

% YY  = Y(:,2:end);
% [~,ind] = sort(sum(YY(:,1:end)),'ascend');
% YY = YY(:,ind);
% names = args.features(ind);

h = area(time,Y(:,[5,3]),'LineWidth',2,'EdgeColor','k');
hold on
set(h,'BaseValue',0);

grid on
colormap jet
% set(gca,'Layer','top')
title 'Stacked Area Plot'
x   = get(gca,'XTick'); str = fex_strtime(x,'short');
set(gca,'XTick',x(2:2:end-1),'XTickLabel',str(2:2:end-1))
    ylim([0,yplotmax]);

% legend(names);


%% SURFACE MODEL

close all

scrsz = get(0,'ScreenSize');
h = figure('Position',[0 scrsz(4) scrsz(3) scrsz(4)],...
    'Name','Emotions','NumberTitle','off','Visible','on');
% set(gcf, 'PaperOrientation', 'landscape');
% hold on

time2 = (0:1:time(end))';
YY = interp1(time,Y(:,2:end),time2);

YYY = [];
for i = 1:size(YY,2)
    YYY = cat(1,YYY,repmat(YY(:,i)',[20,1]));
end
YYY = (255*YYY./max(reshape(YYY,1,numel(YYY))));
% YYY = uint8(YYY);
% img = uint8(YYY);

% H1 = fspecial('motion',  15,180);
H2 = fspecial('gaussian',15,3.5);
% img = imfilter(YYY,H1,'replicate');
% img = imfilter(imfilter(YYY,H2,'replicate'),H1,'replicate');

img = YYY;

% imshow(imresize(img,[scrsz(4) scrsz(3)])',jet);
pcolor(img)
shading interp,
colormap jet,
% imshow(img',jet);

% colorbar
y_inc = size(img,1)/size(YY,2);
y = y_inc-y_inc/2:y_inc:y_inc*size(YY,2);
% 
% x = get(gca,'XTick');
% x = x + mode(diff(x));
set(gca,'fontsize',18,'YTick',y,'YTickLabel',args.features,'box','on','LineWidth',3);

t  = get(gca,'XTick');
st = fex_strtime(t,'short');
set(gca,'XTick',t,'XTickLabel',st,'PlotBoxAspectRatio',[1.5,.75,1],'YDir','reverse');
title('Emotion Heat Map','fontsize',20);


h1 = colorbar;
y1_t = get(h1,'YTick');
val_y   = unique(reshape(YY,1,numel(YY)));
val_col = linspace(min(val_y),max(val_y),256)';
strcol  = {''};
for k = 2:length(y1_t)-1
    strcol{k-1} = sprintf('%.2f',val_col(y1_t(k)));
end
set(h1,'YTick',y1_t(2:end-1),'YTickLabel',strcol,'fontsize',16,'LineWidth',2)


set(h1,'box','on','LineWidth',2)

print(h,'-dpdf','-r450','test_file2.pdf')


