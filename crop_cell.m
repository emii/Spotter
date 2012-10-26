function [ims2 newcell]=crop_cell(ims,BW,cell)

% ims2=crop_stack_poly(ims,RECT,BW)
% crops all stack images with RECT rectangle, likewise crops its
% corresponding mask and returns both for a single cell
xi=cell.PixelList(:,1);
yi=cell.PixelList(:,2);
RECT=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
newcell.rect=RECT;
%newcell.Area=cell.Area;
newcell.Centroid=cell.Centroid-[RECT(1)-1 RECT(2)-1];
newcell.PixelList=cell.PixelList-repmat([RECT(1)-1 RECT(2)-1],size(cell.PixelList,1),1);
%newcell.MeanIntensity=cell.MeanIntensity;
newcell.boundaries=cell.boundaries-repmat([RECT(2)-1 RECT(1)-1],size(cell.boundaries,1),1);
newcell.Label=cell.Label;
s=size(ims);

if size(BW,1)==s(1) & size(BW,2)==s(2), % need to crop the mask, hasn't been done previously
    BW2=imcrop(BW,RECT);
    BW2(BW2~=str2double(cell.Label))=0;%make sure the only mask is the one corresponding to the cell
    BW2(BW2~=0)=1; %BW was a labeled mask, so here we just got rid of the label
    %LATER:there is here a chance to increase the reagion of the mask here 
end
%return the individual mask
newcell.BW=BW2;
% Also multiply by a smoothed version of the polygon BW image
H=fspecial('average',5);
BWsmooth=imfilter(BW2,H);
ims2=zeros(size(BW2,1),size(BW2,2),size(ims,3));
% Now zero the masked background, or do it the minimum
for j=1:size(ims,3)
    Y1=ims(:,:,j);%NOTE: optimize this method!
    YY=imcrop(Y1,RECT);
    YY=YY.*BWsmooth;
    YY(YY==0)=min(min(YY(YY~=0)));%make the background the minimum from what is inside the mask?
    ims2(:,:,j)=YY;
end