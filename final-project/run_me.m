%referenced code links:
%http://au.mathworks.com/help/vision/examples/using-kalman-filter-for-object-tracking.html
%http://au.mathworks.com/help/vision/ref/vision.kalmanfilter-class.html
%http://au.mathworks.com/help/vision/ref/configurekalmanfilter.html
%http://au.mathworks.com/help/vision/examples/image-category-classification-using-bag-of-features.html
%referenced literatures are listed in the report
%produced by Ruoxiang Wen, Pengfei Fang, Yu Wang
%2016 May 17th
clc,clear;
%-------------------------- Initialization --------------------------------%
videoName = 'Clip2_L3T12P4.mp4';                                        	%load video,change this to test another video
videoReader = vision.VideoFileReader(videoName);                            %read the video
%manual counted fruit data for each video and other parameter initialization
switch char(videoName)                                                      
    case 'clip1_B10.mp4'            %success rate %100                  
        appleNum = 0;bananaNum = 10;pearNum = 0;tomatoNum = 0;orangeNum = 0;not_recognizedNum = 0;
        load('svm_trained_data6');track_size = 2100;Adaptive_background_flag = 1;border = 520-100;
    case'Clip2_L3T12P4.mp4'         % 3,11,6,2 
        appleNum = 0;bananaNum = 0;pearNum = 4;tomatoNum = 12;orangeNum = 3;not_recognizedNum = 3;
       	load('svm_trained_data2');track_size = 2100;Adaptive_background_flag = 1;border = 520-200;
    case'Clip3_L7T12.mp4'           %10,7,1 so tomato lost tracks
        appleNum = 0;bananaNum = 0;pearNum = 0;tomatoNum = 12;orangeNum = 7;not_recognizedNum = 1;
       	load('svm_trained_data3');track_size = 2100;Adaptive_background_flag = 1;border = 520-100;
    case'Clip4_M3P5.mp4'            %100 fully indentified
        appleNum = 3;bananaNum = 0;pearNum = 5;tomatoNum = 0;orangeNum = 0;not_recognizedNum = 0;
        load('svm_trained_data6');track_size = 3000;Adaptive_background_flag = 1;border = 520-100;
    case'Clip5_P10M9T7.mp4'         %8,10,7 with few mismatch
        appleNum = 8;bananaNum = 0;pearNum = 10;tomatoNum = 7;orangeNum = 0;not_recognizedNum = 0;
      	load('svm_trained_data5');track_size = 2100;Adaptive_background_flag = 1;border = 520-100;
    case'Clip6_P61M39B51.mp4'       %38,54,59
        appleNum = 39;bananaNum = 52;pearNum = 61;tomatoNum = 0;orangeNum = 0;not_recognizedNum = 0;
        load('svm_trained_data6');track_size = 3000;Adaptive_background_flag = 1;border = 520-100;
    otherwise
        load('svm_trained_data');
end;
%define array to hold apple, banana, pear, tomato, orange, not_recognized counting data;
fruit_counts = zeros(1,6);

%Mixture of Gaussian background subtraction initialization
%define number of Gaussian, number of training frames
foregroundDetector = vision.ForegroundDetector('NumGaussians',2,'NumTrainingFrames',50);
se = strel('disk',7);                                                       %structure element for background
se_edge = strel('disk',3);                                                  %structure element for extract edge

%blob analysis initialization
%this block of code is to initialization the bounding box function
blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort',true,'AreaOutputPort',...
    true,'CentroidOutputPort',true,'MinimumBlobArea',track_size);
videoPlayer = vision.VideoPlayer('Name', 'fruit track');                    %video with name for display

%tracks structure definition
tracks = struct('id',{},'bbox',{},'kalmanFilter',{},'age',{},'totalVisibleCount',...
    {},'consecutiveInvisibleCount',{},'fruitSize',{});
invisibleForTooLong = 10;                                                   %delete track criteria: if track is invisible for too long (10 frames), delete it
ageThreshold = 5;                                                           %start track criteria: if 5 frames passed the detection still exist, then track it
costOfNonAssignment = 10;                                                   %cost of not assigning a detection
nextId = 1;                                                                 %ID of tracks in track structure
minVisibleCount = 8;                                                        %track will only be initialized if minimum visible count larger a value

%printed text location on display frame
value_position =  [1 border-25;   1 border-25*2;   1 border-25*3;   1 border-25*4;   1 border-25*5;  1 border-25*6];
string_position = [30 border-25;  30 border-25*2;  30 border-25*3;  30 border-25*4;  30 border-25*5; 30 border-25*6];
fruit_categories = {'apple';'banana';'pear';'tomato';'orange';'???'};       %text content



