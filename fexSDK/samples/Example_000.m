%% Example of Processing using fexFacet utilities


%% (1) Emotient SDK Preprocessing Example (short)

% Set Up (you need to use genpath to find the executable files)
clear all, clear classes
addpath(genpath(pwd));

% Create the preprocessing object (select data is done with a GUI application)
PpObj = fex_ppo2;

% Execute computation for the first video
PpObj(1).step();


%% (2) Emotient SDK Preprocessing Example (long)

clear all,clear classes
addpath(genpath(pwd));

% (1) Add a costume directory for the results;
% (2) Select variable to be computed by the Emotient SDK. Options include:
%       'face': landmarks and pose only;
%       'emotions': landmarks, pose, emotions and sentiments;
%       'aus': landmarks, pose, action units;
%       'all': landmarks, pose, action units, emotions and sentiments [default].

PpObj = fex_ppo2('chanels','face','outdir',sprintf('%s/NewDirName',pwd));

% Change the comand used to process the frames to use matlab instead of
% ffmpeg/avconv, and set the quality scaling of the output frame to 25%
% (Note that qscale = 0 is best quality, and 1 is worst quality). For more
% information on additional arguments, see
%
% >> help fexppoc.video2frame
%
% Note that using matlab instead of ffmpeg/avconv slows the computation.
% Set up parallel processings helps. Note that it takes time to start
% matlab pool, so you should do it only one at the beginning, and then
% close it when you are done processing all the videos.

matlabpool 4

for i = 1:length(PpObj)
    % Change frame Processing
    PpObj(i) = PpObj(i).video2frame('method','matlab','qscale',.25);
    % Execute the computation for the current video
    PpObj(i).step();
    % Deletre the directory where the frames were temporarely stored
    PpObj(i).clean('quiet');
end

matlabpool close

%% (3) Faster and cleaner


% Set Up (you need to use genpath to find the executable files)
clear all, clear classes
addpath(genpath(pwd));

% Create the preprocessing object (select data is done with a GUI application)
PpObj = fex_ppo2('chanels','face');

% Execute computations
for i = 1:length(PpObj)
    PpObj(i).step();
    PpObj(i).clean('quiet');
end


%% (4) Analyze single image with fex_facetf.m

% make a list of files:
list = {'testdata/images/Sadness.jpg',...
        'testdata/images/Joy.jpg',...
        'testdata/images/Surprise.jpg',...
        'testdata/images/Fear.jpg',...
        'testdata/images/Anger.jpg',...
        'testdata/images/Disgust.jpg'};

X = [];
for i = 1:length(list)
    [x,h] = fex_facetf(list{i},'face');
    X = cat(1,X,x');
end




