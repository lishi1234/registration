function [cleanpoints1,cleanpoints2,H]= rift_feature_matching(des1,des2)

all_target_descriptors = struct('kps', [], 'des', []);

for o = 1:6
    all_target_descriptors.des = [all_target_descriptors.des; des1{1,o}.des];
    all_target_descriptors.kps = [all_target_descriptors.kps; des1{1,o}.kps];
end
[indexPairs, ~]  = matchFeatures(all_target_descriptors.des,des2{1}.des,'MaxRatio', 1, 'MatchThreshold', 100, 'Unique', true);
% 匹配只需一重循环
matchedPoints1 = all_target_descriptors.kps(indexPairs(:,1), :);
matchedPoints2 = des2{1}.kps(indexPairs(:,2), :);

% cleanpoints1 = matchedPoints1;
% cleanpoints2 = matchedPoints2;

H = FSC(matchedPoints1,matchedPoints2,'affine',3);%测试FSC阈值：1,3,5,7,9
combined = [matchedPoints1, matchedPoints2];
%     
% % 查找唯一行
[~, ia] = unique(combined, 'rows', 'stable');

unique_pts1 = matchedPoints1(ia, :);
unique_pts2 = matchedPoints2(ia, :);
    
%     fprintf('精确坐标去重: %d -> %d\n', size(pts1,1), size(unique_pts1,1));

H = FSC(unique_pts1,unique_pts2,'affine',3);%测试FSC阈值：1,3,5,7,9
Y_ = H*[unique_pts1';ones(1,size(unique_pts1,1))];
Y_(1,:) = Y_(1,:)./Y_(3,:);
Y_(2,:) = Y_(2,:)./Y_(3,:);
E = sqrt(sum((Y_(1:2,:)-unique_pts2').^2));
inliersindex = E<3;
cleanpoints1 = unique_pts1(inliersindex,:);
cleanpoints2 = unique_pts2(inliersindex,:);
disp("image matched");
end
