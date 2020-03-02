

function popRasterWrapper(s, vidPath)

r = struct();

% Spikes
% inclCID = find(s.clusters.probes==nProbe-1)-1; 
% inclSpikes = ismember(s.spikes.clusters, inclCID);

% r.st = s.spikes.times(inclSpikes); 
% r.clu = double(s.spikes.clusters(inclSpikes))+1; 
% r.cids = inclCID+1; 
% r.cgs = s.clusters.x_phy_annotation(inclCID+1);
% % depths = s.spikes.depths(inclSpikes); 
% cluDepths = s.clusters.depths(inclCID+1); 
r.st = s.spikes.times; 
r.clu = double(s.spikes.clusters)+1; 
r.cids = unique(r.clu); 
r.cgs = s.clusters.x_phy_annotation;
% depths = s.spikes.depths(inclSpikes); 
cluDepths = s.clusters.depths; 
cluDepths = cluDepths+s.clusters.probes*3840;


% Anatomy
acr = s.channels.brainLocation.allen_ontology;
chanDepth = s.channels.sitePositions(:,2)+s.channels.probe*3840;
lowerBorder = 0; upperBorder = []; acronym = {acr(1,:)};
for q = 2:size(acr,1)
    if ~strcmp(acr(q,:), acronym{end})
        upperBorder(end+1) = chanDepth(q); 
        lowerBorder(end+1) = chanDepth(q); 
        acronym{end+1} = acr(q,:);
    end
end
upperBorder(end+1) = max(chanDepth);
upperBorder = upperBorder'; lowerBorder = lowerBorder'; acronym = acronym';
sep = '---'; 
sepY = upperBorder(1:end-1); 
acrY = (upperBorder+lowerBorder)/2; 
[allY,ii] = sort([acrY; sepY]); 
allAcr = [acronym; repmat({sep}, numel(sepY),1)]; 
allAcr = allAcr(ii); 

% Sorting and plotting of spikes
r.yAxOrderings(1).name = 'depth value'; 
r.yAxOrderings(1).yPos = cluDepths(:);
r.yAxOrderings(1).yLabelVal = allY;
r.yAxOrderings(1).yLabel = allAcr;

r.yAxOrderings(2).name = 'depth index'; 
[cluDepthsSort,ii] = sort(cluDepths); dpOrder = zeros(size(cluDepths)); dpOrder(ii) = 1:numel(cluDepths);
r.yAxOrderings(2).yPos = dpOrder(:);
cluDepthsSort = [cluDepthsSort; max([upperBorder; cluDepths])+1];
upper = arrayfun(@(x)find(cluDepthsSort>upperBorder(x),1), 1:numel(upperBorder));
lower = arrayfun(@(x)find(cluDepthsSort>lowerBorder(x),1), 1:numel(lowerBorder));
eq = lower==upper; 
lower = lower(~eq)'; upper = upper(~eq)'; acronym = acronym(~eq); 

sepY = upper(1:end-1); 
acrY = (upper+lower)/2; 
[allY,ii] = sort([acrY; sepY]); 
allAcr = [acronym; repmat({sep}, numel(sepY),1)]; 
allAcr = allAcr(ii);

r.yAxOrderings(2).yLabelVal = allY;
r.yAxOrderings(2).yLabel = allAcr;

% r.yAxOrderings(3).name = 'clu'; 
% r.yAxOrderings(3).yPos = [1:numel(r.cids)]';

[vals,inst] = countUnique(r.clu);
assert(numel(vals)==numel(r.cids)&&all(vals==r.cids));
[~,ii] = sort(inst); frOrder = zeros(size(inst)); frOrder(ii) = 1:numel(inst);
r.yAxOrderings(3).name = 'firing rate'; 
r.yAxOrderings(3).yPos = frOrder(:);
r.yAxOrderings(3).yLabelVal = [1 numel(inst)];
r.yAxOrderings(3).yLabel = {'min', 'max'};

r.colorings(1).name = 'random'; 
cm = colorcet('C6'); % cm = hsv(100); 
rcm = zeros(numel(r.cids),3);
thisR = rand(1,numel(r.cids));
for c = 1:3    
    rcm(:,c) = interp1(linspace(0, 1, size(cm,1)), cm(:,c), thisR);
end
r.colorings(1).colors = rcm;
r.colorings(2).name = 'by group'; 
r.colorings(2).colors = zeros(numel(r.cids), 4);
r.colorings(2).colors(r.cgs>1,:) = 1;
r.colorings(3).name = 'depth'; 
cm = colorcet('C6'); %cm = hsv(100); 
dcm = zeros(numel(r.cids),3);
for c = 1:3
    dcm(:,c) = interp1(linspace(min(cluDepths), max(cluDepths),size(cm,1)), cm(:,c), cluDepths);
end
r.colorings(3).colors = dcm;
% to add: by spike amplitude, by anatomical region


