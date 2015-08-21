function [fea, row, col ]= getGradient(img, patch_size, overlap)
ps = patch_size;
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';

g11 = conv2(img,hf1,'same');
g12 = conv2(img,vf1,'same');
g21 = conv2(img,hf2,'same');
g22 = conv2(img,vf2,'same');

[fea, row, col] = im2col_overlap(g11, ps, overlap);
fea = [fea; im2col_overlap(g12, ps, overlap)];
fea = [fea; im2col_overlap(g21, ps, overlap)];
fea = [fea; im2col_overlap(g22, ps, overlap)];
fea = single(fea);