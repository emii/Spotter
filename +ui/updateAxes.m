function [nuclei,bwl] = updateAxes(h,x,y,cvx,dots,vols,intensity,bwl,n_ims,snuc,thresholds,thresholdfn,cv,BW,nuclei,ch,cell_dif)
    
    ncell_dif=nan;
    nuc=1;
    %h1===========
    set(h.countNext,'Enable','on');
    st=getappdata(h.f,'status');
    settings=getappdata(h.f,'settings');
    delete(get(h.ax{1},'Children'));
    set(h.ax{1},'NextPlot','add');
    
    %yl1=max(thresholdfn)+max(thresholdfn)*0.1;
    yl1=2000;
    
    plot(h.ax{1},thresholds,thresholdfn,'Color',[.6 .6 .6]);
    l1 = line([x x],[0 yl1],'Color','r','Parent',h.ax{1},'LineWidth',2);
    plot(h.ax{1},x,y,'r+');
    t1 = text(x,y+0.1,[' (' num2str(x,'%10.2f') ',' num2str(y) ')'],...
     'Parent',h.ax{1},'VerticalAlignment','Baseline');   

    set(get(h.ax{1},'Title'),'String','Number of dots at threshold');
    set(h.ax{1},'XLim',[0 1]);
    set(h.ax{1},'YLim',[0 yl1]);
    
    %h2===========
    
    delete(get(h.ax{2},'Children'));
    delete(get(h.ax{4},'Children'));
    set(h.ax{2},'NextPlot','add');
    set(h.ax{4},'NextPlot','add');

    yl2=max(cv)+max(cv)*0.2;
    xlab=['default threshold=' num2str(x)];
    set(get(h.ax{2},'Title'),'String',xlab)
    plot(h.ax{2},thresholds,cv,'Color',[.6 .6 .6]);
    plot(h.ax{4},thresholds,cellfun(@length,cell_dif),'Color','m');
    l2 = line([x x],[0 yl2],'Color','r','Parent',h.ax{2},'LineWidth',2);
    plot(h.ax{2},x,cvx,'r*');
    set(h.ax{2},'XLim',[0 1]);
    set(h.ax{2},'YLim',[0 yl2]);
    
    %imStack============
    
    %cm=brighten(hsv(50),-.5);
    
    delete(get(h.imStack,'Children'));
    set(h.imStack,'NextPlot','add');
    
    znims=zproject(n_ims);
    hf=imagesc(znims,'Parent',h.imStack);
    utilities.plotBoundaries(znims,snuc([snuc.class]==1),'g',h.imStack,0);
    utilities.plotBoundaries(znims,snuc([snuc.class]==2),'m',h.imStack,0);drawnow; 
    
    
    p3=scatter(h.imStack,dots(:,1),dots(:,2),'MarkerEdgeColor','g');  
    %p3=scatter(h.imStack,dots(:,1),dots(:,2),'CData',cm(round(dots(:,3)),:),'SizeData',intensity.*150);
    
   %h3=================

    delete(get(h.ax{3},'Children'));
    set(h.ax{3},'NextPlot','add');
    
    if st.segmented
    [nn_ims, snuc]=crop_cell(znims,BW,nuclei(1));
    xi=nuclei(nuc).PixelList(:,1);
    yi=nuclei(nuc).PixelList(:,2);
    RECT=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
    else
        nn_ims=znims;
        snuc=nuclei(nuc);
        RECT=[1 1 size(znims,1)  size(znims,2)];
        
    end
    zcnims=zproject(nn_ims);
    imshow(zcnims,[0 1],'Parent',h.ax{3});
    utilities.plotBoundaries(zcnims,snuc,'r',h.ax{3},0);drawnow; 
    axis(h.ax{3},'image')
    
