close all;
clc;
clear;
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');
patch_size = 8; % patch size for the low resolution input image
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
patch_size = patch_size*zooming;
zooming2 = sqrt(zooming);
blur = 10;
Num_of_Iterations=1000;
DictSize=1024;
path1 = './SparseCoding./Data/Test/';
[filename,pathname]=uigetfile('*.avi','select an avi video');
if (filename==0) & (pathname==0)
    return
end
[filename2,pathname2]=uigetfile('*.avi','select an avi video');
if (filename2==0) & (pathname2==0)
    return
end
im_name = [pathname filename];
im_name2 = [pathname2 filename2];
mov=mmReader(im_name);
mov2=mmReader(im_name2);
numFrames = get(mov, 'numberOfFrames');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% movFile = avifile([filename '_copy.avi'], 'compression', 'Xvid', 'fps', 10, 'quality', 100);
% if (numFrames>300)
%     numFrames=300;
% end
% for i=1:numFrames  
%     im1=double(read(mov,i))/255;        
%     im1=imresize(im1,2,'bicubic');
%     movFile = addframe(movFile, im1);
% end
% mov_file = close(movFile);
%%%%%%%%%%%%%%%%%%%%%%%%%%
movFile = avifile([filename '_parrel.avi'], 'compression', 'Xvid', 'fps', 10, 'quality', 100);
if (numFrames>300)
    numFrames=300;
end
for i=1:numFrames  
    im1=double(read(mov,i))/255;
    im2=double(read(mov2,i))/255;  
    im3=[im1 im2];
    imshow(im3)
    movFile = addframe(movFile, im3);
end
mov_file = close(movFile);