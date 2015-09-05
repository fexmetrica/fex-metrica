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
%
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

switch prop
case 'user'
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
        self.videos = cellstr(fexwsearchg());
    elseif ischar(varargin)
        self.videos = cellstr(varargin);
    end
otherwise
   error('Only "user" implemented.');     
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = list(self,fpp)
%
% LIST - Make a list of available media on your account.

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
  
t = struct2cell(temp.items);
self.media.videos = t(4,:)';
self.media.id     = t(7,:)';

 
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = grab(self,select)
% 
% GRAB - Download selected emotient analytic files
%
% FIXME: add select criterion.


% Make media list
% ===================
if isempty(self.media)
    self.list;
end

% Make selection based on videos
% ====================
if ~isempty(self.videos)
    [~,name1] = cellfun(@fileparts,self.videos,'UniformOutput',0);
    [~,name2] = cellfun(@fileparts,self.media.videos,'UniformOutput',0);
    [~,ind] = ismember(name1,name2);
else
    ind = (1:length(self.media.videos))';
end

n = length(ind);
for i = ind(:)'
    clc; fprintf('downloading video %d / %d.\n',i,n);
    fid = sprintf('%s/v%d/analytics/%s',self.api_base,self.api_version,self.media.id{i});
    data = webread(fid,self.options);
    data = self.ea_convert(data);
    name = sprintf('%s/%s.mat',self.outdir,name2{i});
    save(name,'data');
    clear data;
end
  
end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function self = send(self,varargin)
%
% SEND - submitt videos to EA server.

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
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++

function data = ea_convert(self,data)
%
% EA_CONVERTER - Helper function to convert downloaded data.
    
for k = 4:size(data,2)
    data.(data.Properties.VariableNames{k}) = cellfun(@str2double,data.(data.Properties.VariableNames{k}));
end

end

% ++++++++++++++++++++++++++++++++++++++++++++++++++
end


%===================================================
end




