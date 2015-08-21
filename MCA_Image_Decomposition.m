function [Cartoon Texture] = MCA_Image_Decomposition(I, blockim, edgemap, n, numIteration, DictSize, Noblocking, TextureDict, CartoonDict, Alg)
warning off;
K = DictSize;
[N1, N2] = size(I);
y=I;
cluster=zeros(1, (N1 - n + 1) * (N2 - n + 1));
patch_size=n;
cnt=1;
for j = 1:1:(N2-patch_size+1)
    for i = 1:1:(N1-patch_size+1)
        patchb = blockim(i:i+patch_size-1, j:j+patch_size-1);         
        if(sum(patchb(:)) == 0)
            cluster(:,cnt) = 2;
            cnt = cnt + 1;
        end      
        if(sum(patchb(:))>0 )            
                cluster(:,cnt) = 2;
                cnt = cnt + 1;            
        end 
    end;
end;
clear Data
Datab = zeros(patch_size^2, length(find(cluster==2)));
Data1 = zeros(patch_size^2, length(find(cluster==1)));
cnt1=1;
cnt2=1;
for j = 1:1:(N2-patch_size+1)
    for i = 1:1:(N1-patch_size+1)
        patch = y(i:i+patch_size-1, j:j+patch_size-1);
        patchb = blockim(i:i+patch_size-1, j:j+patch_size-1);         
        if(sum(patchb(:)) == 0)
            Datab(:,cnt1) = patch(:); 
            cnt1 = cnt1 + 1;
        end      
        if(sum(patchb(:))>0 )            
                Datab(:,cnt1) = patch(:);  
                cnt1 = cnt1 + 1;            
        end 
    end;
end;
%     Data = Data - repmat(mean(Data), [size(Data, 1) 1]);
%     Data = Data ./ repmat(sqrt(sum(Data .^ 2)), [size(Data, 1) 1]);
DictionarySH = [TextureDict(1:patch_size^2,:) CartoonDict(1:patch_size^2,:)];
DictionarySL = [TextureDict(patch_size^2+1:2*patch_size^2,:) CartoonDict(patch_size^2+1:2*patch_size^2,:)];
DictionaryNBH=Noblocking(1:patch_size^2,:);
DictionaryNBL=Noblocking(patch_size^2+1:2*patch_size^2,:);
% DictionaryLsmoothH = [DLS1(1:patch_size^2,:) DLS2(1:patch_size^2,:)];
% DictionaryLsmoothL = [DLS1(patch_size^2+1:2*patch_size^2,:) DLS2(patch_size^2+1:2*patch_size^2,:)];


DictionarySL = DictionarySL ./ repmat(sqrt(sum(DictionarySL .^ 2)), [size(DictionarySL, 1) 1]);
DictionaryNBL = DictionaryNBL ./ repmat(sqrt(sum(DictionaryNBL .^ 2)), [size(DictionaryNBL, 1) 1]);
% DictionaryLsmoothL = DictionaryLsmoothL ./ repmat(sqrt(sum(DictionaryLsmoothL .^ 2)), [size(DictionaryLsmoothL, 1) 1]);
param.K = DictSize;
param.lambda = 0.15;
param.iter = numIteration;
param.L = 20; 
param.eps = 0.05; 
CoefMatrixb = mexOMP(Datab, DictionarySL, param);
param.L = 20; 
param.eps = 0.05; 
CoefMatrix = mexOMP(Data1, DictionaryNBL, param);


