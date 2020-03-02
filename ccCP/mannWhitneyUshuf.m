 
function numer = mannWhitneyUshuf(x,y,shufLabels)
% function numer = mannWhitneyUshuf(x,y,shufLabels)
%
% numer is the number of instances for which x>y, of all possible
% comparisons. Divide by nx*ny for mannWhitney u statistic.
%
% shufLabels is ny x nshuf, each column a random permutation of integers
% from 1:nx. First column of shufLabels should be exactly 1:nx
%
% x and y are vectors
%

nx = numel(x);

t = tiedrank([x(:); y(:)]);

t = t(shufLabels);

if nx==1
    numer = t(:)';
else
    numer = sum(t,1);
end

numer = numer-nx*(nx+1)/2;