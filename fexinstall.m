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
addpath(genpath(pwd))


% Permanently add fex_init to the search path
% init_name = sprintf('%s/fexSDK/fex_init.m',pwd);
% cml = cellstr(importdata(init_name));
% ind = cellfun(@isempty,strfind(cml, 'FEXROOT='));
% cml{ind==0} = sprintf('FEXROOT= "%s")',pwd);
% fid = fopen(init_name,'w');
% for i = 1:length(cml)
%     fprintf(fid,'%s\n',cml{i});
% end
% fclose(fid);
% status = savepath(init_name);
% if status == 1
%     fex_init;
% else
%     warning('I couldn''t add fex_init to Matlab search path.');
%     addpath(genpath(pwd));
% end
    
% Set up some directories
base = pwd;
target_dir = sprintf('%s/fexSDK/src/facet/cpp/osx',pwd);
cd(target_dir);

% Find FACET SDK main directory
FACET_DIR = uigetdir(pwd,'Select "FacetSDK" Directory');

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
h = system(sprintf('source ~/.bashrc && %s',cmd));

% Return to base
cd(base)

% Make fex_json2dat.py executable
system('chmod +x fexSDK/src/util/*py');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% INSTALLATION TESTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if h == 0
    fprintf('\nInstallation was successfull. \n\n');
    fprintf('\n\nRUNNING TETS ...\n\n');
    [n,~,h1] = fex_facetproc(videotest,'dir','fexSDK/test');
    if h1{1} == 0
       fex_jsonparser(n{1},'fexSDK/test/test.csv');
    end
    fprintf('\nTests passed succesfully.\n')
else
    warning('Installation failed.');
end



