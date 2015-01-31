function [box_par,videolist,cmds] = fex_videocrop(list,SAVE_TO)
%
% FEX_VIDEOCROP -- Intereactive video cropping utility.
%
%
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 30-Jan-2015.


% --------------------------
% Read argument
% --------------------------
if ~exist('list','var')
    list = char(fexwsearchg());
elseif isa(list,'cell')
    list = char(list);
end
% --------------------------
% Output Variable
% --------------------------
if ~exist('SAVE_TO','var')
    SAVE_TO = sprintf('%s/fexmediacropped',pwd);
    mkdir(SAVE_TO);
end
% --------------------------
% Space for the box
% --------------------------
box_par = [];
for i = 1:size(list,1)
% --------------------------
% Open video object
% --------------------------
vobj = VideoReader(deblank(list(i,:)));
% --------------------------
% Open Interactive drawing
% --------------------------
pos = [];
for k = round(linspace(1,vobj.NumberOfFrames - 100,4));
    frame = read(vobj,k);
    imshow(frame);
    h1 = imrect();
    pause
    pos = cat(1,pos,getPosition(h1));
    close all;
end
% --------------------------
% Get box size
% --------------------------
pos(:,1:2) = pos(:,3:4) + pos(:,1:2);
pos = [max(pos(:,1:2))-min(pos(:,3:4)),min(pos(:,3:4))];
box_par = cat(2,box_par,pos([3:4,1:2]));
end
% --------------------------
% Create commands
% --------------------------
if strcmpi(computer,'GLNXA64')
    exec = 'avconv';
else
    exec = 'ffmpeg';
end

if exist('~/.bashrc','file')
    pre_str = 'source ~/.bashrc &&';
else
    pre_str = '';
end
videolist = []; cmds = []; strf = sprintf('Video cropping');
for k = 1:size(box_par,1)
    fprintf('\n%s\n',strf);
    strf = [strf,'.'];
    [~,fname] = fileparts(list(k,:));
    newname = sprintf('%s/c_%s.mov',SAVE_TO,fname);
    videolist = cat(1,videolist,{newname});
    str1 = sprintf('%s -i %s -vcodec libx264 -pix_fmt yuv420p -crf 10 -q 0',exec,list(k,:));
    str2 = sprintf('-filter:v crop=%d:%d:%d:%d',box_par(k,:));
    cmd  = sprintf('%s %s %s %s\n',pre_str,str1,str2,newname);
    cmds = cat(1,cmds,{cmd});
% --------------------------
% Execute commands
% --------------------------
    [h,cout] = system(cmd);
    if h ~=0
        warning(cout);
    end
end

