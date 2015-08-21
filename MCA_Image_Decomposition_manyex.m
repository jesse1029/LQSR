function [Dictionary] = MCA_Image_Decomposition_manyex(I , n, zooming, numIteration, DictSize, TextureDict, CartoonDict, Alg)
warning off;

    K = DictSize;
    Data=I;
    % On-line learning
    Data = Data - repmat(mean(Data), [size(Data, 1) 1]);
    Data = Data ./ repmat(sqrt(sum(Data .^ 2)), [size(Data, 1) 1]);
    param.K = DictSize;
    param.lambda = 0.15;
    param.iter = numIteration;
    Dictionary = mexTrainDL(Data, param);
