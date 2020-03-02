

function sepHands = plotAllNeurons(dat, acr, sortBy, acrOrder, xbins, ax, showN)
% function plotAllNeurons(dat, acr, sortBy, acrOrder, xbins)
% sortBy is a vector to be sorted ascending

if nargin<7; showN = true; end
plotDat = zeros(size(dat));
n = 0;
nTick = zeros(1, numel(acrOrder)); 
txt = {};
for q = 1:numel(acrOrder)
    these = strcmp(acr, acrOrder{q});
    nt = sum(these); 
    thisDat = dat(these,:);
    [~,thisSort] = sort(sortBy(these), 'descend'); 
    thisDat = thisDat(thisSort,:); 
    
    plotDat(n+1:n+nt,:) = thisDat;
    
    nTick(q) = n+round(nt/2); 
    txt{q} = sprintf(' (n=%d)', nt);
    
    n = n+nt;
    pars.addSep(q).color = [0.3 0.3 0.3]; 
    %pars.addSep(q).level = n+0.5;
    pars.addSep(q).level = [n-nt n]+0.5;
end

if nargin<6
    figure; 

    ax = axes(); 
end
imagesc(xbins, [], plotDat); 
hold on;
box off; 
set(ax, 'TickDir', 'out'); 
colormap(flipud(colorcet('L3'))); 
pars.tickLocs = nTick; 
if showN
    pars.extraText = txt; 
else    
    pars.extraText = []; 
end
pars.g = brainRegionGroups('gradient'); 
pars.xVal = xbins([1 end]); 
sepHands = addAxisAcronyms(ax, 'Y', acrOrder, pars);