%------------------------------ Start -------------------------------------%
while ~isDone(videoReader)                                                  %while not finished reading the video data
%------------------------- Frame Acquisition  -----------------------------%
frame = step(videoReader);                                                  %read the current video frame
%slice frame to eliminate the white bar: eliminate white bar on the side of 
%conveyor belt
frame = frame(107:576,41:670,:);                                            
trueFrame = frame;

%--------------------- RGB Based Segmentation  ----------------------------%
%RGB segmentation according to RGB color mapping
%RGB is original format, fast. Format convertion needs time, not good for
%real time performance (compared method: Lab clustering, HSV segm)
frame(frame < 0.68) = 0;
frame(frame >= 0.68) = 1;

%------------------- Background Subtraction  ------------------------------%
%foreground detection by mixture of Gaussian, detect moving object,
%generate bw forground
bw_foreground = imfill(step(foregroundDetector, frame),'holes');            
saved_foreground = bw_foreground;
%subtract edges, so bw fruits become more separatable, this is helpful in
%most of the situation (can not handle occlusion, overlaps, and vauge boundary)
bw_foreground(imdilate(edge(imopen(imfill(im2bw(frame),'holes'), se),'Canny'), se_edge) ==1)=0;

%--------------------- bounding box drawing -------------------------------%
%bbox content: [x y width hight]
%monothology operation shrinks the bbox, this line of code enlarge it a bit 
%for classification
[~, centroids, bboxes] = step(blobAnalysis, bw_foreground);                 
bboxes(:,1) = max(bboxes(:,1)-10,1);                                                             
bboxes(:,2) = max(bboxes(:,2)-10,1); bboxes(:,3) = bboxes(:,3)+20; bboxes(:,4) = bboxes(:,4)+20;

%------------ Predict New Locations of Existing Tracks --------------------%
%for each legitimate track get the bbox for the track; at start, no tracks, length = 0
for i = 1:length(tracks)                                                    
    bbox = tracks(i).bbox;
    %predicted bbox according to linear model and Gaussian noise
    predictedCentroid = predict(tracks(i).kalmanFilter);                    
    tracks(i).bbox = [int32(predictedCentroid) - bbox(3:4) / 2, bbox(3:4)];	%relocate bboxes in each tracks
end

%-------------------- Assign Detections to Tracks -------------------------%
%not all the detection are assigned to track, based on the cost_of_not_assign matrix, 
%the lower the value, the less change to assign detections to tracks
%higher the value, the more easier detections will be assigned to tracks
%the value is set low, we don't want to start a track easily during the
%detection, otherwise there will be tracks and bboxes everyway in the
%frame, which is not a good result for classification. Because our
%classification method based sliced image from frame based on bboxes.

%The current cost is decided by the current distance between kalman
%predicted location and the centroid of detection: the further the
%distance, the higher the cost
cost = zeros(length(tracks), size(centroids, 1));                         	%form cost matrix
for i = 1:length(tracks)                                                  	%for each valid tracks
    cost(i, :) = distance(tracks(i).kalmanFilter, centroids);               %cost of assigning each detection to each track
end
[assignments, unassignedTracks, unassignedDetections] = assignDetectionsToTracks(cost, costOfNonAssignment);

%---------------- Update Assigned & Unasigned Track -----------------------%
%the code below get the index of assigned and not assigned index of
%detections. 
%1. If the detections are decided to be assigned, the track
%   structure will add 1, and bbox will be drawn.
%2. For not assigned tracks, the bbox will not be drawn, thus nothing is shown
%  on the screen
%3. for both assigned and not assigned tracks, following value will be
%   added: total visible counts, consecutive invisible counts, age(the number
%   of frame since detected) for each ID of tracks
numAssignedTracks = size(assignments, 1);
for i = 1:numAssignedTracks
    trackIdx = assignments(i, 1);
    detectionIdx = assignments(i, 2);
    centroid = centroids(detectionIdx, :);
    bbox = bboxes(detectionIdx, :);
    correct(tracks(trackIdx).kalmanFilter, centroid);                       %correct the estimate of the object's location
    tracks(trackIdx).bbox = bbox;                                           %update bounding box
    tracks(trackIdx).age = tracks(trackIdx).age + 1;                        %update track's age
    tracks(trackIdx).totalVisibleCount = tracks(trackIdx).totalVisibleCount + 1;%update visibility
    tracks(trackIdx).consecutiveInvisibleCount = 0;                         %set invisible counter to zero
