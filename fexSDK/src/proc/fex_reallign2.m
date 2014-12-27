function [Y,T,M,R] = fex_reallign(XX,nsteps)
%
% reallignment of image to mean

if nargin == 1
    nsteps = 2;
end

R = nan(size(XX,1),1);
T = struct('T',nan,'b',nan,'c',nan);

LL = getlandmarks(XX);
M = nanmean(LL,3);
Y = nan(size(XX,1),numel(M));

for i = 1:size(LL,3)
    if ~isnan(LL(1,1,i))       
        [d,Z,t]= procrustes(M,LL(:,:,i),'scaling',true,'reflection',false);
        R(i)   = d;
        T(i)   = t;
        Y(i,:) = reshape(Z',1,numel(Z));
    end
end

R(~isnan(R)) = zscore(R(~isnan(R)));


function LL = getlandmarks(XX)

lnames = {'FaceBoxX','FaceBoxY','FaceBoxW','FaceBoxH','left_eye_lateral_x','left_eye_lateral_y','left_eye_pupil_x',...
    'left_eye_pupil_y','left_eye_medial_x','left_eye_medial_y','right_eye_medial_x','right_eye_medial_y',...
    'right_eye_pupil_x','right_eye_pupil_y','right_eye_lateral_x','right_eye_lateral_y','nose_tip_x','nose_tip_y'};

L  = double(XX(:,ismember(XX.Properties.VarNames,lnames)));
LL = [];
for i = 1:size(XX,1)
    LL = cat(3,LL,[L(i,1:2:end)',L(i,2:2:end)']);
end
LL(2,:,:) = LL(1,:,:) + LL(2,:,:);


