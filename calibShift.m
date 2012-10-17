
clear all;close all;clc
dapi=parse_stack('./data/beads/dapi_002.tif',1,15);
dapi=zproject(dapi);
%dapi=imadjust(dapi);
tmr=parse_stack('./data/beads/tmr_002.tif',1,15);
tmr=zproject(tmr);
%tmr=imadjust(tmr);
%%
ptsDapi=[];
ptsCh=[];
%%
    OL = zeros(size(dapi, 1), size(dapi, 2), 3);
    OL(:, :, 1) = dapi;
    OL(:, :, 2) = tmr;
    %OL=imadjust(OL,[0 0], [0.8 0]);
    figure;
    imshow(OL)
%%
if isempty(ptsDapi) || isempty(ptsCh)
    [ptsDapi, ptsCh] = cpselect(dapi, tmr, 'Wait', true);
else
    [ptsDapi, ptsCh] = cpselect(dapi, tmr, ptsDapi,ptsCh,'Wait', true);
end
%%
tform = cp2tform(ptsCh,ptsDapi, 'projective');

imChTrans = imtransform(tmr, tform, ...
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
    overlayedImages(:, :, 2) = imChTrans;
    
    figure;
    imshow(im2uint16(overlayedImages),[]);
    

    
    
    