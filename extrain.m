close all;
clc;
clear;
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');
path = './TrainData/';
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
lz=2;
patch_size = 8;
zooming2 = sqrt(zooming);
preTexture_Dict = [];
preCartoon_Dict = [];
blur = 10;
numIteration=1000;
DictSize=4096;
fpath = fullfile(path, '*.*');
img_dir = dir(fpath);
img_dir(1:2)=[];
Xh = [];
Xl = [];
img_num = length(img_dir);
for num = 1:img_num
    num
    tic
    testIm2 = double(imread(fullfile(path, img_dir(num).name)))/255;
    if rem(size(testIm2,1),zooming) ~=0,
        nrow = floor(size(testIm2,1)/zooming)*zooming;
        testIm2 = testIm2(1:nrow,:,:);
    end;
    if rem(size(testIm2,2),zooming) ~=0,
        ncol = floor(size(testIm2,2)/zooming)*zooming;
        testIm2 = testIm2(:,1:ncol,:);
    end;
    lowIm2 = double(rgb2ycbcr(testIm2));
    lImy = lowIm2(:,:,1);
    graytest = lImy;    
    [PSNR_FINAL_ESTIMATE, y_hat_wi] = BM3D(1, graytest, 'blur');
    lImy2 = graytest-y_hat_wi;
    [H, L] = sample_patches(lImy2, [], patch_size, zooming, lz);
    Xh = [Xh, H];
    Xl = [Xl, L];   
    toc
end
Xl = Xl - repmat(mean(Xl), [size(Xl, 1) 1]);
Xl = Xl ./ repmat(sqrt(sum(Xl .^ 2)), [size(Xl, 1) 1]);
Xh = Xh - repmat(mean(Xh), [size(Xh, 1) 1]);
Xh = Xh ./ repmat(sqrt(sum(Xh .^ 2)), [size(Xh, 1) 1]);
save samplepatchblur Xh Xl
param.K = DictSize;
param.lambda = 0.15;
param.iter = numIteration;
DictionaryL = mexTrainDL(Xl, param);
save DictionaryLblur DictionaryL
clear Xh Xl;
load samplepatchblur
DictionaryL = DictionaryL ./ repmat(sqrt(sum(DictionaryL .^ 2)), [size(DictionaryL, 1) 1]);
param.K = DictSize;
param.lambda = 0.15;
param.iter = numIteration;
param.L = 20; 
param.eps = 0.001; 
CoefMatrix = mexOMP(Xl, DictionaryL, param);
save CoefMatrixblur CoefMatrix
clear Xl DictionaryL;
load DictionaryLblur
load CoefMatrixblur
load samplepatchblur
DictionaryH=Xh/CoefMatrix;
save Dictionaryblur DictionaryH DictionaryL