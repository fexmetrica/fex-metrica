function fexObj = fex_imputil(filetype,filepath,moviepath)
%
% FEX_IMPUTIL Import utility function.
%
% SYNTAX:
% fexObj = FEX_IMPUTIL(filetype,filepath);
% fexObj = FEX_IMPUTIL(filetype,filepath,moviepath);
%
% Import utility function. This converts a file to a fexObject. The
% required arguments are:
%
% (1) filetype: a string specifing the format of the original file. For now,
%     the only version allowed is 'AZFile'**.
% (2) filepath: this can be a string with the path to a file. Alternatively
%     is a char s.t. size(filepath,1) is the number of files entered.
%
% Optionally, you can enter:
%
% (3) moviepath: a string with the path to a movie or a char organized in
%     the same way filepath is. If size(moviepath,1) is the same of
%     size(filepath,1), we assume that filpath(i,:) and moviepath(i,:) are
%     associated. Otherwise, the function tries to identify which movie
%     correspond to which file. In order for this to work the name of a
%     file and the name of a movie must be the same:
%
%         file  = "[path_i]/NAME.csv"; 
%         movie = "[path_j]/NAME.avi".
%
% You can use FEXWSEARCHG.m to run a UI that generates "filepath" and
% "moviepath."
%
% ** This fornat is specific to the analysis I run for a project. The
% headers used are stored in util/eviewerhdrs.xlsx.
%
% Example:
% 
% > csv_list   = fexwsearchg();
% > movie_list = fexwsearchg();
% > fexObj = fex_imputil('AZFile',csv_list,movie_list);
%
%
% See also FEXC, FEXWSEARCHG.
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 12-Dec-2014.


if nargin == 0 || nargin > 3
    error('Wrong argument of input argument.');
elseif nargin == 2
    moviepath = '';
end

% Check that all filepaths exist. Return a warning otherwise.
flag = zeros(size(filepath,1),1);
for i = 1:size(filepath,1)
    if ~exist(deblank(filepath(i,:)),'file')
        flag(i) = 1;
    end
end
if sum(flag) > 0 && sum(flag) < length(flag)
    warning('The following files do not exist:\n');
    disp(filepath(flag == 1,:));
    filepath  = filepath(flag == 0,:);
elseif sum(flag) == length(flag)
    error('None of the files provided seem to exist.')
end

% Handle the movie argumen
if isempty(moviepath)
    moviepath = cellstr(repmat(' ',[size(filepath,1),1]));
elseif size(moviepath,1) == length(flag)
    moviepath = cellstr(moviepath(flag == 0,:));
else
% this is the case when only a subset of movies is provided and we need to
% match them with the corresponding files. To do so, we are assuming that
% they have the same name.
    cell_paths = cellstr(filepath);
    cell_paths = cell_paths(cellfun(@isempty,cell_paths) == 0);
    mflag = zeros(size(moviepath,1),1);
    for i = 1:size(moviepath,1)
        [~,fname] = fileparts(deblank(moviepath(i,:)));
        fun = @(f) ~isempty(strfind(f,fname));
        mflag(i) = find(cellfun(fun,cell_paths,'UniformOutput',1),1,'first');
    end
    nmoviepath = cellstr(repmat(' ',[size(filepath,1),1]));
    nmoviepath(mflag(mflag~=0)) = cellstr(moviepath(mflag~=0,:));
    moviepath = nmoviepath;
end


% make space for fexc object
fexObj = [];

switch lower(filetype)
    case 'azfile'
        for i = 1:size(filepath,1)
            warning('off','MATLAB:codetools:ModifiedVarnames');
            temp = dataset('File',deblank(filepath(i,:)),'Delimiter',',');
            warning('on','MATLAB:codetools:ModifiedVarnames');
            fexObj = cat(1,fexObj,convutilint(temp,deblank(moviepath{i})));
            fprintf('Created fexObject %d/%d.\n',i,size(filepath,1));
        end
    case 'ffile'
        for i = 1:size(filepath,1)
            warning('off','MATLAB:codetools:ModifiedVarnames');
            temp = dataset('File',deblank(filepath(i,:)),'Delimiter','\t');
            if ismember('Frame_N',temp.Properties.VarNames);
                temp.FrameNumber = temp(:,{'Frame_N'});
            end 
            mov = deblank(moviepath{i});
            fexObj = cat(1,fexObj,fexc('data',temp,'TimeStamps',temp.Time,'video',mov));
            fprintf('Created fexObject %d/%d.\n',i,size(filepath,1));
        end
    case 'json'
        for i = 1:size(filepath)
            data = fex_jsonparser(deblank(filepath(i,:))); 
            ds = struct2dataset(data);
            [~,ind] = sort(ds.timestamp);
            fexObj = cat(1,fexObj,fexc('data',ds(ind,:),'video',eblank(moviepath{i}),'TimeStamps',ds.timestamp));
        end
    otherwise
    % Right now, only AZFile is supported
        error('File type not supported.');     
end
        
        

% Utility function to do the conversion
function obj = convutilint(initdata,mov)
% 
% makes the actual conversion. Besides changes in naming, there are two
% aspects that need to be fixed when using this format. First, the size of
% the frame is not provided. Second, the system may find mulriple frame in
% the same face, however since a Frame Number is not provided we need to
% inferr where these frames are located from the timestamps difference. I
% am assuming that frames separeted by 10e-4 sec are in fact the same
% frame. fexc constructor takes care of both issues.

if ~exist('mov','var')
    mov = '';
end

% This file contains the headers
hdr = dataset('XLSFile','eviewerhdrs.xlsx');

% Reorder dataset across time direction
[time,ind1] = sort(initdata.timestamp,'ascend');
track_id   = initdata.track_id(ind1);

% Select variables & convert zeros to nans
ind2       = cellfun(@isempty,hdr.Fexchdr) == 0;
initdata   = double(initdata(ind1,ind2));
initdata(repmat(track_id == -1,[1,size(initdata,2)])) = nan;

% Get functional and structural images
datatype = hdr.FeaturesClass(ind2)';
newhdr   = hdr.Fexchdr(ind2);
idhdr = ismember(datatype,{'au','emotions','sentiment','face','landmarks','pose'})';
newdata = mat2dataset(initdata(:,idhdr),'VarNames',newhdr(idhdr));
track_id = mat2dataset(track_id,'VarName',{'track_id'});

% Generate the object
obj = fexc('data',newdata,'TimeStamps',time,'video',mov,'diagnostics',track_id);



