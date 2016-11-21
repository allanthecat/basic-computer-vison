function [data_clusters, cluster_stats] = my_kmeans( nc, imageFile )
img = imread(imageFile);                              %read image
img = im2uint8(img);                                    %convert to class uint8
cform = makecform('srgb2lab');                          %specify color transformation structure 
lab = applycform(img, cform);                           %converts the color values into lab
[rows, cols, ncolors] = size(img);                      %get size of rows, cols, and colors
npixels = rows * cols;                                  %get total pixel number
[x,y] = meshgrid(1:cols,1:rows);                        %two mashgrid x,y,size[384 512]       
features = img;                                         %lab intensity as features 1,2,3
factor = 1 ;                                            %geometric constraints
features(:,:,4) = factor* x;                            %image x coordinates as features 4
features(:,:,5) = factor* y;                            %image y coordinates as features 5
features = reshape( features, [npixels 5] );            %reshape matrix aline the 5 features 
features = im2double(features);                         %convert feature to double
for i=1:size(features,2)                                %[npixels, 5]
features(:,i) = features(:,i) - mean(features(:,i));    %zero mean
features(:,i) = features(:,i) / norm(features(:,i));    % normalize
end
data = features;
ndata = size(data,1);                                   %number pixels
ndims = size(data,2);                                   %number of features dimension (5)
random_labels = floor(rand(ndata,1) * nc) + 1;          %random initialization,random label for each pixel
data_clusters = random_labels;                          %collect current label
cluster_stats = zeros(nc,ndims+1);                      %[3 6]
distances = zeros(ndata,nc);                            %[196608 5] change to [196608 3]
temp_dist = zeros(ndata,ndims,nc);                      %matrix to store distance
while(1)
    pause(0.03);                                        %pauses execution for n seconds before continuing
    last_clusters = cluster_stats;                      % Make a copy of cluster statistics for 
    % comparison purposes.  If the difference is very small, the while loop will exit.
    for c=1:nc                                          %for each cluster  
        [ind] = find(data_clusters == c);               %find all data points assigned to this cluster
        num_assigned = size(ind,1);                     %how many numbers of pix are assigned for one label
        if( num_assigned < 1 )                          %some heuristic codes for exception handling. 
            disp('No points were assigned to this cluster, some special processing is given below');
            max_distances = max(distances);             %calculate the maximum distances from each cluster
            [maxx,cluster_num] = max(max_distances);    
            [maxx,data_point] = max(distances(:,cluster_num));
            data_clusters(data_point) = cluster_num;
            ind = data_point;
            num_assigned = 1;
        end                                             %end of exception handling.   
        cluster_stats(c,1) = num_assigned;              %save number of points per cluster,plus the mean vectors
        if( num_assigned > 1 )
            summ = sum(data(ind,:));                    %sum all pix on the cn
            cluster_stats(c,2:ndims+1) = summ / num_assigned;%average value of all the pix at that cn
        else
            cluster_stats(c,2:ndims+1) = data(ind,:);
        end
    end
    diff = sum(abs(cluster_stats(:) - last_clusters(:)));   % Exit criteria
    if( diff < 0.001 )                                        %change the diff to decide when to exit
        break;
    end
    for c=1:nc
        temp(c,:) = dist(cluster_stats(c,2:ndims+1),data'); %matrix to store the distances
    end
    distances = transpose(temp);                            %get the distances matrix
    for i = 1:ndata
            [~,data_clusters(i,1)]=min(temp(1:nc,i));       %get the closest value between clusters
    end
    displayclusters( img, data_clusters )                   %displace clusters
end
