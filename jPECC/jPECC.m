

function [jPECC_val, jPECC_p] = jPECC(sp1, sp2, kfold, lambda, maxNpc)
% function [jPECC_val, jPECC_p] = jPECC(sp1, sp2, kfold, lambda)
%
% Inputs: 
% - sp1 and sp2 are size [trials, timebins, neurons] and contain spike counts
% aligned to an event, from neurons in area 1 and area 2. The third
% dimension (number of neurons) can be different between sp1 and sp2, but
% the other two should match. 
% - kfold sets cross-validation number of folds
% - lambda is a regularization parameter. Can leave it out and just use
% three input arguments for un-regularized version. 
% - maxNpc is the number of dimensions to keep from PCA analysis. Will keep
% fewer if there aren't enough neurons in the population. Default is 10. 
%
% Outputs: 
% - jPECC_val is size [timebins, timebins] containing the first canonical
% correlation value
% - jPECC_p is the p-value of each correlation 

doPCA = true; % if false, just use what you're given

if nargin<5
    maxNpc = 10; 
end
if nargin<4
    lambda = [];     
end


nBins = size(sp1,2); 

jPECC_val = zeros(nBins);
jPECC_p = zeros(nBins);

N = size(sp1,1); %number of trials
cvp = cvpartition(N, 'KFold', kfold);
nd = min([maxNpc size(sp1,3) size(sp2,3)]);
% nd = min([size(sp1,3) size(sp2,3)]);
for t1 = 1:nBins
    
    % reducing dimensionality to help regularize
    X = squeeze(sp1(:,t1,:));
    if doPCA        
        [~,Xs] = pca(X);
        Xs = Xs(:,1:nd);
    else 
        Xs = X;
    end
    
    
    
    for t2 = 1:nBins
        
        Y = squeeze(sp2(:,t2,:));
        if doPCA
            [~,Ys] = pca(Y);           
            Ys = Ys(:,1:nd);
        else
            Ys = Y;
        end
        
        
        
        % ** Old/simple method: directly perform CCA
        %             [A,B,rval] = canoncorr(...
        %                 Xs,...
        %                 Ys);
        %             jPECC_val(t1,t2) = rval(1);
        
        % ** New method: use cross-validation
        U = zeros(N,1);
        V = zeros(N,1);

        for k = 1:kfold
            
            % generate canonical dimension of each matrix on the training
            % set           
            if isempty(lambda)
                [A,B] = canoncorr(...
                    Xs(cvp.training(k),:),...
                    Ys(cvp.training(k),:));
            else
                % ridge regression version
                [A,B] = canoncorr(...
                    [Xs(cvp.training(k),:); lambda*eye(nd); zeros(nd)],...
                    [Ys(cvp.training(k),:); zeros(nd); lambda*eye(nd)]);
            end
            
            % project the test set onto the canonical dimension
            U(cvp.test(k)) = Xs(cvp.test(k),:)*A(:,1);
            V(cvp.test(k)) = Ys(cvp.test(k),:)*B(:,1);

            
        end
        % correlate the projections. since each test set's projections will
        % be zero mean already, we can just combine them all here
        [rval, pval] = corr(U,V);
        jPECC_val(t1,t2) = rval;
        jPECC_p(t1,t2) = pval;

    end
end