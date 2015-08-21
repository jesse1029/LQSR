function [Noblocking Texture_Dict Cartoon_Dict] = MCA_Image_Decomposition_H(I, blockim, n, DictSize, DicL, DicLb, CoefMatrix, CoefMatrixb, Alg)
warning off;

K = DictSize;
[N1, N2] = size(I);
y = I;
patch_size=n;
Data = zeros(patch_size^2, (N1 - patch_size + 1) * (N2 - patch_size + 1));
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
                cnt2 = cnt2 - 1;
        end 
    end;
end;
Data1=Data(:,1:cnt1-1);
Datab=Data(:,cnt2+1:(N1 - patch_size + 1) * (N2 - patch_size + 1));
clear Data Datas
Data1 = Data1 - repmat(mean(Data1), [size(Data1, 1) 1]);
Data1 = Data1 ./ repmat(sqrt(sum(Data1 .^ 2)), [size(Data1, 1) 1]);
Datab = Datab - repmat(mean(Datab), [size(Datab, 1) 1]);
Datab = Datab ./ repmat(sqrt(sum(Datab .^ 2)), [size(Datab, 1) 1]);
lambda = 0.15;
[DicH1] = reg_sparse_coding(Data1, DictSize, [], 0, lambda, 1,size(Data1, 2), DicL, CoefMatrix);
[DicHb] = reg_sparse_coding(Datab, DictSize, [], 0, lambda, 1,size(Datab, 2), DicLb, CoefMatrixb);
% DicH1=Data1/CoefMatrix;
% DicHb=Datab/CoefMatrixb;
% load DicH
Noblocking=[DicH1;DicL];
Dicsmooth=0;
DictionaryF=[DicHb;DicLb];

PHOG = zeros(36, K);
    VarTheta = zeros(1, K);
    for k=1:1:K        
        atom = reshape(DictionaryF(1:(n)^2, k), [n,n]);
        PHOG(:, k) = HOG(atom);
        [BW, thresh, gv, gh] = edge(atom, 'sobel');
        %Theta = atan2(gv, gh);
        %VarTheta(k) = var(Theta(:)); 
    end
    %VarTheta = VarTheta / max(abs(VarTheta));
    VarTheta = sum(PHOG);
    %AtomFeature = PHOG';
    
    % K-means clustering
    [IDX, C] = kmeans(VarTheta, 2, 'maxiter', 100);
    Atom1 = find(IDX == 1)';
    Atom2 = find(IDX ~= 1)';
    VarTheta1 = mean(abs(VarTheta(Atom1)));
    VarTheta2 = mean(abs(VarTheta(Atom2)));
    
    if Alg == 2
    else
        if (VarTheta1 >= VarTheta2)
            TextureAtoms = Atom1;
            CartoonAtoms = Atom2;
            %fprintf(1, 'Texture->Norm(C1) = %.2f, size(C1) = %d, VarTheta(C1) = %.2f.\n', norm(C(1, :)), size(Atom1, 2), VarTheta1);
            %fprintf(1, 'Cartoon->Norm(C2) = %.2f, size(C2) = %d, VarTheta(C2) = %.2f.\n', norm(C(2, :)), size(Atom2, 2), VarTheta2);
        else
            TextureAtoms = Atom2;
            CartoonAtoms = Atom1;
            %fprintf(1, 'Texture->Norm(C2) = %.2f, size(C2) = %d, VarTheta(C2) = %.2f.\n', norm(C(2, :)), size(Atom2, 2), VarTheta2);
            %fprintf(1, 'Cartoon->Norm(C1) = %.2f, size(C1) = %d, VarTheta(C1) = %.2f.\n', norm(C(1, :)), size(Atom1, 2), VarTheta1);
        end
    end
    temp_TextureDict = DictionaryF(:, TextureAtoms);
    temp_CartoonDict = DictionaryF(:, CartoonAtoms);
    %%
    temp_k=size(temp_CartoonDict,2);
    Dictionary = temp_CartoonDict;
    PHOG = zeros(36, temp_k);
    VarTheta = zeros(1, temp_k);
    for k=1:1:temp_k
        atom = reshape(Dictionary(1:(n)^2, k), [n,n]);
        PHOG(:, k) = HOG_V(atom);
        [BW, thresh, gv, gh] = edge(atom, 'sobel');
        %Theta = atan2(gv, gh);
        %VarTheta(k) = var(Theta(:)); 
    end
    %VarTheta = VarTheta / max(abs(VarTheta));
    VarTheta = sum(PHOG);
    %AtomFeature = PHOG';
    
    % K-means clustering
    [IDX, C] = kmeans(VarTheta, 2, 'maxiter', 100);
    Atom1 = find(IDX == 1)';
    Atom2 = find(IDX ~= 1)';
    VarTheta1 = mean(abs(VarTheta(Atom1)));
    VarTheta2 = mean(abs(VarTheta(Atom2)));
    
    if Alg == 2
    else
        if (VarTheta1 >= VarTheta2)
            TextureAtoms = Atom1;
            CartoonAtoms = Atom2;
            %fprintf(1, 'Texture->Norm(C1) = %.2f, size(C1) = %d, VarTheta(C1) = %.2f.\n', norm(C(1, :)), size(Atom1, 2), VarTheta1);
            %fprintf(1, 'Cartoon->Norm(C2) = %.2f, size(C2) = %d, VarTheta(C2) = %.2f.\n', norm(C(2, :)), size(Atom2, 2), VarTheta2);
        else
            TextureAtoms = Atom2;
            CartoonAtoms = Atom1;
            %fprintf(1, 'Texture->Norm(C2) = %.2f, size(C2) = %d, VarTheta(C2) = %.2f.\n', norm(C(2, :)), size(Atom2, 2), VarTheta2);
            %fprintf(1, 'Cartoon->Norm(C1) = %.2f, size(C1) = %d, VarTheta(C1) = %.2f.\n', norm(C(1, :)), size(Atom1, 2), VarTheta1);
        end
    end
    TextureDict = Dictionary(:, TextureAtoms);
    CartoonDict = Dictionary(:, CartoonAtoms);
    %Dictionary =[temp_TextureDict TextureDict CartoonDict];
    %%
    Texture_Dict = [temp_TextureDict TextureDict];
    %Cartoon_Dict = [temp_CartoonDict CartoonDict];
    %if max(size(CartoonDict))<=1024
        Cartoon_Dict = CartoonDict;
    %else
    %    param.L = 10; 
    %    param.eps = 0.1; 
    %   CoefMatrix = mexOMP(Data, CartoonDict, param);
    %    CoefMatrix =full(CoefMatrix);
    %    index =sum(CoefMatrix,2);
    %    index =sort(index);
    %   index=index(max(size(index))-1023:max(size(index)));
    %    Cartoon_Dict = CartoonDict(:,index);
    %end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
return;