


function [km, binnedSpikes, inclU, inclTimes, trNum, cweA, cwtA, pvals, bslMeans, effectSizes] = ...
    kernelFitBasic(sp, cweA, cwtA, moveData)






%% load some data
% r = listInclRecs();
% n = 9; 
% mouseName = r(n).mouseName; thisDate = r(n).thisDate; 
% tags = getEphysTags(mouseName, thisDate);
% [sp, cweA, cwtA, moveData, lickTimes] = alf.loadCWAlf(mouseName, thisDate, tags{2});


%% choose trials/events
winCountMove = [0.125 0.4];
winNoMove = [-0.05 0.4];
timeBinSize = 0.005;

% trying to fix edge effects by rounding each stim event to the nearest
% time bin... :/ 
% cwtA.stimOn = round(cwtA.stimOn/timeBinSize)*timeBinSize;

stimOn = cwtA.stimOn;
cL = cweA.contrastLeft; 
cR = cweA.contrastRight;
choice = cweA.choice;
fb = cweA.feedback; 
inclT = cweA.inclTrials;

rewNogo = cwtA.feedbackTime(inclT & choice==3 & fb==1);

ucl = unique(cL);
ucr = unique(cR);

[moveTimeUse, firstMoveType, firstMoveTime, hasNoMoveInWin] = ...
                findMoveTimes(cweA, cwtA, moveData, winCountMove, winNoMove);

hasLeftMove = firstMoveTime<winCountMove(2) & firstMoveTime>winCountMove(1) & firstMoveType==1;
hasRightMove = firstMoveTime<winCountMove(2) & firstMoveTime>winCountMove(1) & firstMoveType==2;
moveTimeAbs = moveTimeUse+cwtA.stimOn;

% also fixing these times with rounding
% moveTimeAbs = round(moveTimeAbs/timeBinSize)*timeBinSize;

inclT = inclT & (hasLeftMove | hasRightMove | hasNoMoveInWin);           

% moveTimeUse = moveTimeUse+cwtA.stimOn;

cweA = addvars(cweA, inclT, hasLeftMove, hasRightMove, hasNoMoveInWin, firstMoveType);
cwtA = addvars(cwtA, moveTimeUse, moveTimeAbs);

%% bin spikes

maxT = cwtA.feedbackTime(end)+5;


theseST = sp.st;
clu = sp.clu;

cids = unique(clu);
if numel(cids)==1
    
    binBorders = 0:timeBinSize:maxT;
    tN = binBorders(1:end-1)+timeBinSize/2;
    
    binnedSpikes = histc(theseST, binBorders)./timeBinSize; % dividing here converts to Hz;
    binnedSpikes = binnedSpikes(1:end-1);
    binnedSpikes = binnedSpikes(:);
else
    
    theseClu = double(clu(theseST<maxT & theseST>0));
    theseST = theseST(theseST<maxT & theseST>0);    
    binnedSpikes = full(sparse(ceil(theseST./timeBinSize), theseClu+1, ones(size(theseST))));
    binnedSpikes = binnedSpikes(:,cids+1); % these are the clusters that exist
    binnedSpikes = binnedSpikes./timeBinSize; % convert to spikes/s
    binBorders = (0:size(binnedSpikes,1))*timeBinSize;
    tN = (0:size(binnedSpikes,1)-1)*timeBinSize+timeBinSize/2;
end

% smoothing? 
mgw = myGaussWin(0.025, 1/timeBinSize);
mgw(1:round(numel(mgw)/2)-1) = 0; mgw = mgw./sum(mgw);

binnedSpikes = conv2(mgw, 1, binnedSpikes, 'same');


%% select neurons

% inclusion criterion: mean rate across the key window is greater than
% 0.1sp/s

trTimes = stimOn(inclT)+[0:timeBinSize:winNoMove(end)]; 
trRates = interp1(tN, binnedSpikes, trTimes);
trRates = squeeze(mean(trRates,2));

trMeans = squeeze(mean(trRates))';

inclU = trMeans>0.1 & sp.cgs>1;

