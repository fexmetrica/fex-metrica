function z = fex_zcoord(w)

% Estimate position on the z plane from the width of the face box and the
% formulat to compute the hight of a  pyramidal frustum with larger base
% area max(w)^2.
%
% Input:
%   -- w: width of the box.
%
% Outout:
%   -- z: z-coordinated w.r.t. ref.
%
% _________________________________________________________________________
%
%
% Copiright: Filippo Rossi, Institute for Neural Computation, University
% of California, San Diego.
%
% email: frossi@ucsd.edu
%
% Version: 03/14/14.


a = max(w);                             % side of the larger base
c = .5*(a-w)*csc(pi/4);                 % diagonal for corresponding points
z = .5*sqrt(4*c.^2 - (a-w).^2);         % hight



