function [dots vols intensity bwl]= getdots(n_ims,thr)    
    bwl = n_ims > thr;
    [lab,num_dots] = bwlabeln(bwl);
    props=regionprops(lab,n_ims,'Centroid','Area','MeanIntensity');
    dots=reshape([props.Centroid],3,num_dots)';
    vols=[props.Area]';
    intensity=[props.MeanIntensity]';