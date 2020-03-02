function [mnNorm, mn, stderr] = avgAndNorm(allba, bsl, mgw, trAvg)

mgw3 = zeros(1,1,numel(mgw)); mgw3(1,1,:) = mgw; 
allbaSmooth = convn(allba, mgw3, 'same');

mn = squeeze(mean(allbaSmooth(:,trAvg,:),2));
stderr = squeeze(std(allbaSmooth(:,trAvg,:),[],2))./sqrt(sum(trAvg));
% mn = conv2(1, mgw, mn, 'same');
mnNorm = bsxfun(@rdivide, bsxfun(@minus, mn, bsl), bsl+0.5);

end