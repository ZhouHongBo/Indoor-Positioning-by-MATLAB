% 随机方法
% 
% Args:
%     samples: 训练集样本
%     query: 测试集样本
%     positions: 训练集样本的位置
%     k: 随机选取的RP数
% 
% Returns:
%     prediction: 预测位置 
function [estimates] = randomEstimation(samples, query, positions, k)
    [pos, ~, ~] = unique(positions, 'rows');
    nPoints = size(pos,1);
    nQuery = size(query,1);
    neighbors = ceil(nPoints*rand(nQuery,k));   % Get a random position
    estimates = zeros(nQuery,3);
    
    for i = (1:nQuery)
        ns = neighbors(i,:);
        estimates(i,1) = mean(pos(ns,1));
        estimates(i,2) = mean(pos(ns,2));
        estimates(i,3) = mode(pos(ns,3));
    end
end