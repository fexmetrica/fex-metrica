function args = fex_defaults(name)
%
% FEX_DEFAULTS - Defines default arguments for FEXC methods.
%
% USAGE:
%
% ARGS = FEX_DEFAULTS('METHOD_NAME')
%
% ARGS is a structure with fields labeled after the arguments name for the
% FEXC argument specified by METHOD_NAME.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 3-March-2015.


switch lower(name)
    case '...'
        
        
    otherwise
        error('Method not recognized ... ');
end


