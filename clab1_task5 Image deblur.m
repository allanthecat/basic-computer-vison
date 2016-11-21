clc,clear;
%Institution: Australian National Univeristy
%Author: Ruoxiang Wen
%Course Code: Computer Vision
%Activity: Lab1
%%%%%%%%%%%%%%%%  Task 5 %%%%%%%%%%%%%%%%%%%
%------------------------------------------%
%image blurring and deblurring using bulit-in weiner function
img = imread('Lenna.png');                                  %read image
img = rgb2gray(img);                                        %convert image to gray
figure;subplot(2,2,1);imshow(img);title('original image');  %show image
theta = 30; len = 20;                                       %define motion blur parameters 
h = imrotate(ones(1, len), theta, 'bilinear');              %define motion blur filter
h = h / sum(h(:));                                          %normalizing filter
imgBlur = imfilter(img, h);                                 %blur the image
subplot(2,2,2);imshow(imgBlur);title('blurred image');      %plot the blurred image
imgWnr = deconvwnr(imgBlur, h, 0.001);                      %use built-in deconv wnr filter
subplot(2,2,3);imshow(imgWnr);title('RestoredByWeiner');    %plot the deconv result image
%------------------------------------------%
%self-programmed function
H = zeros(size(img,1),size(img,2));                         %degin filter same size as image
H(1:11,1:18) = h;                                           %locate h values in the new filter
Hf = fft2(H);                                               %inverse fft for the new filter
d = 0.1;                                                    %set threshold for the inverse
Hf(find(abs(Hf)<d))=1;                                      %replace value below theshold
imgDeblur = ifft2(fft2(imgBlur)./Hf);                       %inverse filter deblur method in freq domain
subplot(2,2,4);imshow(mat2gray(abs(imgDeblur)));title('Restored by self-programmed inverse filter');    
                                                            %plot the deconv result image