bslTimes = stimOn(inclT)+[-0.2:timeBinSize:0]; 
bslRates = interp1(tN, binnedSpikes, bslTimes);
bslRates = squeeze(mean(bslRates,2));

stimTimes = stimOn(inclT)+[0.05:timeBinSize:0.15]; 
stimRates = interp1(tN, binnedSpikes, stimTimes);
stimRates = squeeze(mean(stimRates,2));

mvTimes = moveTimeAbs(inclT&(hasLeftMove|hasRightMove))+[-0.1:timeBinSize:0.05]; 
mvRates = interp1(tN, binnedSpikes, mvTimes);
mvRates = squeeze(mean(mvRates,2));
mTr = (hasLeftMove|hasRightMove); mTr = mTr(inclT);
hasR = hasRightMove(inclT); hasL = hasLeftMove(inclT); 

periMvTimes = moveTimeAbs(inclT&(hasLeftMove|hasRightMove))+[-0.05:timeBinSize:0.2]; 
periMvRates = interp1(tN, binnedSpikes, periMvTimes);
periMvRates = squeeze(mean(periMvRates,2));

rewTimes = rewNogo+[0:timeBinSize:0.15]; 
rewRates = interp1(tN, binnedSpikes, rewTimes);
rewRates = squeeze(mean(rewRates,2));

% pick ones only that have significantly different bsl and trial rates
pvals = nan(numel(inclU),6);
effectSizes = nan(numel(inclU),6);
for q = 1:numel(inclU)
    if inclU(q)
        xx = trRates(:,q)-bslRates(:,q);
        pvals(q,1) = signrank(xx); 
        effectSizes(q,1) = sum(xx>0)-sum(xx<0);
        
        xx = stimRates(:,q)-bslRates(:,q);
        pvals(q,2) = signrank(xx); 
        effectSizes(q,2) = sum(xx>0)-sum(xx<0);
        
        xx = mvRates(:,q)-bslRates(mTr,q);
        pvals(q,3) = signrank(xx);
        effectSizes(q,3) = sum(xx>0)-sum(xx<0);
        
        [pvals(q,4),~,stat] = ranksum(mvRates(hasR(mTr),q), mvRates(hasL(mTr),q));
        nullRank = sum(hasR(mTr))*(sum(hasR(mTr))+sum(hasL(mTr)))/2;
        effectSizes(q,4) = stat.ranksum-nullRank; %positive value means that hasR is greater
        
        % these two aren't used for selecting neurons for subsequent
        % analysis, but are used for reporting what's responsive to
        % something
        xx = periMvRates(:,q)-bslRates(mTr,q);
        pvals(q,5) = signrank(xx);
        effectSizes(q,5) = sum(xx>0)-sum(xx<0); %% positive value means periMvRates is greater
        
        [pvals(q,6),~,stat] = ranksum(rewRates(:,q), bslRates(:,q));
        nullRank = numel(rewRates(:,q))*(numel(rewRates(:,q))+numel(bslRates(:,q)))/2;
        effectSizes(q,6) = stat.ranksum-nullRank;
        
        if all(pvals(q,1:4)>0.05) % this is a BUG!
            % the pval will be 'nan' from ranksum if all entries are zero
            % in both sets to be compared. This is because the test starts
            % by dropping all zeros. But really, it is stupid because it
            % ought to return p=1 - clearly the distributions are not
            % different in that case. So, this command is false when one of
            % the values is NaN, and the neuron is kept for inclusion.
            % HOWEVER, if this was the only reason it was failing, then it
            % should have passed since the 'real' pvalue is 1, and it
            % should have been excluded. It seems this happened for ~1000
            % neurons over the whole dataset. But, it's too late to fix it
            % today, and the penalty isn't high: it just means some
            % non-responsive neurons were accidentally included. 
            % The correction is to use "~any" rather than "all"... :/ 
            inclU(q) = false;
        end
            
    end
end

fprintf(1, 'inclusion: %d / %d / %d\n', sum(inclU), sum(~isnan(pvals(:,1))), numel(inclU));

