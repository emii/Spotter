function outims = LOG_filter(ims,N,sigma)

% This generates the LOG filter itself.
% The bandwidth (here 1.5) may need to be changed depending
% on the pixel size of your camera and your microscope's
% optical characteristics.
%H = -fspecial('log',N,sigma);
H = -utilities.fspecial3('log',N,sigma);
%http://www.biomecardio.com/matlab/fspecial3.html#6

% Here, we amplify the signal by making the filter "3-D"
%H = 1/5*cat(3,H,H,H,H,H);

% Apply the filter
outims = imfilter(ims,H,'replicate');

% Set all negative values to zero
outims(find(outims<0)) = 0;