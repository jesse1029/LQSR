function [ReconImRGB1 ReconImRGB2] = JSAD(fname)
addpath('./SparseCoding');
addpath('./SparseCoding/Solver');
addpath('./SparseCoding/Sparse coding');
addpath('./SparseCoding/Sparse coding/sc2');
patch_size = 8; % patch size for the low resolution input image
zooming = 2; % zooming factor, if you change this, the dictionary needs to be retrained.
patch_size = patch_size*zooming;
Num_of_Iterations=1000;
DictSize=1024;
testIm2 = double(imread(fname))/255; % testIm is a high resolution image, we downsample it and do super-resolution
imwrite(testIm2, [fname '-original.jpg']);
%testIm size 512X512
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %產生一半大小的小圖
% % % 
% % testIm2 = imresize(testIm, 1/zooming,'bicubic');
% % if rem(size(testIm2,1),zooming) ~=0,
% %     nrow = floor(size(testIm2,1)/zooming)*zooming;
% %     testIm2 = testIm2(1:nrow,:,:);
% % end;
% % if rem(size(testIm2,2),zooming) ~=0,
% %     ncol = floor(size(testIm2,2)/zooming)*zooming;
% %     testIm2 = testIm2(:,1:ncol,:);
% % end;
% % % testIm2 size 256X256
% % imwrite(testIm2, [fname '_block.jpg'],'quality',15);
% % % imwrite(testIm2, [fname '_block.jpg']);
% % testIm2 = double(imread([fname '_block.jpg']))/255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the LR image and regarded it as the training image
interpIm = imresize(testIm2,zooming,'bicubic');
imwrite(interpIm,[fname '_bb.jpg']);
%interpIm size 512X512
% work with the illuminance domain only
lowIm2 = double(rgb2ycbcr(testIm2));
lImy = lowIm2(:,:,1);
% hImcb = lowIm2(:,:,2);
% hImcr = lowIm2(:,:,3);
%lImy size 256X256
% bicubic interpolation for the other two channels
interpIm2 = rgb2ycbcr(interpIm);
HImy = interpIm2(:,:,1);
hImcb = interpIm2(:,:,2);
hImcr = interpIm2(:,:,3);
%==========================================================================
graytest = lImy;
[N1, N2] = size(lImy);
BW = double(edge(graytest,'canny'));
figure;imshow(BW);
imwrite(BW, [fname '_edge.jpg']);
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
%         t12=(BarRpatch1-BarRpatch2);
%         t13=(BarRpatch1-BarRpatch3);
%         t12(isnan(t12))=0;
%         t13(isnan(t13))=0;        
%         if ((abs(e1(1,1)-e2(1,1))>t12(1,1)) && (abs(e1(2,1)-e2(2,1))>t12(2,1)))
%             graytest2(i+8-1:i+8, j:j+8-1)=1;
%             graytest3(i+8-1:i+8, j:j+8-1)=1;
%         end
%         if ((abs(e1(1,1)-e3(1,1))>t13(1,1)) && (abs(e1(2,1)-e3(2,1))>t13(2,1)))
%             graytest2(i:i+8-1, j+8-1:j+8)=1;
%             graytest3(i:i+8-1, j+8-1:j+8)=1;
%         end
        t12=0.0000001;
        t13=0.0000001;        
        if ((abs(e1(1,1)-e2(1,1))>t12) && (abs(e1(2,1)-e2(2,1))>t12))
            graytest2(i+8-1:i+8, j:j+8-1)=1;
            graytest3(i+8-1:i+8, j:j+8-1)=1;
        end
        if ((abs(e1(1,1)-e3(1,1))>t13) && (abs(e1(2,1)-e3(2,1))>t13))
            graytest2(i:i+8-1, j+8-1:j+8)=1;
            graytest3(i:i+8-1, j+8-1:j+8)=1;
        end
    end
end;
%%%%%%%%%%%%%%%%%%%%%%%%%
% graytest = lImy;
figure,imshow(graytest2);
imwrite(graytest, [fname '_graytest.jpg']);
imwrite(graytest2, [fname '_blockartifact.jpg']);
[PSNR_FINAL_ESTIMATE, y_hat_wi1] = BM3D(1, graytest, 'blur');
lImy2 = graytest-y_hat_wi1; 
lImy3=lImy2-min(min(lImy2));
lImy3=lImy3/max(max(lImy3));
figure,imshow(y_hat_wi1);
figure,imshow(lImy3);
imwrite(lImy3, [fname '_highfre.jpg']);
imwrite(y_hat_wi1, [fname '_y_hat_wi1.jpg']);
% lImy2=lImy;
[DictionaryL1 DictionaryLb CoefMatrix CoefMatrixb]=MCA_Image_Decomposition_many(lImy2, graytest3, patch_size, zooming, Num_of_Iterations, DictSize);
[Noblocking Texture_Dict Cartoon_Dict]  = MCA_Image_Decomposition_H(lImy2, graytest3, patch_size, DictSize, DictionaryL1, DictionaryLb, CoefMatrix, CoefMatrixb, 1);
%NB-Cartoon;B-texture
lImy4=imresize(lImy2,zooming,'bicubic');
graytest5=imresize(graytest3,zooming,'bicubic');
graytest6 = (graytest5 >= 0.5);
BW2 =imresize(BW,zooming,'bicubic');
BW3 = (BW2 >= 0.5);
% clear CoefMatrix CoefMatrixb CoefMatrixs
% save onlinedata
% load onlinedata
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
smooth(:,:,1) = y_hat_wi3;%uint8() 
smooth(:,:,2) = hImcb;
smooth(:,:,3) = hImcr;
Smoothresize = ycbcr2rgb(smooth);
imwrite(Smoothresize, [fname '_smoothresize.jpg']);
NonBlocking = y_hat_wi3 + NonBlockingComponent*1.5;
hImy3 = BlockingComponent-min(min(BlockingComponent));
hImy3 = hImy3/max(max(hImy3));
imwrite(hImy3, [fname '_Blocking.jpg']);
figure,imshow(hImy3);
hImy4 = NonBlockingComponent-min(min(NonBlockingComponent));
hImy4 = hImy4/max(max(hImy4));
imwrite(hImy4, [fname '_NonBlocking.jpg']);
figure,imshow(hImy4);
hImy5 = (NonBlockingComponent+BlockingComponent)-min(min(NonBlockingComponent+BlockingComponent));
hImy5 = hImy5/max(max(hImy5));
imwrite(hImy5, [fname '_NonBlockingresult.jpg']);
figure,imshow(hImy5);
Deblocking(:,:,1) = NonBlocking;%uint8() 
Deblocking(:,:,2) = hImcb;
Deblocking(:,:,3) = hImcr;
ReconImRGB1 = ycbcr2rgb(Deblocking);
imwrite(ReconImRGB1, [fname '_result.jpg'])
figure;imshow(ReconImRGB1)
[PSNR_FINAL_ESTIMATE, Deringing] = BM3D(1, NonBlocking, '10');
Deblocking(:,:,1) = Deringing;%uint8() 
Deblocking(:,:,2) = hImcb;
Deblocking(:,:,3) = hImcr;
ReconImRGB2 = ycbcr2rgb(Deblocking);
imwrite(ReconImRGB2, [fname '_result+deringing.jpg'])
figure;imshow(ReconImRGB2)
return;