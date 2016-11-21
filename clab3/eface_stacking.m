%%%%%%% eface stacking  %%%%%%%%
clc,clear, close all;
load('clab3_data');                                     %load clab3 stored data
num_test = 20;                                          %unmber of PCA concerned
reconstructed_faces = [];                               
a = [];
b = [];
reconstructed_face = zeros(image_dims);
mean = reshape(mean_face, image_dims);
sum_face = zeros(image_dims);
projection_test = zeros(size(data,1),1);
data_num = 11;                                           %reconstructed the 8th image in the training set
test_image = reshape(test_data(:,data_num), image_dims);
for i = 2:1:num_test
    evector_test = evectors(:, i);                          
    projection_test = normc(test_data(:,data_num) * evector_test' *evector_test);%one reconstruction
    sum_face = sum_face + reshape(projection_test, image_dims);%sum with all the perivious reconstruction
    a =  [a mean];
  	b = [b sum_face];
end
figure,imshow([a+b test_image]);        %stack with mean face, along with original face, display
