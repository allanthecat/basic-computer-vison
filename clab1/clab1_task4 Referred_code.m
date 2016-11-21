% Isaac D. Gerg / Pushkar U. Durve
% CSE 485 - Digital Image Processing I 
% Project 4
% Group Number # 4

	clc;
	close all;
	fltInitialCpuTime = cputime;
	
	imgTemp = imread('text_w.jpg');
	% Normalize Image
	imgTissue1 = double(imgTemp) ./ 255;

%-------------------------------------------------------------------------------
% Part 1 - Convert image to gray level
	[X,map] = rgb2ind(imgTissue1,256);
	imgTissue1 = ind2gray(X, map);
	imwrite(imgTissue1, 'tissue1_gray.jpg', 'jpg');

%-------------------------------------------------------------------------------
% Part 2 - Generation of Gaussian noise matrix
	vctTissue1Size = size(imgTissue1);
	mxGaussianNoise = 0.1 .* randn(vctTissue1Size(1), vctTissue1Size(2));

%-------------------------------------------------------------------------------
% Part 3 - Point Spread Function (PSF) Generation
	filterPSF = fspecial('motion', 21, 11);
	imgTissue1Blur = imfilter(imgTissue1, filterPSF);
	imgTissue1BlurAndNoise = imadd(imgTissue1Blur, mxGaussianNoise);
	imwrite(imgTissue1BlurAndNoise, 'tissue1_blur_and_noise.jpg', 'jpg');

%-------------------------------------------------------------------------------
% Part 4 - Noise to Image Power Ratio
	imgTissue1Spectrum = abs(fft2(imgTissue1)).^2;
	fltTissue1Power = sum(imgTissue1Spectrum(:)) / prod(size(imgTissue1Spectrum));
	
	mxGaussianNoiseSpectrum = abs(fft2(mxGaussianNoise)).^2;
	fltGaussianNoisePower = sum(mxGaussianNoiseSpectrum(:)) / prod(size(mxGaussianNoiseSpectrum));
	
	fltNSR = fltGaussianNoisePower / fltTissue1Power;
	disp('Noise to Signal Power Ratio:');
	disp(fltNSR);

%-------------------------------------------------------------------------------
% Part 5 - Autocorrelation Functions
	mxTissue1Autocorrelation = fftshift(real(ifft2(imgTissue1Spectrum)));
	mxGaussianNoiseAutocorrelation = fftshift(real(ifft2(mxGaussianNoiseSpectrum)));

%-------------------------------------------------------------------------------
% Part 6 - Wiener Filtering
	imgTissue1Weiner1 = deconvwnr(imgTissue1BlurAndNoise, filterPSF);
	imgTissue1Weiner2 = deconvwnr(imgTissue1BlurAndNoise, filterPSF, fltNSR);
	imgTissue1Weiner3 = deconvwnr(imgTissue1BlurAndNoise, filterPSF, mxGaussianNoiseAutocorrelation, mxTissue1Autocorrelation);
	
	figure('Name', 'Wiener Filter', 'NumberTitle', 'off', 'MenuBar', 'none');
	colormap(gray);
	subplot(321);
	imagesc(imgTissue1);
	title('Original Image');
	subplot(322);
	imagesc(imgTissue1BlurAndNoise);
	title('Degraded Image');
	subplot(323);
	imagesc(imgTissue1Weiner1);
	title('Default Weiner Filter with NSR = 0');
	subplot(324);
	imagesc(imgTissue1Weiner2);
	title('Weiner Filter Using Noise to Signal Ratio');
	subplot(325);
	imagesc(imgTissue1Weiner3);
	title('Weiner Filter Using Autocorrelation with NSR');

%-------------------------------------------------------------------------------
% Part 7 - Regularized Filtering
	imgTissue1Regular1 = deconvreg(imgTissue1BlurAndNoise, filterPSF);
	imgTissue1Regular2 = deconvreg(imgTissue1BlurAndNoise, filterPSF, fltGaussianNoisePower);
	
	figure('Name', 'Regular Filter', 'NumberTitle', 'off', 'MenuBar', 'none');
	colormap(gray);
	subplot(221);
	imagesc(imgTissue1);
	title('Original Image');
	subplot(222);
	imagesc(imgTissue1BlurAndNoise);
	title('Degraded Image');
	subplot(223);
	imagesc(imgTissue1Regular1);
	title('Regular Filter With No Noise Power');
	subplot(224);
	imagesc(imgTissue1Regular2);
	title('Regular Filter Using Noise Power');

%-------------------------------------------------------------------------------
% Part 8 - Lucy-Richardson Filtering
	imgTissue1LucyRichardson1 = deconvlucy(imgTissue1BlurAndNoise, filterPSF, 5);
	imgTissue1LucyRichardson2 = deconvlucy(imgTissue1BlurAndNoise, filterPSF, 3);
	
	figure('Name', 'Lucy-Richardson Filter', 'NumberTitle', 'off', 'MenuBar', 'none');
	colormap(gray);
	subplot(221);
	imagesc(imgTissue1);
	title('Original Image');
	subplot(222);
	imagesc(imgTissue1BlurAndNoise);
	title('Degraded Image');
	subplot(223);
	imagesc(imgTissue1LucyRichardson1);
	title('Lucy-Richardson Filter, iterations=5');
	subplot(224);
	imagesc(imgTissue1LucyRichardson2);
	title('Lucy-Richardson Filter, iterations=3');

%-------------------------------------------------------------------------------
	disp('CPU Time:');
	disp((cputime - fltInitialCpuTime));
	
	disp('Done.');
%-------------------------------------------------------------------------------
