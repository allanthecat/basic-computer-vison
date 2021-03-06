function output_image = my_Median_filter(img, h)
lenHrow =size(h,1);                                 %get the row of filter
lenHcol =size(h,2);                                 %get the col of filter
lenIrow =size(img,1);                               %get the row of image
lenIcol =size(img,2);                               %get the col of image
%creatre new image with to avoid black edges around the image after convolution 
temp = flipud(img(1:lenHrow,:));                 
imgNew = cat(1,temp,img);
temp = flipud(img(lenIrow-lenHrow+1:lenIrow,:));
imgNew = cat(1,imgNew,temp);
temp = zeros(lenIrow+2*lenHrow,lenHcol);
temp(:,:) = mean(mean(img));
imgNew = cat(2,temp,imgNew);
imgNew = cat(2,imgNew,temp);
temp = fliplr(img(:,1:lenHcol));
imgNew(lenHrow+1:lenHrow+lenIrow,1:lenHcol)=temp;
temp = fliplr(img(:,lenIcol-lenHcol+1:lenIcol));
imgNew(lenHrow+1:lenIrow+lenHrow,lenIcol+lenHcol+1:lenIcol+2*lenHcol)=temp;
%finished creating the new image                             
lenINrow = size(imgNew,1);                      %get the row of new image
lenINcol = size(imgNew,2);                      %get the col of new image
h = fliplr(h);                                  %flip kernel left right
h = flipud(h);                                  %flip kernel up down
pix = 0;
imgNew = im2double(imgNew);                     %convert image to double
result = zeros(lenINrow,lenINcol);              %create matrix to hold result
for k = 1:lenINrow-lenHrow+1                    %pixel operation for image
    for q = 1:lenINcol-lenHcol+1                %pixel opeartion for image
        temp = imgNew(k:k+lenHrow-1,q:q+lenHcol-1);%create a patch same size as the image
        if lenHrow == 5                         %to compare with 3x3 median filter create a 5x5 one
            temp = cat(2,temp(1,1:lenHcol),temp(2,1:lenHcol),temp(3,1:lenHcol),temp(4,1:lenHcol),temp(5,1:lenHcol));
        end
        if lenHrow == 3                         %3X3 median filter
            temp = cat(2,temp(1,1:lenHcol),temp(2,1:lenHcol),temp(3,1:lenHcol));
        end
        temp = sort(temp);                      %sort the array
        pix = median(temp);                     %find the median value of the array
        result(k+round(lenHrow)-1,q+round(lenHcol-1)) = pix;%allocate the pix in the result image
    end
end
output_image = result(lenHrow:lenINrow-lenHrow-1,lenHcol:lenINcol-lenHcol-1);%output of the function