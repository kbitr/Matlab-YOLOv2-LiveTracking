%% Tracking Pedestrians Live
%
% This example shows how to track people using a camera.
% VAR: t*=Threshold, c*=Cost

function mainTracking()
clear all; clc;
addpath(fullfile(pwd,'matlab'));

%% Parameters
vidObj         = webcam();

% Tracking
load('aScale.mat');   % Table with expected sizes at certain positions
tScale         = 100; % Tolerance of the error in estimating the scale of pedestrians (inf=ignore)
tGating        = 0.9; % When to reject a candidate match between a detection and a track
cGating        = 100; % Value for the cost matrix for enforcing the rejection of a candidate match (large)
cNonAssignment = 10;  % Likelihood of creation of a new track
tNumFrames     = 1;  % Number of frames required to stabilize the confidence of a track
tConfidence    = 0;   %4 Threshold for a detection become a true positive (2)
tAge           = 0;   %8 Minimum length required for a track being true positive
tVisibility    = 0.6; % Minimum visibility value for a track being true positive

% YOLO
global thresh;      thresh = 0.24; %display thresh
global hier_thresh; hier_thresh = 0.5;
datacfg = fullfile(pwd,'darknet/cfg/coco.data');
cfgfile = fullfile(pwd,'darknet/cfg/tiny-yolo.cfg');
weightfile = fullfile(pwd,'tiny-yolo-old.weights');

%%  Init
trk = struct('id',{},'color',{},'bboxes',{},'scores',{},'kalmanFilter',{},'age',{},'totalVisibleCount',{},'confidence',{},'predPosition',{}); % Empty array
vPlayer = vision.DeployableVideoPlayer(); % Create player
id = 1; % Id of the first track
yolomex('init',datacfg,cfgfile,weightfile);

%% Detect and track people
runLoop = true; j=1;
while runLoop
    tic;
    frame = snapshot(vidObj);
    [centers, bboxes, scores] = yoloDetectPeople(aScale, frame, tScale);
    trk = predictNewLocationsOfTracks(trk);
    [assigments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(trk, bboxes, tGating, cGating, cNonAssignment);
    trk = updateAssignedTracks(trk, assigments, centers, bboxes, scores, tNumFrames);
    trk = updateUnassignedTracks(trk, unassignedTracks, tNumFrames);
    trk = deleteLostTracks(trk, tConfidence, tAge, tVisibility);
    trk = createNewTracks(trk, unassignedDetections, centers, bboxes, scores, id); id = id + 1;
    timer(j,:) = toc; j = j+1;
    displayResults(vPlayer, frame, trk, tConfidence, tAge);
    
    runLoop = isOpen(vPlayer);
end
release(vPlayer);
yolomex('cleanup');
fps = 1/mean(timer)
end