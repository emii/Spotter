function zim = zproject(ims)
%Assess the min and max of the hole stack
imax=max(ims,[],3);
imin=min(ims,[],3);
imax=max(imax(:));
imin=min(imin(:));
% Make a z-projection of the stac using max value and normalizing, then
% clear the stack
zim = max(ims,[],3);
%Normilize the projection and maximaze contrast
zim =(zim-min(zim(:)))/(max(zim(:))-min(zim(:)));
%zim =zim./max(zim(:));