toUse = ~isnan(pvals(:,1));
alpha = 0.05/size(pvals,2); 
nResp = sum(any(pvals(toUse,:)<alpha,2));
fprintf(1, 'responsive: %d (%.1f)\n', nResp, 100*nResp/sum(toUse));

% subtract baseline
bslMeans = squeeze(mean(bslRates))';

binnedSpikes = bsxfun(@minus, binnedSpikes, bslMeans');
binnedSpikes = binnedSpikes(:,inclU);

%% now fitting: first the shape, then the amplitudes

fprintf(1, 'kernel fitting...\n');

stimWin = [-0.05 0.4];
moveWin = [-0.25 0.025];


% define events

% moveTimeAbs = moveTimeUse+cwtA.stimOn;
% eventTimes = {stimOn(inclT&(cL>0|cR>0)),...
%     moveTimeAbs(inclT&(hasLeftMove|hasRightMove))};
% eventValues = cellfun(@(x)ones(size(x)), eventTimes, 'uni', false);
% windows = {stimWin, moveWin};
% eventNames = {'stim', 'move'};


eventTimes = {stimOn(inclT&cL==ucl(2)), ...
    stimOn(inclT&cL==ucl(3)), ...
    stimOn(inclT&cL==ucl(4)), ...
    stimOn(inclT&cR==ucr(2)), ...
    stimOn(inclT&cR==ucr(3)), ...
    stimOn(inclT&cR==ucr(4)),...
    moveTimeAbs(inclT&(hasLeftMove|hasRightMove)),...
    moveTimeAbs(inclT&(hasLeftMove|hasRightMove))};
moveDir = zeros(size(inclT)); moveDir(hasLeftMove) = 1; moveDir(hasRightMove) = -1;
eventValues = cellfun(@(x)ones(size(x)), eventTimes, 'uni', false);
eventValues{end} = moveDir(inclT&(hasLeftMove|hasRightMove));
windows = {stimWin, stimWin, stimWin, ...
    stimWin, stimWin, stimWin, moveWin, moveWin};
eventNames = {'stimLeft1', 'stimLeft2', ...
    'stimLeft3', 'stimRight1', 'stimRight2', ...
    'stimRight3', 'moveBoth', 'moveLminusR'};

% create kernels
km = KernelModel('toeplitz', tN, 1);
km.setLambda([]);

for e = 1:numel(eventNames)
    es = KernelEventSeries(eventNames{e}, eventTimes{e}, eventValues{e}, windows{e});
    
    pt = es.predictorTimes(timeBinSize);
    
    predVals = ceil((pt-es.window(1)+10e-9)/timeBinSize);

    for p = 1:numel(unique(predVals))
        pr = zeros(size(pt));
        pr(predVals==p) = 1;
        es.addPredictor(pr, timeBinSize);
    end
    
    km.addEventSeries(es);
end

km.generatePredictor;

%% what times to analyze

trStart = stimOn+stimWin(1);
trEndS = stimOn+stimWin(end);
trEndM = max(tN)*ones(size(trEndS));
trEndM(hasLeftMove|hasRightMove) = moveTimeAbs(hasLeftMove|hasRightMove)+moveWin(2);
trEnd = min(trEndS, trEndM);

trNum = WithinRanges(tN, [trStart(inclT) trEnd(inclT)], (1:sum(inclT))', 'vector')';
inclTimes = trNum>0;

%% fit

% A = km.A;
% nPred = km.nPred;
% bs = vertcat(binnedSpikes, zeros(nPred,size(binnedSpikes,2))); % zeros are for regularization

% predictableTimes = sum(A(:,1:end-1)~=0,2)>0;

% X = A(predictableTimes,:)\bs(predictableTimes,:);

% nComp = 30;
% [a, b, R2] = CanonCor2(bs(predictableTimes,:), A(predictableTimes,:));
% [a, b, R2] = CanonCor2all({bs(predictableTimes,:)}, {A(predictableTimes,:)});
% X = b(:,1:nComp) * a(:,1:nComp)';

% bsPred = A*X;
% bsPred = bsPred(1:size(binnedSpikes,1),:);

% km.X = X;
fprintf(1, '  done.\n');