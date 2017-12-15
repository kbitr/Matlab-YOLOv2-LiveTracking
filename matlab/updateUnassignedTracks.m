
%% Update Unassigned Tracks
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function tracks = updateUnassignedTracks(tracks, unassignedTracks, timeWindowSize)

for i = 1:length(unassignedTracks)
    idx = unassignedTracks(i);
    tracks(idx).age = tracks(idx).age + 1;
    tracks(idx).bboxes = [tracks(idx).bboxes; tracks(idx).predPosition];
    tracks(idx).scores = [tracks(idx).scores; 0];
    
    % Adjust track confidence score based on the maximum detection
    % score in the past 'timeWindowSize' frames
    T = min(timeWindowSize, length(tracks(idx).scores));
    score = tracks(idx).scores(end-T+1:end);
    tracks(idx).confidence = [max(score), mean(score)];
end