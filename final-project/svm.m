%referenced code: http://au.mathworks.com/help/vision/examples/image-category-classification-using-bag-of-features.html
clc,clear;
output = 'C:\Users\xiang\Dropbox\6528 computer Vision\project';
root = fullfile(output, 'categories');
imgSets = [ imageSet(fullfile(root, 'apple')), ...    %create folder to hold airplanes pics
            %imageSet(fullfile(rootFolder, 'banana')), ...        %create folder to hold ferry pics
            imageSet(fullfile(root, 'pear')), ...          %create folder to hold laptop pics
            %imageSet(fullfile(rootFolder, 'orange')), ...        %create folder to hold laptop pics
            imageSet(fullfile(root, 'tomato'))]; ...         %create folder to hold laptop pics
            %imageSet(fullfile(rootFolder, 'can')) ];         %create folder to hold laptop pics
{imgSets.Description};                                          %display all labels on one line
[imgSets.Count];                                                %show the corresponding count of image
minSetCount = min([imgSets.Count]);
imgSets = partition(imgSets, minSetCount, 'randomize');         %partition data into few parts
[trainingSets, validationSets] = partition(imgSets, 0.8, 'randomize');%partition again for training and validation
SURfeatures = bagOfFeatures(trainingSets);                              %creating SURF features
img = read(imgSets(1), 1);
classifier = trainImageCategoryClassifier(trainingSets, SURfeatures);%multiclass linear SVM classifier
confusionMatrix = evaluate(classifier, trainingSets);        %evaluate training set
confusionMatrix = evaluate(classifier, validationSets);      %evaluate validation set
mean(diag(confusionMatrix));                                 %compute average accuracy
