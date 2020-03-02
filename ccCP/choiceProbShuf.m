
function [cp, p, cpSummary] = choiceProbShuf(spikeCounts, trialChoice, trialCondition, shufLabels)
% Returns choice probability for a set of trials by combining across
% conditions with a decomposed mann-whitney u-stat.
%
% spikeCounts, trialChoice, trialCondition are all vectors of the same
% length. 
%
% trialChoice should have entries that are only true and false 

n = numel(spikeCounts);
nShuf = size(shufLabels{1},2)-1;

uCond = unique(trialCondition(:));
nTotal = zeros(1,1+nShuf); dTotal = 0; 
for c = 1:numel(uCond)
    inclT = trialCondition==uCond(c);
    
    chA = trialChoice & inclT;
    nA = sum(chA);
    chB = ~trialChoice & inclT;
    nB = sum(chB);
    
%     q = arrayfun(@(x)randperm(nA+nB,nA), 1:nShuf, 'uni', false);
%     shufLabels = vertcat(q{:})';
%     shufLabels = [(1:nA)' shufLabels];
    
    n = mannWhitneyUshuf(spikeCounts(chA), ...
        spikeCounts(chB), shufLabels{c}); 
    nTotal = nTotal+n; 
    dTotal = dTotal+nA*nB;        
end

cp = nTotal./dTotal;

t = tiedrank(cp); 
p = t(1)/(1+nShuf);  

cpSummary = zeros(1,6);
cpSummary(1) = cp(1);
cpSummary(2) = p;
cpSummary(3) = mean(cp(2:end)); % the mean shuffle value
cpSummary(4) = max(t)/(1+nShuf); % max significance attained by any shuffle
cpSummary(5) = min(t)/(1+nShuf);
cpSummary(6) = cp(2); % cp of just one of the shuffles
cpSummary(7) = t(2)/(1+nShuf); % p-value of that one shuffle