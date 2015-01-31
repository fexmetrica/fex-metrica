%% Fex-Metrica Sample Analyze Agent
%
% This script provides an example of analyzer for video data.
%
% Directory three:
%
%   .                 ........... main directory.
%   ./fex_agentx.m    ........... this file.
%   ./[DATA_DIR]      ........... data directory where videos are provided.
%   ./[TARGET_DIR]    ........... output directory where results are saved.
%
% The user place a set of videos in DATA_DIR. This scripts looks for new
% videos in DATA_DIR, once it founds them it perform the following
% operations:
%
% 1. Creates a directory named after each video in TARGET_DIR;
% 2. MOVES each video to the corresponding directory;
% 3. Process the videos using Facet and fex-metrica (.json & .csv files);
% 4. Sleeps for 30 seconds;
% 5. Repeat.
%
% Note that:
%
% * Videos in [DATA_DIR] are removed only after the operation is completed;
% * If you enter a video with an existing TARGET_DIR folder, the video is
%   removed and ignored.
% * Computation is run in parallel using parfor -- the number of worker
%   depends on your Matlab configuration. 
%
%
%
% Copyright (c) - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 30-Jan-2015.


% --------------------------------------
% Enter the directories
% --------------------------------------
DATA_DIR = sprintf('%s/input',pwd);
TARGET_DIR = sprintf('%s/output',pwd);


key_press = 'r';
while ~strcmpi(key_press, 'q')

clc
fprintf('\nChecking for new videos ....')
    
% --------------------------------------
% Data listing and handling
% --------------------------------------

% Look for new videos in the DATA_DIR
[h1,in_videos] = system(sprintf('ls %s',DATA_DIR));
in_videos = strsplit(in_videos(1:end-1),'\t')';

if isempty(in_videos{1})
% Sleep if no video was provided
    str = 'Nothing to do. Sleeping';
    for j = 1:30
        clc
        fprintf('\n%s\n',str);
        pause(1);
        str = [str,'.'];
    end
else

% Existing Directories
[h2,out_list] = system(sprintf('ls %s',TARGET_DIR));
out_list = strsplit(out_list,'\t')';

% Select the video to process based on existing targets
ind   = ismember(in_videos,out_list);
to_do = in_videos(ind == 0);

% --------------------------------------
% Set up Target directory
% --------------------------------------
jobs =  [];
for k = 1:size(to_do,1)
    % Move and make a list of videos to process
    [~,n,ext] = fileparts(to_do{k});
    mkdir(sprintf('%s/%s',TARGET_DIR,n));
    vid_name = sprintf('%s/%s/%s%s',TARGET_DIR,n,n,ext);
    h3 = copyfile(sprintf('%s/%s',DATA_DIR,to_do{k}),vid_name,'f');
    if h3 ~=1
        warning('Failed to copy %s.',vid_name);
    end
    jobs = cat(1,jobs,{vid_name});
end

fprintf('\nPreparing to process %d videos:\n\n',size(jobs,1));
disp(char(out_list'));

% --------------------------------------
% Use facet for the processing
% --------------------------------------
fex_facetproc(jobs);    


% --------------------------------------
% Clean up
% --------------------------------------
for k = 1:length(to_do)
    system(sprintf('rm %s/%s',DATA_DIR,to_do{k}));
end


% --------------------------------------
% Go to sleep
% --------------------------------------
str = 'Sleeping ';
for j = 1:30
    clc
    fprintf('\n%s\n',str);
    pause(1);
    str = [str,'.'];
end

end

end

clc
fprintf('\nExiting on user''s request.');

