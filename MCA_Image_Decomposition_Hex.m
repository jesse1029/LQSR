function [CoefMatrix] = MCA_Image_Decomposition_Hex(Xh, Xl, numIteration, DictSize, Dictionary)
warning off;

K = DictSize;
Data=Xl;
    %Data = Data - repmat(mean(Data), [size(Data, 1) 1]);
    %Data = Data ./ repmat(sqrt(sum(Data .^ 2)), [size(Data, 1) 1]);
Dictionary = Dictionary ./ repmat(sqrt(sum(Dictionary .^ 2)), [size(Dictionary, 1) 1]);
param.K = DictSize;
param.lambda = 0.15;
param.iter = numIteration;
param.L = 10; 
param.eps = 0.1; 
CoefMatrix = mexOMP(Data, Dictionary, param);
return;