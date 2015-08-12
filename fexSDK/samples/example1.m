%% Example file for fex-metrica
%
% FEXEXAMPLE1 -- example file for fex-metrica v1.0.1
%
%
% In order to run this script, you need to have installed fex-metrica using
% FEXINSTALL.m
%
%
% VERSION: 1.0.1 8/11/2015.

%% Generate a Fexc object
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
% 
% --------------------------------
%
% An alternative way of creating a fexc object is to use "varargin" input
% structure:
% 
% vlist  = fexwsearchg(); % Select the .mov files with the ui;
% dlist  = fexwsearchg(); % Select either .json or .csv files with the ui.
% fexobj = fexc('video',vlist,'data',dlist,'outdir',[pwd '/output']);

%% Object description


% Resulting Object:
% >> fexobj
% 
% fexobj = 
% 
%   3x1 fexc array with properties:
% 
%     name
%     video
%     videoInfo
%     functional
%     structural
%     sentiments
%     time
%     design


% Return some summary information of the videos in the fexobj object;
fexobj.summary

% Display the timeseries
% fexobj(1).show();

%% Visualization
%
% Simple Timeseries Visualization:
%
% Visualization and annotation tools

fexobj(1).viewer();

% Annotation can be access with:
fexobj.get('annotations')


%% Alternative Viewer
%
% Underlying muscles

fexobj(1).viewer('overlay');


%% Outliers detection 
%
% This section of the code is meant to get rid of outliers, and false
% positive -- that is, patches of pixels that are recognized as a face, but
% that do not containa  face. One conservative options is to do it in 2
% steps: using face-box position to exclude face.

fexobj.falsepositive('method','position','threshold',3);
fexobj.get('naninfo')
% fexobj.coregister('fp',true,'threshold',2);

% Note that when you call a method from a FEXC object which contain
% data from multiple videos, the method is applied to all videos, unless
% you use indices (e.g. fexobj(1).coregister).

%% Interpolation
%
% This section includes interpolation & fps modification (up or down sample
% the data);

fexobj.interpolate('fps',30,'rule',15);


%% Temporal filterig
%
% Temporal filters

fexobj.temporalfilt([.5,3],'-showonly');
fexobj.temporalfilt([.5,3]);

% Temporalfilt wraps FIR1. Some safety check for parameter specification
% are also implemented following guidinglines from: M.X.Cohen, "Analyzing
% Neural Time Series Data", MIT Press, 2014.

%% Rectification
%
% The second step in normalization is "rectification," which involve
% setting all facial expressions values lower than a threshold *t* to *t*:

fexobj.rectification(-2.5);


%% Normalization
%
% These methods normalize the timeseries. The method SETBASELINE sets a
% baseline for each timeseries independetly. You can use statistics such as
% 'mean', 'median', 'q75' (i.e. 75th quantile).

fexobj.setbaseline('mean','-global');

% You can call SETBASELINE with the flag '-global' that is: 
% 
% In this case, the statistics selected for normalization (i.e. 'mean') is
% computed over all videos in the FEXC object. By default, the descriptive
% statistics is computed video-wise.

%% Export
% 
% Export the resulting data in a new file.

fexobj.fexport('ui')








