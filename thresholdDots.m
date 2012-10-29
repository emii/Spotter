function nucleiDots = thresholdDots(UserData,h,selection)

    stacks=UserData.files(selection);
    nuclei=UserData.nuclei;
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
 
    for ch = 1:numel(stacks),
        msg=['filtering stack: ' stacks{ch} ' please wait...']
        ui.message(h,'filtering, please wait')
        wb = waitbar(0,'Initializing waitbar...');
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
           cims=parse_stack(stackfile,1,50,tform{ch});
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        else
           cims=parse_stack(stackfile,1,50);
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        end
        
        %zcims=zproject(cims);
        %imax=utilities.im(zcims);
        %ax=utilities.plotBoundaries(zcims,nuclei,'g');drawnow;
        %waitfor(ax)
        waitbar(0.5,wb,['Filtering for ' stacks{ch}])
        cims = LOG_filter(cims,10,1.5);
        waitbar(0.9,wb,['Almost Done ' stacks{ch}])
        cims = cims/max(cims(:));
        close(wb)
        zcims=zproject(cims);
        %hn=plotBoundaries(zcims,nuclei,'g');
        %hn=plotBoundaries(zcims,nuclei(5:end),'r',hn);
        imshow(zcims,'Parent',h.imStack);
        utilities.plotBoundaries(zcims,nuclei,'g',h.imStack);
             
        
        
        for n =1:numel(nuclei)
            ui.message(h,['Drag red line to select threshold for nuclei: ' num2str(n)])
            utilities.plotBoundaries(zcims,nuclei,'g',h.imStack);
            utilities.plotBoundaries(zcims,nuclei(n),'r',h.imStack);
            [n_ims snuc]=crop_cell(cims,BW,nuclei(n));

            n_ims = n_ims/max(n_ims(:));%normalize to single cell

            thresholdfn = multithreshstack(n_ims,threshold_num);
            thresholds = (1:threshold_num)/threshold_num;
            [t nc cv]= auto_thresholding(thresholdfn,5,0.1);
            x=thresholds(t);
            y=nc;
            cvx=cv(t);
            [dots vols] = getdots(n_ims,x);
            [dots vols thr num_dots]= ui.updateAxes(h,x,y,cvx,dots,vols,n_ims,snuc,thresholds,thresholdfn,cv);
            dots = [nuclei(n).dots; dots ch.*ones(num_dots,1)];
            nd =[nuclei(n).nd; num_dots ch];
            thr =[nuclei(n).thr; thr ch];
            vols = [nuclei(n).vols; vols ch.*ones(num_dots,1)];
            nuclei(n).dots = dots;
            nuclei(n).nd = nd;
            nuclei(n).thr = thr;
            nuclei(n).vols = vols;
        end
        ui.message(h,'Starting with the next channel ...')
        
    end
    nucleiDots=nuclei;
end
        