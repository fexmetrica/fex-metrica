function args = fex_varargutil(caller,init_args)
%
% FEX_VARARGUTIL - Helper function to read variable arguments from FEXC
% methods.
%
% Usage:
%
% ARG = FEX_VARARGUTIL(caller);
% ARG = FEX_VARARGUTIL(caller,init_args);
%
%
% CALLER is the method calling FEX_VARARGUTIL, for example 'normalize' and
% it is required. When FEX_VARARGUTIL is used only with the CALLER
% argument. The default for that methods are used.
%
% INIT_ARG is the original VARARGIN input argument for that function.
%
% The output ARGS is a structure with the argument of the method in
% question.
%
% NOTE this function is for internal usage.
%
%
% See also FEXC, FEX_GETDEFAULTS.m
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 07-Sept-2015.
%
% FIXME: Currently only implemented for: NORMALIZE, SETBASELINE.


% One argument is needed
% ======================
if ~exist('caller','var')
    error('Caller argument is required');
end

% Extract default for the selected caller method;
% ======================
defaults = importdata('fexdefaults.mat');
try
    defaults = defaults.(lower(caller));
catch messageId
    error(messageId.message);
end

% No extra arguments provided: use defaulst
% ========================
if ~exist('init_args','var')
    args = defaults.defaults;
    return
end


% Select PIVOTAL substructure
% ==========================
if ~isempty(defaults.has_pivot)
    ind = 1;
    if mod(init_args,2) == 0
        ind = 2;
    end
    defaults.(defaults.dict(lawer(init_args{ind})));
    defaults.(defaults.has_pivot) = lawer(init_args{ind});
end

% Assign values:
% ===========================
names = fieldnames(defaults);
if length(init_args) > ind;
    init_names = lower(init_args(ind+1:2:end));
    init_vals  = init_args(ind+2:2:end);
    for k = 1:length(init_names)
        if ismember(init_names{k},names)
            args.(init_names{k}) = init_vals(k);
        end
    end
end
    
% FIXME: Check that proper arguments were specified.






