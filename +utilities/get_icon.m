function icon=get_icon(filename)

dftbgc=get(0, 'defaultuicontrolbackgroundcolor')*255;

[pathstr, ~, ~] = fileparts(mfilename('fullpath'));
        
icofilename=fullfile(pathstr,'icons',filename);

        [icon, ~,bg] = imread(icofilename); 
        bgi=repmat(bg,[1,1,3]);
        bgv=zeros(size(icon));
        bgv(:,:,1)=bg .*dftbgc(1);
        bgv(:,:,2)=bg .*dftbgc(2);
        bgv(:,:,3)=bg .*dftbgc(3);
        icon(bgi) = bgv(bgi);
end