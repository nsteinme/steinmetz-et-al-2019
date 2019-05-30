

function fitK = kernelRegFit(bs, A, b, lambda, opts)

fit = glmnet(A*b, bs, 'gaussian', opts);
this_a = glmnetCoef(fit, lambda);

fitK = this_a(2:end)';


