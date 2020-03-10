

function r = roc(x,y)

nx = numel(x); ny = numel(y);

t = tiedrank([x(:); y(:)]);

numer = sum(t(1:nx))-nx*(nx+1)/2;
denom = nx*ny; 

r = numer/denom;