

function kmd = kmDummy(modelkm, win, stimID, moveDir, simRT)
% moveDir is -1 for left, 0 for nogo, 1 for right
n=1;
tN = win(1):modelkm.timeBinSize:win(end);
kmd = KernelModel('toeplitz', tN, 1);
kmd.eventSeries = modelkm.eventSeries;
kmd.timeBinSize = modelkm.timeBinSize;
evs = kmd.eventSeries;
for e = 1:numel(evs)
    evs{e}.eventTimes = [];
    evs{e}.eventValues = [];
end
if stimID<7
    evs{stimID}.eventTimes = 0; evs{stimID}.eventValues = 1;
end
if moveDir~=0
    evs{7}.eventTimes = simRT; evs{7}.eventValues = 1;
    evs{8}.eventTimes = simRT; evs{8}.eventValues = moveDir;
end
kmd.eventSeries = evs;
kmd.generatePredictor;