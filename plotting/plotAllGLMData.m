

function plotAllGLMData(mdl, dataTab, names, modelSampVals, dataBinVals, outputIdx, outputName)

n = numel(names);

varNames = dataTab.Properties.VariableNames;

isSq = find(cellfun(@(x)x(end)=='2', varNames)); 

outVar = dataTab.(varNames{outputIdx});

plotIdx = 1:numel(varNames);
plotIdx([isSq outputIdx]) = [];
nPlot = numel(plotIdx);

computeIdx = 1:numel(varNames);
computeIdx(outputIdx) = [];
nComp = numel(computeIdx); 

for jj = 1:nPlot
    idx = plotIdx(jj);
    subplot(1,nPlot,jj)
    xtest = modelSampVals{jj}(:);
    binEdges = dataBinVals{jj};
    
    binC = binEdges(1:end-1)+diff(binEdges)/2;
    nb = numel(binEdges)-1;
    empTest = zeros(nb,1); empCI = zeros(nb,2); empN = zeros(nb,1);
    for q = 1:nb
        inclT = dataTab.(varNames{idx})>binEdges(q) & dataTab.(varNames{idx})<=binEdges(q+1);
        x = sum(outVar(inclT));
        nc = sum(inclT);
        p = x/nc;
        empTest(q) = p;
        empN(q) = nc;
        
        % future version could check whether it is bino and get normal
        % confidence intervals if not
        empCI(q,:) = binoCI(x,nc);
    end
    
    %meanTab = table('Size',[numel(xtest) nComp], 'VariableNames',varNames(computeIdx), 'VariableTypes', repmat({'double'},1 ,nComp));
    meanTab = array2table(zeros([numel(xtest) nComp]), 'VariableNames',varNames(computeIdx));
    for ii = 1:nComp
        q = dataTab.(varNames{computeIdx(ii)});
        meanTab.(varNames{computeIdx(ii)}) = mean(q)*ones(size(xtest));
    end
    meanTab.(varNames{idx}) = xtest;
    sqIdx = find(strcmp(varNames, [varNames{idx} '2'])); 
    if ~isempty(sqIdx)
        meanTab.(varNames{sqIdx}) = xtest.^2; 
    end    
    
    [p, pci] = mdl.predict(meanTab); 
    
    plotWithErrUL(xtest, p, pci, 'k');
    ylim([0 1]);
    hold on;
    h = plot(binC, empTest, 'ro');
    h.MarkerFaceColor = 'r';
    for q = 1:numel(binEdges)-1
        plot(binC(q)*[1 1], empCI(q,:), 'r', 'LineWidth',2.0);
    end
    box off;
    xlabel(names{jj});
    ylabel(outputName);
    
end
end

function ci = binoCI(x,n)
ptest = [0:0.01:1];
cix = binocdf(x,n,ptest);
ci = ptest([find(cix>0.975,1, 'last') find(cix<0.025,1)]);
end