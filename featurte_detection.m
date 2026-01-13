function [des_1,des_2] = featurte_detection (im1,im2,patch_size,s,o)
%% scale invariance
% sigma=1.6;%最底层高斯金字塔的尺度
% dog_center_layer=3;%定义了DOG金字塔每组中间层数，默认是3
% contrast_threshold_1=0.03;%Contrast threshold
% contrast_threshold_2=0.03;%Contrast threshold
% edge_threshold=10;%Edge threshold
% is_double_size=false;%expand image or not
% change_form='affine';%change mode,'perspective','affine','similarity'
% is_sift_or_log='GLOH-like';%Type of descriptor,it can be 'GLOH-like','SIFT'
% scale 是尺度空间的参数，不参与描述过程

%% phase congruency
[m1,M1,~,~,~,eo1,~] = phasecong3(im1,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);
[m2,M2,~,~,~,eo2,~] = phasecong3(im2,s,o,3,'mult',1.6,'sigmaOnf',0.75,'g', 3, 'k',1);

a=max(m1(:)); b=min(m1(:)); m1=(m1-b)/(a-b);
a=max(m2(:)); b=min(m2(:)); m2=(m2-b)/(a-b);

a=max(M1(:)); b=min(M1(:)); M1=(M1-b)/(a-b);
a=max(M2(:)); b=min(M2(:)); M2=(M2-b)/(a-b);

% FAST detector on the maximum moment maps to extract edge feature points.
M1_point = detectFASTFeatures(abs(M1+m1),'MinContrast',0.05);
M2_point = detectFASTFeatures(abs(M2+m2),'MinContrast',0.05);
M1_point=M1_point.selectStrongest(2500);
M2_point=M2_point.selectStrongest(2500);
M1_kps=M1_point.Location;
M2_kps=M2_point.Location;

% showpoints detected
cor1_x=M1_kps(:,1);cor1_y=M1_kps(:,2);
button1=figure;colormap('gray');imagesc(im1);
title(['sar image',num2str(size(cor1_x,1)),'points']);hold on;
scatter(cor1_x,cor1_y,'y');hold on;
cor2_x=M2_kps(:,1);cor2_y=M2_kps(:,2);
button2=figure;colormap('gray');imagesc(im2);
title(['optical image',num2str(size(cor2_x,1)),'points']);hold on;
scatter(cor2_x,cor2_y,'y');hold on;

%selc=0;光学图； selc=1;SAR图像
% [des_1] = feature_description (im1,M1_kps,eo1,patch_size,s,o,1);%SAR——RIFT
% [des_2] = feature_description (im2,M2_kps,eo2,patch_size,s,o,0);%光学

% [des_1,C_MIMALL1] = local_rotaion_feature_description (im1,M1_kps,eo1,patch_size,s,o);
% [des_2,C_MIMALL2] = local_rotaion_feature_description (im2,M2_kps,eo2,patch_size,s,o);

% [des_1,DO1] = global_rotaion_feature_description (im1,M1_kps,eo1,patch_size,s,o);
% [des_2,DO2] = global_rotaion_feature_description (im2,M2_kps,eo2,patch_size,s,o);

des_1 = descriptor_circleshift(im1,M1_kps,eo1,patch_size,s,o);
des_2 = descriptor_circleshift(im2,M2_kps,eo2,patch_size,s,o);
end