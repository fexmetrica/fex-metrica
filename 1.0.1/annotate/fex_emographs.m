function hand = fex_emographs(varargin)
%
% Usage 
% hand = fex_emographs(data)
% hand = fex_emographs('interactive')
% hand = fex_emographs('VarArgName1',VarArgVal1, ... )
%
%
% This function reads cvs files with the Emotient SDK readings or a fexc
% Object, and produces graphs with the timeseries for emotions. If time
% stamps are provided, the timeseries are interpolated to have a fixed fps.
% The time series displayed are all rectified (default lower boubd: -1) and
% shifted to have only positive values. When required, time series can be
% smoothed.
%
% Optional Arguments:
%
% 'data':   This provides the data to be plotted. The argument can be:
%           
%     (1) A string with the path to a .csv, .txt or .mat file. NOTE that
%         .mat files can only contain one (or multiple) fexc objects.
%     (2) A cell of string for paths as described above.
%     (3) A wilde card used to locate the file, e.g.: '/some/dir/*.txt'.
%
%     If you input <data> as first argument, you don't need to preceed it
%     with the argument string identifier 'data,' otherwise you do.


%
% 'type'
% 'fps'
% 'rectification'
% 'features'
% 'smoothing'
% 'output'
% 
%__________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 10/30/14.


if isempty(varargin)
    % lunch the gui
    fprintf('Gui version for arguments');
    varargin = fexemographsg();
end
args = handle_VarArg(varargin);

for i = 1:length(args.data)
    fprintf('Creating image %d/%d',i,length(args.data)); 
    ts = tslightpreproc(args,i);
    h  = make_image(ts,args);
    print(h,'-dpdf','-r450',args.output{i});
end

    
    

% ------------------- Helper function for time series processing ----------
function ts = tslightpreproc(args,k)
% 
% Apply few preprocessing operation to emotions timeseries

    


% ------------------- Generate the required image image -------------------
function h = make_image(ts,args)
% 
% Create the current image.





% ------------------- Helper function for argument reading ----------------
function argsOut = handle_VarArg(argsIn)
% 
% Read variable arguments in.



    
    
    


% ------------------- Helper function for data argument reading -----------
function data = handle_data(data_in)
% 
% Read data argument
    