

function [ExKFitRes, bExK] = predictResidualsWith(name, thesePredInds, residName, ...
    allBSresidExK, r, allR, excl, evalWins)

% evalWins: 2x1 cell array, giving the time around visual stimulus, and
% time around movement onset, over which to evaluate the prediction

nCompExK = 18;
opts.alpha = 0.5;
opts = glmnetSet(opts);
useCVG = false; lambda = 0.5;
computeAllTimes = false; % if you turn this on, check "toEval" is used properly
usePreCheck = false;

allR = vertcat(r.r);
allCID = vertcat(r.cid);
allPrbIdx = vertcat(r.prbIdx);
allAcr = vertcat(r.acr);

%% Fit residuals using the last kernel
fprintf(1, 'fit residuals of %s with only %s\n', residName, name);
tic
allA = {};
onlyExKinds = ismember(r(1).km.predictorInds, thesePredInds);
for n = 1:numel(r)
    allA{n} = r(n).A(:, onlyExKinds);
end
[aExK, bExK, R2] = CanonCor2all(allBSresidExK, allA);
% [aLR, bLR, R2] = CanonCor2all(allBS, allA);

toc


%% evaluate this kernel's performance on residuals

fprintf(1, 'evaluate the performance predicting residuals with just %s\n', name);
for n = 1:numel(r)
    r(n).cvp5 = cvpartition(max(r(n).trNum),'KFold',5);
    r(n).cvp10 = cvpartition(max(r(n).trNum),'KFold',10);
end

clear ExKFitRes
nComp = nCompExK;
allIdx = 1:numel(allR); 
inclIdx = allIdx(~excl);
for idx = 1:numel(allR)
    if ~excl(idx)
        n = allR(idx);
        trNum = r(n).trNum;
        trInds = 1:max(trNum);
        
        n = allR(idx);
        %bs = r(n).bs(:,r(n).idx==idx);
        inclIdxThisN = allIdx(~excl & allR==n);
        bs = allBSresidExK{n}(:,inclIdxThisN==idx);
        A = allA{n};
        trNum = r(n).trNum;
        
        % determine the include-able samples for explained variance testing
        tN = r(n).km.tN; inclTimes = r(n).inclTimes; 
        cwtA = r(n).cwtA; cweA = r(n).cweA; inclT = cweA.inclT;
        hasR = cweA.hasRightMove(inclT); hasL = cweA.hasLeftMove(inclT);
