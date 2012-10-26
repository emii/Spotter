
% This function will count the number of mRNAs for 100 thresholds 
% from 0 up to the maximum intensity of the input image.

function nout = multithreshstack(ims,threshold_num)

% Number of thresholds to compute
npoints = threshold_num;

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
