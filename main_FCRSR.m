% Self-learning for super-resolution using Nonlocal means filter by Jesse.
% Contact with me if you have any question. e-mail: m121754@gmail.com

% This code is used to implement the paper which presented in ICCV2009
% "Super resolution from a single image"
% clear all;
close all;
clc;

addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
zooming2 = sqrt(zooming);
path1 = './SparseCoding./Data/Test/';
fname = 'gnd.bmp';
testIm = imread([path1 fname]); % testIm is a high resolution image, we downsample it and do super-resolution
imwrite(testIm, [path1 fname '_block.jpg'],'quality',30);
testIm = imread([path1 fname '_block.jpg']);
%產生一半大小的小圖
testIm = imresize(testIm, 1/zooming);
if rem(size(testIm,1),zooming) ~=0,
    nrow = floor(size(testIm,1)/zooming)*zooming;
    testIm = testIm(1:nrow,:,:);
end;
if rem(size(testIm,2),zooming) ~=0,
    ncol = floor(size(testIm,2)/zooming)*zooming;
    testIm = testIm(:,1:ncol,:);
end;
imwrite(testIm, [path1 fname '_high.bmp']);

% Get the LR image and regarded it as the training image
lowIm = imresize(testIm,1/zooming, 'bicubic');
lowIm = testIm;
imwrite(lowIm,[path1 fname '_low.bmp']);
interpIm = imresize(lowIm,zooming,'bicubic');
imwrite(uint8(interpIm),[path1 fname '_bb.bmp']);

% work with the illuminance domain only
lowIm2 = rgb2ycbcr(lowIm);
lImy = double(lowIm2(:,:,1));

% bicubic interpolation for the other two channels
interpIm2 = rgb2ycbcr(interpIm);
hImcb = interpIm2(:,:,2);
hImcr = interpIm2(:,:,3);

% Get the training patches
h = fspecial('gaussian', 5,4);
h2 = fspecial('gaussian', 5,1);
hP = patch_size;
sP = 9;
ssP = sP / zooming;
pat_pair = [];
pat_h = [];
pat_l = [];
pat_hh = [];
overlap2 = 1;
Xh = [];
Xl = [];
%==========================================================================
% Get all of the possibles oritentations and scales to the training set
%==========================================================================
tpath = './SparseCoding/Data/Training2/';
tdir = dir([ tpath '*.bmp']);

for z=1:10
    lImy=imread([tpath tdir(z).name]) ;
    lImy = rgb2gray(lImy);
    for i=0:4
        lImy2 = imresize(lImy, 0.9^i);
        for j=0:90:270
            lImy2 = double(imrotate(lImy2, j, 'bicubic', 'crop'));
            LI = (imresize(lImy2, 1/zooming));
            U1 = imresize(LI, size(lImy2));
            
            pat0 = im2col_overlap(lImy2, [hP hP], overlap2);
            pat1 = getGradient(U1, [hP hP], overlap2);
            
            stdPat = std(pat1);
            maps = stdPat==0;
            pat0(:,maps) = [];
            pat1(:,maps)= [];
            
            pat_hh = [pat_hh pat0];
            pat_l = [pat_l pat1]; 
            num_patch = round(numel(lImy2) / (hP^2) / 8);
            [H, L] = sample_patches2(lImy2, [], hP, zooming, num_patch, 2);
            Xh = [Xh, H];
            Xl = [Xl, L];
            disp(['Extaracting image ' num2str(z) ' for feature points (tmp)']);
        end
    end
end

disp('Patches extraction has been done.');
pat_hh_mv = repmat(mean(pat_hh),size(pat_hh,1), 1);
pat_hh_std = repmat(std(pat_hh),size(pat_hh,1), 1);
pat_hh_std(pat_hh_std==0) = 1;
pat_hh = (pat_hh - pat_hh_mv);
save _pat.mat pat_hh pat_l pat_hh_mv Xh Xl;
load _pat.mat;
[Dh, Dl] = coupled_dic_train2(Xh, Xl, 1024, 0.1, 3, 5000, 50000);
save dict.mat Dh Dl;
load dict.mat;
Dh2 = Dh; Dl2=Dl;
disp('Learning an overcomplete basis using Efficient Sparse Coding.');

% ======================================================================
% Sprase Coding SR
% ======================================================================
eval('load ./SparseCoding./Data/Dictionary/Dictionary.mat');
lImy2=rgb2ycbcr(lowIm);
lImy2=lImy2(:,:,1);
hImy2 = L1SR(lImy2, zooming, patch_size , overlap, Dh2, Dl2, 0.1, 'L1', 2); % Using Lasso to obtain HR image
% ======================================================================
% Proposed method, features-based
% ======================================================================
% ======================================================================
% Super-resolution using sparse representation
% ======================================================================
ReconIm(:,:,2) = hImcb;
ReconIm(:,:,3) = hImcr;

close all;
fname = '002.bmp'; % This is ground truth
groundtruth = imresize(imread(['./SparseCoding/Data/Test/' fname]), size(hImcb));
nnIm = imresize(lowIm, zooming, 'nearest');
figure, imshow(nnIm);
title('Input image');
figure, imshow(interpIm);
title('Bicubic interpolation');

ReconIm(:,:,1) = uint8(imresize(hImy3, size(hImcb)));
ReconImRGB = uint8(ycbcr2rgb(ReconIm));
imwrite(uint8(ReconImRGB), [path1 fname '_02SCRC.bmp']);
figure,imshow(ReconImRGB,[]);
title('Our method 1');

ssim(groundtruth, ReconImRGB)
PSNR(groundtruth, ReconImRGB)

ReconIm(:,:,1) = uint8(imresize(hImy2, size(hImcb)));
ReconImRGB = uint8(ycbcr2rgb(ReconIm));
imwrite(uint8(ReconImRGB), [path1 fname '_02SC.bmp']);
figure,imshow(uint8(ReconImRGB));
title('Sparse coding');
ssim(groundtruth, ReconImRGB)
PSNR(groundtruth, ReconImRGB)
