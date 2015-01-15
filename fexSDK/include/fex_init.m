function fex_init()
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



FEXMETROOT = '';


if isempty(FEXMETROOT) || ~exist(FEXMETROOT,'dir')
    warning('Root directory was not set, use FEXINSTALL.');
else
    addpath(genpath(FEXMETROOT))
    fprintf('\n\nWelcome to Fex-Metrica (v1.0.1) ...\n\n\n');
end
