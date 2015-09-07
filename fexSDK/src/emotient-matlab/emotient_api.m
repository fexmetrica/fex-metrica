classdef emotient_api < handle
%
% EMOTIENT_API -- Class to interface with Emotient Analytics service.
%
% Create a EMOTIENT_API object to upload videos or download facial
% expression time series files processed with Emotient Analytics (EA)
% (http://www.emotient.com).
%
%
% EMOTIENT_API Properties:
%
% user   - string for EA user name;].
% report - report (not used).
% status - tracking processing status (not implemented).
% videos - cell with a list of videos to upload or download the data. 
% files  - cell with a list of saved files.
% outdir - output directory where FILES are saved.
% media  - list of videos and unique ids for uploaded media. 
% options     - WEBOPTION object used to identify user.
%
% EMOTIENT_API Private Properties:
%
% api_base    - base EA api address.
% api_version - version of the API used.
% apipath     - path to EMOTIENT-MATLAB folder.
% page   - number of items displayed on a page on EA API.
%
% EMOTIENT_API Methods:
%
% emotient-api  - constructor.
%
% set   - set emotient-api properties
% list  - makes a list of media on EA;
% grab  - retrieve all or selected processed files;
% track - track analysis progress status;
% send  - submitt selected media file;
% clean - delete uploaded files;
% kill  - remove users.
%
% EMOTIENT_API Private Methods:
%
% init - constructor helper.
% argcheck - deafaults for argument check.
% checkuser - helper for user constructor.
% finder - wraper for unix "find" command.
% switch_env - patch for issue with Matlab copy of curl.
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 06-Sept-2015.


properties
    % USER - String indicating the user name. This string is linked to
    % "./users/[USER].mat," which is used for autentification to EA API.
    %
    % See also CHECKUSER.
    user
    % REPORT - unused property.
    report
    % STATUS - Percent of analysis completed when new videos are uploaded
    % to EA API.
    %
    % See also SEND, TRACK.
    status
    % VIDEOS - A cell with a list of videos. This list may be uploaded,
    % downloaded, or deleted from EA account.
    %
    % See also SEND, GRAB, CLEAN.
    videos
    % FILES - A cell with the path to the files downloaded. Files are
    % converted so that double are interpreted as double by matlab, and
    % they are saved as tables in the OUTDIR directory with extension .mat.
    %
    % See also GRAB, TABLE, OUTDIR.
    files
    % OUTDIR - String with the directory where the downloaded files will be
    % saved. Default is the current working directory.
    outdir
    % MEDIA - This is a list of media file on your EA account. MEDIA is a
    % structure, which comprises two fields: VIDEOS, and IDS.
    %
    % See also WEBREAD.
    media
    % OPTIONS - This is a WEBOPTIONS instance, which is used to define a
    % user. OPTIONS information is saved in the "users" directory, once a
    % user is genereated. This structure has several fields. The ones that
    % you are allowed to change using SET are:
    %
    % (1) Timeout;
    % (2) Username;
    % (3) Password;
    % (4) KeyValue;
    %
    % See also SET, WEBOPTIONS
    options
end

properties (Access = private)
    % APIPATH - location of emotient-matlab library.
    apipath
    % API_BASE - Base API address, namely 'https://api.emotient.com'. This
    % information is hardcoded in EAAPI.mat in the include directory.
    api_base
    % API_VERSION - Version number of the API. This information is
    % hardcoded in EAAPI.mat in the include directory.
    api_version
    % PAGE - number of items to be displayed by page. Default is set to
    % 500.
    %
    % See also LIST, SET.
    page
    % ENV_FLAG: Boolean value used to switch between DYLD_LIBRARY_PATH on
    % OSX in order to address an issue with https.
    env_flag 
end
 

methods
function self = emotient_api(varargin)
%
% EMOTIENT_API - Constructor
%
% Usage:
%
% Obj = EMOTIENT_API();
% Obj = EMOTIENT_API(ArgName1, ArgVal1, ... );
%
% FIXME: Implement all argument specification

if ~exist('users','dir')
    mkdir('users');
end

self.init();
self.apipath = fileparts(which('emotient_api.m'));
if ~isempty(varargin)
    self.argcheck(varargin);
end

self.checkuser();
    

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = set(self,prop,varargin)
%
% SET - set properties

self.report = 'updating';

switch lower(prop)
case {'user','users','u'}
    load(sprintf('%s/include/ea-headers.mat',self.apipath))
    if isempty(varargin)
        error('You need to provide more info.');
    elseif length(varargin) == 1
        self.user = varargin{1};
        self.checkuser();
    else
        temp = weboptions('Username','batman','KeyName','Authorization','Timeout',100);
        for k = 1:2:length(varargin)
            if isKey(dict.set_user,lower(varargin{k}))
               temp.(dict.set_user(lower(varargin{k}))) = varargin{k+1};
            else
                warning('Unrecognized property "%s".',varargin{k});
            end
        end
        [~,temp.Username] = fileparts(temp.Username);
        self.options = temp;
        self.user = self.options.Username;
        save(sprintf('%s/users/%s.mat',self.apipath,self.user),'temp');
    end
