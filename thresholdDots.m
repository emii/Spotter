function thresholdDots(UserData,h,selection)

    stacks=UserData.files(selection);
    nuclei=UserData.nuclei;
    tform=UserData.tform;
    threshold_num=UserData.threshold_num;
    BW=UserData.BW;
    h1=h.ax{1};h2=h.ax{2};h3=h.ax{3};
 
    for ch = 1:numel(stacks)
        %set(h.uiMessage,'string',stacks{ch});
        ui.message(h,stacks{ch});
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
           cims=parse_stack(stackfile,1,50,tform{ch});
        else
           cims=parse_stack(stackfile,1,50);
        end
        
        %zcims=zproject(cims);
        %imax=utilities.im(zcims);
        %ax=utilities.plotBoundaries(zcims,nuclei,'g');drawnow;
        %waitfor(ax)
        cims = LOG_filter(cims,10,1.5);
        cims = cims/max(cims(:));
        zcims=zproject(cims);
        %hn=plotBoundaries(zcims,nuclei,'g');
        %hn=plotBoundaries(zcims,nuclei(5:end),'r',hn);
        f=imshow(zcims,'Parent',h.imStack);
        utilities.plotBoundaries(zcims,nuclei,'g',h.imStack);
        
%     delete(get(h.ax{3},'Children'));
%     set(h.ax{3},'NextPlot','add');
%     
%     
% %     [n xout]=hist(cims(:),100);
% %     bar(h.ax{3},xout,n,'FaceColor',[.9 .9 .9 ]);
% %     yl3=max(n)+max(n)*.2;
% %     
% %     %line([x x],[0 yl3],'Color','r','Parent',h.ax{3});
% %     set(get(h.ax{3},'Title'),'String','Histogram of intensities')
% %     %set(h.ax{3},'XLim',[0 1]);
% %     %set(h.ax{3},'YLim',[0 yl3]);
%     
        
        
    %for all nuclei:
        [n_ims snuc]=crop_cell(cims,BW,nuclei(1));
        n_ims = n_ims/max(n_ims(:));%normalize the
        
        thresholdfn = multithreshstack(n_ims,threshold_num);
        thresholds = (1:threshold_num)/threshold_num;
        [t nc cv]= auto_thresholding(thresholdfn,5,0.1);
        x=thresholds(t);
        y=nc;
        cvx=cv(t);
        dots = getdots(n_ims,x);
        ui.updateAxes(h,x,y,cvx,dots,n_ims,snuc,thresholds,thresholdfn,cv)
        

        
    end
end
        