function thresholdDots(UserData,h,selection)

    stacks=UserData.files(selection);
    nuclei=UserData.nuclei;
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
    
    for ch = 1:numel(stacks)
        set(h.uiMessage,'string',stacks{ch});
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
           cims=parse_stack(stackfile,1,50,tform{ch});
        else
           cims=parse_stack(stackfile,1,50);
        end
        
        zcims=zproject(cims);
        %imax=utilities.im(zcims);
        utilities.plotBoundaries(zcims,nuclei,'g');

        
        cims = LOG_filter(cims,10,1.5);
        cims = cims/max(cims(:));
        zcims=zproject(cims);
        %hn=plotBoundaries(zcims,nuclei,'g');
        %hn=plotBoundaries(zcims,nuclei(5:end),'r',hn);
        imshow(zcims,'Parent',h.imStack);
        utilities.plotBoundaries(zcims,nuclei,'g',h.imStack);
        waitforbuttonpress
    end
end
        