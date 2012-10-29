function [blobMeasurements, DL2]= filterSegmentation(DL2,zim,ax,bad)
%%get blobmesurements and plot the segmentation result
    if nargin ==4
        for i = bad
            DL2(DL2==i)=0;
        end
        DL2=bwlabel(DL2);
    end
    % Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
    Iproperties={'MeanIntensity','Area','Centroid','PixelIdxList','PixelList'};
    blobMeasurements = regionprops(DL2, zim, Iproperties);
    pl=regionprops(DL2, zim,'Perimeter');
    numberOfBlobs = size(blobMeasurements, 1);
    blobMeasurements(numberOfBlobs).dots=[];
    blobMeasurements(numberOfBlobs).nd=[];
    blobMeasurements(numberOfBlobs).thr=[];
    blobMeasurements(numberOfBlobs).vols=[];
    

    % bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
    % Plot the borders of all the coins on the original grayscale image using the coordinates returned by bwboundaries.
    cla(ax);
    imagesc(zim,'Parent',ax);colormap gray;
    %title('Labeled segmented nuclei()'); axis square;
    hold on;
    boundaries = bwboundaries(DL2);	
    numberOfBoundaries = size(boundaries,1);
    labelShiftX = -7;	% Used to align the labels in the centers of the blobs.
    for k = 1 : numberOfBoundaries
        thisBoundary = boundaries{k};
        plot(ax,thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 1); 
        blobMeasurements(k).boundaries=boundaries{k};
    end
    blobECD = zeros(1, numberOfBlobs);
    filterArea=blobECD;
    thrup=40000;thrlow=500;
    % Print header line in the command window.
    fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
    % Loop over all blobs printing their measurements to the command window.
    for k = 1 : numberOfBlobs           % Loop through all blobs.
        meanGL = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a
        blobArea = blobMeasurements(k).Area;		% Get area.
        if (blobArea>thrup || blobArea<thrlow)
            filterArea(k)=k;
        else
            filterArea(k)=0;
        end
%         xi=pl(k).PixelList(:,1);
%         yi=pl(k).PixelList(:,2);
%         blobMeasurements(k).Rect=[min(xi) min(yi) max(xi)-min(xi)  max(yi)-min(yi)];
        blobMeasurements(k).Label=num2str(k);
        blobPerimeter = pl(k).Perimeter;		% Get perimeter.
        blobCentroid = blobMeasurements(k).Centroid;		% Get centroid.
        blobECD(k) = sqrt(4 * blobArea / pi);					% Compute ECD - Equivalent Circular Diameter.
        fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meanGL, blobArea, blobPerimeter, blobCentroid, blobECD(k));
        text(blobCentroid(1) + labelShiftX, blobCentroid(2), num2str(k), 'FontSize', 14, 'FontWeight', 'Bold'); 
    end
    clean=filterArea(filterArea>0);
    if ~isempty(clean)
        for i=clean
            DL2(DL2==i)=0;
        end
        DL2(DL2>0)=1;
        DL2=imclearborder(DL2);
        DL3=bwlabel(DL2);
        [blobMeasurements, DL2]= filterSegmentation(DL3,zim,ax);
    else
        drawnow
         return
    end
    
    
    
    