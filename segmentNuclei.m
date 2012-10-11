function DL=segmentNuclei(zim)
%Beigin segmentation with parameters zim (the projection)
% Convert to binary using Otsus method
thr=graythresh(zim);
bw=im2bw(zim,thr);
% Fill the holes inside cells
bw = imfill(bw,'holes');
%Open close objects
se = strel('disk',5);
bw = imopen(bw, se);
%Remove small objects with area below 100px
bw = bwareaopen(bw, 100);%subplot(3,3,3);imshow(bw);title('background')
%Identify objects with a high intensity (foreground)
fgm=im2bw(zim,thr*1.5);
% Fill the holes inside cells
fgm = imfill(fgm,'holes');
%Open close objects
se = strel('disk',5);
fgm = imopen(fgm, se);
%Remove small objects with area below 100px
fgm = bwareaopen(fgm, 100);%subplot(3,3,4);imshow(fgm);title('foreground')
%Calculate distances
D = bwdist(~bw);
D = -D;
D(fgm)=-inf;
D(~bw)=-inf;%subplot(3,3,5);imshow(D,[]);title('basins');
DL = watershed(D);%subplot(3,3,6);imshow(DL,[]);title('watershed');