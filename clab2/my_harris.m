function [data_clusters, cluster_stats] = my_harris(imageFile )
img = imread(imageFile);                                %load image
img = rgb2gray(img);                                    %convert it to gray scale
bw = im2double(img);                                    %convert it to class double
sigma = 2;                                              %sigma of gaussian kernel
thresh =0.008;                                          %threshold value filter small cornerness
sze = 11;                                               %size of maximum filter
disp = 0;                                               %display parameter
dy = [-1 0 1; -1 0 1; -1 0 1];                          %gradient filter in y direction
dx = dy';                                               %gradient filter in x direction               
lx = conv2(bw,dx,'same');                               %gradient image in x direction                               
ly = conv2(bw,dy,'same');                               %gradient image in y direction
g = fspecial('gaussian',max(1,fix(6^sigma)),sigma);     %define gaussian kernel, more importance in the middle of the window
lx2 = conv2(lx.^2, g, 'same');                          %smoothed image derivatives in x direction
ly2 = conv2(ly.^2, g, 'same');                          %smoothed image derivatives in y direction                          
lxy = conv2(lx.*ly,g, 'same');                          %smoothed image derivatives in xy direction
                %compute the cornerness
K = 0.05;                                               %empirical constant 0.01-0.1
R = (lx2 .* ly2) - (lxy.^2) - K * ( lx2 + ly2 ).^ 2;    %cornerness
                %non-maximum suppression
mx = ordfilt2(R, sze^2, ones(sze));                     %maximum filter find max in cornerness function                  
radius = sqrt(sze-1);                                   %define radius of the window
bordermask = zeros(size(R));                            %greate bordermask same size as the image
bordermask(radius+1:end-radius, radius+1:end-radius) = 1;%set outer ring to 1
cornerness = (R==mx) & (R>thresh) & bordermask;         %find maxima, threshold, and apply bordermask
[rows,cols] = find(cornerness==1);                      %return all the corner coordinates
imshow(bw);                                             %show original image
hold on;                                                %hold the image in same figure
p = [cols rows];                                        %collect rows and cols of corners
plot(p(:,1),p(:,2),'or');                               %plot on the original image
title('\bf Harris Corners');                            %create title for the iamge

