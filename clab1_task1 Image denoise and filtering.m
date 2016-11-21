clc,clear;
%Institution: Australian National Univeristy
%Author: Ruoxiang Wen
%Course Code: Computer Vision
%Activity: Lab1
%%%%%%%%%%%%%%%%  Task 1 %%%%%%%%%%%%%%%%%%%
%% step 1:read img,resize to 512 x 512,convert to greyscale,[0, 255]
%%{
img = imread('face.jpg');           %read image from folder
angleDeg = 90;                      %set a rotation angle of 90 degrees
img=imrotate(img,angleDeg);         %rotate the image by 90 degrees
img = imresize(img, 0.4);           %resize the image to 0.4 of the original
img = img(200:711, 70:581,:);       %slice the image to meet resolution
img = rgb2gray(img);                %convert image to grayscale
imwrite(img,'face_w.jpg');
%}
img = imread('face_w.jpg');

%% step 2: add gaussian and salt&pepper noise use imnoise
imgN1 = imnoise(img,'gaussian',0, 5/255);          
                                    %gaussian noise mean 0 & var 5
imgN2 = imnoise(img,'salt & pepper',0.1);     
                                    %salt&pepper density 0.1
%figure;
subplot(2,2,1);imshow(img);title('Orignal Image');
                                    %display original image
subplot(2,2,2);imshow(imgN1);title('Gaussian');
                                    %display gaussian noised image
subplot(2,2,3);imshow(imgN2);title('Salt and Pepper');
                                    %display salt&pepper noised image

%% step 3:implement 9X9 gaussian filter
%%{
figure;%for gaussian noisy image           
for i = 1:3
    hsize = 9;                          %define gaussian filter size
    sigma = 1+4*(i-1);                          %define gaussian filter variance
    h = fspecial('gaussian',hsize,sigma);%create a gaussian filter kernel
    result = my_Gauss_filter(imgN1,h);  %call the filtering function
    img = im2double(img);               %convert the original image to double
    SNR = 20*log ( norm(img,'fro') /norm(img - result, 'fro' ));
                                    %calculate the signal to noise ratio
    subplot(2,2,i);imshow(result);title(['Gauss: sigma ', num2str(sigma) ',SNR ',num2str(SNR)]);
end
figure;%for salt&pepper noisy image
for i = 1:3
    hsize = 9;                          %define gaussian filter size
    sigma = 1+4*(i-1);                          %define gaussian filter variance
    h = fspecial('gaussian',hsize,sigma);%create a gaussian filter kernel
    result = my_Gauss_filter(imgN2,h);  %call the filtering function
    img = im2double(img);               %convert the original image to double
    SNR = 20*log ( norm(img,'fro') /norm(img - result, 'fro' ));
                                    %calculate the signal to noise ratio
    subplot(2,2,i);imshow(result);title(['sl&ppr: sigma ', num2str(sigma) ',SNR ',num2str(SNR)]);
end
%}

%%{
%% step 4:implement 3x3 median filter
figure;
h = zeros(3,3);
result = my_Median_filter(imgN2,h);
subplot(2,2,1);imshow(result);title('3x3 median filter'); %display result image
h = zeros(5,5);
result = my_Median_filter(imgN2,h);
subplot(2,2,2);imshow(result);title('5x5 median filter'); %display result image
result = medfilt2(imgN2);
subplot(2,2,3);imshow(result);title('bulit-in median filter'); %display result image
%}

%% step 5:implement 3x3 sobel edge detector
%%{
figure;
h = [-1 0 1; -2 0 2; -1 0 1;];
result = my_Sobel_filter(img,h);
subplot(2,2,1);imshow(result);title('vertical edge'); %display result imag
h = [1 2 1; 0 0 0; -1 -2 -1;];
result1 = my_Sobel_filter(img,h);
subplot(2,2,2);imshow(result1);title('horizontal edge'); %display result imag
result = my_Sobel_filter(result,h);
subplot(2,2,3);imshow(result);title('ver&horz edge'); %display result imag
h = fspecial('sobel');
result = imfilter(img,h);
subplot(2,2,4);imshow(result);title('built-in sobel'); %display result imag
%}
