close all;
clc;
clear;
tic
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');
path1 = './SparseCoding./Data/Test/';
patch_size = 8; % patch size for the low resolution input image
% overlap = 8; % overlap between adjacent patches
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
patch_size = patch_size*zooming;
preTexture_Dict = [];
preCartoon_Dict = [];
blur = 35;
Num_of_Iterations=1000;
DictSize=1024;
fname = '006.jpg';
testIm = double(imread([path1 fname]))/255; % testIm is a high resolution image, we downsample it and do super-resolution
% [fname,pathname]=uigetfile('*.*','select an video');
% if (fname==0) & (pathname==0)
%     return
% end
% im_name = [pathname fname];
% mov=mmReader(im_name);
% testIm = double(read(mov,1))/255; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imwrite(testIm, [fname '.jpg']);
%testIm size 512X512
%產生一半大小的小圖
% 
testIm2 = imresize(testIm, 1/zooming,'bicubic');
if rem(size(testIm2,1),zooming) ~=0,
    nrow = floor(size(testIm2,1)/zooming)*zooming;
    testIm2 = testIm2(1:nrow,:,:);
end;
if rem(size(testIm2,2),zooming) ~=0,
    ncol = floor(size(testIm2,2)/zooming)*zooming;
    testIm2 = testIm2(:,1:ncol,:);
end;
% testIm2 size 256X256
imwrite(testIm2, [fname '_block.jpg'],'quality',15);
% imwrite(testIm2, [fname '_block.jpg']);
testIm2 = double(imread([fname '_block.jpg']))/255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the LR image and regarded it as the training image
interpIm = imresize(testIm2,zooming,'bicubic');
imwrite(interpIm,[fname '_bb.jpg']);
%interpIm size 512X512
% work with the illuminance domain only
lowIm2 = double(rgb2ycbcr(testIm2));
lImy = lowIm2(:,:,1);
hImcb = lowIm2(:,:,2);
hImcr = lowIm2(:,:,3);
[PSNR_FINAL_ESTIMATE, y_hat_wi1] = BM3D(1, lImy, '10');
toc
Deblocking(:,:,1) = y_hat_wi1;%uint8() 
Deblocking(:,:,2) = hImcb;
Deblocking(:,:,3) = hImcr;
ReconImRGB = ycbcr2rgb(Deblocking);
imwrite(ReconImRGB, [fname '_result.jpg'])
figure;imshow(ReconImRGB)
