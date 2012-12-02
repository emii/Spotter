
% This function will count the number of mRNAs for 100 thresholds 
% from 0 up to the maximum intensity of the input image.

function nout = multithreshstack(ims,threshold_num,h)

% Number of thresholds to compute
npoints = threshold_num;

sprintf('Computing threshold (of %d):    1',npoints);
wb = waitbar(0,'Computing thresholds :    ');
for i = 1:npoints
  % Apply threshold
  bwl = ims > i/npoints;

  % Find particles
  [lab,n] = bwlabeln(bwl);  

  % Save count into variable nout
  nout(i) = n;

  sprintf('\b\b\b%3i',i);
  waitbar(0.01*i,wb,['Computing threshold :    ' num2str(i)])
end;
fprintf('\n');
close(wb)
