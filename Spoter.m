clear all;close all;clc
stack_dapi='./data/dapi_008.tif';
% Parse stack, in this function they also take into account filtering outlier images
ims=parse_stack(stack_dapi,1,40);
zim_dapi = zproject(ims);
%perform segmentation by watershed method
DL=segmentNuclei(zim_dapi);
%filtler for area and background
[nuclei BW]=filterSegmentation(DL,zim_dapi);clear DL;
%%
%filter bad segmentation for 17 and 18
[nuclei BW]=filterSegmentation(BW,zim_dapi,[17 18]);
%calculate DAPI intensity as the sum of its intensity throughout the stack
%minus the bg 
    for j=1:numel(nuclei);
    tmp=ims.*repmat(BW==j,[1,1,size(ims,3)]);
    nuclei(j).dapi=sum(tmp(:));% correct for bg still missing
    end
clear ims tmp stack_dapi zim_dapi j;
%%
%IMPORTANT:still have to correct for the shift
stacks={'./data/cy5_008.tif','./data/a594_008.tif','./data/tmr_008.tif'};
UData=struct('Sigma',[],'Stacks',[],'R',[]);
c=0;
  figure;
        n_nuc=numel(nuclei);
        adots=struct('Centroid',[],'coord',[],'numdots',[],'Label',[],'dotVol',[]);
        adots(n_nuc).Label=NaN;%preallocate structure array
for ch = 1:numel(stacks);
    stacks{ch}
    cims=parse_stack(stacks{ch},1,40);
    %filter ims
    cims=LOG_filter(cims,15,1.5);
    % Normalize ims
    cims = cims/max(cims(:));
    %Assess Sigma
    Sigma=1:0.1:5;
    [ndots Rmax Smax lab m]=sigma_threshold(cims,BW,nuclei,Sigma,ch);
    subplot(3,2,ch+c);plot(Sigma,[m.R],'r-');title('R_sigma')
    c=c+1;
    subplot(3,2,ch+c);plot(Sigma,[m.tndots],'r-');title('total num spots')
    [ndots Rmax Smax lab m]=sigma_threshold(cims,BW,nuclei,Smax,ch);
    for i = 1:n_nuc;
            adots(i).coord=[adots(i).coord;ndots(i).coord];
            adots(i).numdots=[adots(i).numdots; ndots(i).numdots];
            adots(i).Centroid=[adots(i).Centroid; ndots(i).Centroid];
            adots(i).Label=ndots.Label;
            adots(i).dotVol=[adots(i).dotVol; ndots(i).dotVol];
    end
        
        
          
UData.Sigma=[UData.Sigma Smax];
UData.R=[UData.R Rmax];
UData.Stacks=[UData.Stacks; [stacks(ch) num2str(size(cims))]];
end


clear Sigma Smax Rmax cims ch j lab stacks c m BW ndots n_nuc i