%     xi=nuclei(1).PixelList(:,1);
%     yi=nuclei(1).PixelList(:,2);
%     RECT=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
    
    
    
    x1=round(dots(:,2));y1=round(dots(:,1));
    dots_nuc=BW(sub2ind(size(BW), x1, y1));
    
    dots_idx=dots_nuc==nuc;
    ndots=dots(dots_idx,:);
    ndots=ndots-repmat([RECT(1)-1 RECT(2)-1 0],size(ndots,1),1);


    %p3=scatter(h.ax{3},dots(:,1),dots(:,2),'MarkerEdgeColor','g');  
    %scatter(h.ax{3},ndots(:,1),ndots(:,2),'CData',cm(round(ndots(:,3)),:),'SizeData',intensity(dots_idx).*150);
    axes(h.ax{3})
    scatter(h.ax{3},ndots(:,1),ndots(:,2),'SizeData',intensity(dots_idx).*150,'MarkerEdgeColor','m');


    
    
    
    set(hf,'ButtonDownFcn',@plotSingleNuclei)
    set(l1,'ButtonDownFcn',@startDragFcn);
    %set(h.f,'WindowButtonUpFcn',@stopDragFcn) 
    
    
    
    function plotSingleNuclei(varargin)

        xy = get(h.imStack,'CurrentPoint');
        nuc = BW(round(xy(1,2)),round(xy(1,1)));
        if nuc ==0;
            return
        end
        
        if st.segmented
        [nn_ims, snuc]=crop_cell(znims,BW,nuclei(nuc));
            xi=nuclei(nuc).PixelList(:,1);
            yi=nuclei(nuc).PixelList(:,2);
            RECT=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
        else
            nn_ims=znims;
            snuc=nuclei(nuc);
            RECT=[1 1 size(znims,1)  size(znims,2)];
        end


        %h3=================

        delete(get(h.ax{3},'Children'));
        set(h.ax{3},'NextPlot','add');


        zcnims=zproject(nn_ims);
        imshow(zcnims,[0 1],'Parent',h.ax{3});
        utilities.plotBoundaries(zcnims,snuc,'r',h.ax{3},0); 
        axis(h.ax{3},'image')
        
        dots_idx=dots_nuc==nuc;
        ndots=dots(dots_idx,:);
        ndots=ndots-repmat([RECT(1)-1 RECT(2)-1 0],size(ndots,1),1);
        

        %p3=scatter(h.ax{3},dots(:,1),dots(:,2),'MarkerEdgeColor','g');  
        axes(h.ax{3})
        scatter(h.ax{3},ndots(:,1),ndots(:,2),'SizeData',intensity(dots_idx).*150,'MarkerEdgeColor','m');

        
    end
    
    
    
    
    
    
    function startDragFcn(varargin)
        
        set(h.f,'WindowButtonMotionFcn',@draggingFcn);
        set(h.f,'WindowButtonUpFcn',@stopDragFcn);
        set(hf,'ButtonDownFcn','');
    end

    function draggingFcn(varargin)
        pt = get(h.ax{1},'CurrentPoint');
        x = pt(1);
        if x > 1
            x=1;
        elseif x<min(thresholds);
            x=min(thresholds);
        end
        ncell_dif=cell_dif{round(x*settings.thr_number)};
        x= thresholds(round(x*settings.thr_number));
        y = thresholdfn(round(x*settings.thr_number)); 
        
        
        set(l1,'XData',x*[1 1])
        set(t1,'Position',[x,yl1*0.5],'String',...
            [' (' num2str(x,'%10.2f') ',' num2str(y) ')']);
        set(l2,'XData',x*[1 1])   
        
    end
    
    function stopDragFcn(varargin)
        delete(findobj(h.imStack,'color','r'));
        set(h.f,'WindowButtonMotionFcn','');
        set(h.f,'WindowButtonUpFcn','');
        [dots, vols, intensity, bwl]=getdots(n_ims,x);
        set(p3,'XData',dots(:,1),'YData',dots(:,2));
        utilities.plotBoundaries(znims,nuclei(ncell_dif),'r',h.imStack,0);
        x1=round(dots(:,2));y1=round(dots(:,1));
        dots_nuc=BW(sub2ind(size(BW), x1, y1));
        
        
        delete(findobj(h.ax{3},'type','hggroup'));
        dots_idx=dots_nuc==nuc;
        ndots=dots(dots_idx,:);
        ndots=ndots-repmat([RECT(1)-1 RECT(2)-1 0],size(ndots,1),1);
        scatter(h.ax{3},ndots(:,1),ndots(:,2),'SizeData',intensity(dots_idx).*150,'MarkerEdgeColor','m');

        
        
        
        set(hf,'ButtonDownFcn',@plotSingleNuclei);
    end
    

    
            waitfor(h.countNext,'UserData',1)
    
    for n = 1:numel(nuclei)
        if st.segmented
            xi=nuclei(n).PixelList(:,1);
            yi=nuclei(n).PixelList(:,2);
            RECT=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
        else
            RECT=[1 1 size(znims,1)  size(znims,2)];
        end
        
        dots_idx=dots_nuc==n;
        ndots=dots(dots_idx,:);
        drow=[ndots-repmat([RECT(1)-1 RECT(2)-1 0],size(ndots,1),1) ch.*ones(size(ndots,1),1)];
        %drow=[ndots ch.*ones(size(ndots,1),1)];
        nd =[nuclei(n).nd; size(ndots,1) ch];
        thr = [nuclei(n).thr; x ch];
        volms = [nuclei(n).vol; vols(dots_idx) ch.*ones(size(ndots,1),1)];
        intensities = [nuclei(n).intensity; intensity(dots_idx) ch.*ones(size(ndots,1),1)];
               
                nuclei(n).dots = [nuclei(n).dots ; drow];
                nuclei(n).nd = nd;
                nuclei(n).thr = thr;
                nuclei(n).vol = volms;
                nuclei(n).intensity = intensities;
    end     
    %reset values   
    try
    set(h.tb.save,'Enable','on');
    set(l1,'ButtonDownFcn','');
    set(h.f,'WindowButtonUpFcn','');
    set(hf,'ButtonDownFcn','');
    set(h.ax{1},'NextPlot','replaceChildren');
    set(h.ax{2},'NextPlot','replaceChildren');
    set(h.imStack,'NextPlot','replaceChildren');
    set(h.ax{3},'NextPlot','replaceChildren');
    set(h.ax{4},'NextPlot','replaceChildren');
    set(h.countNext,'UserData',0)
    set(h.countNext,'Enable','off');
    catch err
        display(err.identifier)
    end
        


    

end