function [x,clx] = fex_facetf(img,chanels)
%
% fex_facetf(img)
% fex_facetf(img,chanels)
% [x,clx] = fex_facetf(...)
%
% Analyze image file provided in "img" using the Emotient SDK. Returns
% value for the required chanels in "x" and column header in "clx." The
% input "img" can be matrix or the path to an image.
%
% The Optional argumnets "chanels" indicate which features to compute,
% between: {"All","Face","AUs", "Emotions",and "Landmarks"}.
%
%_______________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 06/10/14.


% Get arguments in
if nargin == 0
    error('You need to enter the path to an image file.');
elseif nargin == 1
    chanels = 'All';
end

% Prepare input image
id  = sprintf('temp%.0f',now*100);
fid = fopen(sprintf('%s/%s.txt',pwd,id),'w');
if ~ischar(img)
   rm    = 1;
   nfile = sprintf('%s/%s.jpg',pwd,id);
   imwrite(img,nfile,'Quality',100);
else
    rm    = 0;
    % make sure that name is an absolute path
    nfile = img;
end

% Write path to a file
fprintf(fid,'%s',nfile);
fclose(fid);
   
% Get fexfacet bin directory & headers
bin = sprintf('%s/bin',fileparts(which('fexfacet_face.cpp')));
load('fexfacethdr.mat');

switch upper(chanels)
    case {'ALL'}
        cmd = sprintf('%s/fexfacet_full',bin);
        clx = fexfacethdr.all;
    case {'AUS','AU'}
        cmd = sprintf('%s/fexfacet_aus',bin);
        clx = fexfacethdr.aus;
    case {'EMOTIONS','EMOTION'}
        cmd = sprintf('%s/fexfacet_emotions',bin);
        clx = fexfacethdr.emotions;
    case {'FACE','LANDMARKS'}
        cmd = sprintf('%s/fexfacet_face',bin);
        clx = fexfacethdr.face;
    otherwise
        warinig('Unrecognized chanel option: %s. Outputing all.',chanels);
        cmd = sprintf('%s/fexfacet_full',bin);
        clx = fexfacethdr.all;
end

[~,x] = unix(sprintf('source ~/.bashrc && %s < %s/%s.txt',cmd,pwd,id));
x = strsplit(x,'\t');
x = cellfun(@str2double,x(2:end))';

if strcmpi(chanels,'landmarks')
    % change face vector to landmark matrix
    x   = face2landmarks(x);
    clx = fexfacethdr.landmarks;
end

% remove temp file if needed;
unix(sprintf('rm %s/%s.txt',pwd,id));
if rm == 1
    unix(sprintf('rm %s',nfile));
end


function p = face2landmarks(x)
% reshape the face if landmarks are required
%
% drop pose information
x = x(3:end-3);
tp = [x(1:2:end)',x(2:2:end)];

% get face box position
p(1,:) = tp(1,:);
p(2,:) = tp(1,:) + tp(2,:);

% add eyes, pupil and nose points
p = cat(1,p,tp(3:end,:));





