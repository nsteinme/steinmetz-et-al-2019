
function [Acos,newPredInds] = makeCosReg(km, cosSep, A, trNum)

% make cos function
% cosSep = 0.05; % sec, from Park & Pillow
cosF = 1/(cosSep*4); % Hz
cosSep = cosSep/km.timeBinSize;
cosSamps = 1/cosF/km.timeBinSize;
cosFcn = (1-cos(linspace(0, 2*pi, cosSamps)))/2;

% figure out which columns of the toeplitz are our seed here
keepP = []; newPredInds = [];
for e = 1:numel(km.eventSeries)
    pidx = find(km.predictorInds==e);
    keepP = [keepP pidx(round(round(cosSep/2):cosSep:end))];
    newPredInds = [newPredInds e*ones(1,numel(pidx(round(round(cosSep/2):cosSep:end))))];
end

% for each trial, make the cos-convolved version
tidx = unique(trNum);
Acos = zeros(size(A,1), numel(keepP));
for t = 1:numel(tidx)
    theseT = trNum==tidx(t);
    q = arrayfun(@(x)conv(A(theseT,x),cosFcn,'same'),keepP,'uni',false);
    Acos(theseT,:) = horzcat(q{:});
end