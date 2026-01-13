function [desall] = feature_description (im,kps,eo,patch_size,s,o,selc)
[yim,xim,~] = size(im);
KPS=kps';
%% RIFT进行循环移位，生成6个不同方向的MIM，进行多次描述匹配
CS = zeros(yim, xim, o); %convolution sequence
MIM_new = cell(1,o);

for j=1:o
    for i=1:s
        eo_choice=abs(eo{i,j});
        CS(:,:,j)=CS(:,:,j)+eo_choice;
    end  
end

if selc == 0
    [~, MIM_new{1}] = max(CS, [], 3);
    t = 1;
else
    t = o;
    for j = 1:o
        cs_shifted = circshift(CS, j-1, 3);
        [~, MIM_new{j}] = max(cs_shifted, [], 3);
    end
end
%%  description
desall = cell(1,t);
for layer=1:t
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
            kps_to_ignore(k)=1;%kps_to_ignore(i)=1;
            continue;
        end
        
        patch = MIM_new{layer}(y1:y2,x1:x2); %local MIM patch for feature description
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
    desall{layer} = des;
end 
end