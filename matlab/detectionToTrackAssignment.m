%% Assign Detections to Tracks
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(trk, bboxes, gatingThresh, gatingCost, costOfNonAssignment)

% Compute the overlap ratio between the predicted boxes and the
% detected boxes, and compute the cost of assigning each detection
% to each track. The cost is minimum when the predicted bbox is
% perfectly aligned with the detected bbox (overlap ratio is one)
predBboxes = reshape([trk(:).predPosition], 4, [])';
cost = 1 - bboxOverlapRatio(predBboxes, bboxes);

% Force the optimization step to ignore some matches by
% setting the associated cost to be a large number. Note that this
% number is different from the 'costOfNonAssignment' below.
% This is useful when gating (removing unrealistic matches)
% technique is applied.
cost(cost > gatingThresh) = 1 + gatingCost;

% Solve the assignment problem.
[assignments, unassignedTracks, unassignedDetections] = assignDetectionsToTracks(cost, costOfNonAssignment);