function [ind_fp,mdist_fp,h] = fex_falsepositive(x,y,z,w,alpha,image_size)
%
% 
% fex_falsepositive uses multivariate outliers detection to single out
% potential false positives identified by the face finder code. The
% function uses translatin in the x,y,and z plane, as well as size of the
% face box, and distance of the lower left corner to the mean location of
% the lower left corner. Mahalanobis distance is computed as well as a
% critical value for p < alpha, and potential outliers are identified.
%
% Input:
% -- x: a vector of x coordinate for the lower left corner of the box;
% -- y: a vector of y coordinate for the lower left corner of the box;
% -- z: a vector of z coordinate.
% -- alpha: threshold p value, such that if p_i < alpha, i is considered an
%       outlier.
% -- image_size [optional]: a vector [frame_with,frame_hight]. When this argument is
%       entered, fex_falsepositive outout an image with infor about the
%       outliers.
%
% Output:
% -- ind_fp: index for potential false positive;
% -- Mahalanobis distance for potential outliers;
% -- handle for the image.
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


warning('The PCA approach will be substitute by Kalman smoother.')

% Compute nan index and prepare matrix
face_idx   = double(~isnan(x));
face_info  = [w,x,y,z];
mean_location = nanmean(face_info(:,2:end));
frame_list = find(face_idx == 1);
face_info  = face_info(face_idx == 1,:);

% Compute Euclidean distance from the mean
EDM = sqrt(sum((face_info(:,2:4) - repmat(mean_location,[size(face_info,1),1])).^2,2));
% Using translation in x,y,z plane and distance from the center
face_info(2:end,2:4) = (face_info(1:end-1,2:4) - face_info(2:end,2:4));
% Compute euclidean distance between consecutive frames(this is for the image)
EDT  = sqrt(sum(face_info(2:end,2:4).^2,2))./diff(frame_list);
% Weight translations by numebr of frames
face_info(2:end,2:4) = (face_info(2:end,2:4))./repmat(diff(frame_list),[1,3]);
% Fill in the first observation
face_info(1,2:4) = mean(face_info(2:end,2:4));
face_info = cat(2,face_info,EDM);


% Compute Mahalanobius distance
D = mahal(face_info,face_info);

% Compute critical value for distance
dim = size(face_info);
f   = finv(1-alpha,dim(2),dim(1)-dim(2)-1);
cv  = (dim(2)*(dim(1)-1)^2*f)/(dim(2)*(dim(1)-dim(2)-1) + (prod(dim)*f));

% Return the results
face_idx(face_idx == 1) = D;
ind_fp   = find(face_idx > sqrt(cv));
mdist_fp = face_idx(ind_fp); 


% When you enter the size of the frame, an image is generated.
if nargin == 6
    scrsz = get(0,'ScreenSize');
    h = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.2 scrsz(4)],...
    'Name','False Positive Detection','NumberTitle','off');

    % Drow Average face position, and putative false positive
    subplot(2,2,1),hold on, box on, axis equal
    for i = ind_fp(:)'
        rectangle('Position',[x(i),y(i),w(i),w(i)],'LineStyle','--','edgecolor',[.5,.5,.5]);
    end
    rectangle('Position',nanmean([x,y,w,w]),'LineWidth',2,'LineStyle','--');
    ylim([0,image_size(1)]); xlim([0,image_size(2)]);
    title('Face Box Location','fontsize',16)
    xlabel('Pixels','fontsize',16); ylabel('Pixels','fontsize',16);
    set(gca,'fontsize',14,'LineWidth',2);
    
    % Scatter lower left corner
    subplot(2,2,2)
    title('Lower left corner','fontsize',16)
    scatter3(x,y,z,20,'filled');
    hold all, box on, axis equal
    scatter3(x(ind_fp),y(ind_fp),z(ind_fp),50,'r','filled')
    xlabel('x','fontsize',16); ylabel('y','fontsize',16); zlabel('z','fontsize',16);
    set(gca,'fontsize',14,'LineWidth',2);

    
    % Time-series of distance traveled
    ced = conv(EDT,normpdf((-1.5:1/5:1.5),0,1)'./sum(normpdf((-1.5:1/5:1.5),0,1)),'same');
    subplot(2,2,[3,4]),hold all, box on
    plot(frame_list(2:end),ced,'k','LineWidth',1)
    scatter(ind_fp,ced(ind_fp-1),50,'r','filled');
    title('Distance Traveled','fontsize',16)
    xlabel('Frame','fontsize',16); ylabel('Euclidean Distance','fontsize',16);
    set(gca,'fontsize',14,'LineWidth',2); 
end

