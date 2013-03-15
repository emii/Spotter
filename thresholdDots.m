function UserData= thresholdDots(UserData,h,selection)
% some parameters
    CV_width = 5;
    CV_offset = 0.1;
    %LOG_Size = [11 11 7];%15
    %LOG_Sigma = [1.4 1.4 1.1];%1.3
    LOG_Size = [15 15 7];%15
    LOG_Sigma = [1.3 1.3 1.1];%1.3
    
    

    stacks=UserData.files;
    nuclei=UserData.nuclei;
    st=getappdata(h.f,'status');
    
    
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
    L=UserData.L;
    for ch = selection,
        
        if st.counted(ch)
            for i= 1:numel(nuclei)
                nuclei(i).nd=nuclei(i).nd(nuclei(i).nd(:,2)~=selection,:);
                nuclei(i).thr=nuclei(i).thr(nuclei(i).thr(:,2)~=selection,:);
                nuclei(i).dots=nuclei(i).dots(nuclei(i).dots(:,4)~=selection,:);
                nuclei(i).intensity=nuclei(i).intensity(nuclei(i).intensity(:,2)~=selection,:);
                nuclei(i).vol=nuclei(i).vol(nuclei(i).vol(:,2)~=selection,:);
            end
        end
        
        msg=['filtering stack: ' stacks{ch} ' please wait...'];
        ui.message(h,msg)
        wb = waitbar(0,'Parsing and filtering and stuff...');
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
           info=imfinfo(stackfile);
           cims=parse_stack(stackfile,1,numel(info),tform{ch});
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        else
           info=imfinfo(stackfile);
           cims=parse_stack(stackfile,1,numel(info));
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        end
        

        waitbar(0.5,wb,['Filtering for ' stacks{ch}])
        cims = LOG_filter(cims,LOG_Size,LOG_Sigma);
        waitbar(0.9,wb,['Almost Done ' stacks{ch}])
        cims = cims/max(cims(:));
        close(wb)
        zcims=zproject(cims);
        %hn=plotBoundaries(zcims,nuclei,'g');
        %hn=plotBoundaries(zcims,nuclei(5:end),'r',hn);
        delete(allchild(h.imStack));
        imshow(zcims,'Parent',h.imStack);drawnow;
        set(h.imStack,'NextPlot','add')
        utilities.plotBoundaries(zcims,nuclei([nuclei.class]==1),'g',h.imStack);
        utilities.plotBoundaries(zcims,nuclei([nuclei.class]==2),'m',h.imStack);
        set(h.imStack,'NextPlot','replacechildren')
        %L{ch}=zeros(size(cims,2),size(cims,1));
        
        
%             utilities.plotBoundaries(zcims,nuclei([nuclei.class]==1),'g',h.imStack,0);
%             utilities.plotBoundaries(zcims,nuclei([nuclei.class]==2),'m',h.imStack,0);
            %[n_ims snuc]=crop_cell(cims,BW,nuclei(n));

            %n_ims = n_ims/max(n_ims(:));%normalize to single cell
            BW1=BW;
            BW1(BW1>0)=1;
            cims=cims.*repmat(BW1,[1,1,size(cims,3)]);
            [thresholdfn, cell_dif] = multithreshstack(cims,threshold_num,BW,numel(nuclei),h);
            thresholds = (1:threshold_num)/threshold_num;
            [t, nc, cv]= auto_thresholding(thresholdfn,CV_width,CV_offset);
            ui.message(h,'Drag red line to select threshold for nuclei: ')

            x=thresholds(t);
            y=nc;
            cvx=cv(t);
            
            [dots, vols, intensity, bwl] = getdots(cims,x);

            [nuclei,bwl] = ui.updateAxes(h,x,y,cvx,dots,vols,intensity,bwl,cims,nuclei,thresholds,thresholdfn,cv,BW,nuclei,ch,cell_dif);
                 L{ch}=max(bwl,[],3);
                 %L{ch}(nuclei(n).PixelList(:,2),nuclei(n).PixelList(:,1))=...
                  %  bwl(snuc.PixelList(:,2),snuc.PixelList(:,1));
% 
%                 dots = [nuclei(n).dots; dots ch.*ones(num_dots,1)];
%                 nd =[nuclei(n).nd; num_dots ch];
%                 thr =[nuclei(n).thr; thr ch];
%                 vols = [nuclei(n).vol; vols ch.*ones(num_dots,1)];
%                 intensities = [nuclei(n).intensity; intensity ch.*ones(num_dots,1)];
%                 nuclei(n).dots = dots;
%                 nuclei(n).nd = nd;
%                 nuclei(n).thr = thr;
%                 nuclei(n).vol = vols;
%                 nuclei(n).intensity = intensities;
                
        %end
        try
        ui.message(h,'Spots in the channel counted, you can save')
        catch err
            display(err.identifier)
        end
        
        st.counted(ch)=1;
        UserData.Counted(ch)=1;
    end
    setappdata(h.f,'status',st)
    UserData.nuclei=nuclei;
    UserData.L=L;
end
        