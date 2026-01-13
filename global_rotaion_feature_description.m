function [des,DO] = global_rotaion_feature_description (im,kps,eo,patch_size,s,o)
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
% figure;
% imshow(MIM,[]);
%% global rotation MIM
MIM_vector = MIM(:);
C_MIM = mode(MIM_vector);
DO = C_MIM* (180/o);%0~180 % 如何解决360度的循环问题；（210-180=30（逆向旋转））
% RMIM_global = MIM;
MIM_new = MIM - C_MIM + 1;
% % 处理边界情况（索引小于1）
MIM_new(MIM_new < 1) = MIM_new(MIM_new < 1) + o;
RMIM_global= MIM_new;
% CMIM = mode(RMIM_global(:));
% DO = CMIM* (180/o);
%new MIM
% 生成全局RMIM
% RMIM_global = generate_RMIM_from_MIM2(MIM_ref, o,DO, C_MIM, model);
figure;
imshow(RMIM_global,[]);
% title("MIMnew")             

%%  description
des = zeros(36*o, size(KPS,2)); %descriptor (size: 6×6×o)
kps_to_ignore = zeros(1,size(KPS,2));

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
    
    patch = RMIM_global(y1:y2,x1:x2); %local MIM patch for feature description
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