function mainFile()
clear all; clc;

%% Parameters
thresh = 0.24; %display thresh
hier_thresh = 0.5;
frame = imread(fullfile(pwd,'images/img0.jpg'));

%% Init
datacfg = fullfile(pwd,'/darknet/cfg/coco.data');
cfgfile = fullfile(pwd,'darknet/cfg/tiny-yolo.cfg');
weightfile = fullfile(pwd,'tiny-yolo-old.weights');

yolomex('init',datacfg,cfgfile,weightfile);

%% Detect
tic;
ddts = yolomex('detect',frame,thresh,hier_thresh);
toc;

%% Display
for i = 1:size(vertcat(ddts.left))
    bbs = [ddts(i).left ddts(i).top ddts(i).right-ddts(i).left ddts(i).bottom-ddts(i).top];
    frame = insertShape(frame, 'FilledRectangle', bbs, 'Color',[158, 255, 158], 'Opacity',0.35);
    frame = insertObjectAnnotation(frame, 'rectangle', bbs, ddts(i).class, 'Color','yellow', 'LineWidth',1);
end
imshow(frame);
%% Cleanup
yolomex('cleanup');
end