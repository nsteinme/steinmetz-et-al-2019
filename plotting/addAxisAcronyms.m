

function sepHands = addAxisAcronyms(ax, whichAxis, acrInOrder, pars)

if nargin<4
    pars = struct();
end
tickLocs = getOr(pars, 'tickLocs', (1:numel(acrInOrder))');
addSep = getOr(pars, 'addSep', []);
extraText = getOr(pars, 'extraText', {});
xVal = getOr(pars, 'xVal', []);
g = getOr(pars, 'g', brainRegionGroups());


t = [whichAxis 'Tick']; tl = [whichAxis 'TickLabel']; 

set(ax, t, tickLocs);

acrWithColor = cellfun(@(x)colorStringForAcr(x, g), acrInOrder, 'uni', false);

if ~isempty(extraText)
    acrWithColor = arrayfun(@(x)strcat(acrWithColor{x}, extraText{x}), 1:numel(acrWithColor), 'uni', false);    
end

set(ax, tl, acrWithColor); 
sepHands = []; 
if ~isempty(addSep)    
    for q = 1:numel(addSep)
        if size(addSep(q).level,2)>1 % gave start/stop - draw vertical lines
            sepHands(q) = plot(xVal(1)*[1 1], addSep(q).level, ...
                'Color', colorForAcr(acrInOrder{q}, g),...
                'LineWidth',6.0);
            plot(xVal(1)+diff(xVal)/18*[-1 1], addSep(q).level(1)*[1 1], 'k'); 
        else
            sepHands(q) = plot(xlim(), addSep(q).level*[1 1], 'Color', addSep(q).color);
        end
    end
end

function colStr = makeColorStr(text, color)
colStr = sprintf('\\color[rgb]{%.2f, %.2f, %.2f} %s', color(1), color(2), color(3), text);

function colStr = colorStringForAcr(acr, g)
colStr = makeColorStr(acr, colorForAcr(acr, g)); 

