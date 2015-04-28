function f = fex_fastproc(videos,fps)
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


if ~exist('videos','var')
    error('You need to enter a list of videos');
elseif ~exist('fps','var')
    fps = 0.50;
elseif fps <= 0 || fps > 2
    warning('Fps requirements: 0 <= fps <= 2. Set to 0.50');
    fps = 0.05;
end


% Select executable
% ---------------------
exec = 'ffmpeg';
if strcmi(computer,'glnxa64')
    exec = 'avconv';
end

% Temorary directory for low fps files
% -----------------------
SAVE_TO = sprintf('%s/fexfasttemp',pwd);
if exist(SAVE_TO,'dir')
    unix(sprintf('rm %s/*',SAVE_TO));
else
    mkdir(SAVE_TO);
end

% Utility for unix command
% -----------------------
cmd = @(exec,v1,fps,v2)sprintf('%s -i "%s" -r %.1f -vcodec mjpeg -an -q 0 -loglevel quiet "%s"',...
    exec,v1,fps,v2);

% Resample videos
% --------------------
nname = cell(size(videos,1),1);
for k = 1:size(videos,1)
    [~,f] = fileparts(videos{k});
    nn = sprintf('%s/fexfasttemp/%s.avi',f);
    [h,out] = unix(sprintf('source ~/.bashrc && %s',cmd(exec,videos{k},fps,nn)));
    if h == 0
        nname{k} = nn;
    else
        warning(out);
    end 
end

% Generate % Process
% -----------------------
f = fexc(nname);
f.facet;

% False allarm
% -----------------------
f.falsepositive('position')

% Crop videos with new face size
% -----------------------
for k = 1:videos
    f(k).videoutil(true);
end

end

