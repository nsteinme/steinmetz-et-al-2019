function S = loadSession(sesPath)
% function to load a session of the Steinmetz Neuropixels dataset
% Author: Michael G. Moore, Michigan State University, 
%  - Modified by NS 2020-03-09, with some dataset-specific enhancements
% Version:  V2 2020-03-09

% sesPath   is the directory name of the session, including any required 
%           path information

% S         a data structure containing all the session variables   

% assumptions:
%   - the data files for a session are in a unique folder.
%   - all .npy and .tsv files in the folder are part of the data
%   - file names indicate a structural hierarchy of the data via the '.' 
%   - matlab knows the path to the npy-matlab-master package  

S = struct;
S.sesPath = sesPath;

% get session name
temp = strsplit(sesPath,filesep);
S.sesName = temp{end};

% list all files and info
fdir = dir(sesPath);
fdir = fdir(3:end); % remove '.' and '..' from the file-list

S.fileList = fdir; % add the file-list to the dataset structure as a record

% examine each file and either read it into Matlab or ignore it
for f = 1:length(fdir)
    % check if file or subdirectory (ignore subdirectories)
    if fdir(f).isdir
        continue
    end
    % separate file type and data structure fields
    temp = strsplit(fdir(f).name,'.');
    ftype = temp{end};
    fields = temp(1:(end-1));
    % keep only .npy and .tsv files
    if ~isequal(ftype,'npy') && ~isequal(ftype,'tsv')
        continue
    end
    % check fields for valid names
    for m = 1:length(fields)
        % Modify the names so that they are valid Matlab variable names
        %   if first character is not a letter, will prefix an "x" 
        %   whitespace will be deleted
        %   whitespace followed by a letter will be replaced by the capitalized letter
        %   invalid characters will be replaced by underscore
        fields{m} = matlab.lang.makeValidName(fields{m});
    end
    % read the .npy and .tsv files
    if isequal(ftype,'npy')
        val = readNPY([sesPath filesep fdir(f).name]);
    elseif isequal(ftype,'tsv')
        val = tdfread([sesPath filesep fdir(f).name]);
    end      
    % create a field of S using fields and val 
    S = setfield(S,fields{1:end},val);
   
end


% acronyms for each channel
acrPerChannel = arrayfun(@(x)S.channels.brainLocation.allen_ontology(x,:), 1:size(S.channels.brainLocation.allen_ontology,1), 'uni', false); 
acrPerChannel = cellfun(@(x)x(1:iff(any(x==' '), find(x==' ',1)-1, numel(x))), acrPerChannel, 'uni', false); 
S.channels.acronym = acrPerChannel';


end