% Behavioral Events
visColorsL = copper(4); visColorsL = visColorsL(2:4, [3 1 2]);
visColorsR = copper(4); visColorsR = visColorsR(2:4, [1 3 2]);
stimOn = s.trials.visualStim_times;
cL = s.trials.visualStim_contrastLeft;
uL = unique(cL);
cR = s.trials.visualStim_contrastRight;
uR = unique(cR);
n = 1;
events(n).times = stimOn(cR==uR(2)); events(n).name = 'stim right low';
events(n).spec = {'Color', visColorsR(1,:), 'LineWidth',0.5};
n = n+1;
events(n).times = stimOn(cR==uR(3)); events(n).name = 'stim right med';
events(n).spec = {'Color', visColorsR(2,:), 'LineWidth',1.0};
n = n+1;
events(n).times = stimOn(cR==uR(4)); events(n).name = 'stim right high';
events(n).spec = {'Color', visColorsR(3,:), 'LineWidth',2.0};
n = n+1;
events(n).times = stimOn(cL==uL(2)); events(n).name = 'stim left low';
events(n).spec = {'Color', visColorsL(1,:), 'LineWidth',0.5, 'LineStyle', '--'};
n = n+1;
events(n).times = stimOn(cL==uL(3)); events(n).name = 'stim left med';
events(n).spec = {'Color', visColorsL(2,:), 'LineWidth',1.0, 'LineStyle', '--'};
n = n+1;
events(n).times = stimOn(cL==uL(4)); events(n).name = 'stim left high';
events(n).spec = {'Color', visColorsL(3,:), 'LineWidth',2.0, 'LineStyle', '--'};

beeps = s.trials.goCue_times;
n = n+1;
events(n).times = beeps; events(n).name = 'aud tone cue'; events(n).spec = {'Color', [0 0 1]};

feedbackTime = s.trials.feedback_times;
feedbackType = s.trials.feedbackType;
n = n+1;
events(n).times = feedbackTime(feedbackType==1); events(n).name = 'reward'; events(n).spec = {'Color',[0 1 0]};
n = n+1;
events(n).times = feedbackTime(feedbackType==-1); events(n).name = 'neg feedback'; events(n).spec = {'Color',[1 0 0]};
    

% Behavioral traces
t = s.wheel.timestamps; p = s.wheel.position;
tPerSamp = interp1(t(:,1), t(:,2), 0:numel(p)-1);
tVec = tPerSamp(1):(1/1000):tPerSamp(end);
p = interp1(tPerSamp, p, tVec); 
tr = computeVelocityForWheel(p, 0.025, 1/mean(diff(tVec)));
traces(1).t = tVec; traces(1).v = tr; traces(1).name = 'wheel velocity';
traces(1).color = [1 1 1];

t = s.lickPiezo.timestamps; tr = s.lickPiezo.raw;
tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
traces(2).t = tVec; traces(2).v = tr; traces(2).name = 'lick signal';
traces(2).color = [0 1 1];

t = s.eye.timestamps; tr = s.eye.area;
tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
traces(3).t = tVec; traces(3).v = tr; traces(3).name = 'pupil area';
traces(3).color = [1 1 0];

auxVid = [];
if ~isempty(vidPath)&&exist(fullfile(vidPath, 'eye.mj2'))
    t = s.eye.timestamps; tr = s.eye.area;
    tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
    auxVid = makeAuxVid(fullfile(vidPath, 'eye.mj2'), tVec, 'eye');
end
if ~isempty(vidPath)&&exist(fullfile(vidPath, 'face.mj2'))
    t = s.face.timestamps; tr = s.face.motionEnergy;
    tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
    av = makeAuxVid(fullfile(vidPath, 'face.mj2'), tVec, 'face');
    if exist('auxVid')
        auxVid = [auxVid av]; 
    else
        auxVid = av;
    end
end





viewerPars.startTime = stimOn(1);

popRasterViewer(r, events, traces, auxVid, viewerPars)




function [vel, acc] = computeVelocityForWheel(pos, smoothSize, Fs)
% function [vel, acc] = computeVelocity(pos, smoothSize, Fs)
%
% assumes pos is uniformly sampled in time
%
% smooth size is in units of seconds

% area of this smoothing window is 1 so total values are unchanged - units
% don't change
% smoothWin = wheel.gausswin(smoothSize)./sum(gausswin(smoothSize));
smoothWin = myGaussWin(smoothSize, Fs); 
pos = pos(:);
vel = [0; conv(diff(pos), smoothWin, 'same')]*Fs; % multiply by Fs to get cm/sec

if nargout>1
    % here we choose to apply the smoothing again - it's sort of
    % empirically necessary since derivatives amplify noise. 
    acc = [0; conv(diff(vel), smoothWin, 'same')]*Fs; %cm/sec^2
end


function auxVid = makeAuxVid(vidPath, tVid, name)

auxVid = struct();

if exist(vidPath, 'file')
    vr = VideoReader(vidPath);
    auxVid(1).data = {vr, tVid};
    auxVid(1).f = @plotMJ2frame;
    auxVid(1).name = name;
end

