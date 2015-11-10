function [ll,b,P] = fex_softmax(X,Y,bnd)



Y = dummyvar(Y);

if ~exist('bnd','var')
    bnd = [0,1];
end


b = fminbnd(@sfx,bnd(1),bnd(2));
[ll,P] = sfx(b);


function [l,P] = sfx(bs)

P = exp(bs*X)./repmat(sum(exp(bs*X),2),[1,size(X,2)]);
l = -1*sum(sum(log(P).*Y,2));    
 
end
        





end