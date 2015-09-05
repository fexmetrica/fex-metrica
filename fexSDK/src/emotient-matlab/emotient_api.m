classdef emotient_api < handle
%
% EMOTIENT_API -- Class to interface with Emotient Analytics service
%
%
% PUBLIC METHODS:
%
% list   - make a list of existing media files;
% grab   - retrieve all or selected analysis files;
% track  - track analysis progress status;
% send   - submitt selected media file;
% clean  - delete uploaded files;
% set    - set properties;
% kill   - remove users.
%
% PRIVATE METHODS:
%
% argcheck - deafaults and argument check.
% init
% checkuser
%
% FIXME - Make user files password protected 

properties
    user        % ok;
    media       % Change media format;
    report      % Remove (?);
    status      % Tracking -- getter function;
    videos      % ok (add set option)
    files       % ok
    outdir      % ok
    page
% private ==============
    api_base    % hard coded
    api_version % hard coded
    apipath     % derived (ok)
    options     % make set specific fields
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
    % Username
    % Password
    % KeyValue
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

function data = ea_convert(self,data)
    
for k = 4:size(data,2)
    data.(data.Properties.VariableNames{k}) = cellfun(@str2double,data.(data.Properties.VariableNames{k}));
end

end
% ++++++++++++++++++++++++++++++++++++++++++++++++++


end   
end




