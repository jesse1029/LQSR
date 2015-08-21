% Self-learning for super-resolution using Nonlocal means filter by Jesse.
% Contact with me if you have any question. e-mail: m121754@gmail.com

% This code is used to implement the paper which presented in ICCV2009
% "Super resolution from a single image"
% clear all;
close all;
clc;
tic
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');

patch_size = 12; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
zooming2 = sqrt(zooming);
path1 = './SparseCoding./Data/Test/';
fname = 'gnd512.bmp';
testIm = imread([path1 fname]); % testIm is a high resolution image, we downsample it and do super-resolution

%產生一半大小的小圖
testIm2 = imresize(testIm, 1/zooming);
if rem(size(testIm2,1),zooming) ~=0,
    nrow = floor(size(testIm2,1)/zooming)*zooming;
    testIm2 = testIm2(1:nrow,:,:);
end;
if rem(size(testIm2,2),zooming) ~=0,
    ncol = floor(size(testIm2,2)/zooming)*zooming;
    testIm2 = testIm2(:,1:ncol,:);
end;
imwrite(testIm2, [path1 fname '_block.jpg'],'quality',30);
testIm2 = imread([path1 fname '_block.jpg']);
imwrite(testIm2, [path1 fname '_high.bmp']);
% Get the LR image and regarded it as the training image
lowIm = testIm2;
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
dict_size=512;
sP = 9;
ssP = sP / zooming;
pat_pair = [];
pat_h = [];
pat_l = [];
pat_hh = [];
overlap2 = 1;
Xh = [];
Xl = [];
Xhb = [];
Xlb = [];
%==========================================================================
% Get all of the possibles oritentations and scales to the training set
%==========================================================================
    graytest = lImy;
    blur = 10;    
    [PSNR_FINAL_ESTIMATE, y_hat_wi] = BM3D(1, graytest, blur);
    y_hat_wi=y_hat_wi*255;
    lImy2 = graytest-y_hat_wi;   
    imwrite(uint8(lImy2), [path1 fname '_highfre.bmp']);
    imshow(lImy2/255)
    LI = imresize(lImy2, 1/zooming);
    U1 = imresize(LI, size(lImy2));             
    
    pat0 = im2col_overlap(lImy2, [hP hP], overlap2);
    pat1 = getGradient(U1, [hP hP], overlap2);
            
    stdPat = std(pat1);
    maps = stdPat==0;
    pat0(:,maps) = [];
    pat1(:,maps)= [];
        
    pat_hh = [pat_hh pat0];
    pat_l = [pat_l pat1]; 
    [H, L] = sample_patches(lImy2, [], hP, zooming, zooming);
    Xh = [Xh, H];
    Xl = [Xl, L];
    [H2, L2] = sample_patches2(lImy2, [], hP, zooming, zooming);
    Xhb = [Xhb, H2];
    Xlb = [Xlb, L2];
    % P=reshape(H(:,10),10,10);imshow(P)
    disp(['Extaracting image '' for feature points (tmp)']);
% 
% 
disp('Patches extraction has been done.');
pat_hh_mv = repmat(mean(pat_hh),size(pat_hh,1), 1);
pat_hh_std = repmat(std(pat_hh),size(pat_hh,1), 1);
pat_hh_std(pat_hh_std==0) = 1;
pat_hh = (pat_hh - pat_hh_mv);
save _pat.mat pat_hh pat_l pat_hh_mv Xh Xl;
load _pat.mat;
[Dh, Dl] = coupled_dic_train2(Xh, Xl, dict_size, 0.1, 3, 5000, 50000);
[Dhb, Dlb] = coupled_dic_train2(Xhb, Xlb, dict_size, 0.1, 3, 5000, 50000);
save dict.mat Dh Dl Dhb Dlb;
load dict.mat;
Dh2 = Dh; Dl2=Dl;
Dhb2 = Dhb; Dlb2=Dlb;
Dh2(isnan(Dh2))=0;
Dl2(isnan(Dl2))=0;
Dhb2(isnan(Dhb2))=0;
Dlb2(isnan(Dlb2))=0;
Dhb3=[Dh2 Dhb2];
Dlb3=[Dl2 Dlb2];
grad=zeros(16,dict_size);
HOGDl=zeros(4,dict_size);
for i=1:dict_size
    Dlpic=reshape(Dhb3(1:16,i),4,4);
    grad(1:72,i) = HOG1(Dlpic);
end
[IDX,C] = kmeans(grad',2);
DHdb=Dhb3;
DLdb=Dlb3;
num1=length(find(IDX==1));
num2=length(find(IDX==2));
if num1>num2
    numbe=1;
else
    numbe=2;
end
[dictionaryh dictionaryw]=size(DHdb);
Deblock=zeros(dictionaryh,1);
for i=1:dict_size
    if(IDX(i)==numbe)        
        DHdb(:,i)=Deblock;
    end
end
Dhb3=DHdb;
Dlb3=DLdb;
Dh4=[Dh2 Dhb3];
Dl4=[Dl2 Dlb3];
disp('Learning an overcomplete basis using Efficient Sparse Coding.');
toc
% ======================================================================
% Sprase Coding SR
% ======================================================================
eval('load ./SparseCoding./Data/Dictionary/Dictionary.mat');
lImy2=rgb2ycbcr(lowIm);
lImy2=double(lImy2(:,:,1));
blur = 10;    
[PSNR_FINAL_ESTIMATE, y_hat_wi] = BM3D(1, lImy2, blur);
y_hat_wi=y_hat_wi*255;
lImy2=lImy2-y_hat_wi;
hImy2 = L1SR(lImy2, zooming, patch_size , overlap, Dh4, Dl4, 0.1, 'L1', zooming); % Using Lasso to obtain HR image
smoothim = imresize(y_hat_wi, size(hImy2));
hImy3 = double(hImy2)+smoothim;
% ======================================================================
% Proposed method, features-based
% ======================================================================
% ======================================================================
% Super-resolution using sparse representation
% ======================================================================
ReconIm(:,:,2) = hImcb;
ReconIm(:,:,3) = hImcr;

close all;
fname = 'gnd512.bmp'; % This is ground truth
groundtruth = imresize(imread(['./SparseCoding/Data/Test/' fname]), size(hImcb));
nnIm = imresize(lowIm, zooming, 'nearest');
figure, imshow(nnIm);
title('Input image');
figure, imshow(interpIm);
title('Bicubic interpolation');
%最後HR是ReconImRGB
ReconIm(:,:,1) = uint8(imresize(hImy3, size(hImcb)));
ReconImRGB = uint8(ycbcr2rgb(ReconIm));
imwrite(uint8(ReconImRGB), [path1 fname '_addhighfre.bmp']);
imwrite(ReconImRGB,'result.jpg')
figure,imshow(uint8(ReconImRGB));
title('Sparse coding');
PSNR(groundtruth, ReconImRGB);
ReconIm(:,:,1) = uint8(imresize(smoothim, size(hImcb)));
ReconImRGB = uint8(ycbcr2rgb(ReconIm));
imwrite(uint8(ReconImRGB), [path1 fname '_smoothresize.bmp']);