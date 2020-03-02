
function inclU = getIncludedUnits(sessionName)

mfpath = mfilename('fullpath');
inclUnitsPath = fullfile(fileparts(mfpath), 'neurons');

inclU = readNPY(fullfile(inclUnitsPath, [sessionName '_inclNeurons.npy'])); 
