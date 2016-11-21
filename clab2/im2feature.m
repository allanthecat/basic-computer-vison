function [features] = im2feature(img)                   %get image feature
[rows, cols, ncolors] = size(img);                      %3d matrix, y,x,and color, a block
npixels = rows * cols;                                  %total pixels number
[x,y] = meshgrid(1:cols,1:rows);                        % Each feature vector consists of [ L,a,b,x,y]
features = img;
factor = 1.0 ; % In your experiment, you may also change the value of 'factor' to e.g. 10, or 0.1, to see whether there is any change to your final results.
features(:,:,4) = factor* x;
features(:,:,5) = factor* y;
features = reshape( features, [npixels 5] );            % Normalize the features
for i=1:size(features,2)
% Zero mean
features(:,i) = features(:,i) - mean(features(:,i));
% Normalize
features(:,i) = features(:,i) / norm(features(:,i));
end