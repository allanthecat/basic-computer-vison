clc,clear;
img = imread('face_w.jpg');%rotate square gray image
img45 = my_Rotation(img,pi/4);
img90 = my_Rotation(img,pi/2);
img45M = imrotate(img,45);
subplot(2,2,1);imshow(img);title('original');
subplot(2,2,2);imshow(img45);title('rotate45');
subplot(2,2,3);imshow(img90);title('rotate90');
subplot(2,2,4);imshow(img45M);title('builtInRotate45');