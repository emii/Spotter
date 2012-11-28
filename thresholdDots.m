function UserData= thresholdDots(UserData,h,selection)
% some parameters
    CV_width = 5;
    CV_offset = 0.1;
    LOG_Size = [11 11 7];%15
    LOG_Sigma = [1.4 1.4 1.1];%1.3

    stacks=UserData.files(selection);
    nuclei=UserData.nuclei;
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
    L=UserData.L;
    for ch = 1:numel(stacks),
        msg=['filtering stack: ' stacks{ch} ' please wait...'];
        ui.message(h,msg)
        wb = waitbar(0,'Parsing and filtering and stuff...');
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
           info=imfinfo(stackfile);
           cims=parse_stack(stackfile,1,numel(info),tform{ch});
           %=======
%            aa=sort(cims(:));
%            b1=size(aa,1)*0.999;
%            c1=aa(round(b1));
%            cims(cims>c1)=c1;
           %=======
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        else
           info=imfinfo(stackfile);
           cims=parse_stack(stackfile,1,numel(info));
           %========
%            aa=sort(cims(:));
%            b1=size(aa,1)*0.999;
%            c1=aa(round(b1));
%            cims(cims>c1)=c1;
           %========
           waitbar(0.3,wb,['Loading and correcting shift for ' stacks{ch}])
        end
        
        %zcims=zproject(cims);
        %imax=utilities.im(zcims);
        %ax=utilities.plotBoundaries(zcims,nuclei,'g');drawnow;
        %waitfor(ax)
        waitbar(0.5,wb,['Filtering for ' stacks{ch}])
        cims = LOG_filter(cims,LOG_Size,LOG_Sigma);
        waitbar(0.9,wb,['Almost Done ' stacks{ch}])
        cims = cims/max(cims(:));
        close(wb)
        zcims=zproject(cims);
        %hn=plotBoundaries(zcims,nuclei,'g');
        %hn=plotBoundaries(zcims,nuclei(5:end),'r',hn);
        imshow(zcims,'Parent',h.imStack);
        utilities.plotBoundaries(zcims,nuclei,'g',h.imStack);
        
        %L{ch}=zeros(size(cims,2),size(cims,1));
        
        
            ui.message(h,['Drag red line to select threshold for nuclei: '])
            utilities.plotBoundaries(zcims,nuclei,'g',h.imStack,0);
            %utilities.plotBoundaries(zcims,nuclei(n),'r',h.imStack,0);
            %[n_ims snuc]=crop_cell(cims,BW,nuclei(n));

            %n_ims = n_ims/max(n_ims(:));%normalize to single cell
            BW1=BW;
            BW1(BW1>0)=1;
            cims=cims.*repmat(BW1,[1,1,size(cims,3)]);
            thresholdfn = multithreshstack(cims,threshold_num);
            thresholds = (1:threshold_num)/threshold_num;
            [t nc cv]= auto_thresholding(thresholdfn,CV_width,CV_offset);
            x=thresholds(t);
            y=nc;
            cvx=cv(t);
            
            [dots vols intensity bwl] = getdots(cims,x);

            [dots vols intensity bwl thr num_dots]= ui.updateAxes(h,x,y,cvx,dots,vols,intensity,bwl,cims,nuclei,thresholds,thresholdfn,cv,BW,nuclei);
%                 bwl=max(bwl,[],3);
%                 L{ch}(nuclei(n).PixelList(:,2),nuclei(n).PixelList(:,1))=...
%                     bwl(snuc.PixelList(:,2),snuc.PixelList(:,1));
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
                
        end
        ui.message(h,'Spots in the channel counted, you can save')
        
    %end
    %UserData.nuclei=nuclei;
    %UserData.L=L;
end
        