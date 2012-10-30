function UserData= thresholdDots(UserData,h,selection)

    stacks=UserData.files(selection);
    nuclei=UserData.nuclei;
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
    L=UserData.L;
    for ch = 1:numel(stacks),
        msg=['filtering stack: ' stacks{ch} ' please wait...'];
        ui.message(h,msg)
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
        
        L{ch}=zeros(size(cims,2),size(cims,1));
        
        
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
            [dots vols bwl] = getdots(n_ims,x);
            [dots vols bwl thr num_dots]= ui.updateAxes(h,x,y,cvx,dots,vols,bwl,n_ims,snuc,thresholds,thresholdfn,cv);
                bwl=max(bwl,[],3);
                L{ch}(nuclei(n).PixelList(:,2),nuclei(n).PixelList(:,1))=...
                    bwl(snuc.PixelList(:,2),snuc.PixelList(:,1));

                dots = [nuclei(n).dots; dots ch.*ones(num_dots,1)];
                nd =[nuclei(n).nd; num_dots ch];
                thr =[nuclei(n).thr; thr ch];
                vols = [nuclei(n).vols; vols ch.*ones(num_dots,1)];
                nuclei(n).dots = dots;
                nuclei(n).nd = nd;
                nuclei(n).thr = thr;
                nuclei(n).vols = vols;
        end
        ui.message(h,'Spots in the channel counted, you can save')
        
    end
    UserData.nuclei=nuclei;
    UserData.L=L;
end
        