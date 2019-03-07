

function [a, b, R2] = CanonCor2all(Y, X)
% [a, b, R2] = CanonCor2all(Y, X)
%
% Version of CanonCor2 (see original doc below) that accepts cell arrays of
% Y and X which represent different instances of the mapping from the same
% X variables to different Y's. 
%
% The intended application is for doing a reduced-rank regression between
% behavioral predictors and neural activity, for many non-simultaneously
% recorded neurons at once. 
%
% - Y and X must have the same number of cells
% - Each entry i in Y is size [t_i, n_i] and X is [t_i, p] where p (the 
% predictors) are the same across all X. t_i and n_i are specific to each
% instance (e.g., time during that recording, and number of neurons in that
% recording). 
%
% -- CanonCor2 doc -- 
% does a sort of canonical correlation analysis on two sets of data X and Y
% except that now it finds the linear combinations of X that predict
% the largest variance fractions of Y.
%
% You should think of Y as the dependent variable, and X as the independent
% variable.
%
% R2 is the fraction of the total variance of Y explained by
% the nth projection
%
% the approximation of Y based on the first n projections is:
% Y = X * b(:,1:n) *a'(:,1:n);
%
% the nth variable for the ith case gives the approximation
% Y(i,:)' = a(:,n) * b(:,n)' * X(i,:)'
%
%
% -- End CanonCor2 doc --
% 
% CanonCor2 from KDH
% Updated by NAS for multiple instances

% Make covariance matrices
nInst = numel(Y);
nX = size(X{1}, 2);
nY = sum(cellfun(@(x)size(x,2), Y));

% first covariance of X
allX = vertcat(X{:});
CXX = cov(allX);
eps = 1e-7; 
CXX = CXX+eps*eye(nX); % prevents imaginary results in some cases

CXXMH = CXX ^ -0.5; 

% now covariance of Y with X, assembled instance-by-instance
CYX = zeros(nY, nX);
varY = zeros(1,nY);
startInd = 1;

for q = 1:nInst
    
    % -- A first method here uses the logic of the old CanonCor2 but ends
    % up recomputing CXX and CYY needlessly
%     BigCov = cov([X{q}, Y{q}]);
%     CYX(startInd:startInd+size(Y{q},1)-1,:) = BigCov(nX+1:end, 1:nX);
%     varY(startInd:startInd+size(Y{q},1)-1) = diag(BigCov(nX+1:end,nX+1:end));
    
    % -- This version directly computes just the part we want
    thisY = Y{q};
    thisX = X{q};
    thisYmnSub = thisY - mean(thisY);
    thisXmnSub = thisX - mean(thisX);
    denom = size(thisX,1)-1;    
    CYX(startInd:startInd+size(thisY,2)-1,:) = (thisYmnSub'*thisXmnSub)./denom;
    varY(startInd:startInd+size(thisY,2)-1) = var(thisY);
    
    startInd = startInd+size(thisY,2);
end

% matrix to do svd ...
M = CYX * CXXMH;

% do svd
[d, s, c] = svd(M, 0);

b = CXXMH * c;
a = d * s;

R2 = (diag(s).^2)/sum(varY);

