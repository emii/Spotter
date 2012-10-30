function [nout,thresholds] = BW_multithreshstack(ims,BW,npoints)

% Note ims is already the log filtered image

BW(BW>0)=1;%make a labeled mask a binary one;
USE_UNIFORM=1; % Use uniformly spaced thresholds (Arjun's method)

if ~isempty(BW)
    USE_ERODE_MASK=1;
    %Image already normalized
    %ims = ims/max(ims(:));
    last_stack=size(ims,3);
    if USE_ERODE_MASK,
        BW2=imerode(BW,strel('square',20));
        for kk=1:last_stack,
            ims(:,:,kk)=ims(:,:,kk).*BW2;
        end
    end
    for k=1:last_stack,
        temp=ims(:,:,k);
        temp(temp==0)=min(min(temp(temp~=0)));
        ims(:,:,k)=temp;
    end
end
% Compute thresholds according to equal histogram sampling
[p,x]=hist(ims(:),10000);
p=p/sum(p);
C=cumsum(p);
vec=linspace(C(1),C(end),npoints);

% Over-riding this with Arjun's code
if USE_UNIFORM,
    thresholds=(1:npoints)/npoints;
else
    thresholds=zeros(1,npoints);
    for i=1:npoints,
        if isempty(find(C>=vec(i))),
            thresholds(i)=x(1);
        else
            thresholds(i)=x(min(find(C>=vec(i))));
        end
    end
end
nout=NaN(1,npoints);
for j = 1:npoints,
    bwl = ims > thresholds(j);
    [lab,spot_num] = bwlabeln(bwl);
    nout(j) = spot_num;
end;
