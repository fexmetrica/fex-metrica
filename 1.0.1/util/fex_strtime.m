function str = fex_strtime(sec)
%
% str = fex_strtime(sec)
%
% "sec" is a float indicating time elappsed in seconds.
% The function converts sec into a string formatted as
% follow:
%
%   HH:MM:SS:MT
%
% HH = hours, MM = minutes, SS = seconds and MT = microtime resolution.
% This format is used in ffmpeg to identify time in a video.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 06/17/14.

str = sprintf('%.2d:%.2d:%.2d:%.2d',...
               floor(sec/3600),...                 % hours
               floor(mod(sec/60,60)),...           % Minutes
               floor(mod(sec,60)),...              % Seconds
               round((sec - floor(sec))*100));     % Microtime resolution
end

