function PpObj = fex_ppo2(varargin)
% 
% PpObj = fex_facet();
% PpObj = fex_facet('ArgNam1',ArgVal1,...);
%
% Creates an object of Class "fexppoc." Optional arguments include the
% following:
%
% 'files', a list of files generated with fex_lsg.m (see docs
%       there). If you leave this argument empty, the function will open a
%       GUI for file selection.
%
% "chanels:" a string to select variables to be computed by the Emotient
%       SDK (http://www.emotient.com). Options include:
%
%       - 'face': landmarks and pose only;
%       - 'emotions': landmarks, pose,emotions and sentiments;
%       - 'aus': landmarks, pose, action units;
%       - 'all': landmarks, pose, action units, emotions and sentiments
%               [default].
%
% 'outdir', a string with the directory where the Emotient SDK .txt files
%       are saved. Default is a diretctory labeled 'facet_[K]' in the
%       current directory. Note that datestr(K/100) is the date, hour,
%       minute and second when the folder was generated.
%
%
%_______________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 06/05/14.


% Set some defaults
% Make default output directory name
arg.outdir   = sprintf('%s/facet%.0f',pwd,now);
% Select default number of chanels
arg.chanels  = 'all';
% Use gui to select files
arg.files = '';

try
    % Attempt to read variable arguments.
    for i = 1:2:length(varargin)
        arg.(sprintf('%s',varargin{i})) = varargin{i+1};
    end
catch
    % somethiong went wrong, and I am reverting back to defaults.
    warning('Argument mispecification. Using defaults.');
end

% Make sure that chanels were specified correctly
switch arg.chanels
    case {'all','All','a'}
        arg.chanels = 'all';
    case {'face','Face','f'}
        arg.chanels = 'face';
    case {'emotions','Emotions','emo','e'}
        arg.chanels = 'emotions';
    case {'au','AU','ActionUnits','aus','AUs'}
        arg.chanels = 'aus';
    otherwise
        warning('Unknown chanels name: %s. Using all chanels.',arg.chanels);
        arg.chanels = 'all';
end


% Create output directory if it doesn't exist yet
if ~exist(arg.outdir, 'dir')
    mkdir(arg.outdir);
end

% Get a list of files with gui when needed
if isempty(arg.files)
    arg.files = fex_lsg;
end

% Now generate the fexPpObj object
PpObj = fexppoc('outdir',arg.outdir,'video',strtrim(arg.files(1,:)),'chanels',arg.chanels);
for ifile = 2:size(arg.files,1)
    PpObj(ifile) = fexppoc('outdir',arg.outdir,...
                           'video',strtrim(arg.files(ifile,:)),...
                           'chanels',arg.chanels);
end


% Save ppo object in the selected output directory
% save(sprintf('%s/PpObj',arg.outdir),'PpObj');


