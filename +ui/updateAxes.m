function [dots vols intensity bwl x y] =updateAxes(h,x,y,cvx,dots,vols,intensity,bwl,n_ims,snuc,thresholds,thresholdfn,cv)
    
    %h1===========
    
    delete(get(h.ax{1},'Children'));
    set(h.ax{1},'NextPlot','add');
    
    yl1=50;
    
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
    set(h.ax{2},'NextPlot','add');

    yl2=max(cv)+max(cv)*0.2;
    xlab=['default threshold=' num2str(x)];
    set(get(h.ax{2},'Title'),'String',xlab)
    plot(h.ax{2},thresholds,cv,'Color',[.6 .6 .6]);
    l2 = line([x x],[0 yl2],'Color','r','Parent',h.ax{2},'LineWidth',2);
    plot(h.ax{2},x,cvx,'r*');
    set(h.ax{2},'XLim',[0 1]);
    set(h.ax{2},'YLim',[0 yl2]);
    
    %h3============
    
    cm=brighten(jet(50),-.5);
    
    delete(get(h.ax{3},'Children'));
    set(h.ax{3},'NextPlot','add');
    
    zcnims=zproject(n_ims);
    imshow(zcnims,[0 1],'Parent',h.ax{3});
    utilities.plotBoundaries(zcnims,snuc,'r',h.ax{3},0);drawnow; 
    axis(h.ax{3},'image')
    
    
    p3=scatter(h.ax{3},dots(:,1),dots(:,2),'MarkerEdgeColor','g');  
    %p3=scatter(h.ax{3},dots(:,1),dots(:,2),'CData',cm(round(dots(:,3)),:),'SizeData',intensity.*150);

    
    set(l1,'ButtonDownFcn',@startDragFcn);
    set(h.f,'WindowButtonUpFcn',@stopDragFcn)
    
    
    function startDragFcn(varargin)
        
        set(h.f,'WindowButtonMotionFcn',@draggingFcn);
    end

    function draggingFcn(varargin)
        pt = get(h.ax{1},'CurrentPoint');
        x = pt(1);
        if x > 1
            x=1;
        elseif x<0.01
            x=0.01;
        end
        x= thresholds(round(x*100));
        y = thresholdfn(round(x*100)); 
        
        
        set(l1,'XData',x*[1 1])
        set(t1,'Position',[x,yl1*0.5],'String',...
            [' (' num2str(x,'%10.2f') ',' num2str(y) ')']);
        set(l2,'XData',x*[1 1])   
        
    end
    
    function stopDragFcn(varargin)
        set(h.f,'WindowButtonMotionFcn','');
        [dots vols intensity bwl]=getdots(n_ims,x);
        set(p3,'XData',dots(:,1),'YData',dots(:,2));
        %set(p3,'XData',dots(:,1),'YData',dots(:,2),'CData',cm(round(dots(:,3)),:),'SizeData',intensity.*150);
        
  
    end
    waitfor(h.countNext,'UserData',1)
    set(l1,'ButtonDownFcn','');
    set(h.f,'WindowButtonUpFcn','');
    set(h.ax{1},'NextPlot','replaceChildren');
    set(h.ax{2},'NextPlot','replaceChildren');
    set(h.ax{3},'NextPlot','replaceChildren');
    set(h.countNext,'UserData',0)
end