clc,clear;
%Institution: Australian National Univeristy
%Author: Ruoxiang Wen
%Course Code: Computer Vision
%Activity: Lab1
%%%%%%%%%%%%%%%%  Task 2 %%%%%%%%%%%%%%%%%%%
%%
img = imread('text_w.jpg');                         %read image from folder
%%{
figure;
angleDeg = 45;                                %set a rotation angle of n degrees
imgRotate=imrotate(img,angleDeg,'nearest');               %rotate the image by n degrees
subplot(1,2,1);imshow(imgRotate);title('bulit-in rotate 45, nearest');
imgRotate=imrotate(img,angleDeg,'bilinear');               %rotate the image by n degrees
subplot(1,2,2);imshow(imgRotate);title('bulit-in rotate 45, bilinear');
%display
%}
%%{
lenIrow =size(img,1);                               %get the row of image
lenIcol =size(img,2);                               %get the col of image
length = ceil(sqrt(lenIrow^2+lenIcol^2))+1;         %get the max length of result iamge
padsize = ceil((length - lenIrow)/2)+1;             %get the padsize for array padding
img = padarray(img,[padsize padsize],0);            %pad arrays to original image
imgR = zeros(length,length);                        %create matrix to hold the result
mid = ceil((length)/2);                             %get the midile of the result image
theta = -45;                                        %set rotation angle
theta = deg2rad(theta);                             %convert angle to radian
R = [cos(theta),-sin(theta),0;                      %rotation matrix
    sin(theta),cos(theta),0;
    0,0,1;];
tx = -mid;                                          %define variable for translation
ty = -mid;                                          %define variable for translation
T = [1,0,tx;...                                     %translation matrix
0,1,ty;...
0,0,1;];
T1 = [1,0,-tx;...                                   %translation matrix       
0,1,-ty;...
0,0,1;];
for row = padsize:length-padsize                    %for pix in range of original image size
    for col = padsize:length-padsize                %for pix in range of original image size
        A = [row;col;1];                            %define homo coordinate
        A = T1*R*T*A;                               %1: move every pix to origin
                                                    %2: rotate every pix by
                                                    %3: move every pix back                                             
        rowR = round(A(1,1));                       %get a rough interperation
        colR = round(A(2,1));
        imgR(rowR,colR) = img(row,col);             %assign every pix to result image
    end
end
figure;
imshow(imgR);                                       %show result image
%}
