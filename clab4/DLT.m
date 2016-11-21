function [H xy2_T] = DLT(xy1, xy2)
xy1 = round(xy1);                               %round the raw xy data from giput
xy2 = round(xy2);                               %round the raw xy data from giput
xy1_T = xy1';                                   %transpose matrix
xy2_T = xy2';                                   %transpose matrix
xy2_T = padarray(xy2_T,[1,0],1,'post');         %convert to homogeneous
xy1_T = padarray(xy1_T,[1,0],1,'post');         %convert to homogeneous
num_of_samples = size(xy1_T,2);                 %number of points in raw data
c_size = 9;                                     %size of homography matrix
A = [];                                         %empty matrix for cat
for i = 1:num_of_samples
    xi = xy1_T(1,i);
    yi = xy1_T(2,i);
    wi = xy1_T(3,i);
    Xi = xy2_T(:,i);
    Ai = [
            0, 0, 0,    -wi * Xi',   yi * Xi' ;
            wi * Xi',     0, 0, 0,   -xi * Xi'
            ];
    A = [ A ; Ai ];                             %DLT matrix
end;
[U,D,V] = svd(A);                               %svd decomposition of A
h = V(:,c_size);                                %take the last column
h = h/h(c_size);                                %normalized to zero
H = reshape(h,3,3)';                            %reshape to homography matrix
end
