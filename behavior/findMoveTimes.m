
function [moveTimeUse, firstMoveType, firstMoveTime, hasNoMoveInWin] = ...
    findMoveTimes(...
    cweA, cwtA, moveData, win, winNoMove)
% determine the movement times to use, including choosing a suitable null 

if nargin<4
    win = [0.075 0.4];
    winNoMove = [-0.1 0.4];
elseif nargin<5
    winNoMove = [-0.1 0.4];
end


inclTrials = cweA.inclTrials;
nT = numel(inclTrials);

firstMoveTime = NaN(nT,1);
firstMoveType = NaN(nT,1);
hasNoMoveInWin = false(nT,1);

mOn = moveData.moveOnsets;
mType = moveData.moveType;
stimOn = cwtA.stimOn;
fbTime = cwtA.feedbackTime;

for t = 1:nT
    thisM = find(mOn>stimOn(t)-0.1,1); 
    % -0.1 because there is a pre-stim quiescent period - some movements
    % can start just before the stimulus onset, but they won't start before
    % that. 
    
    mt = mOn(thisM);
    if mt<fbTime(t) % move happened some time during this trial
        firstMoveTime(t) = mt-stimOn(t);
        firstMoveType(t) = mType(thisM);
                
        if firstMoveTime(t)<winNoMove(1) || firstMoveTime(t)>winNoMove(2)
            hasNoMoveInWin(t) = true;        
        end
        
    end
end

moveTimeUse = firstMoveTime;

allMT = moveTimeUse(...
    (firstMoveType==1 | firstMoveType==2) & ...
    (firstMoveTime>=win(1) & firstMoveTime<=win(2)) & ...
    inclTrials);

% here, choose "moveTime" for the no-move trials to be randomly selected
% from actual move times, for use as a control
moveTimeUse(hasNoMoveInWin) = allMT(randi(numel(allMT), sum(hasNoMoveInWin),1));
