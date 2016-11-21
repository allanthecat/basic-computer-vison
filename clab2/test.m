img0 = imread('img0.jpg');
img1 = imread('img1.jpg');
im = appendimages(img0, img1);
imwrite(im,'imapp.jpg');