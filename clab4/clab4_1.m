clc,clear;
load('img_uv_xyz.mat');                     %load points and image data
[C,uv_ver] = calibrate(img1, xyz, uv);               %camera matrix and plotting
[K, R, t] = vgg_KR_from_P(C, 1);            %C = K[R|t]

%K: camera calibration matrix 3x3, intrisics
%R: rotation matrix 3x3
%R|t or R[I|-CamCenter]: camera extrinsics
%C = K[R | ?RCamCenter]= [M| ?MCamCenter]
focal_length = K(1,1);                      %from intrisics matrix K
Y_axis = [0,1,0];                           %vector of y axis
temp = dot(t',Y_axis)/(norm(t')*norm(Y_axis));%sine of the ptich angle
pitch_angle = asin(temp)*180/pi;
