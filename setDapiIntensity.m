function UserData = setDapiIntensity(UserData)
    ims=UserData.I/max(UserData.I(:));       
    wb = waitbar(0,'Calculating DAPI Background ...');
    im=NaN(size(ims));
       for i=1:size(ims,3),
            waitbar(0.01*(i/size(ims,3)),wb);
            tmp=ims(:,:,i);
            t=sort(tmp(:));
            BG=t(floor(length(t)/10));
            im(:,:,i)=max(tmp-BG,0);
       end       
    fprintf(1,'Saving...');
    waitbar(0.01*(i/size(ims,3)),wb,'Calculating DAPI Intensity ...');
    fprintf(1,'Blob #\tDapi Intensity\n');
    dapi_intensity=0;
    for k = 1:numel(UserData.nuclei)
        for i=1:size(ims,3),
            waitbar(k/numel(UserData.nuclei),wb);
            tt=im(:,:,i);
            vec=tt(UserData.BW==k);
            dapi_intensity=dapi_intensity+sum(vec);
        end
        fprintf(1,'#%2d\t%.2f\n', k, dapi_intensity);
            UserData.nuclei(k).Dapi=dapi_intensity;
    end
   close(wb)
end
