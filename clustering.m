function [index, center, data] = clustering(data, clusterNum, method)

% mode 4 denotes that no dimensionality reduction method is used.
center = [];
if (method~=4) 
    P = data;
    addPath('Manifold');
    mv=mean(P,2);
    
    invars = cell(1,2);
    invars{1}.para.dim = 3;
    invars{1}.para.opts.PCARatio = 0.98;
    invars{1}.para.opts.ReducedDim = invars{1}.para.dim;
    invars{1}.para.opts.bDisp = 0;
    invars{1}.para.knn = 200;
    
    invars{1}.para.options = [];
    invars{1}.para.options.Metric = 'Euclidean';
    invars{1}.para.options.NeighborMode = 'KNN';
    invars{1}.para.options.k = invars{1}.para.knn;
    invars{1}.para.options.t = 0.0001;
    invars{1}.para.options.WeightMode = 'HeatKernel';
   
    P = P - repmat(mv, 1, size(P, 2));
    invars{1}.data = P;
    invars{2} = method;
    [Y, ~] = DimensionalityReduction(invars);
    
    
    mp1 = zeros(size(Y,2), size(P,2));
    for i=1:size(P,2)
        mp1(:, i) = Y' * P(:, i);
    end
    
    
    figure(2),scatter(mp1(1,:), mp1(2,:), 3, 1:size(mp1, 2), 'filled')
    drawnow;

    
    [index, center2] =soft_kmeans(mp1', clusterNum, 0.2);
    center.T = Y;
    center.cent = center2;
else
%     [index, center] = kmeans(data', clusterNum, 'start', 'uniform');
    [index, center] =soft_kmeans(data', clusterNum, 0.0);
    
end
% save _index.mat index center;
a=1;