%% Predict New Locations of Existing Tracks
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function tracks = predictNewLocationsOfTracks(tracks)
for i = 1:length(tracks)
    % Get the last bounding box on this track.
    bbox = tracks(i).bboxes(end, :);
    
    % Predict the current location of the track.
    predictedCentroid = predict(tracks(i).kalmanFilter);
    
    % Shift the bounding box so that its center is at the predicted location.
    tracks(i).predPosition = [predictedCentroid - bbox(3:4)/2, bbox(3:4)];
end