%         startTime = cwtA.stimOn(inclT);
%         stimWindowMax = r(n).km.eventSeries{1}.window(end);
%         mvTimeAbs = cwtA.moveTimeAbs(inclT);
%         mvTime = max(tN)*ones(size(startTime)); mvTime(hasR|hasL) = mvTimeAbs(hasR|hasL);
%         endTime = min(mvTime, startTime+stimWindowMax); 
%         useTN = logical(WithinRanges(tN, [startTime endTime])); 

        if ~isempty(evalWins{1})
            % the stim window goes until evalWin(2) only if the move
            % doesn't start first
            stimStarts = cwtA.stimOn(inclT)+evalWins{1}(1); 
            mvTime = max(tN)*ones(size(stimStarts)); 
            mvTimeAbs = cwtA.moveTimeAbs(inclT);
            mvTime(hasR|hasL) = mvTimeAbs(hasR|hasL);
            stimEnds = min(mvTime, cwtA.stimOn(inclT)+evalWins{1}(2)); 
        else
            stimStarts = []; stimEnds = []; 
        end
        if ~isempty(evalWins{2})
            % the move window starts at evalWin(1) only if the stim already
            % came on
            mvTimeAbs = cwtA.moveTimeAbs(inclT);
            stOn = cwtA.stimOn(inclT);
            moveStarts = max(stOn(hasR|hasL), mvTimeAbs(hasR|hasL)+evalWins{2}(1)); 
            moveEnds = mvTimeAbs(hasR|hasL)+evalWins{2}(2); 
        else
            moveStarts = []; moveEnds = []; 
        end
        useTN = WithinRanges(tN, [stimStarts stimEnds; moveStarts moveEnds])>0; 
        
        toEval = useTN(inclTimes); 
        
        cvp = r(n).cvp5;
        didTest = false(size(trNum));
        cvBS = zeros(size(bs,1), nComp);
        
        if usePreCheck
            for i = 1
                trIdx = ismember(trNum, trInds(cvp.training(i)));
                teIdx = ismember(trNum, trInds(cvp.test(i)));
                
                trA = A(trIdx,:)*bExK;
                trBS = bs(trIdx,:);
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
                    cvBS(teIdx,nc) = teA*(bExK(:,1:nc)*fitK(:,1:nc)');
                end
                didTest(teIdx)=true;
            end
            
            
            
            explVarAll = zeros(nComp,1);
            for nc = 1:nComp
                explVarAll(nc) = ...
                    1-(var(bs(didTest&toEval)-cvBS(didTest&toEval,nc)))./ ...
                    var(bs(didTest&toEval));
            end
        else
            explVarAll = ones(nComp,1); % this will trigger the full test
        end
        
        fullTest=false;
        explVarByTime = zeros(size(A,2),1);
        cvBSbyTime = zeros(size(bs,1),nComp,size(A,2));
        if max(explVarAll)>0.02 % greater than half a percent - proceed with a more thorough test
            fullTest = true;
            cvp = r(n).cvp10;
            
             
            
            for i = 1:10
                trIdx = ismember(trNum, trInds(cvp.training(i)));
                teIdx = ismember(trNum, trInds(cvp.test(i)));
                
                trA = A(trIdx,:)*bExK;
                trBS = bs(trIdx,:);
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
                    cvBS(teIdx,nc) = teA*(bExK(:,1:nc)*fitK(:,1:nc)'); 
                    
                    if computeAllTimes
                        % compute also for including only the beginning of the
                        % kernel up to each time point
                        for tidx = 1:size(A,2)
                            cvBSbyTime(teIdx,nc,tidx) = ...
                                teA(:,1:tidx)*(bExK(1:tidx,1:nc)*fitK(:,1:nc)'); 
                        end
                    end
                end
                didTest(teIdx)=true;
            end
            
            
            explVarAll = zeros(nComp,1);
            
            for nc = 1:nComp
                explVarAll(nc) = ...
                    1-(var(bs(didTest&toEval)-cvBS(didTest&toEval,nc)))./ ...
                    var(bs(didTest&toEval));
            end
            
            [mxVarExpl, nDimMx] = max(explVarAll);
                                                
            % now that we have the number of dimensions to use, let's
            % compute CV for each time point      
            
            if computeAllTimes
                cvBSbyTime = squeeze(cvBSbyTime(:,nDimMx,:));
                for tidx = 1:size(A,2)
                    explVarByTime(tidx) = ...
                        1-(var(bs(didTest)-cvBSbyTime(didTest,tidx)))./var(bs(didTest));
                end
            end
            
            % get total fit so we have the overall kernel
            if useCVG
                fit = cvglmnet(A*bExK, bs, 'gaussian', opts);
                this_a = cvglmnetCoef(fit, 'lambda_min');
            else               
                fit = glmnet(A*bExK, bs, 'gaussian', opts);
                this_a = glmnetCoef(fit, lambda);
            end
            fitK = this_a(2:end)';
        end
        
        [mxVarExpl, nDimMx] = max(explVarAll);
        ExKFitRes(idx).explVarAll = explVarAll;
        if computeAllTimes
            ExKFitRes(idx).explVarByTime = explVarByTime;
        end
        ExKFitRes(idx).mxVarExpl = mxVarExpl;
        ExKFitRes(idx).nDimMx = nDimMx;
        if useCVG
            ExKFitRes(idx).lambda_min = fit.lambda_min;
            lm = fit.lambda_min;
        else
            lm = lambda;
        end
        ExKFitRes(idx).fullTest = fullTest;
        ExKFitRes(idx).fitK = fitK;
        
        
        uStr = sprintf('%s [%s %s %s %d]', allAcr{idx}, r(n).mouseName, r(n).thisDate, ...
            r(n).tags{allPrbIdx(idx)}, allCID(idx));
        
        fprintf(1, '%d: %s: %.2f (%d, %.2f', idx, uStr, mxVarExpl*100, nDimMx, lm);
        if fullTest; fprintf(1, ', full)\n'); else; fprintf(1, ')\n'); end
        
    end
end