function [C,uv_ver] = calibrate(img1, xyz, uv)
xyz_T = xyz';                                   %tanspose of data
uv_T = uv';                                     %tanspose of data
uv_T = padarray(uv_T,[1,0],1,'post');           %pad to homogeneous coordinates
xyz_T = padarray(xyz_T,[1,0],1,'post');         %pad to homogeneous coordinates
num_of_samples = size(xyz_T,2);                 %number of poionts in xyz and uv
c_size = 12;                                    %size of camera calibration matrix 
A = [];                                         %empty matrix far cat
for i = 1:num_of_samples                        %for each point
    xi = uv_T(1,i);                            
    yi = uv_T(2,i);
    wi = uv_T(3,i);
    Xi = xyz_T(:,i);
    Ai = [
            0, 0, 0, 0,    -wi * Xi',   yi * Xi' ;
            wi * Xi',     0, 0, 0, 0,   -xi * Xi'
            ];                                  %DLT matrix 
    A = [ A ; Ai ];
end;
[~,~,V] = svd(A);                               %svd decomposition
c = V(:,c_size);                                %get the last column
c = c/c(c_size);                                %normalized 
C = reshape(c,4,3)';                            %respape to camera matrix
temp = [0 0 0 7;                                %vanishing point ploting, add extra world coordiantes
        0 0 7 0;
        0 7 0 0;
        1 0 0 0;
    ];
xyz_T = cat(2, xyz_T, temp);                    %cat the extra world coordinates
uv_T_ver = C*xyz_T;                             %XYZ projection 
for i = 1: size(uv_T_ver,2)                     %convert to non-homogeneous coordinate
uv_T_ver(1,i) = uv_T_ver(1,i)/uv_T_ver(3,i);
uv_T_ver(2,i) = uv_T_ver(2,i)/uv_T_ver(3,i);
uv_T_ver(3,i) = uv_T_ver(3,i)/uv_T_ver(3,i);
end
uv_ver = round(uv_T_ver(1:2,:)');               %round to display, and display the vanishing line
img1 = insertShape(img1,'Line',[uv_ver(end-3,:) uv_ver(end-2,:); ...
                                uv_ver(end-3,:) uv_ver(end-1,:); ...
                                uv_ver(end-3,:) uv_ver(end,:); ...
                                                                    ]);
imshow(img1);
hold on
plot(uv(:,1), uv(:,2), 'r*');
hold on
distance = sum(sqrt(sum((uv_ver(1:end-4,:) - uv) .^ 2))); 	%element wise mean squared error
str = sprintf('overlaid UV and project XYZ with mean squared error %0.5g',distance);
plot(uv_ver(:,1), uv_ver(:,2), 'g*');title(str);
