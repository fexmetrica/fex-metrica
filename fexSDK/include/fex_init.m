function varargout = fex_init()
%
% FEX_INIT - initialization function for FEX-METRICA.
%
% This file is updated when FEXINSTALL is run, and it is added to the
% permament matlab search path.
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 11-Jan-2015.



FEXMETROOT = '/Users/filippo/Documents/code/GitHub/fex-metrica/fexSDK';


if isempty(FEXMETROOT) || ~exist(FEXMETROOT,'dir')
    warning('Root directory was not set, use FEXINSTALL.');
    s = 0;
else
    addpath(genpath(FEXMETROOT))
    s = 1;
    fprintf('\n\nWelcome to Fex-Metrica (v1.0.1) ...\n\n\n');
end

if nargout > 0
    varargout{1} = s;
end