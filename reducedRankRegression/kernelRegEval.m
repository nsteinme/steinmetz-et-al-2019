

function cvVarExpl = kernelRegEval(trueBS, predBS)

cvVarExpl = 1 - ( var(trueBS-predBS) ./ var(trueBS) );