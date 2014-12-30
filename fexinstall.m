%% Installation Script for fex-metrica
%
% Run this script to install fex-metrica. This script compiles the .cpp
% files in fexSDK/facet/cppdir/osx. 



% Installation is developped only for mac
if ~strcmpi(computer, 'maci64');
    warning('Install currently works on Mac only.');
    return
end

% Add path
addpath(genpath(pwd));

% Set up some directories
base = pwd;
target_dir = sprintf('%s/fexSDK/src/facet/cppdir/osx',pwd);
cd(target_dir);

% Change specific lines on CMakeList.txt and config.hpp
cmakefilename = sprintf('%s/CMakeLists.txt',target_dir);
confifilename = sprintf('%s/config.hpp',target_dir);
videotest = sprintf('%s/fexSDK/samples/data/test/test.mov',base);

% Find FACET SDK main directory
FACET_DIR = uigetdir(pwd,'Select "FacetSDK" Directory'); %'/Users/filippo/src/emotient/Dec2014/FACET/FacetSDK';

% Add FACET SDK to CMakeList.txt
cml = cellstr(importdata(cmakefilename));
ind = cellfun(@isempty,strfind(cml, 'set(FACETMAIN'));
cml{ind==0} = sprintf('set(FACETMAIN "%s")',FACET_DIR);
fid = fopen(cmakefilename,'w');
for i = 1:length(cml)
    fprintf(fid,'%s\n',cml{i});
end
fclose(fid);

% Update config.hpp with FACET_DIR/facets
con = cellstr(importdata(confifilename));
ind = cellfun(@isempty,strfind(con, '#define FACETSDIR'));
con{ind==0} = sprintf('#define FACETSDIR ("%s/facets")',FACET_DIR);
fid = fopen(confifilename,'w');
for i = 1:length(con)
    fprintf(fid,'%s\n',con{i});
end
fclose(fid);

% Compile files
try 
   system('make clean');
catch error
    warning(error.message);
end
cmd = 'cmake -G "Unix Makefiles" && make';
h = system(cmd);

if h == 0
    fprintf('\nInstallation was successfull. \n\n');
else
    warning('Installation failed.');
end

% Return to base
cd(base)

% Run test for fexfacetexec
fprintf('\n+++++++++++++++++++++++++++++++\nRUNNING TETS ...\n+++++++++++++++++++++++++++++++\n\n');
[~,h] = fex_facetproc(videotest);



