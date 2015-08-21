close all;
clc;
clear;
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');
path2 = './NonBlocking/';
patch_size = 8; % patch size for the low resolution input image
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
patch_size = patch_size*zooming;
zooming2 = sqrt(zooming);
% blur = 10;
Num_of_Iterations=1000;
DictSize=512;
path1 = './SparseCoding./Data/Test/';
[filename,pathname]=uigetfile('*.avi','select an avi video');
if (filename==0) & (pathname==0)
    return
end
im_name = [pathname filename];
mov=mmReader(im_name);
numFrames = get(mov, 'numberOfFrames');
movFile = avifile([filename '_Result.avi'], 'compression', 'Xvid', 'fps', 10, 'quality', 100);
if (numFrames>510)
    numFrames=510;
end
%==========================================================================
for k=211:numFrames
    k
    im=double(read(mov,k))/255;
    im2 = rgb2ycbcr(im);
    lImy = im2(:,:,1);
    interpIm = imresize(im,zooming,'bicubic');
    interpIm2 = rgb2ycbcr(interpIm);
    hImcb = interpIm2(:,:,2);
    hImcr = interpIm2(:,:,3);
    [N1, N2] = size(lImy);
    graytest = lImy;
    BW = double(edge(graytest,'canny'));
    graytest2=graytest;
    graytest3=zeros(size(graytest));
    %%%%%%%%%%%%%%find blocking artifact
    for j = 1:8:(N2-15)
    for i = 1:8:(N1-15)
        Q=0.01;
        patch1 = graytest(i:i+8-1, j:j+8-1);     
        patch2 = graytest(i+8:i+16-1, j:j+8-1);
        patch3 = graytest(i:i+8-1, j+8:j+16-1);
        DCTpatch1=dct2(patch1);
        DCTpatch2=dct2(patch2);
        DCTpatch3=dct2(patch3);
        Qpatch1=round(DCTpatch1/Q);
        Qpatch2=round(DCTpatch2/Q);
        Qpatch3=round(DCTpatch3/Q);
        Rpatch1=Qpatch1*Q;
        Rpatch2=Qpatch2*Q;
        Rpatch3=Qpatch3*Q;
        a1=sqrt(2)./abs(Rpatch1);
        a2=sqrt(2)./abs(Rpatch2);
        a3=sqrt(2)./abs(Rpatch3);
        delta1=(Q/2)*(coth(a1*Q./2))-1./a1;
        delta2=(Q/2)*(coth(a2*Q./2))-1./a2;
        delta3=(Q/2)*(coth(a3*Q./2))-1./a3;
        BarRpatch1=Qpatch1*Q-sign(Qpatch1).*delta1;
        BarRpatch2=Qpatch2*Q-sign(Qpatch2).*delta2;
        BarRpatch3=Qpatch3*Q-sign(Qpatch3).*delta3;
        e1=(BarRpatch1-Rpatch1)./Rpatch1;
        e2=(BarRpatch2-Rpatch2)./Rpatch2;
        e3=(BarRpatch3-Rpatch3)./Rpatch3;
        e1(isnan(e1))=0;
        e2(isnan(e2))=0;
        e3(isnan(e3))=0;
        t12=(BarRpatch1-BarRpatch2);
        t13=(BarRpatch1-BarRpatch3);
        t12(isnan(t12))=0;
        t13(isnan(t13))=0;        
        if ((abs(e1(1,1)-e2(1,1))>t12(1,1)) && (abs(e1(2,1)-e2(2,1))>t12(2,1)))
            graytest2(i+8-1:i+8, j:j+8-1)=1;
            graytest3(i+8-1:i+8, j:j+8-1)=1;
        end
        if ((abs(e1(1,1)-e3(1,1))>t13(1,1)) && (abs(e1(2,1)-e3(2,1))>t13(2,1)))
            graytest2(i:i+8-1, j+8-1:j+8)=1;
            graytest3(i:i+8-1, j+8-1:j+8)=1;
        end
    end
    end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [PSNR_FINAL_ESTIMATE, y_hat_wi1] = BM3D(1, graytest, 'blur');
    lImy2 = graytest-y_hat_wi1; 
    if(mod(k-1,15)==0)
        [DictionaryL1 DictionaryLb CoefMatrix CoefMatrixb]=MCA_Image_Decomposition_many(lImy2, graytest3, patch_size, zooming, Num_of_Iterations, DictSize);
        [Noblocking Texture_Dict Cartoon_Dict]  = MCA_Image_Decomposition_H(lImy2, graytest3, patch_size, DictSize, DictionaryL1, DictionaryLb, CoefMatrix, CoefMatrixb, 1);
    end    
    lImy4=imresize(lImy2,zooming,'bicubic');
    graytest5=imresize(graytest3,zooming,'bicubic');
    graytest6 = (graytest5 >= 0.5);
    BW2 =imresize(BW,zooming,'bicubic');
    BW3 = (BW2 >= 0.5);
    [NonBlockingComponent BlockingComponent] = MCA_Image_Decomposition(lImy4, graytest6, BW3,patch_size, Num_of_Iterations, DictSize, Noblocking, Texture_Dict, Cartoon_Dict, 1);
    BlockingComponent(isnan(BlockingComponent))=0;
    [height width]=size(NonBlockingComponent);
    for i=1:height
           for j=1:width
               temp1=NonBlockingComponent(i,j)>100;
               temp2=NonBlockingComponent(i,j)<100;
               if temp1==0 && temp2==0                
                   NonBlockingComponent(i,j)=0;
               end            
           end   
    end
    y_hat_wi3=imresize(y_hat_wi1,2,'bicubic');
    NonBlocking = y_hat_wi3 + NonBlockingComponent*1.5;
    Deblocking(:,:,1) = NonBlocking;
    Deblocking(:,:,2) = hImcb;
    Deblocking(:,:,3) = hImcr;
    ReconImRGB = ycbcr2rgb(Deblocking);
    movFile = addframe(movFile, ReconImRGB);
end
mov_file = close(movFile);