case {'video','videos','v'}
    if isempty(varargin)
        self.videos = self.finder();
        warning('Selecting all files in the current directory.')
    elseif length(varargin) == 1
        self.videos = cellstr(varargin);
    else
        self.videos = self.finder(varargin{:});
    end
case {'outdir','dir','dirout'}
    self.outdir = varargin{1};
    if ~exist(self.outdir,'dir')
        mkdir(self.outdir);
    end     
otherwise
   error('Only "user" implemented.');     
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = list(self,fpp)
%
% LIST - Make a list of available media on your account.

self.report = 'listing';

if exist('fpp','var')
    self.page = fpp;
end
disp_all = sprintf('?per_page=%d&page=1',self.page);

target = sprintf('%s/v%d/media%s',self.api_base,self.api_version,disp_all);
try
    temp = webread(target,self.options);
catch error
    warning(error.message);
    return
end

if isempty(temp.items)
    self.media.videos = [];
    self.media.id     = [];
    self.status       = nan;
else
    t = struct2cell(temp.items);
    self.media.videos = t(4,:)';
    self.media.id     = t(7,:)';
    self.status = mean(ismember(t(1,:)','Analysis Complete'));
end
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = grab(self,select)
% 
% GRAB - Download selected emotient analytic files
%

self.report = 'grabbing';
% FIXME: add select criterion.
if ~exist('select','var');
    select = nan;
end

% Make media list
% ===================
if isempty(self.media)
    self.list;
end

% Make selection based on videos
% ====================
[ind,name2] = self.compare_videos('download');

% Start Tracking
% ===================
h = waitbar(0,'Downloading files ... ');
n = length(ind); k = 1;
self.files = cell(n,1);
for i = ind(:)'
    clc; fprintf('downloading video %d / %d.\n',i,n);
    fid = sprintf('%s/v%d/analytics/%s',self.api_base,self.api_version,self.media.id{i});
    data = webread(fid,self.options);
    data = self.ea_convert(data);
%     name = sprintf('%s/%s.mat',self.outdir,name2{i});
    name = sprintf('%s/%s.csv',self.outdir,name2{i});
    self.files{k,1} = name;
    k = k + 1;
    export(table2dataset(data),'file',name,'delimiter',',');
%     save(name,'data');
    waitbar(k/n,h);
end
delete(h);
  
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = send(self,varargin)
%
% SEND - submitt videos to EA server.

if isempty(self.videos)
    error('Nothing to upload');
else
    self.switch_env(1);
    for i = 1:length(self.videos);
        cmd = self.curl_cmd('put',i);
        [h,o] = system(cmd);
        if h == 0
            fprintf('Uploaded video %s.\n',o);
        else
            warning('Issues with video: %s.\n',self.video{i});
        end
    end
    self.switch_env(2);
end
self.list();
% NOTE: 
% fid  = sprintf('%s/v%d/upload',self.api_base,self.api_version);
% for i = 1:length(self.videos)
%    [resp] = webwrite(fid','file',self.videos{i},self.options);
% end
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
function self = clean(self,varargin)
%
% CLEAN - remove videos from EA website.

% FIXME: Implement selection!

% Update list
% ===============
self.list();

self.switch_env(1);
for i = 1:length(self.media.id);
    cmd = self.curl_cmd('delete',i);
    [~,o] = system(cmd);
    if o == 0
        fprintf('Deleted video %s.\n',self.media.videos{i});
    else
        warning('Issues with video: %s: %s\n',self.media.videos{i},o);
    end
end
self.switch_env(2);
self.list();
end 

%===================================================
%===================================================

end

methods (Access = private)
% ++++++++++++++++++++++++++++++++++++++++++++++++++
function self = argcheck(self,args)
%
% ARGCHECK - helper function for argument parsing.

% def_vals = importdata(sprintf('%s/include/ea_defaults.mat',self.apipath));
self.init();
if ~exist('args','var')
    return
end

for vals = args(1:2:end)
    try
        self.(vals{1}) = args{find(strcmpi(vals{1},args(1:2:end)))+1};
    catch error
        warning(error.message);
    end
end
     
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
function self = init(self)
%
% INIT - Initialize EMOTIENT_API

path = which('emotient_api.m');
path = fileparts(path);
args = importdata(sprintf('%s/include/eaapi.mat',path));
args.outdir = pwd;

for k = fieldnames(args)'
    self.(k{1}) = args.(k{1});
end
% Initialize DYLD_LIBRARY_PATH
self.env_flag.env = getenv('DYLD_LIBRARY_PATH');

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
function self = checkuser(self)
%
% CHECKUSER - check user status.

[~,self.user] = fileparts(self.user); 
if isempty(self.user) && isempty(ls(sprintf('%s/users',self.apipath)))
    warning('No users exists, create a users with ".set(''user'')".');
elseif isempty(self.user) && ~isempty(ls(sprintf('%s/users',self.apipath)))
    [~,user_list] = system(sprintf('find %s/users -name *.mat|sort',self.apipath));
    user_list = strsplit(user_list(1:end-1),'\n');
    [~,user_list] = cellfun(@fileparts,user_list,'UniformOutput',0);
    user_list = table(user_list);
    warning('Select a user.');
    disp(user_list);
elseif ~exist(sprintf('%s/users/%s.mat',self.apipath,self.user),'file');
    warning('User "%s" does not extist.',self.user);
else
    self.options = importdata(sprintf('%s/users/%s.mat',self.apipath,self.user));
    self.list();
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function [ind,name2,name1] = compare_videos(self,action)
%
% COMPARE_VIDEOS - Compare uploaded and locally selected videos.
  
switch action
    case 'download'
        if ~isempty(self.media.videos)
            try self.list()
                [~,name2] = cellfun(@fileparts,self.media.videos,'UniformOutput',0); 
            catch errorid
                errorid(errorid.message);
                name2 = '';
            end
        end
        
        if isempty(self.videos)
            name1 = '';
            ind = (1:length(self.media.videos))';
        else
            [~,name1] = cellfun(@fileparts,self.videos,'UniformOutput',0);
            [~,ind] = ismember(name1,name2);
        end
    case 'upload'
        fprintf('todo');
    otherwise
        error('Unrecognized action.');
end


end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function data = ea_convert(self,data)
%
% EA_CONVERTER - Helper function to convert downloaded data.
    
for k = 4:size(data,2)
    data.(data.Properties.VariableNames{k}) = cellfun(@str2double,data.(data.Properties.VariableNames{k}));
end
self.report = 'converting';

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
function some_list = finder(self,varargin)
%
% FINDER - uses unix comand "find" to make a list of files.
%
% Usage:
%
% list = FINDER();
% list = FINDER(dir);
% list = FINDER(dir,ext);
%
% Example:
%
% list = FINDER(pwd,'*.csv');
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu.
%
% This method is a copy of FEX_FIND.m from FexMetrica Toolbox
% (fexmetrica.com).
%
% VERSION: 1.0.1 05-Sept-2015.


% Assign arguments
% ====================
if isempty(varargin)
    dirp = pwd;
    extf = '*';
elseif length(varargin) == 1;
    dirp = varargin{1};
    extf = '*';
elseif length(varargin) >= 2;
    dirp = varargin{1};
    extf = varargin{2};
end
    
% Issue unix command
% ====================
cmd = sprintf('find "%s" -name %s|sort',dirp,extf);
[h,o] = system(cmd);

% Output list
% ====================
if h ~= 0
    error('Error code: %d.\n',h);
else
    some_list = cellstr(strsplit(o(1:end-1),'\n'))';
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
function self = switch_env(self,arg)
%
% SWITCH_ENV fixed an issue with curl and https on Matlab (tested on mac
% only);
%
% FIXME: This was tested only on my machine. But there are several post
% indicating problems with Matlab version of libcurl.4.dylib and https and
% git.
% 
% References:
%
% http://benheavner.com/systemsbio/index.php?title=Matlab_git#Getting_Git_to_work_in_MATLAB_.28on_Mac.29
% http://www.mathworks.com/matlabcentral/answers/17437-dyld_library_path-problem

if ~strcmp(computer,'MACI64')
    return
end

if arg == 1
    self.env_flag.val = 1;
    setenv('DYLD_LIBRARY_PATH','/usr/local/bin:/usr/bin:/usr/local/sbin');
else
    self.env_flag.val = 2;
    setenv('DYLD_LIBRARY_PATH',self.env_flag.env);
end

end
% ++++++++++++++++++++++++++++++++++++++++++++++++++

function c = curl_cmd(self,task,k)
% 
% CURL_CMD - create curl command for Uploading and deleting files.

if strcmp(task,'put')
    c = sprintf('curl -X POST %s/v%d/upload -H ''Authorization: %s'' -F file=@%s',...
        self.api_base,self.api_version,self.options.KeyValue,self.videos{k});
else
    c = sprintf('curl -X DELETE %s/v%d/media/%s -H ''Authorization: %s''',...
        self.api_base,self.api_version,self.media.id{k},self.options.KeyValue);
end

end
% ++++++++++++++++++++++++++++++++++++++++++++++++++
end
%===================================================
end




