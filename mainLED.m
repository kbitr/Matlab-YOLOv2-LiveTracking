% This function uses it's own display fuction (see below)

function mainLED()
delete(instrfindall);
clear all; clc;

%% Parameters

% YOLO
datacfg = fullfile(pwd,'darknet/cfg/coco.data');
cfgfile = fullfile(pwd,'darknet/cfg/tiny-yolo.cfg'); %or: yolo.cfg
weightfile = fullfile(pwd,'weights/tiny-yolo.weights'); %or: yolo.weights
resizeRatio = 1;
thresh = 0.24;
hier_thresh = 0.5;

% Display
live = 1; % live or file mode
serial = 0;
numFrame = 500; % Set start frame
numLED      = 10;
drawBoxes   = 1;
drawLED     = 0;
drawLines   = 0;
serialLED   = 0;

%% Init
% Serial
if serial
    serObj = ('/dev/ttyS0'); % options: seriallist()
    fopen(serObj);
end

% YOLO
yolomex('init',datacfg,cfgfile,weightfile);

% Image Source
obj.videoPlayer = vision.DeployableVideoPlayer();
if live
    vidObj  = webcam();
    frame = snapshot(vidObj);
else
    frame = imread(fullfile(pwd, 'images/img0.jpg'));
end
frameSize = size(frame);

% LED
if drawLED
    coord = zeros(numLED-1:4);
    x_coord = frameSize(2)/numLED;
    y = frameSize(1);
    for li = 1:numLED-1
        coord(li,:) = [li*x_coord 0 li*x_coord y];
    end
end

%% Detector
runLoop = true;
while runLoop
    if live
        frame = snapshot(vidObj);
    else
        frame = imread(fullfile(pwd, sprintf('images/img%d.jpg', numFrame)));
        numFrame = numFrame+1;
    end
    frame = imresize(frame, resizeRatio, 'Antialiasing',false);
    tic;
    ddts = yolomex('detect', frame, thresh, hier_thresh);
    FPS = 1/toc
    displayResults();
    runLoop = isOpen(obj.videoPlayer);
end

%% Cleanup
release(obj.videoPlayer);
yolomex('cleanup');
if serial, fscanf(serObj); end
delete(instrfindall);

%% Display Results
    function displayResults()
        if drawLines
            frame = insertShape(frame, 'Line', coord, 'Color','yellow', 'Opacity',0.1);
        end
        if ~isempty(ddts)
            for i = 1:size(vertcat(ddts.left))
                if strcmp(ddts(i).class, 'person') % Only Persons
                    if drawBoxes
                        bbs = [ddts(i).left ddts(i).top ddts(i).right-ddts(i).left ddts(i).bottom-ddts(i).top];
                        frame = insertShape(frame, 'FilledRectangle', bbs, 'Color','yellow', 'Opacity',0.1);
                        frame = insertObjectAnnotation(frame, 'rectangle', bbs, ddts(i).class, 'Color','yellow', 'LineWidth',1);
                    end
                    if drawLED
                        x_coord = frameSize(2)/numLED;
                        LED_left = round(ddts(i).left/frameSize(2)*numLED);
                        LED_right = round(ddts(i).right/frameSize(2)*numLED);
                        LED_range = LED_right - LED_left;
                        frame = insertShape(frame, 'FilledRectangle', [LED_left*x_coord, 0, LED_range*x_coord, frameSize(1)], 'Color','green', 'Opacity',0.2);
                        if serialLED
                            stringLED = 'LED';
                            for LEDs = LED_left:LED_right
                                stringLED = strcat(stringLED,'-',num2str(LEDs));
                            end
                            if serial
                                fprintf(serObj,stringLED);
                                %input = fgetl(serObj); %or: fgets, fscanf % for test printing
                            end
                        end
                    end
                end
            end
        end
        step(obj.videoPlayer, frame);
    end
end