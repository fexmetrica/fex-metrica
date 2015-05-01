classdef fexvideoc < handle
%
% FEXVIDEO - FexMetrica 1.0.1 video utility object.
%
% Use information from FEXC file or video file, and allow a set of
% operations, including:
%
%
% CROP - Crop video (with/without UI);
% RGBSEP - Separate RGB channels;
% ENCDE - Re-encode video;
% HRE - Estimate heart-rate from video;
% PDE - Estimates pupil dilatation.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 29-Apr-2015.

properties
    % VIDEO: Cell of paths to video files, or string to video file that
    % will be manipulated.
    video
    % EXEC: Name of the executable used, i.e. ffmpeg (osx, win64) or avconv
    % glnxa64).
    exec
    % NV: Number of videos in the object.
    nv
    % BOX: Face bounding box (part of the downsampling procedure).
    facebox
    % FLAG: ??
    flag
    % FACE: ??
    face
    % PROJTREE: structure with print directories. By default, this is a new
    % directory named "fexvideod" in the current directory. Each method will
    % generated a subdirectory. The FEXVIDEC project three is organized as
    % such:
    %
    %   ./fexvideod ................ Working directory (pwd)
    %         ./fexlfpsd ........... Directory with low fps videos
    %         ./fexcropd ........... Directory with cropped videos
    %         ./fexnencd ........... Directory with re-encoded videos
    %         ./fexaudid ........... Directory with audio files
    % 
    % Note that if this project tree already exists, files will be
    % overwritten
    projtree
    % LAST_BRANCH: ...
    last_branch
    % VIDEOINFO: ... 
    info
end


methods
function self = fexvideoc(varargin)
%
% FEXVIDEOC - Constructor for FEX video utilities objec.

% Set up executable
% ----------------------------
self.execset();
self.info = [];
                       
% Read video argument
% ----------------------------
if isempty(varargin)    
    self.video = cellstr(fexwsearchg());
    if isempty(self.video)
        return
    end
elseif isa(varargin{1},'char')
    self.flag  = 1;
    self.video = cellstr(varargin{1});
    self.face  = [];
elseif isa(varargin{1},'cell')
    self.flag  = 1;
    self.video = varargin{1};
    self.face  = [];
elseif isa(varargin{1},'fexc')
    self.flag  = 2;
    self.video = varargin{1}.get('videos');
    self.face  = varargin{1};
    B = self.face.get('facebox');
    self.facebox = double(B(:,[3,4,1,2]));
else
    warning('Not recognized argument.');
    return
end

% Check whether videos exist
% ----------------------------
c = ones(length(self.video),1);
for k = 1:length(self.video)
    if ~exist(self.video{k},'file')
        warning('%s not found',self.video{k});
        c(k) = 0;
    end
end
self.video = self.video(c == 1);
self.nv = sum(c);

% Set up project tree
% ----------------------------
self.projtree = struct('root',sprintf('%s/fexvideod',pwd),...
    'original',struct('dir',cell(self.nv,1),'files',cell(self.nv,1)),...
    'fexlfpsd',struct('dir',sprintf('%s/fexvideod/fexlfpsd',pwd),'files',cell(self.nv,1)),...
    'fexcropd',struct('dir',sprintf('%s/fexvideod/fexcropd',pwd),'files',cell(self.nv,1)),...
    'fexnencd',struct('dir',sprintf('%s/fexvideod/fexnencd',pwd),'files',cell(self.nv,1)),...
    'fexaudid',struct('dir',sprintf('%s/fexvideod/fexaudid',pwd),'files',cell(self.nv,1)));
for k = 1:self.nv
    p = fileparts(self.video{k});
    self.projtree.original.dir{k} = p;
    self.projtree.original.files{k} = self.video{k};
end

self.last_branch = '';
self.videoinfo();

% Create main output directory
% ----------------------------
if ~exist(self.projtree.root,'dir') && self.nv > 0;
    mkdir(self.projtree.root);
end


end

% ==============================================


function self = execset(self,varargin)
%
% EXECSET - Set up executable cmd used.

prex = '';
if exist('~/.bashrc','file');
    prex = 'source ~/.bashrc';
end

if strcmp(computer,'GLNXA64')
    self.exec = sprintf('%s && avconv',prex);
else
    self.exec = sprintf('%s && ffmpeg',prex);
end
    
[h,out] = system(self.exec);
if h == 127
    warning('Executable not found.\n');
else
    s = strsplit(out,'\n');
    fprintf('\nObject using: %s\n\n',s{1});
end

        
end

% ==============================================


