

function c = colorForAcr(acr, g)

c = [0 0 0];
for q = 1:numel(g)
    if any(cellfun(@(x)strcmp(acr,x), g(q).acr))
        c = g(q).color;
    end
end