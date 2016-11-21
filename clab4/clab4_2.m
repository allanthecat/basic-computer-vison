clc,clear;
img1 = imread('Left.jpg');                      %load iamge
img2 = imread('Right.jpg');
img1 = rgb2gray(img1);
img2 = rgb2gray(img2);
load('clab4_2_xy_data.mat');                    %load xy coordinates
[H, xy2_T] = DLT(xy1,xy2);                      %DLT transform of image2 to image1, retunrn H matrix
xy1_T_ver = H*xy2_T;                            %coordinates projection form image2 to image1
for i = 1: size(xy1_T_ver,2)                    %convert to non-homogeneous coordinate
xy1_T_ver(1,i) = xy1_T_ver(1,i)/xy1_T_ver(3,i);
xy1_T_ver(2,i) = xy1_T_ver(2,i)/xy1_T_ver(3,i);
xy1_T_ver(3,i) = xy1_T_ver(3,i)/xy1_T_ver(3,i);
end
xy1_ver = round(xy1_T_ver(1:2,:)'); 
figure;                                         %visulization
subplot(2,2,1);imshow(img2);title('original points');hold on;
plot(xy2(:,1), xy2(:,2), 'r*');
subplot(2,2,2);imshow(img1);title('original points');hold on;
plot(xy1(:,1), xy1(:,2), 'r*');
img1 = insertShape(img1,'Line',[xy2(:,:) xy1_ver(:,:)]);
subplot(2,2,3:4);imshow(img1);title('projected points');hold on;
plot(xy2(:,1), xy2(:,2), 'r*');hold on;
plot(xy1_ver(:,1), xy1_ver(:,2), 'y*');hold on;
plot(xy1(:,1), xy1(:,2), 'r*');

