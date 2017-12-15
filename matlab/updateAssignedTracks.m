%% Update Assigned Tracks
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function tracks = updateAssignedTracks(tracks, assignments, centroids, bboxes, scores, timeWindowSize)

numAssignedTracks = size(assignments, 1);
for i = 1:numAssignedTracks
    trackIdx = assignments(i, 1);
    detectionIdx = assignments(i, 2);
    
    centroid = centroids(detectionIdx, :);
    bbox = bboxes(detectionIdx, :);
    
    % Correct the estimate of the object's location
    % using the new detection.
    correct(tracks(trackIdx).kalmanFilter, centroid);
    
    % Stabilize the bounding box by taking the average of the size
    % of recent (up to) 4 boxes on the track.
    T = min(size(tracks(trackIdx).bboxes,1), 4);
    w = mean([tracks(trackIdx).bboxes(end-T+1:end, 3); bbox(3)]);
    h = mean([tracks(trackIdx).bboxes(end-T+1:end, 4); bbox(4)]);
    tracks(trackIdx).bboxes(end+1, :) = [centroid - [w, h]/2, w, h];
    
    % Update track's age.
    tracks(trackIdx).age = tracks(trackIdx).age + 1;
    
    % Update track's score history
    tracks(trackIdx).scores = [tracks(trackIdx).scores; scores(detectionIdx)];
    
    % Update visibility.
    tracks(trackIdx).totalVisibleCount = ...
        tracks(trackIdx).totalVisibleCount + 1;
    
    % Adjust track confidence score based on the maximum detection
    % score in the past 'timeWindowSize' frames.
    T = min(timeWindowSize, length(tracks(trackIdx).scores));
    score = tracks(trackIdx).scores(end-T+1:end);
    tracks(trackIdx).confidence = [max(score), mean(score)];
end