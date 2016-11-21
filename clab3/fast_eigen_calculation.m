function [evalues evectors]= fast_eigen_calculation(data)
B = data';                                            	%transpose of data
covarianceB = B*B';                                    	%much smaller size of covariance
[evectorsB evaluesB]=eig(covarianceB);                 	%eigenvector and eigenvalue of the covariance matrix
evectors = data*evectorsB;                             	%fast way to calcualted the eigenvalue of the much larger matrix
temp = pinv(evectors)*data;                            	%use inverse eigen vector to calculate the eigen value
temp = temp*data';                                     	
evalues = temp*evectors;                               	