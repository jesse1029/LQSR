clc;
clear all;
im1=double(imread('010.jpg.jpg'));
imb=double(imread('010.jpg_bb.jpg'));
ims=double(imread('010.jpg_result.jpg'));
diffb=im1-imb;
diffs=im1-ims;
MSEB004 = sum(diffb(:).*diffb(:))/prod(size(im1));
MSES004 = sum(diffs(:).*diffs(:))/prod(size(im1));
PSNRB004 = 10*log10(255^2/MSEB004)
PSNRS004 = 10*log10(255^2/MSES004)

% im1=double(imread('002.bmp.jpg'));
% imb=double(imread('002.bmp_bb.jpg'));
% ims=double(imread('002.bmp_result.jpg'));
% diffb=im1-imb;
% diffs=im1-ims;
% MSEB002 = sum(diffb(:).*diffb(:))/prod(size(im1));
% MSES002 = sum(diffs(:).*diffs(:))/prod(size(im1));
% PSNRB002 = 10*log10(255^2/MSEB002);
% PSNRS002 = 10*log10(255^2/MSES002);
% 
% im1=double(imread('010.jpg.jpg'));
% imb=double(imread('010.jpg_bb.jpg'));
% ims=double(imread('010.jpg_result.jpg'));
% diffb=im1-imb;
% diffs=im1-ims;
% MSEB010 = sum(diffb(:).*diffb(:))/prod(size(im1));
% MSES010 = sum(diffs(:).*diffs(:))/prod(size(im1));
% PSNRB010 = 10*log10(255^2/MSEB010);
% PSNRS010 = 10*log10(255^2/MSES010);