CoefMatrixs1 = 0;
CoefMatrixs2 = 0;
DictionaryLsmoothH=zeros(3,3);
DLS1=zeros(2,1);
DLS2=zeros(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%
CoefMatrixTexture = CoefMatrixb(1:size(TextureDict, 2), :);
CoefMatrixCartoon = CoefMatrixb((size(TextureDict, 2) + 1):(size(TextureDict, 2) + size(CartoonDict, 2)), :);

% Texture = RecoverImage(y, N1, N2, 0, DictionarySH(:, 1:size(TextureDict, 2)), CoefMatrixTexture);
% Cartoon =  RecoverImage(y, N1, N2, 0, DictionarySH(:, (size(TextureDict, 2) + 1):(size(TextureDict, 2) + size(CartoonDict, 2))), CoefMatrixCartoon);
% % Cartoon = RecoverImage(y, N1, N2, 0, DictionaryH, CoefMatrixCartoon);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
Texture = RecoverImageb(y, cluster, N1, N2, 0, DictionarySH(:, 1:size(TextureDict, 2)),DictionaryLsmoothH(:,1:size(DLS1,2)), CoefMatrixTexture,CoefMatrixs1);
Cartoon = RecoverImage(y, cluster, N1, N2, 0, DictionaryNBH, DictionarySH(:, (size(TextureDict, 2) + 1):(size(TextureDict, 2) + size(CartoonDict, 2))),DictionaryLsmoothH(:,size(DLS1,2)+1:size(DLS1,2)+size(DLS2,2)), CoefMatrix, CoefMatrixCartoon,CoefMatrixs2);
return;

function yout=RecoverImageb(y, cluster, N1, N2, lambda, D,DS, CoefMatrix,CoefMatrixs)
n=sqrt(size(D,1)); 
yout=zeros(N1,N2); 
Weight=zeros(N1,N2); 
cnt=1;
cnt1=1;
cnt2=1;
i=1; j=1;
for k=1:1:(N1-n+1)*(N2-n+1)    
    if (cluster(cnt)==2)
        patch=reshape(D*CoefMatrix(:,cnt1),[n,n]); 
        yout(i:i+n-1,j:j+n-1)=yout(i:i+n-1,j:j+n-1)+patch; 
        Weight(i:i+n-1,j:j+n-1)=Weight(i:i+n-1,j:j+n-1)+1; 
        cnt1=cnt1+1;
    end
    if (cluster(cnt)==3)
        patch=reshape(DS*CoefMatrixs(:,cnt1),[n,n]); 
        yout(i:i+n-1,j:j+n-1)=yout(i:i+n-1,j:j+n-1)+patch; 
        Weight(i:i+n-1,j:j+n-1)=Weight(i:i+n-1,j:j+n-1)+1; 
        cnt2=cnt2+1;
    end
    cnt=cnt+1;
    if i<N1-n+1 
        i=i+1; 
    else
        i=1; j=j+1; 
    end;
end;
yout=(yout+lambda*y)./(Weight+lambda); 
return;

function yout=RecoverImage(y, cluster, N1, N2, lambda, D, DB,DS, CoefMatrix, CoefMatrixCartoon,CoefMatrixs)
n=sqrt(size(D,1)); 
yout=zeros(N1,N2); 
Weight=zeros(N1,N2); 
cnt=1;
cnt1=1;
cnt2=1;
cnt3=1;
i=1; j=1;
for k=1:1:(N1-n+1)*(N2-n+1)
    if (cluster(cnt)==1)
        patch=reshape(D*CoefMatrix(:,cnt1),[n,n]); 
        yout(i:i+n-1,j:j+n-1)=yout(i:i+n-1,j:j+n-1)+patch; 
        Weight(i:i+n-1,j:j+n-1)=Weight(i:i+n-1,j:j+n-1)+1; 
        cnt1=cnt1+1;
    end
    if (cluster(cnt)==2)
        patch=reshape(DB*CoefMatrixCartoon(:,cnt2),[n,n]); 
        yout(i:i+n-1,j:j+n-1)=yout(i:i+n-1,j:j+n-1)+patch; 
        Weight(i:i+n-1,j:j+n-1)=Weight(i:i+n-1,j:j+n-1)+1; 
        cnt2=cnt2+1;
    end
    if (cluster(cnt)==3)
        patch=reshape(DS*CoefMatrixs(:,cnt3),[n,n]); 
        yout(i:i+n-1,j:j+n-1)=yout(i:i+n-1,j:j+n-1)+patch; 
        Weight(i:i+n-1,j:j+n-1)=Weight(i:i+n-1,j:j+n-1)+1; 
        cnt3=cnt3+1;
    end
    cnt=cnt+1;
    if i<N1-n+1 
        i=i+1; 
    else
        i=1; j=j+1; 
    end;
end;
yout=(yout+lambda*y)./(Weight+lambda); 
return;