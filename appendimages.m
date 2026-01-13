function  [fhand]=appendimages(image1, image2,correspond1,correspond2)

rows1 = size(image1,1);%调整图像大小一致
rows2 = size(image2,1);

col1=size(image1,2);
col2=size(image2,2);

if (rows1 < rows2)
     image1(rows1+1:rows2,1:col1,:) = 0;
elseif(rows1 >rows2)
     image2(rows2+1:rows1,1:col2,:) = 0;
end

temp1=size(image1,3);
temp2=size(image2,3);
if(temp1==1 && temp2==3)
    image2=rgb2gray(image2);%调整图像通道一致
elseif(temp1==3 && temp2==1)
    image1=rgb2gray(image1);
end

im3 = [image1 image2]; %图像拼接以及显示

fhand=figure;
imshow(im3,'border','tight','initialmagnification','fit');
title(['left is the reference --- the number of pairs ',num2str(size(correspond1,1)),' --- right is the To be registered']);
set (gcf,'Position',[0,0,size(im3,2) size(im3,1)]);
axis normal;

hold on;
cols1 = size(image1,2);
for i = 1: size(correspond1,1)
        line([correspond1(i,1) correspond2(i,1)+cols1], ...
             [correspond1(i,2) correspond2(i,2)], 'Color', 'y','LineWidth',0.75);% 线
         plot(correspond1(i,1),correspond1(i,2),'y.','MarkerSize', 5,'LineWidth',0.75);% 点
%          text(double(correspond1(i,1)),double(correspond1(i,2)),num2str(i),'FontSize',14,'color','y');%,'FontWeight','Bold');% 标号
         plot(correspond2(i,1)+cols1,correspond2(i,2),'r.','MarkerSize', 5,'LineWidth',0.75);
%          text(double(correspond2(i,1)+cols1),double(correspond2(i,2)),num2str(i),'FontSize',14,'color','y');%,'FontWeight','Bold');
end

hold off;

end

