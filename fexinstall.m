%% Installation Script for fex-metrica
%
% Run this script to install fex-metrica. There are 3 installation
% options:
%
% 1. Compile fexfacet.cpp from "./fexSDK/facet/cppdir/osx"
% ========================================================
%
% The directory "cppdir/osx" contains a .cpp file which will produce the
% .json file output expected by fex-metrica. Note that in order to compile
% fexfacet.cpp, you need to have a copy of the SDK already installed. A UI
% will ask for the location of Facet SDK.
%
%
% 2. Enter location of compiled fexfacet.cpp, without compiling it
% ========================================================
%
%
%
% 3. Use **fex-metrica** without FACET SDK.
% ========================================================
%
%
%
%
%
% Version -- 04/09/2015.


% ---------------------------------------------------------------
% Select installation type
% ---------------------------------------------------------------

clb = @(popup,callbackdata) popup.Value;
d   = dialog('Position',[300,300,250,150],'Name','Select Installation');
popup = uicontrol('Parent',d,'Style','popup',...
    'Position', [100 70 100,25],'String', ...
    {'Compile (OSX)'; 'Choose Executable'; 'Without Facet'},...
    'Callback',clb);

uiwait(d);





% ---------------------------------------------------------------
% Add path to fex-metrica
% ---------------------------------------------------------------

fprintf('Adding "include" to search path (use fex_init from now on).\n');

init_name = sprintf('%s/fexSDK/include/fex_init.m',pwd);
cml = cellstr(importdata(init_name));
ind = cellfun(@isempty,strfind(cml, 'FEXMETROOT = '));
cml{ind==0} = sprintf('FEXMETROOT = ''%s/fexSDK'';',pwd);
fid = fopen(init_name,'w');
for i = 1:length(cml)
    fprintf(fid,'%s\n',cml{i});
end
fclose(fid);
% Add path name permanently
path(path,fileparts(init_name));
savepath;
fex_init;

% ---------------------------------------------------------------
% Unzip example
% ---------------------------------------------------------------

fprintf('Unpack sample data.\n');
unzip('fexSDK/samples/data.zip','fexSDK/samples');

% ---------------------------------------------------------------
% Make *py script executable
% ---------------------------------------------------------------

system('chmod +x fexSDK/src/util/*py');

% ---------------------------------------------------------------
% Compiled files only for OSX
% ---------------------------------------------------------------

if ~strcmpi(computer, 'maci64');
    warning('Install currently works on Mac only.');
    return
end

fprintf('Select Facet SDK main directory.\n');

% Set up some directories
base = pwd;
target_dir = sprintf('%s/fexSDK/src/facet/cpp/osx',pwd);
cd(target_dir);

% Find FACET SDK main directory
FACET_DIR = uigetdir(pwd,'Select "FacetSDK" Directory');

if FACET_DIR == 0
    warning('No FACET SDK provided.');
    fprintf('\nInstallation completed without SDK.\n');
    cd(base);
    return
end

% Add FACET SDK to CMakeList.txt
cmakefilename = sprintf('%s/CMakeLists.txt',target_dir);
confifilename = sprintf('%s/config.hpp',target_dir);
videotest = sprintf('%s/fexSDK/test/test.mov',base);
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

% Clean Build directory
if exist('build','dir')
    [h,out] = system('rm -r build');
    if h ~= 0
        warning(out);
    end
end

% Build executable files
mkdir('build'); cd('build')
cmd = 'cmake -G "Unix Makefiles" .. && make';
if exist('~/.bashrc','file')
    cmd = sprintf('source ~/.bashrc && %s',cmd);
end
h = system(cmd);
% Return to base
cd(base)


% ---------------------------------------------------------------
% Installation test
% ---------------------------------------------------------------

if h == 0
    fprintf('\nInstallation was successfull. \n\n');
    fprintf('\n\nRUNNING TETS ...\n\n');
    [n,~,h1] = fex_facetproc(videotest,'dir','fexSDK/test');
    if h1{1} == 0
       fex_jsonparser(n{1},'fexSDK/test/test.csv');
    end
    fprintf('\nTests passed succesfully.\n')
    tests.exec = 1;
else
    tests.exec = 0;
    warning('Installation failed.');
end
save('fexSDK/test/fextest_report.mat','tests');



