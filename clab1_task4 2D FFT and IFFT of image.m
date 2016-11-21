clc,clear;
%Institution: Australian National Univeristy
%Author: Ruoxiang Wen
%Course Code: Computer Vision
%Activity: Lab1
%%%%%%%%%%%%%%%%  Task 4 %%%%%%%%%%%%%%%%%%%
%------------------------------------------%
img = imread('sydney.jpg');                         %read iamge
img = imresize(img,0.6);                            %resize image
img = rgb2gray(img);                                %convert to gray
img = img(1:512,70:582);                            %slice image
figure;                                             %envolve a figure
F=fft2(double(img));                                %convert to double and do fft
A=fftshift(F);                                      %move zero-freq to the center for visulization
A=log2(A);                                          %computes the base 2 logarithm                         
A=abs(A);                                           %returns the absolute value
IF =ifft2(F);                                       %do inverse fft
IF =uint8(IF);                                      %convert to unit8 for visulization
subplot(4,3,1);imshow(img);title('orignial');       %display
subplot(4,3,2);imagesc(A);title('orignial FFT');        
subplot(4,3,3);imshow(IF);title('orignial IFFT');
%------------------------------------------%
h = [1 ,1,1; 1,1,1; 1,1,1];                         %define filter
imgF = imfilter(img,h/9,'conv');                      %convolve filter and image
F=fft2(double(imgF)); 
A=fftshift(F);
A=log2(A);
A=abs(A);
IF = ifft2(F);
IF =uint8(IF);
subplot(4,3,4);imshow(imgF);title('afterFFT');
subplot(4,3,5);imagesc(A);title('powerSpectrumafterFFT');
subplot(4,3,6);imshow(IF);title('IFFTimage');       
%------------------------------------------%
h = [ 1,1,1; 0,0,0 ; -1,-1,-1];
imgF = imfilter(img,h,'conv');
F=fft2(double(imgF));
A=fftshift(F);
A=log2(A);
A=abs(A);
IF = ifft2(F);
IF =uint8(IF);
subplot(4,3,7);imshow(imgF);title('afterFFT');
subplot(4,3,8);imagesc(A);title('powerSpectrumafterFFT');
subplot(4,3,9);imshow(IF);title('IFFTimage');
%------------------------------------------%
h = [ -1,-1, -1; -1 , 8, -1; -1,-1,-1];
imgF = imfilter(img,h,'conv');
F=fft2(double(imgF));
A=fftshift(F);
A=log2(A);
A=abs(A);
IF = ifft2(F);
IF =uint8(IF);
subplot(4,3,10);imshow(imgF);title('afterFFT');
subplot(4,3,11);imagesc(A);title('powerSpectrumafterFFT');
subplot(4,3,12);imshow(IF);title('IFFTimage');
%subplot(4,3,3);imagesc(img-IF);title('img-IF'); 
%------------------------------------------%


