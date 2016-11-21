clc,clear;
%Institution: Australian National Univeristy
%Author: Ruoxiang Wen
%Course Code: Computer Vision
%Activity: Lab1
%%%%%%%%%%%%%%%%  Task 2 %%%%%%%%%%%%%%%%%%%
%%
%step 1:read img,resize to 1024 x 1024,convert to greyscale,[0, 255]
%%{
img = imread('text.png');                   %read image from folder
img = imresize(img, 0.604);                 %resize the image to 0.4 of the original
img = img(1:1024,:,:);                      %slice the image to meet resolution
img = rgb2gray(img);                        %convert image to grayscale
%% step 2: threshold the histogram to binary image
img = im2bw(img, 0.5);                      %bulit-in function to convert to binary
imwrite(img,'text_w.jpg');
img = imcomplement(img);                    %complement the iamge
figure;
imshow(img);                                %show image
[counts,binLocations] = imhist(img);        %use histogram to counts
blackPix = counts(1,1);                     %number of black pix
whitePix = counts(2,1);                     %number of white pix
totalPix = blackPix + whitePix;             %total pix of the binary image
SE = strel('square',5)                      %define a structure element
imgErode = imerode(img,SE,'same');                 %perform image erosion
imgDilate = imdilate(img,SE);               %perform image dilation
imgOpen = imopen(img,SE);                   %perform image opening
imgClose = imclose(img,SE);                 %perform image closing
figure;                                     %display the above four image
subplot(2,2,1);imshow(imgErode);title('erosion');
subplot(2,2,2);imshow(imgDilate);title('dilation');
subplot(2,2,3);imshow(imgOpen);title('opening');
subplot(2,2,4);imshow(imgClose);title('closing');
lenIrow = size(img,1);                      %get the row of image
lenIcol = size(img,2);                      %get the col of image
temp = ones(lenIrow,1);                     %create a temp array to hold variables
rowCollector = [];                          %define empty array to collect rows

SE = strel('rectangle',[30 100]); 
imgClose = imclose(img,SE);
figure,imshow(imgClose); 
[L,num] = bwlabel(imgClose);
i = 1;
for i = 1:num
[r, c] = find(L == i);
rMax = max(r);
rMin = min(r);
temp = img(rMin:rMax,:);
str = num2str(num+1-i);
imwrite(temp,strcat('line',str,'.jpg'));
end
