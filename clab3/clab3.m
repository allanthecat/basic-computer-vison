clc;clear all;close all;
%%%%%% data acquisition %%%%%%
input_dir = 'C:\Users\xiang\Dropbox\6528 computer Vision\lab\lab3\training_set_cropped';%input directory
[raw_data num_images] = raw_data_aquisition(input_dir); %raw data aquisition

%%%%%% training %%%%%%
mean_face = mean(raw_data, 2);                        	%calculated mean of each rows
image_dims = [180, 130];                               	%size of each iamge
data = raw_data - repmat(mean_face, 1, num_images);   	%subtract mean from raw data
[evals evtrs]= fast_eigen_calculation(data);            %fast eigen vector and value calculation
[evalues evectors]  = sort_eigen(evals, evtrs);        	%alocate the eigen vector according to decending order of evalue
num_eface = 15;                                         %number of eigen faces to keep
evectors_tun = evectors(:, 1:num_eface);               	%discard the rest of the eigen faces
projection = evectors_tun' * data;                     	%project data to those eigen vectors

%%%%%% classification test set %%%%%%
input_dir = 'C:\Users\xiang\Dropbox\6528 computer Vision\lab\lab3\test_set_cropped';%input directory
[test_img num] = raw_data_aquisition(input_dir);        %raw data aquisition
test_data = test_img - repmat(mean_face, 1, num);     	%subtract mean face
test_projection = evectors_tun' * (test_data);         	%project test image data to the eigen vectors
%%%%%% similar faces display %%%%%%
figure(1);title('test image and three of the most similar faces');
for i = 1:num
    distance = arrayfun(@(n) norm(projection(:,n) - test_projection(:,i)), 1:num_images);%distance between test data and all the image
    [~, index] = sort(distance);                       	%acending order of distance
    similar_faces = [];                                	%similar faces          
    for j = 1:3                                        	%for the closest distances
        temp = reshape(raw_data(:,index(j)), image_dims);%reshape data into image
        similar_faces = [similar_faces temp];          	%cat the similar faces into 1 pic horizontally
    end
    subplot(ceil(sqrt(num)),ceil(sqrt(num)),i);
    imshow([reshape(test_img(:,i), image_dims) similar_faces]);%display
end

%%%%%% eigen faces display %%%%%%
figure(2);title('15 faces with largest eiven value');
for i = 1:num_eface
    subplot(ceil(sqrt(num_eface)), ceil(sqrt(num_eface)), i);
    eface = reshape(evectors_tun(:,i), image_dims);
    imshow(eface,[]);
end
%%%%%% mean face display %%%%%%
figure(3);mface = reshape(mean_face, image_dims);
imshow(mface);
