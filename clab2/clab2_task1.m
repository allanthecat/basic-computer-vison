clc,clear;
%figure; my_harris('Right.jpg' );
%figure; my_harris('peppers.png' );
%figure; my_harris('Lenna.png' );
%figure; my_harris('mandm.png' );
img = imread('Right.jpg');      %read image
img = im2double(img);           %covert image to double
img = rgb2gray(img);            %covert image to gray
c = corner(img);                %get the corner by bulitin function
imshow(img);                    %show image
hold on
plot(c(:,1), c(:,2), 'r*');     %hold figure and map the corner