function [DicL1 DicLb CoefMatrix CoefMatrixb] = MCA_Image_Decomposition_many(I, blockim, n, zooming, numIteration, DictSize)
warning off;

K = DictSize;
[N1, N2] = size(I);
Il = imresize(I,1/zooming,'bicubic');
Il = imresize(Il,zooming,'bicubic');
pic2 = zeros(N1, N2);
y = Il;
patch_size=n;
Data = zeros(patch_size^2, (N1 - patch_size + 1) * (N2 - patch_size + 1));
cnt=1;
cnt1 = 1; 
cnt2 = (N1 - patch_size + 1) * (N2 - patch_size + 1);
for j = 1:1:(N2-patch_size+1)
    for i = 1:1:(N1-patch_size+1)
        patch = y(i:i+patch_size-1, j:j+patch_size-1);
        patchb = blockim(i:i+patch_size-1, j:j+patch_size-1);
        if(sum(patchb(:)) == 0)
            Data(:,cnt1) = patch(:); 
            cnt1 = cnt1 + 1;
        end      
        if(sum(patchb(:))>0 )            
            Data(:,cnt2) = patch(:);  
            pic2(i:i+patch_size-1, j:j+patch_size-1) = patch;
            cnt2 = cnt2 - 1;            
        end 
    end;
end;
    % On-line learning
    Data1=Data(:,1:cnt1-1);
    Datab=Data(:,cnt2+1:(N1 - patch_size + 1) * (N2 - patch_size + 1),:);
    clear Data Datas
    Data1 = Data1 - repmat(mean(Data1), [size(Data1, 1) 1]);
    Data1 = Data1 ./ repmat(sqrt(sum(Data1 .^ 2)), [size(Data1, 1) 1]);
    Datab = Datab - repmat(mean(Datab), [size(Datab, 1) 1]);
    Datab = Datab ./ repmat(sqrt(sum(Datab .^ 2)), [size(Datab, 1) 1]);
    param.K = DictSize;
    param.lambda = 0.15;
    param.iter = numIteration;
    param.L = 20; 
    param.eps = 0.001; 
    DicL1 = mexTrainDL(Data1, param);
    DicLb = mexTrainDL(Datab, param);
    Dictionary = DicL1 ./ repmat(sqrt(sum(DicL1 .^ 2)), [size(DicL1, 1) 1]);
    CoefMatrix = mexOMP(Data1, Dictionary, param);
    %%%%%%%%%%%%%%%%%%%%%%
    Dictionaryb = DicLb ./ repmat(sqrt(sum(DicLb .^ 2)), [size(DicLb, 1) 1]);
    CoefMatrixb = mexOMP(Datab, Dictionaryb, param);
return;

