

function movieWithTracesSpikesWrapper(s, nProbe)





tInd=1;
t = s.eye.timestamps; tr = s.eye.area;
tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
traces(tInd).t = tVec;
traces(tInd).v = tr;
traces(tInd).name = 'eye.area';
eyeInTr = tr(tVec>min(s.trials.intervals(:)) & tVec<max(s.trials.intervals(:)));
traces(tInd).lims = prctile(eyeInTr, [5 95]);

tInd=2;
t = s.lickPiezo.timestamps; tr = s.lickPiezo.raw;
tVec = interp1(t(:,1), t(:,2), 0:numel(tr)-1);
traces(tInd).t = tVec;
traces(tInd).v = tr;
traces(tInd).name = 'lickPiezo.raw';
traces(tInd).lims = [-1 1]*max(abs(tr))*0.75;

tInd=3;
t = s.wheel.timestamps; p = s.wheel.position;
tPerSamp = interp1(t(:,1), t(:,2), 0:numel(p)-1);
tVec = tPerSamp(1):(1/1000):tPerSamp(end);
p = interp1(tPerSamp, p, tVec); 
tr = computeVelocityForWheel(p, 0.025, 1/mean(diff(tVec)));
traces(tInd).t = tVec;
traces(tInd).v = tr;
traces(tInd).name = 'lickPiezo.raw';
traces(tInd).lims = [-1 1]*max(abs(tr))*0.75;


t = s.trials.visualStim_times;
[xx,yy] = rasterize(t);
traces(end+1).t = xx;
traces(end).v = yy;
traces(end).name = 'stimOn';

t = s.trials.goCue_times;
[xx,yy] = rasterize(t);
traces(end+1).t = xx;
traces(end).v = yy;
traces(end).name = 'goCue';

t = s.trials.feedback_times;
[xx,yy] = rasterize(t);
traces(end+1).t = xx;
traces(end).v = yy;
traces(end).name = 'feedback';

% load videos
% auxVid = prepareAuxVids(mouseName, thisDate, expNum);
% faceT = readNPY(fullfile(alfDir, 'face.timestamps.npy'));
% tVec = interp1(faceT(:,1), faceT(:,2), 0:numel(auxVid(1).data{2})-1);
% auxVid(1).data{2} = tVec;
% eyeT = readNPY(fullfile(alfDir, 'eye.timestamps.npy'));
% tVec = interp1(eyeT(:,1), eyeT(:,2), 0:numel(auxVid(2).data{2})-1);
% auxVid(2).data{2} = tVec;
auxVid = [];

inclCID = find(s.clusters.probes==nProbe-1)-1; 
inclSpikes = ismember(s.spikes.clusters, inclCID);

st = s.spikes.times(inclSpikes); 
clu = double(s.spikes.clusters(inclSpikes))+1; 
% depths = s.spikes.depths(inclSpikes); 


% create a simulated set of "waveforms" that will just highlight the
% correct segment of the probe
% uClu = unique(clu); 
% fakeWF = zeros(numel(uClu), numel(sp(spInd).xcoords));
% ycBins = ceil(sp(spInd).ycoords/depthBin)*depthBin;
% for c = 1:numel(uClu)
%     fakeWF(c,ycBins==uClu(c)) = 1;
% end
% anatData.wfLoc = fakeWF;

% switch type
%     case 'mua'
%         depthBinSize = 80;
%         clu = ceil(depths/depthBinSize);
%         pars.smoothSizeT = 0;
%         
%         % create a simulated set of "waveforms" that will just highlight the
%         % correct segment of the probe
% %         uClu = unique(clu);
% %         fakeWF = zeros(numel(uClu), numel(xcoords));
% %         ycBins = ceil(ycoords/depthBinSize)*depthBinSize;
% %         for c = 1:numel(uClu)
% %             fakeWF(c,ycBins==uClu(c)) = 1;
% %         end
% %         anatData.wfLoc = fakeWF;
%     case 'clu'
%         clu = readNPY(fullfile(alfDir, tag, 'spikes.clusters.npy'));
%         % now re-sort the clu numbers by depth
% end
pars.winSize = [-2 1];
pars.normalize = false;
pars.binSize = 0.002;
movieWithTracesSpikes(st, clu, traces, auxVid, [], pars)



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