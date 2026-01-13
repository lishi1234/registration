function [cleanedPoints1,cleanedPoints2,H]= r2fd2_featurematch(des_1,des_2)
[indexPairs,matchmetric] = matchFeatures(des_1.des,des_2.des,'MaxRatio',0.9,'MatchThreshold', 100,'Unique',true);
matchedpoints1 = des_1.kps(indexPairs(:,1),:);
matchedpoints2 = des_2.kps(indexPairs(:,2),:);
H=FSC(matchedpoints1,matchedpoints2,'affine',3);
% Y_=H*[matchedpoints1';ones(1,size(matchedpoints1,1))];
% Y_(1,:)=Y_(1,:)./Y_(3,:);
% Y_(2,:)=Y_(2,:)./Y_(3,:);
% E=sqrt(sum((Y_(1:2,:)-matchedpoints2').^2));
% inliersIndex=E<3;
% cleanedPoints1 = matchedpoints1(inliersIndex, :);
% cleanedPoints2 = matchedpoints2(inliersIndex, :);
cleanedPoints1 = matchedpoints1;
cleanedPoints2 = matchedpoints2;
disp('Show matches')
end