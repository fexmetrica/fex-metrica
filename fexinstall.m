function fexinstall()
%
% FEXINSTALL - Installation function for FexMetrica 1.0.1.
%
% Call this function to install FexMetrica. There are three installation
% options. A UI will ask for the location of Facet SDK. The three options
% are:
%
%
% [1] Compile fexfacet.cpp from "./fexSDK/facet/cppdir/osx": The directory
%     "cppdir/osx" contains a .cpp file which will produce the .json file
%     output expected by fex-metrica.
%
% [2] Enter location of compiled fexfacet.cpp, without compiling it. This
%     requires you to select the executable file which will be used for
%     processing video files with FACET SDK.
%
% [3] Use **fex-metrica** without FACET SDK. This allows most of
%     Fex-Metrica functionalities, but you won't be able to call FACET SDK
%     executable.
%
% NOTE: For option [1] and [2], you need to have a copy of the SDK already
% installed. A UI will ask for the location of Facet SDK. **fex-metrica**
% assumes That you are using FACET SDK v4.0 or later.
%   
%
%
% Copyright (c) - 2014-2015 Filippo Rossi, Institute for Neural
% Computation, University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 09-Apr-2015.


% Initialize FEXINFO
fexinfo = struct('ROOT',sprintf('%s/fexSDK',pwd),'INST',1,'EXEC','');
base = pwd;

% ---------------------------------------------------------------
% Add path to fex-metrica
% ---------------------------------------------------------------

fprintf('Adding "include" to search path (use fex_init from now on).\n');

init_name = sprintf('%s/fexSDK/include/fex_init.m',pwd);
cml = cellstr(importdata(init_name));
ind = cellfun(@isempty,strfind(cml, 'FEXMETROOT = '));
cml{ind==0} = sprintf('FEXMETROOT = ''%s/fexSDK'';',pwd);
fidif = fopen(init_name,'w');
for i = 1:length(cml)
    fprintf(fidif,'%s\n',cml{i});
end
fclose(fidif);

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
% Select installation type
% ---------------------------------------------------------------

% Default: Install without Facet SDK functionality 
inst_type = 1;
if ismember(lower(computer), {'pcwin64','pcwin'});
    warning('Full install currently works on Unix system only.');
else
    d = dialog('Position',[300,300,250,150],'Name','Fex-Metrica: Installation');
    
    txt = uicontrol('Parent',d,'Style','text','Position', [20 80 210 40],...
        'String','Select installation type:');
    
    popup = uicontrol('Parent',d,'Style','popup','Position', [25 50 200,50],...
        'String',{'Compile "fexfacet.cpp"'; 'Choose Executable'; 'Without Facet'},...
        'Callback',@select_callback);
    btn = uicontrol('Parent',d,'String','Select',...
        'Callback','delete(gcf)'); 
    % Wait for answer:
    uiwait(d);
end

fexinfo.INST = inst_type;

% ---------------------------------------------------------------
% Install Fex-Metrica
% ---------------------------------------------------------------

