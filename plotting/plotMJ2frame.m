

function plotMJ2frame(ax, currTime, myData)
vr = myData{1};
t = myData{2};
thisFrame = find(t>currTime, 1);

if ~isempty(thisFrame)
    img = read(vr, thisFrame);

    imHand = get(ax, 'Children');
    if isempty(imHand)
        imagesc(img); 
        colormap(gca, 'gray'); 
        axis off
        axis image
    else
        set(imHand, 'CData', img);
    end
end