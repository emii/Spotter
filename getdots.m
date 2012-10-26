function dots = getdots(n_ims,thr)    
    bwl = n_ims > thr;
    [lab,num_dots] = bwlabeln(bwl);
    props=regionprops(lab,'Centroid');
    dots=reshape([props.Centroid],3,num_dots)';
