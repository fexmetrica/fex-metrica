function z = fex_zcoord(w)
%
% FEX_ZCOORD infer z-plan coordinate of a face from face size
%
% SYNTAX:
%
% z = FEX_ZCOORD(w)
%
% FEX_ZCOORD Estimates position on the z plane from the width of the face
% box W and the formulat to compute the hight of a  pyramidal frustum with
% larger base area max(W)^2.
%
% w - width of the box.
% z - z-coordinated w.r.t. ref.
%
%
%
% Copyright (c) - 2014 Filippo Rossi, Institute for Neural Computation,
% University of California, San Diego. email: frossi@ucsd.edu
%
% VERSION: 1.0.1 14-Mar-2014.


a = max(w);                             % side of the larger base
c = .5*(a-w)*csc(pi/4);                 % diagonal for corresponding points
z = .5*sqrt(4*c.^2 - (a-w).^2);         % hight