switch fexinfo.INST
    case 1
    % Compiled files in fexSDK/src/facet/cpp/osx (Currently
    % works on OSX only).
        
        fprintf('Installation Method 1:\nSelect Facet SDK main directory.\n');
        % Set up some directories
        fexinfo.EXEC = sprintf('%s/fexSDK/src/facet/cpp/osx/fexfacetexec',pwd);
        save('./fexSDK/include/fexinfo.dat','fexinfo');
        target_dir = sprintf('%s/fexSDK/src/facet/cpp/osx',pwd);
        cd(target_dir);

        % Find FACET SDK main directory
        FACET_DIR = uigetdir(pwd,'Select "FacetSDK" Main Directory');

        if FACET_DIR == 0
            warning('No "FACET SDK" provided.');
            fprintf('\nInstallation completed without FacetSDK functionality.\n');
            fexinfo.INST = 3; fexinfo.EXEC = '';
            cd(base)
            save('./fexSDK/include/fexinfo.dat','fexinfo');
            return
        end
        
        % Add FACET SDK to CMakeList.txt
        costumize_path()
        
        % Clean Build directory
        if exist('build','dir')
            system('rm build/*');
        else
            system('mkdir build');
        end
        
        % Build executable files
        cd('build')
        cmd = 'cmake -G "Unix Makefiles" .. && make';
        if exist('~/.bashrc','file')
            cmd = sprintf('source ~/.bashrc && %s',cmd);
        end
        h = system(cmd);
        
        % Return to base
        cd(base)
        
        % Test Installation: 
        test_install(inst_type,h); 
        
    case 2
    % Select executable from your FACET SDK directory.
        
        fprintf('Installation Method 2:\nSelect Executable File.\n');
        % Select File
        [FexFacetExec, fexfd] = uigetfile('*','Select File:');
        
        % Abort
        if FexFacetExec == 0
            warning('No file provided.\n');
            fprintf('\nInstallation completed without FacetSDK functionality.\n');
            fexinfo.INST = 3; fexinfo.EXEC = '';
            save('./fexSDK/include/fexinfo.dat','fexinfo');
            return
        else
            h = 0;
            fexinfo.EXEC = sprintf('%s%s',fexfd,FexFacetExec);
            save('./fexSDK/include/fexinfo.dat','fexinfo');
        end

        % Test Installation: 
        test_install(inst_type,h); 
                
    otherwise
    % Use Fex-Metrica without FACET SDK
        fexinfo.INST = 3; fexinfo.EXEC = '';
        save('./fexSDK/include/fexinfo.dat','fexinfo');    
        fprintf('\nInstallation completed without FacetSDK functionality.\n');
        return
end


% ---------------------------------------------------------------
% Helper Functions for Installation
% ---------------------------------------------------------------


function select_callback(popup,callbackdata)
%
% SELECT_CALLBACK - Callback for installation select.

inst_type = popup.Value;  

end
 
% ---------------------------------------------------------------

function costumize_path()
%
% COSTUMIZE_PATH - Update CMakeLists.txt and config.hpp in fexSDK/fexSDK/src/facet/cpp/osx.
%

% Update CMakeLists.txt 
cmakefilename = sprintf('%s/CMakeLists.txt',target_dir);
confifilename = sprintf('%s/config.hpp',target_dir);
cml = cellstr(importdata(cmakefilename));
ind = cellfun(@isempty,strfind(cml, 'set(FACETMAIN'));
cml{ind==0} = sprintf('set(FACETMAIN "%s")',FACET_DIR);
fid = fopen(cmakefilename,'w');
for k = 1:length(cml)
    fprintf(fid,'%s\n',cml{k});
end
fclose(fid);

% Update config.hpp with FACET_DIR/facets
con = cellstr(importdata(confifilename));
ind = cellfun(@isempty,strfind(con, '#define FACETSDIR'));
con{ind==0} = sprintf('#define FACETSDIR ("%s/facets")',FACET_DIR);
fid = fopen(confifilename,'w');
for k = 1:length(con)
    fprintf(fid,'%s\n',con{k});
end
fclose(fid);

end
    

% ---------------------------------------------------------------

function test_install(inst_type,h)
%    
% TEST_INSTALL - Test whether FACET SDK works properly. 
%

videotest = sprintf('%s/fexSDK/test/test.mov',base);
if h == 0
    fprintf('\nInstallation was successfull. \n\n');
    fprintf('\n\nRUNNING TETS ...\n\n');
    
    if inst_type == 1 || inst_type == 2
        [n,~,h1] = fex_facetproc(videotest,'dir',sprintf('%s/fexSDK/test',base));
        if h1{1} == 0
            fex_jsonparser(n{1},sprintf('%s/fexSDK/test/test.csv',base));
        end
        fprintf('\nTests passed succesfully.\n')
        tests.exec = 1;
    else
        % DO SOMETHING TO INSTALL Version 2
    end
else
    tests.exec = 0;
    warning('Installation failed.');
end
save(sprintf('%s/fexSDK/test/fextest_report.mat',base),'tests');

end

% ---------------------------------------------------------------

end

