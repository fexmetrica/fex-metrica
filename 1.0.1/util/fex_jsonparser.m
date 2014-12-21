function data = fex_jsonparser(jsonfile)
% 
%
% FEX_JSONPARSER parse JSON file from FACET SDK.
%
% SYNTAX:
%
% This json parser is set to import json files from FACET SDK, and saves
% them as csv files.
%
% file FEX_JSONPARSER(jsonfile)
%
% - JSONFILE: a path to a json file.
% - DATA: a structure with the JSON data.
%
% See also FEXC, FEX_IMPUTIL.
%
%
% NOTE: this is very slow, and needs to be hardcoded instead.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 18-Dec-2014.


% Prapare all the names for the variables you are looking for:
aus = [1,2,4:7,10,12,14,15,17,18,20,23:26,28];
aus = strsplit(sprintf(repmat('AU%d\n',[1,length(aus)]),aus),'\n');
names1 = {'timestamp','isMale','anger','confusion','contempt','disgust','fear','frustration',...
    'joy','negative','neutral','positive','sadness','surprise'};
names1 = [names1,aus(1:end-1),'pitch','roll','yaw','width','height','x','y'];


% Landmarks and locations: there are 9 "x" and 9 "y" entries per frame,
% which needs to be reshaped.
names2 = {'center_mouth','left_eye_lateral','left_eye_medial',...
    'left_eye_pupil','nose_tip','right_eye_lateral','right_eye_medial',...
    'right_eye_pupil'};


% Set some parsing utility
parsustil = @(s) str2double(strsplit(s,':'));

% Import the json file
jstring = importdata(jsonfile);
% Initialize data
data = [];
for n = names1
% Loop across argument names1
    fprintf('Importing feature: %s.\n',n{1});
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


end

