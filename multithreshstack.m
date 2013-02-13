
% This function will count the number of mRNAs for 100 thresholds 
% from 0 up to the maximum intensity of the input image.

function [nout ndif] = multithreshstack(ims,threshold_num,BW,nnuclei,h)

% Number of thresholds to compute
npoints = threshold_num;
nout=nan(1,npoints);
ndif=cell(1,npoints);
cn=1:nnuclei;

sprintf('Computing threshold (of %d):    1',npoints);
wb = waitbar(0,'Computing thresholds :    ');
old_count=zeros(nnuclei,1);
for i = 1:npoints
  % Apply threshold
  bwl = ims > i/npoints;

  % Find particles
  [lab,n] = bwlabeln(bwl);  
  new_count=zeros(nnuclei,1);
  props=regionprops(lab,'Centroid');
  dots=reshape([props.Centroid],3,n)';
  x1=round(dots(:,2));y1=round(dots(:,1));
  dots_nuc=BW(sub2ind(size(BW), x1, y1));
  dots_nuc=dots_nuc(dots_nuc>0);
  [idx counts]=utilities.count_unique(dots_nuc);
  new_count(idx)=counts;  
  dif=new_count-old_count;
  ndif{i}=cn(dif~=0);
  old_count=new_count;

  
  
  
  

  % Save count into variable nout
  nout(i) = n;

  sprintf('\b\b\b%3i',i);
  waitbar(0.01*i,wb,['Computing threshold :    ' num2str(i)])
end;
fprintf('\n');
close(wb)
