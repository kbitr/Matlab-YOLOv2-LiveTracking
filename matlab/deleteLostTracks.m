%% Delete Lost Tracks
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function trk = deleteLostTracks(trk, confidenceThresh, ageThresh, visThresh)

if isempty(trk)
    return;
end

% Compute the fraction of the track's age for which it was visible.
ages = [trk(:).age]';
totalVisibleCounts = [trk(:).totalVisibleCount]';
visibility = totalVisibleCounts ./ ages;

% Check the maximum detection confidence score.
confidence = reshape([trk(:).confidence], 2, [])';
maxConfidence = confidence(:, 1);

% Find the indices of 'lost' tracks.
lostInds = (ages <= ageThresh & visibility <= visThresh) | ...
    (maxConfidence <= confidenceThresh);

% Delete lost tracks.
trk = trk(~lostInds);