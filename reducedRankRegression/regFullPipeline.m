


% FULL PIPELINE for reduced rank regression, start to finish

% *******
% IMPORTANT. Should import code from canonCorAll_LR and crossValExcludingK
% -- while so doing, need to fix the evaluation of cross validated
% performance to include only up to time of movement onset though kernel
% will go on longer than that (to resolve stupid misalignment bug). 
% -- so, time to re-run. consider doing long process of finding right dims
% to use for each neuron. 
% -- also good single example neuron plotting code in there canonCorAll_LR

%% load basic
addpath(genpath('F:\Dropbox\ucl\code\analysisScripts\CoriMullerRadnitz\'))

av = readNPY('J:/allen/annotation_volume_10um_by_index.npy');
st = loadStructureTree();
r = loadInclRecs(av, st, 'noSpDetail');

%% load part 2


% ii = 0;
for n = 1%:numel(r)           
    fprintf(1, '%d...\n', n);
    [km, binnedSpikes, inclU, inclTimes, trNum, cweA, cwtA, pvals, bslVals] = ...
        kernelFitBasic(r(n).sp, r(n).cweA, r(n).cwtA, r(n).moveData);


    A = km.A;
    nPred = km.nPred;
    if ~isempty(km.lambda)
        bs = vertcat(binnedSpikes, zeros(nPred,size(binnedSpikes,2))); % zeros are for regularization
    else
        bs = binnedSpikes; % no regularization now
    end
%     predictableTimes = sum(A(:,1:end-1)~=0,2)>0;
    
    r(n).inclTimes = inclTimes;
    r(n).trNum = trNum(inclTimes);
    r(n).inclU = inclU;
    r(n).bs = bs(inclTimes,:);    
    r(n).A = A(inclTimes,:);
    km.A = [];
    r(n).km = km;
    r(n).r = n*ones(sum(inclU),1);
    r(n).cweA = cweA;
    r(n).cwtA = cwtA;
    r(n).cid = r(n).sp.origcids(inclU);
    r(n).prbIdx = r(n).sp.probeInds(inclU);
    r(n).acr = r(n).sp.acr(inclU);
    r(n).pvals = pvals;
    r(n).bslVals = bslVals;
    if n>1; ii = r(n-1).idx(end); else; ii=0; end
    r(n).idx = (1:sum(inclU))+ii;
%     ii = ii+sum(inclU);
end

allR = vertcat(r.r);
allCID = vertcat(r.cid);
allPrbIdx = vertcat(r.prbIdx);
allAcr = vertcat(r.acr);

%% basic regression
tic
[a, b, R2] = CanonCor2all({r.bs}, {r.A});
toc

% cut some dimensions just to start with 
b = b(:,1:200);

%% 1. test full model on each neuron with c.v. (takes forever!!)
% ideally would run this with cvglmnet and with all CV folds... but it
% takes forever already...
% ** really should make basicFitRes a table rather than struct array
addpath('C:\Users\Nick\Documents\MATLAB\glmnet_matlab\glmnet_matlab');


nfold = 5;
nComp = 50;
opts.alpha = 0.5;
opts = glmnetSet(opts);
useCVG = false; lambda = 0.5;
clear basicFitRes
for idx = 1:numel(allR)
    
    
    n = allR(idx);
    trNum = r(n).trNum;
    
    bs = r(n).bs(:,r(n).idx==idx);
    A = r(n).A;
    
    
      trInds = 1:max(trNum);
      cvp = cvpartition(max(trNum),'KFold',nfold);

    didTest = false(size(trNum));
    cvBS = zeros(size(bs,1), nComp);

    for i = 1:nfold
        trIdx = ismember(trNum, trInds(cvp.training(i)));
        teIdx = ismember(trNum, trInds(cvp.test(i)));

        trA = A(trIdx,:)*b;
        trBS = bs(trIdx,:);
        if var(trBS)>0 % nothing in it
            if useCVG
                fit = cvglmnet(trA, trBS, 'gaussian', opts);
                this_a = cvglmnetCoef(fit, 'lambda_min');
            else
                fit = glmnet(trA, trBS, 'gaussian', opts);
                this_a = glmnetCoef(fit, lambda);
            end
            fitK = this_a(2:end)';

            teA = A(teIdx,:);
            for nc = 1:nComp
                cvBS(teIdx,nc) = teA*(b(:,1:nc)*fitK(:,1:nc)');
            end
        else
            cvBS(teIdx,:) = 0;
        end
        didTest(teIdx)=true;
    end
    
    
    % determine the include-able samples for explained variance testing
    tN = r(n).km.tN; inclTimes = r(n).inclTimes;
    cwtA = r(n).cwtA; cweA = r(n).cweA; inclT = cweA.inclT;
    hasR = cweA.hasRightMove(inclT); hasL = cweA.hasLeftMove(inclT);
    startTime = cwtA.stimOn(inclT);
    stimWindowMax = r(n).km.eventSeries{1}.window(end);
    mvTimeAbs = cwtA.moveTimeAbs(inclT);
    mvTime = max(tN)*ones(size(startTime)); 
    mvTime(hasR|hasL) = mvTimeAbs(hasR|hasL);
    endTime = min(mvTime, startTime+stimWindowMax);
    useTN = logical(WithinRanges(tN, [startTime endTime]));
    toEval = useTN(inclTimes);
    

    explVarAll = zeros(nComp,1); corrAll = zeros(nComp,1);
    if var(bs(didTest&toEval))>1e-3
        for nc = 1:nComp
            explVarAll(nc) = ...
                1-(var(bs(didTest&toEval)-cvBS(didTest&toEval,nc)))./...
                var(bs(didTest&toEval));
            corrAll(nc) = corr(bs(didTest&toEval), cvBS(didTest&toEval,nc));
        end
    end
    [mxVarExpl, nDimMx] = max(explVarAll);
    [mxCorr, nDimCorrMx] = max(corrAll);
    
    fullFit = false;
    if mxVarExpl>0.01
        fullFit = true;
        % fit full model to keep kernels
        if useCVG
            fit = cvglmnet(A*b, bs, 'gaussian', opts);
            this_a = cvglmnetCoef(fit, 'lambda_min');
        else
            fit = glmnet(A*b, bs, 'gaussian', opts);
            this_a = glmnetCoef(fit, lambda);
        end
        fitK = this_a(2:end)';
    end
    
    basicFitRes(idx).explVarAll = explVarAll;
    basicFitRes(idx).mxVarExpl = mxVarExpl;
    basicFitRes(idx).nDimMx = nDimMx;
    basicFitRes(idx).mxCorr = mxCorr;
    basicFitRes(idx).nDimCorrMx = nDimCorrMx;
    if useCVG
        basicFitRes(idx).lambda_min = fit.lambda_min;
        lm = fit.lambda_min; 
    else
        lm = lambda;
    end
    basicFitRes(idx).fitK = fitK;
    basicFitRes(idx).fullFit = fullFit;
    basicFitRes(idx).cvBSmx = cvBS(:,nDimMx);

    
    uStr = sprintf('%s [%s %s %s %d]', allAcr{idx}, r(n).mouseName, r(n).thisDate, ...
        r(n).tags{allPrbIdx(idx)}, allCID(idx));
    
    fprintf(1, '%d: %s: %.2f (%d, %.2f) (%d, %.2f)\n', ...
        idx, uStr, mxVarExpl*100, nDimMx, lm, nDimCorrMx, mxCorr);
    
end


%% save

saveDir = 'F:\Dropbox\ucl\data\CoriMullerRadnitz\results20181022'; mkdir(saveDir)
clear cd; cd(saveDir); 
save(fullfile(saveDir, 'basicFitRes'), 'basicFitRes', 'a', 'b', ...
    'allAcr', 'allCID', 'allPrbIdx', 'allR', '-v7.3');

%% report results of that fit by area

allMx = [basicFitRes.mxVarExpl];
fprintf(1, 'All neurons: %.2f, %.2f, %.2f (for 1, 3, 10 pct var expl)\n',...
    100*sum(allMx>0.01)/numel(allMx), ...
    100*sum(allMx>0.03)/numel(allMx), ...
    100*sum(allMx>0.1)/numel(allMx));

uacr = unique(allAcr);
for u = 1:numel(uacr)
    theseAcr = strcmp(allAcr, uacr{u});
    theseMx = allMx(theseAcr);
    fprintf(1, '%s: (n=%d) %.2f, %.2f, %.2f\n', uacr{u}, sum(theseAcr), ...
        100*sum(theseMx>0.01)/sum(theseAcr), ...
        100*sum(theseMx>0.03)/sum(theseAcr), ...
        100*sum(theseMx>0.1)/sum(theseAcr));
    
end

%% define which neurons to skip for subsequent analyses

excl = false(size(allR));
excl(1:numel(basicFitRes)) = [basicFitRes.mxVarExpl]<0.02;


%% cross-validation on residuals
cd(saveDir); 
residFrom = {'stimLeft', 'stimRight', 'moveEither', 'moveLR'};
residPredInds = {[1:3], [4:6], 7, 8};

predWith = {'stimLeft', 'stimRight', 'moveEither', 'moveLR'};
predPredInds = {[1:3], [4:6], 7, 8};

evalWins = {...
    {[0.05 0.4], [-0.2 0]}, ...
    {[0.05 0.4], [-0.2 0]}, ...
    {[0.05 0.4], [-0.2 0]}, ...
    {[0.05 0.4], [-0.2 0]} ...
    };

for q = 1:4%1:numel(residFrom)
    
    fprintf(1, 'predict %s from %s residuals\n', predWith{q}, residFrom{q});
    
    residFn = sprintf('cvTest_residWithout_%s', residFrom{q});
    
    if exist([residFn '.mat'], 'file')
        load(residFn)
    else
        name = residFrom{q};
        thesePredInds = residPredInds{q};
        [allBSresidExK, noExKfitRes, bNoExK] = determineResidualsWithout(...
            name, thesePredInds, r, basicFitRes);
        save(residFn, 'allBSresidExK', 'name', 'noExKfitRes', 'bNoExK', 'excl');
    end
    
    
    predFn = sprintf('cvTest_pred_%s_onResidWithout_%s', predWith{q}, residFrom{q});
    if exist([predFn '.mat'], 'file')
        % done
    else
        thesePredInds = predPredInds{q};
        predName = predWith{q};
        residName = residFrom{q};
        
        [ExKFitRes, bExK] = predictResidualsWith(predName, thesePredInds, residName, ...
            allBSresidExK, r, allR, excl, evalWins{q});
        
        saveFn = sprintf('cvTest_pred_%s_onResidWithout_%s', predName, residName);
        save(saveFn, 'ExKFitRes', 'predName', 'thesePredInds', 'residName', ...
            'bExK', 'excl');
    end
end


%% list the top ones

q = [ExKFitRes.mxVarExpl];
ExKFitMx = zeros(size(allR));
ExKFitMx(~arrayfun(@(x)isempty(ExKFitRes(x).mxVarExpl),1:numel(ExKFitRes))) = q;

[~, ii] = sort(ExKFitMx, 'descend');

for q = 1:sum(ExKFitMx>0.02)
    idx = ii(q);
    
    n = allR(idx);
    uStr = sprintf('%s [%s %s %s %d]', allAcr{idx}, r(n).mouseName, r(n).thisDate, ...
            r(n).tags{allPrbIdx(idx)}, allCID(idx));
    %if strcmp(allAcr{idx}, 'VISam'); fprintf(1, '**'); end
    fprintf(1, '%d: %s: %.2f (%d)\n', idx, uStr, ...
        ExKFitRes(idx).mxVarExpl*100, ExKFitRes(idx).nDimMx);
end

fprintf(1, 'total = %d\n', sum(ExKFitMx>0.02));

%% compare different ones


% names = {'stimLeft', 'stimRight', 'moveLR', 'moveEither'};
names = {'moveLR', 'moveEither'};

figure; 
for n = 1:numel(names)
    fn = sprintf('cvTest_pred_%s_onResidWithout_%s', names{n}, names{n});
    load(fn);
    
    q = [ExKFitRes.mxVarExpl];
    ExKFitMx = zeros(size(allR));
    ExKFitMx(~arrayfun(@(x)isempty(ExKFitRes(x).mxVarExpl),1:numel(ExKFitRes))) = q;
    
    [mxSort, ii] = sort(ExKFitMx, 'descend');
    plot(mxSort, '.-'); hold on;
end
xlim([0 200]); 
legend(names);



%% summary plots across areas for each regressor

% ** see /papers/.../figs/kernelCVtestSummary