function [data,new_name] = fex_jsonparser(jsonfile,new_name,USE_MATLAB)
% 
%
% FEX_JSONPARSER - parses a JSON file from FACET SDK.
%
% FEX_JSONPARSER is set to import .json files from FACET SDK.
% FEX_JSONPARSER saves the data as .csv files, and return a structure DATA
% with the new data. Since reading a .json file in Matlab is slow,
% FEX_JSONPARSER uses the Python script FEX_JSON2DAT when possible.
%
% SYNTAX:
%
% DATA =  FEX_JSONPARSER(jsonfile)
%
% INPUT:
%
% JSONFILE -  a path to a json file.
% NEW_NAME - path to the new file name.
% USE_MATLAB - boolean value. When true, the JSONFILE is read using Matlab,
%   otherwise FEX_JSON2DAT.PY is used. Default: false.
%
% OUTPUT:
%
% DATA - a structure with data from the .json file.
%
% See also FEXC, FEX_IMPUTIL, FEX_JSON2DAT.PY.
%
%
%
% Copyright (c) - 2014 - 2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 10-Jan-2015.


data = [];

if ~exist('jsonfile','var')
    error('Not enough input argument.')
elseif ~exist(jsonfile,'file')
    error('I couldnt find the .json file.')
end

% Set the new name:
if ~exist('new_name','var')
    [p,n] = fileparts(jsonfile);
else
    [p,n] = fileparts(new_name);
end
% Add directory
if isempty(p)
    p = pwd;
end
% Throw an error when the target directory does not exist
if ~exist(p,'dir')
    error('Target directory not found.');
end

% Generate new name
new_name = sprintf('%s/%s.csv',p,n);

% Find Python script
JSON_EXEC = which('fex_json2dat.py');
if isempty(JSON_EXEC)
    USE_MATLAB = true;
    warning('fex_json2dat.py not found. Using Matlab instead');
end

% Set USE_MATLAB flag
if ~exist('USE_MATLAB','var')
    USE_MATLAB = false;
end

% Import the .json file
if USE_MATLAB
% Slow MATLAB based parsing
    data = matjsonpars(jsonfile,new_name);
else
% Use Python script
    cmd = sprintf('python %s "%s" "%s" -nohdr',JSON_EXEC,jsonfile,new_name);
    [h,out] = system(cmd);  
    if h ~= 0 
        w_mess = sprintf('FEX_JSON2DAT.PY failed with error:\n\n');
        warning('%s%s\n\nSet: USE_MATLAB = true.',w_mess,out);
    else
        warning('off','stats:dataset:ModifiedVarnames')
        % Fixme: wired incompatibility with np.savetxt when it has more
        % than the required arguments. This may be specific to my
        % installation and conflicting copies of python.
        % data = dataset2struct(dataset('File',new_name,'delimiter',','),'AsScalar',true);
        datat = importdata(new_name);
        [hdr,hdrc]  = get_hdr();
        fid = fopen(new_name,'w');
        fprintf(fid,'%s\r\n',hdr);    
        fclose(fid);
        dlmwrite(new_name,datat,'-append','delimiter',',');
        warning('on','stats:dataset:ModifiedVarnames')
        for i = 1:length(hdrc)
            data.(hdrc{i}) = datat(:,i);
        end
    end
end
    
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function data = matjsonpars(jsonfile,new_name)
%
% MATJSONPARS - Heloper for parsing of JSON files. 
%
% Internal use only.

% Set Up Variables Names
aus = [1,2,4:7,10,12,14,15,17,18,20,23:26,28];
aus = strsplit(sprintf(repmat('AU%d\n',[1,length(aus)]),aus),'\n');
names1 = {'timestamp','isMale','height','width','x','y'};
names1 = [names1,'anger','contempt','disgust','fear','joy','sadness','surprise'];
names1 = [aus(1:end-1),names1,'pitch','roll','yaw'];
% Add Landmarks Names - this is done separately because of the x - y fields.
names2 = {'center_mouth','left_eye_lateral','left_eye_medial',...
    'left_eye_pupil','nose_tip','right_eye_lateral','right_eye_medial',...
    'right_eye_pupil'};

% Set Up Parsing Shortcut
parsustil = @(s) str2double(strsplit(s,':'));

% Import the .json file as a string
% Fixme: on 2013b this would work. Instead I have to use fopen logic here.
% jstring = importdata(jsonfile);
jstring = {};
fid = fopen(jsonfile);
tline = fgetl(fid);
while ischar(tline)
    jstring = cat(1,jstring,{tline});
    tline = fgetl(fid);
end
fclose(fid);

% Initialize data
data = [];
% Loop across argument names1
for n = names1
% fprintf('Importing feature: %s.\n',n{1});
ind = cellfun(@isempty,strfind(jstring,sprintf('"%s"',n{1})));
p  = jstring(ind == 0); 
if ~isempty(p)
    A = cell2mat(cellfun(parsustil,cellstr(p),'UniformOutput',0));
    data.(n{1}) = A(:,2);
end
end

% Import facebox & remove with & and hight
data.FaceBoxW = data.width(2:end);
data.FaceBoxH = data.height(2:end);
data.FrameRows = repmat(data.width(1),[length(data.FaceBoxW),1]);
data.FrameCols = repmat(data.height(1),[length(data.FaceBoxW),1]);

% Reshape the the landmark data
Lx = reshape(data.x,length(data.FaceBoxW),9);
Ly = reshape(data.y,length(data.FaceBoxW),9);
% Add x and y face box info
data.FaceBoxX = Lx(:,1);
data.FaceBoxY = Ly(:,1);
for j = 1:8
    data.(sprintf('%s_x',names2{j})) = Lx(:,j+1);
    data.(sprintf('%s_y',names2{j})) = Ly(:,j+1);
end

% Clean obsolete fields
data = rmfield(data,{'width','height','x','y'});
X = [];
% Save the dataset to [new_name].csv file
fid = fopen(new_name,'w');
hdr_c = fieldnames(data)';
hdr = hdr_c{1};
for i = 2:length(hdr_c)
    hdr = sprintf('%s,%s',hdr,hdr_c{i});
    X = cat(2,X,data.(hdr_c{i}));
end
fprintf(fid,'%s\r\n',hdr);    
fclose(fid);
dlmwrite(new_name,X,'-append','delimiter',',');

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function [hdr,hdr_c] = get_hdr()
%
% GET HDR - Helper function for header information

hdr_c = {'FrameRows','FrameCols','timestamp','FaceBoxH','FaceBoxW','FaceBoxX',...
'FaceBoxY','isMale','AU1','AU2','AU4','AU5','AU6','AU7','AU9','AU10','AU12',...
'AU14','AU15','AU17','AU18','AU20','AU23','AU24','AU25','AU26','AU28','anger',...
'contempt','disgust','fear','joy','sadness','surprise','confusion',...
'frustration','positive','negative','neutral','center_mouth_x','center_mouth_y',...
'left_eye_lateral_x','left_eye_lateral_y','left_eye_medial_x','left_eye_medial_y',...
'left_eye_pupil_x','left_eye_pupil_y','nose_tip_x','nose_tip_y','right_eye_lateral_x',...
'right_eye_lateral_y','right_eye_medial_x','right_eye_medial_y','right_eye_pupil_x',...
'right_eye_pupil_y','pitch','roll','yaw','track_id'};

hdr = hdr_c{1};
for i = 2:length(hdr_c)
    hdr = sprintf('%s,%s',hdr,hdr_c{i});
end