function self = crop(self,which_method,which_branch)
%
% CROP - Crop video based on:
%
% 2. Manual area selection;
% 1. Given coordinates;
% 3. Fast face finder code (compiled only).

% cmd4 = @(f1,f2,b) sprintf('-i %s -filter:v crop=%d:%d:%d:%d -q:v 0 -y -loglevel quiet %s',f1,b,f2);
cmd4 = @(f1,f2,b) sprintf('-i %s -filter:v crop=%d:%d:%d:%d -q:v 0 -vcodec mjpeg -an -y -loglevel quiet %s',f1,b,f2);


if ~exist('which_branch','var');
    which_branch = 'original';
end

if ~exist('which_method','var') && ~isempty(self.facebox)
    which_method = 1;
end


SAVE_TO = self.projtree.fexcropd.dir;
if ~exist(SAVE_TO,'dir')
    mkdir(SAVE_TO);
end

switch which_method
% Use existing face box
% ---------------------
case 1
    for k = 1:self.nv
        fprintf('Generating new videos %d / %d ...\n ',k,self.nv)
        [~,f,ex] = fileparts(self.projtree.(which_branch).files{k});
        % nn = sprintf('%s/%s%s',SAVE_TO,f,ex);
        nn = sprintf('%s/%s%s',SAVE_TO,f,'.avi');
        bk = self.facebox(k,:); bk(3:4) = rempamt(max(bk(3:4),[1,2]));
        c4 = cmd4(self.projtree.(which_branch).files{k},nn,bk);
        [h,o] = system(sprintf('%s %s',self.exec,c4));
        if h ~=0
            warning(o);
        else
            self.projtree.fexcropd.files{k} = nn;
        end
    end
    self.last_branch = 'fexcropd';
case 2
% Drow face-box
% ---------------------
    if isempty(self.projtree.fexlfpsd.files);
        self.condense();
    end
    self.drawbox(self.projtree.fexlfpsd.files);
    for k = 1:self.nv
        fprintf('Generating new videos %d / %d ...\n ',k,self.nv)
        [~,f,ex] = fileparts(self.projtree.(which_branch).files{k});
        % nn = sprintf('%s/%s%s',SAVE_TO,f,ex);
        nn = sprintf('%s/%s%s',SAVE_TO,f,'.mov');
        c4 = cmd4(self.projtree.(which_branch).files{k},nn,self.facebox(k,:));
        [h,o] = system(sprintf('%s %s',self.exec,c4));
        if h ~=0
            warning(o);
        else
            self.projtree.fexcropd.files{k} = nn;
        end
    end
otherwise
    return
end



end

% ==============================================

function [self,nn] = condense(self,fps,rf)
%
% SMALL - Reduce file size in time.
%
% FPS = frames per second in new video (default 0.5);

if ~exist('fps','var')
    fps = 0.50;
elseif fps <= 0 || fps > 2
    warning('Fps requirements: 0 <= fps <= 2. Set to 0.50');
    fps = 0.05;
end

if ~exist('rf','var')
    rf = false;
elseif ~rf
    rf = false;
end


% Directory for low fps files
% -----------------------
SAVE_TO = self.projtree.fexlfpsd.dir;
if ~exist(SAVE_TO,'dir')
    mkdir(SAVE_TO);
end

% Set up utilities command 
% -----------------------
cmd1 = @(N1,FPS,S)sprintf(' -i "%s" -r %.1f -q:v 0 -loglevel quiet %s/img%s.jpg',N1,FPS,SAVE_TO,'%08d');
cmd2 = @(S,N2)sprintf(' -i %s/img%s.jpg -r 15 -vcodec mjpeg -q:v 0 -loglevel quiet "%s"',S,'%08d',N2);
c3 = sprintf('find %s/ -name "*.jpg" -delete',SAVE_TO);

% Downsample videos
% -----------------------
for k = 1:self.nv
    fprintf('Resemapling video %d / %d ...\n ',k,self.nv)
    [~,f] = fileparts(self.video{k});
    nn = sprintf('%s/%s.avi',SAVE_TO,f);
    c1 = sprintf('%s %s',self.exec,cmd1(self.video{k},fps,SAVE_TO));
    c2 = sprintf('%s %s',self.exec,cmd2(SAVE_TO,nn));
    [h,out] = system(sprintf('%s && %s && %s',c1,c2,c3));
    if h == 0
        self.projtree.fexlfpsd.files{k} = nn;
    else
        warning(out);
    end 
end

self.last_branch = 'fexlfpsd';

% Run facet when required
% -----------------------
if rf
    self.facet('fexlfpsd');
end

end

% ==============================================