end
%for not assigned tracks, the consecutive invisible count increase
%age increase since there is a detection
for i = 1:length(unassignedTracks)                                        	%for unassigned tracks
    ind = unassignedTracks(i);                                              %get the index in tracks struct
    tracks(ind).age = tracks(ind).age + 1;                                  %update the age
    tracks(ind).consecutiveInvisibleCount = tracks(ind).consecutiveInvisibleCount + 1;%update teh invisible counter
end

if ~isempty(tracks)
%-------------------------- Fruit Analysis --------------------------------%
%to save computational time and eliminate classification errors due to light change,
%classification only happen once passed the predifined border line
%1. light change: light source cast from one direction, but background
%   illumination change due to shadow and belt texture and belt reflection
%2. classify the fruit when the accuracy is the highest
%the following code detect how many inseparated fruits in a sliced frame
for i = 1: size(tracks,2)
temp = [tracks(i).bbox];                                                    %get the current bbox
fruits = struct('Part',{});                                                 %to store sliced frames of fruits
if (temp(2)+temp(4)-1>=border)                                              %if passed the border line
    %get the frame that has fruit according to the size of bbox
    fruit_coordinate = [max(1,temp(2)) min(temp(2)+temp(4),size(frame,1))...
        max(1,temp(1)) min(temp(1)+temp(3)-1,size(frame,2))];
    %slice the fruit out of the whole video frame, but fruits can be
    %inseparable by mothology operation.
    fruit = trueFrame(fruit_coordinate(1):fruit_coordinate(2),...
        fruit_coordinate(3):fruit_coordinate(4),:);
    fruit = im2double(fruit);
    %get the bw sliced image
    bw_fruit = imopen(imfill(im2bw(frame(fruit_coordinate(1):fruit_coordinate(2),...
        fruit_coordinate(3):fruit_coordinate(4),:)),'holes'), se);
    %regional properties analysis
    stat = regionprops(bw_fruit,'Area','Eccentricity','Extrema','Perimeter','MajorAxisLength','MinorAxisLength','Orientation','Extrema');
    %select stat with largest area
    a = []; temp_area = arrayfun(@ (n) [a stat(n).Area], 1:(size(stat,1)));
    [val,ind] = max(temp_area);     disp(stat(ind));
    %occlusion condition, if overlapped, spilt image into two according to
    %regional extrema and orientation of the bw fruits. If the orientation
    %of bw area is > 45, split image horizontally, otherwise vertically
    %This solution is not perfect, but is accurate enough to raise the success rate
    if (((~isempty(ind)) && stat(ind).Area>12000 && stat(ind).MajorAxisLength-stat(ind).MinorAxisLength>80 ...
        && stat(ind).Eccentricity>0.7 && stat(ind).Eccentricity<0.905 && stat(ind).Perimeter >730 ...
        && temp(4)*temp(3)>40000 ) ||((~isempty(ind)) && stat(ind).Area>16000))
        figure(1);imshow(bw_fruit);
        %partition occlued based on orientation and extrema
        if (stat(ind).Orientation <45 && stat(ind).Orientation > - 45 && stat(ind).Area<40000)
            break_row = round((stat(ind).Extrema(1,2)+stat(ind).Extrema(2,2)+stat(ind).Extrema(5,2)+stat(ind).Extrema(6,2))/4);
            fruits(1).Part = fruit(1:break_row,:,:);
            fruits(2).Part = fruit(break_row:end,:,:);
           	disp('found two fruits in this window');
        elseif ((stat(ind).Orientation >=45 || stat(ind).Orientation <= - 45) && stat(ind).Area<43000)
            break_col = round((stat(ind).Extrema(1,1)+stat(ind).Extrema(2,1)+stat(ind).Extrema(5,1)+stat(ind).Extrema(6,1))/4);
            fruits(1).Part = fruit(:,1:break_col,:);
            fruits(2).Part = fruit(:,break_col:end,:);
          	disp('found two fruits in this window');
        elseif (stat(ind).Orientation <45 && stat(ind).Orientation > - 45 && stat(ind).Area>=43000)
            break_row = round((stat(ind).Extrema(1,2)+stat(ind).Extrema(2,2)+stat(ind).Extrema(5,2)+stat(ind).Extrema(6,2))/4);
            fruits(1).Part = fruit(1:floor(end/3),:,:);
            fruits(2).Part = fruit(floor(end/3):2*floor(end/3),:,:);
            fruits(3).Part = fruit(2*floor(end/3):end,:,:);
          	disp('found three in this window');
        elseif ((stat(ind).Orientation >=45 || stat(ind).Orientation <= - 45) && stat(ind).Area>=40000)
            break_col = round((stat(ind).Extrema(1,1)+stat(ind).Extrema(2,1)+stat(ind).Extrema(5,1)+stat(ind).Extrema(6,1))/4);
            fruits(1).Part = fruit(:,1:floor(end/3),:);
            fruits(2).Part = fruit(:,floor(end/3):2*floor(end/3),:);
            fruits(3).Part = fruit(:,2*floor(end/3):end,:);
          	disp('found three fruits in this window');
        else
            disp('error: no fruits assigned');
        end
    else
        fruits(1).Part = fruit;
        disp('found one fruit in this window');
    end
    
