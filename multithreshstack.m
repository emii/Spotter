
% This function will count the number of mRNAs for 100 thresholds 
% from 0 up to the maximum intensity of the input image.

function nout = multithreshstack(ims,BW)

    n_stack=size(ims,3);
    BW2=imerode(BW,strel('square',20));
    for kk=1:n_stack,
        ims(:,:,kk)=ims(:,:,kk).*BW2;
    end

    for kk=1:n_stack,
        temp=ims(:,:,kk);
        temp(temp==0)=min(min(temp(temp~=0)));
        ims(:,:,kk)=temp;
    end
    
% Normalize image
ims = ims/max(ims(:));

% Number of thresholds to compute
npoints = 100;

fprintf('Computing threshold (of %d):    1',npoints);

for i = 1:npoints
  % Apply threshold
  bwl = ims > i/npoints;

  % Find particles
  [lab,n] = bwlabeln(bwl);  

  % Save count into variable nout
  nout(i) = n;

  fprintf('\b\b\b%3i',i);
end;
fprintf('\n');
