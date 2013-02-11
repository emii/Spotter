function h = plotBoundaries(zim,cells,color,hn,label)
if nargin<5;
    label=1;
end
if nargin<4
hn=utilities.im(zim);title('Boundaries');hold on
end
labelShiftX = 0;	% Used to align the labels in the centers of the blobs.
for k = 1:size(cells,1)
    
plot(hn,cells(k).boundaries(:,2),cells(k).boundaries(:,1),'Color',color)
%axis square
if label
text(cells(k).Centroid(1) + labelShiftX, cells(k).Centroid(2), cells(k).Label,...
     'FontSize', 9, 'FontWeight', 'Bold','Color','w','Parent',hn);
end
end
h=hn;