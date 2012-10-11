function h = plotBoundaries(zim,cells,color,hn)
if nargin<4
    figure;hn=imshow(zim,[]);title('Boundaries');hold on
end
labelShiftX = -7;	% Used to align the labels in the centers of the blobs.
for k = 1:size(cells,1)
    plot(cells(k).boundaries(:,2),cells(k).boundaries(:,1),'Color',color)
    axis square
    text(cells(k).Centroid(1) + labelShiftX, cells(k).Centroid(2), cells(k).Label,... 
    'FontSize', 14, 'FontWeight', 'Bold','Color','w'); 
end
h=hn;