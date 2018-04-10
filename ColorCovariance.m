close all;
C = imread('ObjectDetection.PNG'); %read image
imshow(C)
pimg = double(C(126:191,283:292,:)); %Select a pillar patch
%Computing color covariance of pillar patch
v12 = cov(pimg(:,:,1), pimg(:,:,2));
v13 = cov(pimg(:,:,1), pimg(:,:,3));
v23 = cov(pimg(:,:,2), pimg(:,:,3));

v = [v12(1,1) v12(1,2) v13(1,2);
    v12(2,1) v12(2,2) v23(1,2);
    v13(2,1) v23(2,1) v23(2,2)];
[ev,lv]=eig(v);


bimg = double(C(172:180,366:380,:)); %Select a barrel patch
%Computing color covariance of barrel patch
u12 = cov(bimg(:,:,1), bimg(:,:,2));
u13 = cov(bimg(:,:,1), bimg(:,:,3));
u23 = cov(bimg(:,:,2), bimg(:,:,3));

u = [u12(1,1) u12(1,2) u13(1,2);
    u12(2,1) u12(2,2) u23(1,2);
    u13(2,1) u23(2,1) u23(2,2)];
[eu,lu]=eig(u);