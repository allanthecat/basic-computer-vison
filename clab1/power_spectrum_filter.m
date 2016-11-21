clc,clear
f = [1 ,1,1; 1,1,1; 1,1,1];
F=fft2(f, 256,256);
F2=fftshift(F);
F2=abs(F2); 
F2=log(1+F2);   
figure,imshow(F2,[]);
f = [ 1,1,1; 0,0,0 ; -1,-1,-1];
F=fft2(f, 256,256);
F2=fftshift(F);
F2=abs(F2); 
F2=log(1+F2);   
figure,imshow(F2,[]);
f =[ -1,-1, -1; -1 , 8, -1; -1,-1,-1];
F=fft2(f, 256,256);
F2=fftshift(F);
F2=abs(F2); 
F2=log(1+F2);   
figure,imshow(F2,[]);   