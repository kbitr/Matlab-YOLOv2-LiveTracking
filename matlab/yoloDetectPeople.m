%% Detect People
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function [centroids, bboxes, scores] = yoloDetectPeople(aScale, frame, scThresh)
%% Run

global thresh;
global hier_thresh;
bboxes = [9999 9999 9999 9999]; % out of range init
scores = 0;

ddts = yolomex('detect',frame,thresh,hier_thresh);

for i = 1:size(vertcat(ddts.left))
    %if strcmp(ddts(i).class,'person')
        bboxes(i,:) = [ddts(i).left ddts(i).top ddts(i).right-ddts(i).left ddts(i).bottom-ddts(i).top];
        scores(i,:) = [ddts(i).prob];
   % end
end
% Look up the estimated height of a pedestrian based on location of their feet.
height = bboxes(:, 4);
y = (bboxes(:,2)-1) / 2;
yfoot = min(length(aScale), round(y + height));
estHeight = aScale(1); %% (yfoot) !! %%

% Remove detections whose size deviates from the expected size,
% provided by the calibrated scale estimation.
invalid = abs(estHeight-height)>estHeight*scThresh;
bboxes(invalid, :) = [];
scores(invalid, :) = [];

% Apply non-maximum suppression to select the strongest bounding boxes.
[bboxes, scores] = selectStrongestBbox(bboxes, scores, ...
    'RatioType', 'Min', 'OverlapThreshold', 0.6);

% Compute the centroids
if isempty(bboxes)
    centroids = [];
else
    centroids = [(bboxes(:, 1) + bboxes(:, 3) / 2), ...
        (bboxes(:, 2) + bboxes(:, 4) / 2)];
end