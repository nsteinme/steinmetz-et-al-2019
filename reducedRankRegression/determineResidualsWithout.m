


function [allBSresidExK, noExKfitRes, bNoExK] = determineResidualsWithout(...
    name, thesePredInds, r, basicFitRes)
% see script crossValExcludingK for usage


nComp = 75; % for the fit without these

%%



fprintf(1, 'fit without %s\n', name);
tic
allBS = {r.bs};
allA = {};
allPredInds = unique(r(1).km.predictorInds);
notThesePredInds = allPredInds(~ismember(allPredInds, thesePredInds));
noExKInds = ismember(r(1).km.predictorInds, notThesePredInds);
allR = vertcat(r.r);

excl = false(size(allR));
excl(1:numel(basicFitRes)) = [basicFitRes.mxVarExpl]<0.02;

for n = 1:numel(r)
    allA{n} = r(n).A(:, noExKInds);
    allBS{n} = allBS{n}(:,~excl(r(n).idx));
end


% this comes out really almost indistinguishable from the original b, so
% that's great. can continue using the original. 
% [aSub, bSub, R2] = CanonCor2all(allBS, {r.A});

% This one is quite similar as well but more significantly different - so,
% good to use it
[aNoExK, bNoExK, R2] = CanonCor2all(allBS, allA);
        

toc
%% predict with the no-Whatever model, get residuals
% need to regularize a here for each neuron. 
allBSresidExK = {}; q = 0;
 
fprintf(1, 'predict data without %s and get residuals\n', name);

opts.alpha = 0.5;
opts = glmnetSet(opts);
useCVG = false; lambda = 0.5;
clear noExKfitRes
for idx = 1:numel(allR)
    if ~excl(idx)
        fprintf(1, '%d.', idx); q = q+1; if q>10; fprintf(1, '\n'); q = 0; end;
        n = allR(idx);
        bs = r(n).bs(:,r(n).idx==idx);
        if useCVG
            fit = cvglmnet(allA{n}*bNoExK(:,1:nComp), bs, 'gaussian', opts);
            this_a = cvglmnetCoef(fit, 'lambda_min');
        else
            fit = glmnet(allA{n}*bNoExK(:,1:nComp), bs, 'gaussian', opts);
            this_a = glmnetCoef(fit, lambda);
        end
        fitK = this_a(2:end)';
        
        predbs = allA{n}*bNoExK(:,1:nComp)*fitK(:,1:nComp)';
        if numel(allBSresidExK)<n
            allBSresidExK{n} = bs-predbs;
        else
            allBSresidExK{n}(:,end+1) = bs-predbs;
        end
        noExKfitRes(idx).fitK = fitK;
    end
end
fprintf(1, '\ndone.\n');



