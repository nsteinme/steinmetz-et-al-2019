

function launchNeuronRasterViewer()

rootDir = uigetdir(pwd, 'Select folder containing the downloaded sessions');

if ~isempty(rootDir)
    d = dir(fullfile(rootDir, '*')); 
    d = d([d.isdir]); 
    sessionNames = {d.name}; 
    sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
    indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

    if ~isempty(indx)
        
        % load session 
        s = loadSession(fullfile(rootDir, sessionNames{indx}));
        
        r = s.probes.rawFilename.rawFilename;
        probeNames = arrayfun(@(x)r(x,:),1:size(r,1),'uni',false);
        
        indx = listdlg('ListString',probeNames, 'Name', 'Select a recording');
        
        if ~isempty(indx)
            eventRasters(s,indx);
        end
    end
end
