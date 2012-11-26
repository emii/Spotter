function DL=segmentNuclei(I)


H = FSPECIAL('disk',10);
I2=imfilter(I,H,'replicate');
gt=graythresh(I2);
bw = im2bw(I2, gt);

% hy = fspecial('sobel');
% hx = hy';
% Iy = imfilter(I2, hy, 'replicate');
% Ix = imfilter(I2, hx, 'replicate');
% gradmag = sqrt(Ix.^2 + Iy.^2);
% 
% 
% se = strel('disk', 20);
% Ie = imerode(I, se);
% Iobr = imreconstruct(Ie, I);
% Iobrd = imdilate(Iobr, se);
% Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Iobrcbr = imcomplement(Iobrcbr);
% 
% se2 = strel('disk', 10);
% fgm = imregionalmax(Iobrcbr,4);
% fgm2 = imerode(fgm, se2);
% fgm3 = bwareaopen(fgm2, 200);
% fgm4=fgm3 & bw;
% 
% gradmag2 = imimposemin(gradmag,fgm4);
% 
% gradmag2=gradmag2.*bw;
% gradmag2(isnan(gradmag2))=0;
% 
% DL = watershed(gradmag2);
[DL bn] = bwlabel(imdilate(bw,strel('disk',5)));
%====================================================

Iproperties={'Area','PixelIdxList','PixelList'};
blobM = regionprops(DL, I, Iproperties);
thrup=14000;
for k = 1:bn
        if blobM(k).Area>thrup
            xi=blobM(k).PixelList(:,1);
            yi=blobM(k).PixelList(:,2);
            rect=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
            ni=imcrop(I,rect);
            dli=imcrop(DL,rect);
            
            H = FSPECIAL('disk',10);
            I2=imfilter(ni,H,'replicate');
            gt=graythresh(I2);
            bw = im2bw(I2, gt);
            
            hy = fspecial('sobel');
            hx = hy';
            Iy = imfilter(I2, hy, 'replicate');
            Ix = imfilter(I2, hx, 'replicate');
            gradmag = sqrt(Ix.^2 + Iy.^2);
            
            
            se = strel('disk', 20);
            Ie = imerode(ni, se);
            Iobr = imreconstruct(Ie, ni);
            Iobrd = imdilate(Iobr, se);
            Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
            Iobrcbr = imcomplement(Iobrcbr);
            
            se2 = strel('disk', 10);
            fgm = imregionalmax(Iobrcbr,4);
            fgm2 = imerode(fgm, se2);
            fgm3 = bwareaopen(fgm2, 200);
            fgm4=fgm3 & bw;
            
            gradmag2 = imimposemin(gradmag,fgm4);
            
            gradmag2=gradmag2.*bw;
            gradmag2(isnan(gradmag2))=0;
            
            NDL = watershed(gradmag2);
            NDL(NDL==1)=0;
            NDL(NDL>0)=1;
            NDL=imclearborder(NDL);
            NDL=imdilate(NDL,strel('disk',7));
            
            [rows cols]=find(dli==k);
            lindex=sub2ind(size(ni),rows, cols);
            DL(blobM(k).PixelIdxList)=NDL(lindex);
        end
end



DL=bwlabel(DL);
DL=imclearborder(DL);
DL=bwlabel(DL);





end


