function [dots vols intensity bwl]= getdots(n_ims,thr)    
    bwl = n_ims > thr;
    [lab,num_dots] = bwlabeln(bwl);
    props=regionprops(lab,n_ims,'Centroid','Area','MeanIntensity');
    dim=numel(size(n_ims));
    dots=reshape([props.Centroid],dim,num_dots)';
    vols=[props.Area]';
    intensity=[props.MeanIntensity]';