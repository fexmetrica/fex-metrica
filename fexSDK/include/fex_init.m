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



FEXMETROOT = '/home/filippor/Documents/GitHub/fex-metrica/fexSDK';


if isempty(FEXMETROOT) || ~exist(FEXMETROOT,'dir')
    warning('Root directory was not set, use FEXINSTALL.');
else
% This excludes the 'dev' folder
    for j = {'external','include','samples','shared','src','test'};
        addpath(genpath([FEXMETROOT,'/',j{1}]))
    end
    clc
    disp(' ');
    disp('  *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*');
    disp(' ');
    disp(' ');
    disp('  ...............     ...............     ......           ......   ');
    disp('  ................    ................     ......         ......    ');
    disp('  ................    ................      ......       ......     ');
    disp('  ...............     ...............        ......     ......      ');
    disp('  .....               .....                   ......   ......       ');
    disp('  .....               .....                    ...... ......        ');
    disp('  ...............     ...............           ...........         ');
    disp('  ................    ................          ..........          ');
    disp('  ................    ................          ...........         ');
    disp('  ...............     ...............          ...... ......         ');
    disp('  .....               .....                   ......   ......        ');
    disp('  .....               .....                  ......     ......       ');
    disp('  .....               ...............       ......       ......      ');
    disp('  .....               ................     ......         ......     ');
    disp('  .....               ................    ......           ......    ');
    disp('  .....               ...............    ......             ......   ');
    disp(' ');
    disp(' ');
    disp('  *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*');
    fprintf('\n\nWelcome to Fex-Metrica (v1.0.1) ...\n\n');

end

% Add .bashrc search to enviroment
if strcmp(computer,'MACI64')
    setenv('DYLD_LIBRARY_PATH',['/usr/local/bin:/usr/bin:/usr/local/sbin:',getenv('DYLD_LIBRARY_PATH')]);
end
