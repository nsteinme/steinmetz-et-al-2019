function launchPopRasterMovie()

rootDir = uigetdir(pwd, 'Select folder containing the downloaded sessions');

vidDir = uigetdir(pwd, 'Select folder containing the video data (cancel to skip videos but proceed)');


if ~isempty(rootDir)
    d = dir(fullfile(rootDir, '*')); 
    d = d([d.isdir]); 
    sessionNames = {d.name}; 
    sessionNames = sessionNames(~strcmp(sessionNames, '.') & ~strcmp(sessionNames,'..')); 
    indx = listdlg('ListString',sessionNames, 'Name', 'Select a session');

    if ~isempty(indx)
        
%         % load session 
%         s = loadSession(fullfile(rootDir, sessionNames{indx}));
%         
%         r = s.probes.rawFilename.rawFilename;
%         probeNames = arrayfun(@(x)r(x,:),1:size(r,1),'uni',false);
        
        % try to find the video 
        if ~isempty(vidDir)
            vidPath = fullfile(vidDir, [sessionNames{indx} '_videos']); 
            if ~exist(vidPath, 'dir')
                fprintf(1, 'Looked for the folder %s and did not find it\n', vidPath); 
                vidPath = []; 
            end
        end 
        popRasterWrapper(s,vidPath);
        
%         indx = listdlg('ListString',probeNames, 'Name', 'Select a recording');
        
%         if ~isempty(indx)
%             popRasterWrapper(s,indx,vidPath);
%         end
    end
end