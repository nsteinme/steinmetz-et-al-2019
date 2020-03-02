

function [hasL, hasR, hasNone] = getIncludedTrials(sessionName)

mfpath = mfilename('fullpath');
inclTrPath = fullfile(fileparts(mfpath), 'trials'); 

hasL = readNPY(fullfile(inclTrPath, [sessionName '_hasLeft.npy'])); 
hasR = readNPY(fullfile(inclTrPath, [sessionName '_hasRight.npy'])); 
hasNone = readNPY(fullfile(inclTrPath, [sessionName '_hasNone.npy'])); 