%------------------- SVM Based Object Recognition -------------------------%
    for j = 1:size(fruits,2)
        [labelIdx, ~] = predict(categoryClassifier, fruits(1,j).Part);        %image classification
        fruit_name = categoryClassifier.Labels(labelIdx);                   %get the fruit name
        switch char(fruit_name)                                             %furit counting
            % apple, banana, pear, tomato, orange, not_recognized;
            case 'apple'
                fruit_counts(1) = fruit_counts(1) + 1;
            case'banana'
                fruit_counts(2) = fruit_counts(2) + 1;
            case'pear'
                fruit_counts(3) = fruit_counts(3) + 1;
            case'tomato'
                fruit_counts(4) = fruit_counts(4) + 1;
            case'orange'
                fruit_counts(5) = fruit_counts(5) + 1;
            otherwise
                fruit_counts(6) = fruit_counts(6) + 1; [y,Fs] = audioread('alarm.mp3'); sound(y,Fs);
        end;
      	disp(fruit_name);
    end
    %after svm recognition the track should be deleted to prevent further counting
    %this three criteria serve the same purpose
    tracks(i).totalVisibleCount = 0;    
    tracks(i).consecutiveInvisibleCount = 100;
    tracks(i).age = 1;
end
end
%-------------------- Lost Track Elimination --------------------------%
    ages = [tracks(:).age];                                                 %the number of frames since the track was first detected
    totalVisibleCounts = [tracks(:).totalVisibleCount];                     %total visible frames counter
    visibility = totalVisibleCounts ./ ages;                                %calculate the visibility
    lostInds = (ages < ageThreshold & visibility < 0.6) |...                %true false to indicate the lostInds
        [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
    tracks = tracks(~lostInds);                                             %use the index to eliminiate the lost tracks
end

%--------------------- Create New Tracks ------------------------------%
centroids = centroids(unassignedDetections, :);                             %get the detected but unassigned centroids
bboxes = bboxes(unassignedDetections, :);                                   %get the detected bu unassgined  bboxes
for i = 1:size(centroids, 1)                                                %for each detected but unassigned object
    centroid = centroids(i,:);
    bbox = bboxes(i, :);                                                    %create a Kalman filter object and create new track
   	fruit_coordinate = [max(1,bbox(2)) min(bbox(2)+bbox(4)-1,size(frame,1)) max(1,bbox(1)) min(bbox(1)+bbox(3)-1,size(frame,2))];
    if (fruit_coordinate(2)<border)
    fruitSize = regionprops(saved_foreground(fruit_coordinate(1):fruit_coordinate(2),fruit_coordinate(3):fruit_coordinate(4),:),'Area');
    kalmanFilter = configureKalmanFilter('ConstantVelocity',centroid, [20, 20], [20, 20], 100);
    tracks(end + 1) = struct('id', nextId,'bbox',bbox,'kalmanFilter',kalmanFilter,'age',1,'totalVisibleCount',1,'consecutiveInvisibleCount', 0,'fruitSize',1.5*max([fruitSize.Area]));
    nextId = nextId + 1;                                                    %increment of track().id
    end
end

%------------------- Display Tracking Results -------------------------%
if ~isempty(tracks)                                                         %if track is assigned
    reliableTrackInds = [tracks(:).totalVisibleCount] > minVisibleCount;    %based on minimum visible count to select reliable tracks
    reliableTracks = tracks(reliableTrackInds);                             %use the index to slect the visible tracks
    if ~isempty(reliableTracks)                                             %if reliable tracks exist
        bboxes = cat(1, reliableTracks.bbox);                               %get bounding boxes
        ids = int32([reliableTracks(:).fruitSize]);                         %get ids.
        labels = cellstr(strcat('fruit size ',int2str(ids')));            	%convert cell to string
        trueFrame = insertObjectAnnotation(trueFrame, 'rectangle',bboxes, labels);  %if reliable then display
    end
end
trueFrame = insertShape(trueFrame,'Line',[1 border size(trueFrame,2) border],'color','red');%insert features
trueFrame = insertText(trueFrame,value_position,fruit_counts,'FontSize',14);
trueFrame = insertText(trueFrame,string_position,fruit_categories,'FontSize',14);
videoPlayer.step(trueFrame);
end
release(videoReader);