clc,clear;
%[img, descriptor, locs] = sift('face90.jpg');             %find sift keypoints img1
%showkeys(img, locs);
[img1, descriptor1, locs1] = sift('img0.jpg');             %find sift keypoints img1
showkeys(img1, locs1);
[img2, descriptor2, locs2] = sift('img1.jpg');            %find sift keypoints img2
showkeys(img2, locs2);
ratio = 0.6;                                                %define matching ratio
Pair = zeros(1,size(descriptor1,1));                        %create match table
for i = 1 : size(descriptor1,1)
   distance = dist(descriptor1(i,:),descriptor2');          %calculate Euclidean distance between discriptors
   [value,index] = sort(distance);                          %sort distance
   if (value(1) < ratio * value(2))                         %closest match compare to sencond closest match
      Pair(i) = index(1);                                   %if valid collect the closest match, non-max suppresion
   else                                                     %discard value if not the max value
      Pair(i) = 0;                                          %otherwise set 0
   end
end
imgAppend = imread('imapp.jpg');                      %load appended face iamge
figure;imshow(imgAppend);hold on;                           %show the imgAppend as background
for i = 1:10:size(descriptor1,1)                            %change the amount of line by spacing
  if (Pair(i) > 0)
    line([locs1(i,2) locs2(Pair(i),2)+size(img1,2)],[locs1(i,1) locs2(Pair(i),1)], 'Color', 'g');      %x,y coordinate
  end
end
hold off;