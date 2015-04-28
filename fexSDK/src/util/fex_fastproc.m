function [f,oet] = fex_fastproc(videos,fps)
%
% FEX_FASTPROC - Fast analysis of downsampled video
% 
% Enter a set of videos, and select a very low FPS, default 0.5 frames per
% seconds. Indicat an output directory for the new videos.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 29-Apr-2015.

tic;
if ~exist('videos','var')
    error('You need to enter a list of videos');
elseif ~exist('fps','var')
    fps = 0.50;
elseif fps <= 0 || fps > 2
    warning('Fps requirements: 0 <= fps <= 2. Set to 0.50');
    fps = 0.05;
end


% Select executable ! To test
% ---------------------
exec = 'ffmpeg';
if strcmpi(computer,'glnxa64')
    exec = 'avconv';
end

% Temorary directory for low fps files
% -----------------------
SAVE_TO = sprintf('%s/fexfasttemp',pwd);
if exist(SAVE_TO,'dir')
    [h,o] = unix(sprintf('rm %s/*',SAVE_TO));
    if h ~=0 
        oet = o;
    else
        oet = '';
    end
else
    mkdir(SAVE_TO);
end

% Utility for unix command
% -----------------------
cmd1 = @(EX,N1,FPS,S) sprintf('%s -i "%s" -r %.1f -q:v 0 -loglevel quiet %s/img%s.jpg',EX,N1,FPS,SAVE_TO,'%08d');
cmd2 = @(EX,S,N2) sprintf('%s -i %s/img%s.jpg -r 15 -vcodec mjpeg -q:v 0 -loglevel quiet "%s"',EX,S,'%08d',N2);
c3 = sprintf('find %s/ -name "*.jpg" -delete',SAVE_TO);

% Resample videos
% --------------------
nname = cell(size(videos,1),1);
for k = 1:size(videos,1)
    fprintf('Resemapling video %d / %d ... ',k,size(videos,1))
    [~,f] = fileparts(videos{k});
    nn = sprintf('%s/%s.avi',SAVE_TO,f);
    c1 = cmd1(exec,videos{k},fps,SAVE_TO);
    c2 = cmd2(exec,SAVE_TO,nn);
    [h,out] = unix(sprintf('source ~/.bashrc && %s && %s && %s',c1,c2,c3));
    if h == 0
        nname{k} = nn;
    else
        warning(out);
    end 
end

% Generate % Process
% -----------------------
Y = fex_facetproc(nname,'dir',SAVE_TO);
f = fexc('videos',nname,'files',Y);

% False allarm & Face box size
% -----------------------
f.falsepositive('position');
f.falsepositive('size');

t = toc;
% Get FaceBox
% -----------------------
B = f.get('facebox');
B = double(B(:,[3,4,1,2]));

% Generate new videos
% ------------------------
% cmd2 = @(exec,n,s,nn) sprintf('%s -i %s -filter:v crop=%d:%d:%d:%d -q:v 0 %s',exec,n,s,nn);

end

