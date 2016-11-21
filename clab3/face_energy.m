%%%%%% energy captured by the first 15 eigen values %%%%%%
clc,clear, close all;
load('clab3_data');
total_energy = sum(arrayfun(@(n) ((evectors(:,n)')*evectors(:,n))^2, 1:size(evectors,2)));%calculate total energy
nrd_energy =  (arrayfun(@(n) ((evectors(:,n)')*evectors(:,n))^2, 1:size(evectors,2)))/ total_energy;  %normalized one each energy of eigen face                   
figure, plot(cumsum(nrd_energy));                      %plot the cumilative function
xlabel('No. of PCA'),ylabel('Energy');xlim([1 15]), ylim([0 1]), grid on;
