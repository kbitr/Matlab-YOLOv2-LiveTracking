%% Display Results
% Adapted from PedestrianTrackingFromMovingCameraExample, 2014 The MathWorks, Inc.

function displayResults(vPlayer, frame, trk, tConfidence, tAge)

if ~isempty(trk)
    confidence = reshape([trk(:).confidence], 2, [])';
    maxConfidence = confidence(:, 1);
    avgConfidence = confidence(:, 2);
    opacity = min(0.5,max(0.1,avgConfidence/3));
    noDispInds = ([trk(:).age]' < tAge & maxConfidence < tConfidence) | ([trk(:).age]' < tAge / 2);
    
    for i = 1:length(trk)
        if ~noDispInds(i)
            frame = insertShape(frame, 'FilledRectangle', trk(i).bboxes(end, :), 'Color',trk(i).color, 'Opacity',opacity(i));
            frame = insertObjectAnnotation(frame, 'rectangle', trk(i).bboxes(end, :), num2str(avgConfidence(i)), 'Color',trk(i).color);
        end
    end
end
step(vPlayer, frame);