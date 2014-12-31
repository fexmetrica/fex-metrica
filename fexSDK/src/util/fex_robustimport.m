function [data,cmd] = fex_robustimport(file,ExtraName)
%
%
% FEX_ROBUSTIMPORT develops procedures to import datasets.
%
% SYNTAX:
%
% cmd = FEX_ROBUSTIMPORT(FILE)
% cmd = FEX_ROBUSTIMPORT(FILE,EXTRANAME)
%
% FEX_ROBUSTIMPORT tries to import FILE as a Matlab dataset using multiple
% strategies. If the operation succeeds, CMD is an handle to an anonimous
% function that import files such as 'file' as datasets. Otherwise, a gui
% is prompted for the user to write the syntax of the anonymous function to
% use to import the data.
%
% FEX_ROBUSTIMPORT is meant to import three groups of files:
%
%       (1) .txt,.cvs,.xlm(s) files;
%       (2) .mat files;
%       (3) .jason files [NOT IMPLEMENTED YET].
%
%
% ARGUMENTS:
%
% FILE - a string with the path to a file containing the desired data.
% ExtraName - [OPTIONAL], the name of the variable in a .mat file with
%        multiple variables, or the name of the sheet in an Excel
%        (.xls,.xlsx) file.
%
% OUTPUT:
%
% DATA - is the imported dataset;
% CMD -  is an anonymous function, s.t.:
%
%        >> data = cmd(file);
%
%
% See also FEX_JSONPARSER, FEXIMPORTDG.
%
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 7-Aug-2014.


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

