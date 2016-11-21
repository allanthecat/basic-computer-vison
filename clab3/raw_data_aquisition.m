function [raw_data num_images] = raw_data_aquisition(input_dir)
filenames = dir(fullfile(input_dir, '*.jpg'));        	%read all the jpg image
num_images = numel(filenames);                        	%number of image received
raw_data = [];                                        	%array to hold pix after reshape
for i = 1:num_images
    filename = fullfile(input_dir, filenames(i).name); 	%read the filename of n'th image in the set
    img = imread(filename);                            	%read the image in matlab workspace
    img = im2double(img);                              	%convert image to double class
    img = rgb2gray(img);                               	%convert image to grayscale
    raw_data(:, i) = img(:);                           	%reshape image and store as raw data,row by row
end
end