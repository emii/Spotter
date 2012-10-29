function tform=calibrateShift(dapi_b_file,ch_b_file)

scr=get(0, 'ScreenSize');
pos=[scr(1:2)+scr(3:4).*0.01,scr(3:4).*0.95];
    
tmp=parse_stack(dapi_b_file,1,15);
dapi = tmp/max(tmp(:));
dapi=zproject(tmp);

tmp=parse_stack(ch_b_file,1,15);
ch = tmp/max(tmp(:));
ch=zproject(tmp);

dapi=imadjust(dapi, stretchlim(dapi,[0 0.999]),[]);
ch=imadjust(ch, stretchlim(ch,[0 0.999]),[]);

if mean(dapi(:))<mean(ch(:))
    [counts,x] = imhist(dapi,1000);
    ch=histeq(ch,counts);
else
    [counts,x] = imhist(ch,1000);
    dapi=histeq(dapi,counts);
end

    [ptsDapi, ptsCh] = cpselect(dapi, ch, 'Wait', true);
    
    fig = figure( ...
            'Units', 'pixel', ...
            'Position', pos, ...
            'Name', 'Nucleus Spot Counter', ...
            'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
            'NumberTitle', 'off', ...
            'Resize', 'on', ...
            'Visible', 'off');    

        tform = cp2tform(ptsCh, ptsDapi, 'projective');

        imChTrans = imtransform(ch, tform, ...
            'XData', [1, size(dapi, 2)], ...
            'YData', [1, size(dapi, 1)]);

        % plot the two images overlayed with each image assigned to one color
        % red: left image
        % green: transformed right image
        % blue: no image
        % well aligned points should appear as a single yellow point
        % bad aligned points show up as points with the two distinct colors

        ha = ui.tight_subplot(1,2,[.01 .01],[.01 .01],[.01 .01]);

        axes(ha(1));
        OL = zeros(size(dapi, 1), size(dapi, 2), 3);
        OL(:, :, 1) = dapi;
        OL(:, :, 2) = ch;
        imshow(OL,[]);title('Before','Fontsize',18)
        axis(ha(1),'off','image','ij','square');
        overlayedImages = zeros(size(dapi, 1), size(dapi, 2), 3);
        overlayedImages(:, :, 1) = dapi;
        overlayedImages(:, :, 2) = imChTrans;
        axes(ha(2));
        imshow(im2uint16(overlayedImages),[]);title('After','Fontsize',18)
        axis(ha(2),'off','image','ij','square');
        set(fig,'Visible','on')
        waitfor(fig)
   
end


    
    
    