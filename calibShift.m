
clear all;close all;clc
dapi=parse_stack('./data/beads/dapi_002.tif',1,15);
dapi=zproject(dapi);
%dapi=imadjust(dapi);
tmr=parse_stack('./data/beads/tmr_002.tif',1,15);
tmr=zproject(tmr);
%tmr=imadjust(tmr);
%%
    OL = zeros(size(dapi, 1), size(dapi, 2), 3);
    OL(:, :, 1) = dapi;
    OL(:, :, 2) = tmr;
    
    figure;
    imshow(im2uint16(OL))
%%

    [pointsLeft, pointsRight] = cpselect(dapi, tmr, 'Wait', true);

%%
tform = cp2tform(pointsRight, pointsLeft, 'projective');

imageRightTransformed = imtransform(tmr, tform, ...
        'XData', [1, size(dapi, 2)], ...
        'YData', [1, size(dapi, 1)]);
    
        % plot the two images overlayed with each image assigned to one color
    % red: left image
    % green: transformed right image
    % blue: no image
    % well aligned points should appear as a single yellow point
    % bad aligned points show up as points with the two distinct colors
    overlayedImages = zeros(size(dapi, 1), size(dapi, 2), 3);
    overlayedImages(:, :, 1) = dapi;
    overlayedImages(:, :, 2) = imageRightTransformed;
    
    figure;
    imshow(im2uint16(overlayedImages),[]);
    

    
    
    