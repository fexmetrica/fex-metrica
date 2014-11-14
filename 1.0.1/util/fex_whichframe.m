function fid = fex_whichframe(ts,varargin)
% 
% fid = fex_whichframe(ts)
% fid = fex_whichframe(ts,'VarArgName1',VarArgVal1, ...)
%
% This function tries to recover indices for frames from timestamps and
% further information. This function applies to the a very specific case:
%
% 1. The output from emotient contains timestamps;
% 2. The row of the dataset only contains frames where a face was found;
% 3. You don't have indices that maps rows onto frames in a video.
%
% Required argument:
%
%  "ts": a vector with timestamps for each row of the data matrix (i.e.
%        each frame where a face was found.
%
% Optional arguments:
%
%   "fps"
%   "duration"
%   "nframes"