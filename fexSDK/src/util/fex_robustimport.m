function [data,cmd] = fex_robustimport(file,ExtraName)
%
% cmd = fex_robustimport(file)
%
% fex_robustimport.m tries to import "file" as a dataset using multiple
% strategy. If the operation succeed, cmd is an handle to an anonimous
% function that import as dataset files such as 'file.' Otherwise, a gui is
% prompted for the user to write the syntax of the anonymous function to
% use to import the data.
%
% The function handles:
%
%       (1) .txt,.cvs,.xlm(s) files;
%       (2) .mat files;
%       (3) .jason files.
%
% *************************************************************************
%
% Input:
%
%   "file" is the path to a file containing the desired data.
%   "ExtraName" [OPTIONAL], the name of the variable in a .mat file with
%           multiple variables, or the name of the sheet in an Excel
%           (.xls,.xlsx) file.
%
% Output:
%
%   "data" is the imported dataset;
%   "cmd" is an anonymous function, s.t.:
%
%   >> data = cmd(file);
%
%__________________________________________________________________________
% 
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 08/07/14.


% Get file when not provided
if nargin == 0
    [f,p] = uigetfile('*','DialogTitle','Select File'); 
    file  = sprintf('%s%s',p,f);
end
    
% Add optional argument
if ~exist('ExtraName','var')
    ExtraName  = '';
end

% Send error when file does not exist.
if ~exist(file,'file')
    error('The file provided does not exist.');
end

% Get file kind
[~,~,fkind] = fileparts(file);

% Start the actual import procedure
switch fkind
    case 'jason'
    % Parse .jason file.
        [data,cmd] = parsejason(file);
    case 'mat'
        wsm    = load(file);
        cls    = datasetfun(@class,wsm,'UniformOutput',false);
        fnames = fieldnames(cls);
        if ismember('dataset',cls)
            data = wsm.(fnames{ismember('dataset',cls)});
        else
           data = [];
           cmd  = '';
        end
    case {'xls','xlsx'}
    % Excel file or workbook    
        if ~isempty(ExtraName)
            [val,txt] = xlsread(file,'sheet',ExtraName);
        else
            [val,txt] = xlsread(file);
        end
        [data,cmd] = parsexls(val,txt);   
    case {'txt','csv'}
        data = dataset('File',file);        
    otherwise
        fprintf('Allowed extensions: mat,jason,xls(x),txt,csv.\n');
        warning('Exiting without actions.');
        return
end
        
    
% some concluding stuff



end



function [data,cmd] = parsejason(file)

    fprintf('file: %s.\n',file);
    warning('Json parser not implemented yet.');
    data = [];
    cmd  = '';
end

function [data,cmd] = parsexls(val,txt)

    fprintf('file: xls.\n');
    warning('xls(x) parser not implemented yet.');
    data = val;
    cmd  = txt;
end

