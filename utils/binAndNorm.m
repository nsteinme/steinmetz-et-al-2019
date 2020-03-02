
function [allba, mnNorm, bins, mn] = binAndNorm(st, clu, evt, binSize, win, bsl, mgw, trAvg)
[allba, bins] = makeAllBA(st, clu, evt, binSize, win);
allba = allba./binSize; % Hz

if isempty(bsl)
    bsl = mean(mean(allba(:,:,bins<0),3),2);
end

[mnNorm, mn] = avgAndNorm(allba, bsl, mgw, trAvg);
end