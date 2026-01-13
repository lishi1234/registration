function [des,C_MIMALL] = local_rotaion_feature_description (im,kps,eo,patch_size,s,o)
[yim,xim,~] = size(im);
KPS=kps';
%% R2FD2 对MIM的关键点局部进行重排对齐
CS = zeros(yim, xim, o); %convolution sequence
for j=1:o
    for i=1:s
        CS(:,:,j)=CS(:,:,j)+abs(eo{i,j});
    end
end
[~, MIM] = max(CS,[],3); % MIM maximum index map

%%  description
des = zeros(36*o, size(KPS,2)); %descriptor (size: 6×6×o)
kps_to_ignore = zeros(1,size(KPS,2));
C_MIMALL = cell(1,size(KPS,2));

for k = 1: size(KPS,2)
    x = round(KPS(1, k));
    y = round(KPS(2, k));
    
    x1 = max(1,x-floor(patch_size/2));
    y1 = max(1,y-floor(patch_size/2));
    x2 = min(x+floor(patch_size/2),size(im,2));
    y2 = min(y+floor(patch_size/2),size(im,1));
    
    if y2-y1 ~= patch_size || x2-x1 ~= patch_size
        kps_to_ignore(i)=1;
        continue;
    end
%  %% generate new local MIM_
    MIM_vector = MIM(y1:y2,x1:x2);
    C_MIM = mode(MIM_vector(:));
    C_MIMALL{k} = C_MIM;
    DO = (C_MIM-1)* (360/o);%0~180 ,180,360存在不变性
    MIM_new = MIM_vector - C_MIM + 1;
    % 处理边界情况（索引小于1）
    MIM_new(MIM_new < 1) = MIM_new(MIM_new < 1) + o;
    RMIM_local = MIM_new;
    %对RMIM进行旋转，可以用于计算置信空间
%     RMIM_local = generate_RMIM_from_MIM(MIM_vector, o,DO, C_MIM, model);
    figure;
    imshow(RMIM_local,[]);
%     title("MIMnew")             
    patch = RMIM_local; %local MIM patch for feature description
%     patch = MIM(y1:y2,x1:x2);
    [ys,xs]=size(patch);
    
    ns=6;
    RIFT_des = zeros(ns,ns,o);  %descriptor vector
    
    % histogram vectors
    for j = 1:ns
        for i = 1:ns
            clip = patch(round((j-1)*ys/ns+1):round(j*ys/ns),round((i-1)*xs/ns+1):round(i*xs/ns));
            RIFT_des(j,i,:) = permute(hist(clip(:), 1:o), [1 3 2]);
        end
    end
    
    RIFT_des=RIFT_des(:);
    
    if norm(RIFT_des) ~= 0
        RIFT_des = RIFT_des /norm(RIFT_des);
        
    end
    
    des(:,k)=RIFT_des;
end
des = struct('kps', KPS(:,kps_to_ignore ==0)', 'des', des(:,kps_to_ignore==0)');
end 