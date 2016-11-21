clc,clear;
nc = 3;                                                %define number of clusters in final result
[data_clusters, cluster_stats] = my_kmeans(nc,'peppers.png' );  %run my kmeans function
%[data_clusters, cluster_stats] = my_kmeans(nc,'mandm.png' );    %run my kmeans function
