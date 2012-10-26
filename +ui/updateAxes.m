function updateAxes(h,x,y,cvx,dots,n_ims,snuc,thresholds,thresholdfn,cv)
    
    ui.message(h,'mmm');
    %h1===========
    
    delete(get(h.ax{1},'Children'));
    set(h.ax{1},'NextPlot','add');
    
    yl1=min(thresholdfn(thresholds<0.17));
    
    plot(h.ax{1},thresholds,thresholdfn,'Color',[.6 .6 .6]);
    line([x x],[0 yl1],'Color','r','Parent',h.ax{1});
    plot(h.ax{1},x,y,'r+');
    text(x,y+0.1,[' (' num2str(x,'%10.2f') ',' num2str(y) ')'],...
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
    line([x x],[0 yl2],'Color','r','Parent',h.ax{2});
    plot(h.ax{2},x,cvx,'r*');
    set(h.ax{2},'XLim',[0 1]);
    set(h.ax{2},'YLim',[0 yl2]);
    
    %h3============
    
    delete(get(h.ax{3},'Children'));
    set(h.ax{3},'NextPlot','add');
    
    
    [n xout]=hist(n_ims(:),100);
    axes(h.ax{3})
    imhist(n_ims);
    yl3=max(n)+max(n)*.2;
    
    %line([x x],[0 yl3],'Color','r','Parent',h.ax{3});
    set(get(h.ax{3},'Title'),'String','Histogram of intensities')
    %set(h.ax{3},'XLim',[0 1]);
    %set(h.ax{3},'YLim',[0 yl3]);
    
  
    
    %imStack=========
    
    delete(get(h.imStack,'Children'));
    set(h.imStack,'NextPlot','add');
    
    zcnims=zproject(n_ims(:));
    imshow(zcnims,'Parent',h.imStack);
    utilities.plotBoundaries(zcnims,snuc,'g',h.imStack);drawnow; 
    axis(h.imStack,'image')
    
    for i=1:2,
        h4=plot(h.imStack,dots(:,1),dots(:,2),'go','MarkerSize',6);  
        pause(0.2);
        delete(h4);
        pause(0.2);        
    end
    plot(h.imStack,dots(:,1),dots(:,2),'go','MarkerSize',6); 
    ui.message(h,'finito');
    
end