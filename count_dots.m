function [lab,num_dots,coord,area]=count_dots(c_ims,ncell,Sigma)
imask=ncell.BW;
B=Inf*ones(size(imask));
maxproj=max(c_ims,[],3);
%for each cell:
idx=find(imask);
m=mean(maxproj(idx));
st=std(maxproj(idx));
B(idx)=m+Sigma*st;
%end for each cell
temp=zeros(size(B,1),size(B,2),size(c_ims,3));
for j=1:size(c_ims,3),
    temp(:,:,j)=B;
end
bwl = c_ims > temp;
[lab,num_dots] = bwlabeln(bwl);
props=regionprops(lab,'Centroid','Area');
coord=reshape([props.Centroid],3,num_dots)';
area=[props.Area];
area=area(:);