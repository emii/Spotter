function tform=calibrateShift(dapi_b_file,ch_b_file)

scr=get(0, 'ScreenSize');
pos=[scr(1:2)+scr(3:4).*0.01,scr(3:4).*0.95];
fig2 = figure( ...
        'Units', 'pixel', ...
        'Position', pos, ...
        'Name', 'Nucleus Spot Counter', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Visible', 'off');
    
    



tmp=parse_stack(dapi_b_file,1,15);
dapi=zproject(tmp);
tmp=parse_stack(ch_b_file,1,15);
ch=zproject(tmp);
ptsDapi=[];
ptsCh=[];


    [ptsDapi, ptsCh] = cpselect(dapi, ch, 'Wait', true);
    
tform = cp2tform(ptsDapi, ptsCh, 'projective');

imChTrans = imtransform(ch, tform, ...
        'XData', [1, size(dapi, 2)], ...
        'YData', [1, size(dapi, 1)]);
    
    % plot the two images overlayed with each image assigned to one color
    % red: left image
    % green: transformed right image
    % blue: no image
    % well aligned points should appear as a single yellow point
    % bad aligned points show up as points with the two distinct colors
    
    ha = tight_subplot(1,2,[.01 .01],[.01 .01],[.01 .01]);

    axes(ha(1));
    OL = zeros(size(dapi, 1), size(dapi, 2), 3);
    OL(:, :, 1) = dapi.*1.7;
    OL(:, :, 2) = ch.*1.7;
    imshow(OL,[]);title('Before','Fontsize',18)
    axis(ha(1),'off','image','ij','square');
    overlayedImages = zeros(size(dapi, 1), size(dapi, 2), 3);
    overlayedImages(:, :, 1) = dapi.*1.7;
    overlayedImages(:, :, 2) = imChTrans.*1.7;
    axes(ha(2));
    imshow(im2uint16(overlayedImages),[]);title('After','Fontsize',18)
    axis(ha(2),'off','image','ij','square');
    set(fig2,'Visible','on')
    waitfor(fig2)
end

    
    
    