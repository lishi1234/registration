function des = descriptor_circleshift(im, kps,eo, patch_size, s,o)

KPS=kps'; %keypoints
[yim,xim,~] = size(im);
d=12;%扇形分块数360/12=30度————————变化需要根据方向进行分块；原始扇区划分d=16;
ns=6;%直方图数
%% MIM最大索引图
CS = zeros(yim, xim, o); %convolution sequence

for j=1:o
    for i=1:s
        eo_choice=abs(eo{i,j});
        CS(:,:,j)=CS(:,:,j)+eo_choice;
    end
end
[~, MIM] = max(CS,[],3); 
% clear i
%% log_polar description——需要对对极数坐标的扇形区域的统计顺序进行修改
des = zeros(size(KPS,2),(2*d+1)*o ); %descriptor (size: 6×6×o)
kps_to_ignore = zeros(1,size(KPS,2));

radius=floor(patch_size/2);

for k = 1: size(KPS,2)
    x = round(KPS(1, k));%列
    y = round(KPS(2, k));%行
    
    x1 = max(1,x-floor(patch_size/2));
    y1 = max(1,y-floor(patch_size/2));
    x2 = min(x+floor(patch_size/2),size(im,2));
    y2 = min(y+floor(patch_size/2),size(im,1));
    
    if y2-y1 ~= patch_size || x2-x1 ~= patch_size %不考虑边沿
        kps_to_ignore(k)=1;
        continue;% 跳过后面步骤开始下一次循环 break会结束整个for循环，不能用在这里
    end
    
    center_x=x-x1+1;
    center_y=y-y1+1;
    
    %局部主方向
    MIM_vector = MIM(y1:y2,x1:x2);
    C_MIM = mode(MIM_vector);
    DO = C_MIM* (180/o);
    MIM_new = MIM_vector - C_MIM + 1;
    MIM_new(MIM_new < 1) = MIM_new(MIM_new < 1) + o;
    RMIM_local = MIM_new;
    patch =RMIM_local; %local MIM patch for feature description
    [ys,xs]=size(patch);
    %圆环
    X=-(x-x1):1:(x2-x);
    Y=-(y-y1):1:(y2-y);
    [XX,YY]=meshgrid(X,Y);
    log_amplitude=sqrt(XX.^2+YY.^2);
    r1=radius*0.25;
    r2=radius*0.75;
    r3=radius;
    log_amplitude(log_amplitude<=r1)=1;
    log_amplitude(log_amplitude>r1 & log_amplitude<=r2)=2;
    log_amplitude(log_amplitude>r2 & log_amplitude<=r3)=3;
    log_amplitude(log_amplitude>r3)=0;
    
    %扇区
    log_angle=atan2(YY,XX);
    log_angle=log_angle/pi*180;% [-180, 180]
%     log_angle = log_angle +DO;% % 加主导方向，使其归零；——加减仍需斟酌
    log_angle(log_angle<0)=log_angle(log_angle<0)+360;
    log_angle=round(log_angle*d/360);
    log_angle(log_angle<=0)=log_angle(log_angle<=0)+d;
    log_angle(log_angle>d)=log_angle(log_angle>d)-d;
    % 然后进行量化到d个扇区

     % log_angle(log_angle == 0) = d; % 将0重新映射为第d扇区 
    
    RIFT_des = zeros(1,ns*(2*d+1));  %descriptor vector
    % histogram vectors
    for i=1:1:ys
        for j=1:1:xs
            if ((i-center_y)^2+(j-center_x)^2)<=radius^2
            bin=patch(i,j);
            angle_bin=log_angle(i,j);
            amplitude_bin=log_amplitude(i,j);
            
            if log_amplitude(i,j)==1
                RIFT_des(bin)= RIFT_des(bin)+1;
            else 
                RIFT_des(((amplitude_bin-2)*d+angle_bin)*ns+bin)=... 
                   RIFT_des(((amplitude_bin-2)*d+angle_bin)*ns+bin)+1; 
            end
            end
            
        end
    end
                
    if norm(RIFT_des) ~= 0
        RIFT_des = RIFT_des /norm(RIFT_des);
    end
    
    des(k,:)=RIFT_des;
end
des = struct('kps', KPS(:,kps_to_ignore ==0)', 'des', des(kps_to_ignore==0,:));
end