function self = facet(self,which_branch,thrs)
%
% FACET - Run facet SDK on videos in WHICH_BRANCH
%
% Output file are .json & FEXC objects in the WHICH_BRANCH directory.


% Test FACET SDK
% -----------------------
test = importdata('fexinfo.dat');
if test.INST == 3
    warning('You can''t run Facet SDK.');
    return;
end

% READ Threshold
% -----------------------
if ~exist('thrs','var')
    thrs = 1.5;
elseif thrs == 0
    thrs = 'off';
end

% Process with FACET SDK
% -----------------------
SAVE_TO = self.projtree.(which_branch).dir;
Y = fex_facetproc(self.projtree.(which_branch).files,'dir',SAVE_TO);
f = fexc('videos',self.projtree.(which_branch).files,'files',Y);

% False allarm & Face box size
% -----------------------
if ~sum(strcmpi(thrs,{'off','false'})) == 0
    f.falsepositive('position','threshold',thrs);
    f.falsepositive('size','threshold',thrs);
end

% Get FaceBox
% -----------------------
B = f.get('facebox');
self.facebox = double(B(:,[3,4,1,2]));

end

% ==============================================

function self = sound(self,ab,an,ar)
%
% SOUND - Extract sound track from 
%
% ab: audio bitrate; default = 160 kb/sec.;
% an: number of audio channels; default = 2;
% ar: audio sampling rate; default = 44100;
%
% Output file is an .mp3.


end

% ==============================================


function self = hre(self,varargin)
%
% HRE - Estimate heart rate response -- 
%
% Lock / Scale Forehead;
% Extract / Scale Green Channel Values;
% Estimate HR on Sample 30 sec.
% Measure HR for video.


    
end

% ==============================================

function ts = findgreen(self,which_branch,pxl)
%
% FINDGREEN - Find spikes in green channel from a video
   

if ~exist('which_branch','var')
    which_branch = 'original';
end

if ~exist('pxl','var')
    pxl = [25,25];
end

cmd = @(n1,n2)sprintf('%s -i %s -vcodec mjpeg -q:v 15 -vf "crop=%d:%d:0:0" -loglevel quiet -y %s',self.exec,n1,pxl,n2);

for k = 1:self.nv
    p  = fileparts(self.projtree.(which_branch).files{k});
    fprintf('Generating temp video \n')
    n2 = sprintf('%s/temp.mov',p); 
    [h,o] = system(cmd(self.projtree.(which_branch).files{k},n2));
    if h ~=0
        error(o);
    end
    fprintf('Reaeding temp video ... ');
    vidObj = VideoReader(n2);
    img = read(vidObj,1);
    img = 0.2126*img(:,:,1) + 0.7152*img(:,:,2) + 0.0722*img(:,:,3);
    F = mean(reshape(img(:,:,1),1,numel(img(:,:,1))));
    for j = 2:self.info(k,3)
        clc; fprintf('Grabbing frame %d / %d.\n',j,self.info(k,3));
        try
           img = read(vidObj,j);
           img = 0.2126*img(:,:,1) + 0.7152*img(:,:,2) + 0.0722*img(:,:,3);
           F = cat(1,F,mean(reshape(img(:,:,1),1,numel(img(:,:,1)))));
        catch errorid
            ts = F;
            warning(errorid.message);
            return
        end
    end
    ts = F;
end
        
end



% ==============================================

function self = videoinfo(self)
%
% VIDEOINFO -- Extract video information

prop = {'FrameRate','Duration','NumberOfFrames','Width','Height'};

for k = 1:self.nv
    try
        self.info = cat(1,self.info,cell2mat(get(VideoReader(self(k).video),prop)));
    catch
        cmd  = sprintf('%s -i %s 2>&1 | grep "Duration"',self.exec,self.video{k});
        [~,o] = system(sprintf('%s',cmd));
        s = strsplit(o,' ');
        % FIXME:  This makes the assumption that it is always in 3rd position.
        VI(2) = fex_strtime(s{3}(1:end-1));
        cmd   = sprintf('%s -i %s 2>&1 | grep "fps"',self.exec,self.video{k});
        [~,o] = system(sprintf('%s',cmd));
        s = strsplit(o,' ');
        VI(1) = str2double(s{find(strcmp(s,'fps,'))-1});
        % FIXME:  This makes the assumption that it is always in 11th position.
        VI(4:5) = cellfun(@str2double,strsplit(s{11},'x'));
        % FIXME: This is an approximation
        VI(3) = round(VI(2)*VI(1));
        self.info = cat(1,self.info,VI);
    end
end

end

% ==============================================


end

end