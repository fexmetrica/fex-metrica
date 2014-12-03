function [kk,nkk] = fex_gauss2(m,s1,s2,d,t)
%
% Create a kernel for a double Gaussian. One Gaussian controlls the
% increasing part of the function (which is assumed to be on the left,while
% the other gaussian controlls the decreasing part. Parameters include:
%
% [m]  :
% [s1] :
% [s2] :
% [d]  :
% [t]  :
%
%
% _________________________________________________________________________
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 12/01/14.

% set up function handles
funl = @(m,s,t) exp(-(min(t-m,0)).^2/(2*s^2));
funr = @(m,s,t) exp(-(max(t-m,0)).^2/(2*s^2));

% Generate kernel. 
kk  = funl(m,s1,t).*funr(m+d,s2,t);
nkk = kk./sum(kk); 



end

