%% Example file for fex-metrica
%
% FEXEXAMPLE1 -- example file for fex-metrica v1.0.1
%
%
% In order to run this script, you need to have installed fex-metrica using
% FEXINSTALL.m
%
%
% VERSION: 1.0.1 14-Jan-2015.

%% 1. Generate a Fexc object
%
% Fexc object is the main class used for the analysis, and can be generated
% in several ways. The easiest way is to use the ui option. The UI let you
% select:
% 
% 1. Video files;
% 2. Files with the facial expressions timeseries;
% 3. Outout directory.

fex_init;
fexobj = fexc('ui');

% Calling FEX_INIT adds fex-metrica to Matlab search path.
%
% If you have the movies, but not the files with facial expressions, the UI
% gives you the option to analyze the data. For this option to work, you
% need to have a local copy of the Facet SDK installed.