



function eventRasters(s, nProbe)
% Wrapper for evRastersGUI from /cortex-lab/spikes
%
% Inputs:
%   - s - is a struct created with loadSession
%   - nProbe - is an index of which probe to include (1-indexed, i.e. cannot
%   be zero)
%
% Example usage:
% >> s = loadSession('Muller_2017-01-07');
% >> eventRasters(s)

if nargin<2
    nProbe = 1; 
end

inclCID = find(s.clusters.probes==nProbe-1)-1; 
inclSpikes = ismember(s.spikes.clusters, inclCID);

st = s.spikes.times(inclSpikes); 
clu = s.spikes.clusters(inclSpikes); 

lickTimes = s.licks.times;

contrastLeft = s.trials.visualStim_contrastLeft;
contrastRight = s.trials.visualStim_contrastRight;
feedback = s.trials.feedbackType;
choice = s.trials.response_choice;
choice(choice==0) = 3; choice(choice==1) = 2; choice(choice==-1) = 1;

cweA = table(contrastLeft, contrastRight, feedback, choice); 

stimOn = s.trials.visualStim_times;
beeps = s.trials.goCue_times;
feedbackTime = s.trials.feedback_times;

cwtA = table(stimOn, beeps, feedbackTime);

moveData = struct();
moveData.moveOnsets = s.wheelMoves.intervals(:,1); 
moveData.moveOffsets = s.wheelMoves.intervals(:,2); 
moveData.moveType = s.wheelMoves.type;


% anatData - a struct with: 
%   - coords - [nCh 2] coordinates of sites on the probe
%   - wfLoc - [nClu nCh] size of the neuron on each channel
%   - borders - table containing upperBorder, lowerBorder, acronym
%   - clusterIDs - an ordering of clusterIDs that you like
%   - waveforms - [nClu nCh nTimepoints] waveforms of the neurons
anatData = struct();
coords = s.channels.sitePositions(s.channels.probe==nProbe-1,:);
anatData.coords = coords;

temps = s.clusters.templateWaveforms(inclCID+1,:,:);
tempIdx = s.clusters.templateWaveformChans(inclCID+1,:);
wfs = zeros(numel(inclCID), size(coords,1), size(temps,2));
for q = 1:size(wfs,1); wfs(q,tempIdx(q,:)+1,:) = squeeze(temps(q,:,:))'; end
anatData.wfLoc = max(wfs,[],3)-min(wfs,[],3); 
anatData.waveforms = wfs;

acr = s.channels.brainLocation.allen_ontology(s.channels.probe==nProbe-1,:);
lowerBorder = 0; upperBorder = []; acronym = {acr(1,:)};
for q = 2:size(acr,1)
    if ~strcmp(acr(q,:), acronym{end})
        upperBorder(end+1) = coords(q,2); 
        lowerBorder(end+1) = coords(q,2); 
        acronym{end+1} = acr(q,:);
    end
end
upperBorder(end+1) = max(coords(:,2));
upperBorder = upperBorder'; lowerBorder = lowerBorder'; acronym = acronym';
anatData.borders = table(upperBorder, lowerBorder, acronym);

pkCh = s.clusters.peakChannel(s.clusters.probes==nProbe-1);
[~,ii] = sort(pkCh); 
anatData.clusterIDs = inclCID(ii); 
anatData.wfLoc = anatData.wfLoc(ii,:); 
anatData.waveforms = anatData.waveforms(ii,:,:);

f = evRastersGUI(st, clu, cweA, cwtA, moveData, lickTimes, anatData);