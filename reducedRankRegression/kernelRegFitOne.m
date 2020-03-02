

function fitRes = kernelRegFitOne(bs, A, b, trNum, nComp, nfold, useCVG, lambda, opts, toEval, predInds)

if isempty(nComp)
    skipComp = true; nComp = 1;
else
    skipComp = false;
end

nTrials = max(trNum);
trInds = 1:nTrials;

% do cross-validation by trial, not by time point
cvp = cvpartition(nTrials,'KFold',nfold);

% didTest = false(size(trNum));
for q = 1:4 % full, stim-only, move-only, choice-only
    cvBS{q} = zeros(size(bs,1), nComp);
end

outVar = {};
parfor i = 1:nfold
    trIdx = ismember(trNum, trInds(cvp.training(i)));
    teIdx = ismember(trNum, trInds(cvp.test(i)));
    
    % get training set
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
        if skipComp
            %cvBS(teIdx) = teA*(b*fitK');
            outVar{i}{1} = teA*(b*fitK');
            for xx = 1:3
                kSub = fitK; kSub(predInds~=xx)=0;
                outVar{i}{xx+1} = teA*(b*kSub');
            end
        else
            q = zeros(sum(teIdx),nComp);
            for nc = 1:nComp
                %cvBS(teIdx,nc) = teA*(b(:,1:nc)*fitK(:,1:nc)');
                q(:,nc) = teA*(b(:,1:nc)*fitK(:,1:nc)');
            end
            outVar{i}{1} = q;
            
            for xx = 1:3
                kSub = fitK; kSub(predInds~=xx)=0;
                
                q = zeros(sum(teIdx),nComp);
                for nc = 1:nComp
                    %cvBS(teIdx,nc) = teA*(b(:,1:nc)*fitK(:,1:nc)');
                    q(:,nc) = teA*(b(:,1:nc)*kSub(:,1:nc)');
                end
                outVar{i}{xx+1} = q;
            end
        end
    else
        %cvBS(teIdx,:) = 0;
        for q = 1:4; outVar{i}{q} = 0; end;
    end
    %didTest(teIdx)=true;
end
for i = 1:nfold
    teIdx = ismember(trNum, trInds(cvp.test(i)));
    for q = 1:4
        cvBS{q}(teIdx,:) = outVar{i}{q};
    end
end
didTest = true(size(trNum));

for q = 1:4
    explVarAll{q} = zeros(nComp,1); corrAll{q} = zeros(nComp,1);
    if var(bs(didTest&toEval))>1e-3
        if skipComp
            explVarAll{q} = 1-(var(bs(didTest&toEval)-cvBS{q}(didTest&toEval)))./...
                var(bs(didTest&toEval));
            corrAll{q} = corr(bs(didTest&toEval), cvBS{q}(didTest&toEval));
        else
            for nc = 1:nComp
                explVarAll{q}(nc) = ...
                    1-(var(bs(didTest&toEval)-cvBS{q}(didTest&toEval,nc)))./...
                    var(bs(didTest&toEval));
                corrAll{q}(nc) = corr(bs(didTest&toEval), cvBS{q}(didTest&toEval,nc));
            end
        end
    end
    [mxVarExpl{q}, nDimMx{q}] = max(explVarAll{q});
    [mxCorr{q}, nDimCorrMx{q}] = max(corrAll{q});
    
end

fullFit = false;
if true%mxVarExpl>0.01
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


fitRes.explVarAll = explVarAll;
fitRes.mxVarExpl = mxVarExpl;
fitRes.nDimMx = nDimMx;
fitRes.mxCorr = mxCorr;
fitRes.nDimCorrMx = nDimCorrMx;
if useCVG
    fitRes.lambda_min = fit.lambda_min;
    lm = fit.lambda_min;
else
    lm = lambda;
end
fitRes.fitK = fitK;
fitRes.fullFit = fullFit;
fitRes.cvBSmx = cvBS{1}(:,nDimMx{1});