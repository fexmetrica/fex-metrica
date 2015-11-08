function model_str = fex_mlstring(varn,dep,randef)



% Get model matrix
if ~iscell(varn)
    try
        varn = get_fname(varn);
    catch
        varn = {varn};
    end
end

% Get string
model_str = sprintf('%s ~ 1 ',dep);
for k = varn(:)'
    model_str = sprintf('%s + %s ',model_str,k{1});
end

% Add rf
if exist('randef','var')
    model_str = sprintf('%s + (1|%s)',model_str,randef);
end
    


function n = get_fname(type)

if ~exist('type','var')
    type = 'all';
end

% Fixme: use dictionary instead.
c = dataset('File','fexchannels.txt');
switch lower(type)
    case {'primary','p','pe'}
      target = 'emo1';
    case {'secondary','se','cf'}
      target = 'emo2';
    case {'emotion','emotions','e'}
      target = {'emo1','emo2'};
    case {'aus','au','a'}
      target = 'au';
    case {'face','f'}
      target = 'face';
    case {'landmarks','landmark','land','l'}
       target = 'land';
    case {'sentiments','sentiment','s','sent'}
       target = 'sent1';
    case {'pose','ps'}
       target = 'pose';
    case 'all'
       target = unique(c.Class);
    otherwise
       warning('TYPE not recognized: %s.', type);
end
   
n = deblank(c.Name(ismember(c.Class,target)));