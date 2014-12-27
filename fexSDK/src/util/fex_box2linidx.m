function [in,out,mask] = fex_box2linidx(data)
%
% [in,out,mask] = fex_box2linidx(data)
% 
% 
               
% Get coordinates
pre   = [data.FaceBoxY-1,data.FaceBoxX-1];
post  = pre + data.FaceBoxW;
post  = [data.FrameRows,data.FrameCols] - post;
post  = max(post,0);
pre(pre<1) = 1;

% Create mask of zeros and ones
mask = ones(data.FaceBoxW);
mask = padarray(mask,pre,'pre');
mask = padarray(mask,post,'post');

% Test size
mask = mask(1:data.FrameRows,1:data.FrameCols);

% Get indices
in  = find(mask == 1);
out = find(mask == 0);