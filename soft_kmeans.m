function [index, center, data] = soft_kmeans(data, clusterNum, degree)

% Processing
data = data/max(data(:));
% parameter
beta = 3;

sampleNum = size(data, 1);
featureNum = size(data, 2);
step = floor(sampleNum / clusterNum);
% residue = sampleNum - step * clusterNum;

% Get the initial centers
cen = zeros(clusterNum, featureNum);
prvcen = cen;

[index1, cen] = kmeans(data, clusterNum, 'start', 'uniform');
if (degree == 0)
    center = cen;
    index = index1;
    return;
end

iter = 0;
while(1)
    iter = iter + 1;
    % Get the degree values of samples.
    dis = zeros(sampleNum, clusterNum);
    R = zeros(sampleNum, clusterNum);
    % 1. Get the distance information first
    for i=1:sampleNum
        for j=1:clusterNum
            dis(i, j) = sum(sqrt((cen(j,:) - data(i, :)).^2));
        end
    end
    % 2. Computing the degree values.
    bases = sum(dis, 2);
    for i=1:sampleNum
        for j=1:clusterNum
            R(i, j) = (exp(-beta*dis(i, j))) / exp(-beta*bases(i)); % scalar
        end
    end
    
    % Updating the centers
    for i=1:clusterNum
        % mean-vector
        cen(i, :) = sum(repmat(R(:, i), 1, featureNum) .* data, 1) ./ sum(R(:,i));
    end
    
    % Criterion for convergence testing
    err = abs(prvcen-cen);
    err = sum(err(:));
    prvcen = cen;
    if (err<1e-15 || iter>500), break; end
    test(1,iter) = err;
end
figure(921), plot(test); drawnow;
center = cen;
% Get the index
% index = (R-min(R(:)))/(max(R(:))-min(R(:)));

index = zeros(size(R));
for i=1:clusterNum
    step = length(find(index1==i));
    step = round(step + step*degree); % Number of the samples in each cluster
    if (step>size(data,2)), step = round(step * 0.9); end
    [~, idx] = sort(R(:, i), 'descend');
    index(idx(1:step), i) = i;
end

