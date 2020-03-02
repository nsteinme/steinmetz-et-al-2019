


function [winSamps, bsByTr, bsByTrP, bsByTrR] = computeRegTraces(...
    bs, residBS, predBs, win, bsBinSize, inclTimes, km, bsl, evTimes)




% compute firing rate from BS, and prediction from kernel reg


% rbs is the prediction we must have had at the beginning, to get
% these residuals
rbs = bs-residBS;

% A = r(n).A;
allbs = nan(size(inclTimes)); allpbs = nan(size(inclTimes));
allrbs = nan(size(inclTimes)); allresidbs = nan(size(inclTimes));
allbs(inclTimes) = bs; allpbs(inclTimes) = predBs;
allrbs(inclTimes) = rbs; allresidbs(inclTimes) = residBS;

% bsl = r(n).bslVals(cn);
allbs = allbs+bsl; allpbs = allpbs+bsl;
allrbs = allrbs+bsl; allresidbs = allresidbs+bsl;

winSamps = win(1):bsBinSize:win(end);
bsByTr = interp1(km.tN', allbs, evTimes+winSamps);
bsByTrP = interp1(km.tN', allpbs, evTimes+winSamps);
bsByTrR = interp1(km.tN', allrbs, evTimes+winSamps);
% bsByTrResid = interp1(km.tN', allresidbs, evTimes+winSamps);

