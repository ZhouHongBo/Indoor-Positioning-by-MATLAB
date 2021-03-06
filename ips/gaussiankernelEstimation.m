% Estimate locations based on Gaussian assumption.
% 
% Args:
%     samples: 训练集样本
%     query: 测试集样本
%     positions: 训练集样本的位置
%     sigma: 核函数的宽度
%     k: 最近邻个数
% 
% Returns:
%     prediction: 预测位置 
function [prediction] = gaussiankernelEstimation(samples, query, positions, sigma, k)
    % number of reference points in training database
    numFps = size(samples, 1);
    % number of query points in test data
    numQ = size(query,1);
    % allocate memory for output
    prediction = zeros(numQ, 3);

    % set optionally not detected APs to NaN, can provide robustness
    samples(samples==-105) = NaN;
    query(query==-105) = NaN;

    % treat each RSS measurement as independent fingerprint and ignore the 6
    % samples that are associated to the same fingerprint location
    for i = 1:numQ   % For each query sample
        queryMat = repmat(query(i,:), numFps, 1);

        % Associate each point a probability / cost corresponding to the
        % likelihood that the current RSS vector corresponds to that position

        % probability for each AP in each point using Gaussian similarity
        likelihoodMatrix = 1/sqrt(2*pi*sigma^2) ...
            * exp(-(samples - queryMat).^2/(2*sigma^2));
        % replace zeros with a very small value
        likelihoodMatrix(isnan(likelihoodMatrix)) = 1e-6;
        % use logaritmic probabilities for incraesed efficiency and stability
        likelihoodMatrix = log(likelihoodMatrix);
        % combine individual likelihoods
        costFunction = sum(likelihoodMatrix,2);

        % compute position estimate as average of k most likely positions
        k = min(k, numFps);
        prediction(i,:) = estimateKNN(costFunction, positions, k);
    end
end

% Estimate position being the average of k-likeliest positions
function [estPos, w] = estimateKNN(cf, positions, k)
    [~, idx] = sort(cf, 1, 'descend');
    ests = positions(idx(1:k),:);
    % indicator of quality of estimate
    w = sum(cf(idx(1:k))) / k;

    estPos = [mean(ests(:,1:2), 1), mode(floor(ests(:,3)), 1)];
end

