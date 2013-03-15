function zim = zproject(ims,method)
if nargin<2
    method='max';
end

%Assess the min and max of the hole stack
imax=max(ims,[],3);
imin=min(ims,[],3);

% Make a z-projection of the stac using max value and normalizing, then
% clear the stack
switch method
    case 'max'
        zim = max(ims,[],3);
    case 'cv'
        zim=std(ims,0,3)./mean(ims,3);
    case 'mean'
        zim=mean(ims,3);
    case 'std'
        zim=std(ims,0,3);
end
%Normilize the projection and maximaze contrast
zim =(zim-min(zim(:)))/(max(zim(:))-min(zim(:)));
%zim =zim./max(zim(:));