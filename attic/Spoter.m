clear all;close all;clc
stack_dapi='./data/dapi_005.tif';
% Parse stack, in this function they also take into account filtering outlier images
ims=parse_stack(stack_dapi,1,50);
zim_dapi = zproject(ims);
%perform segmentation by watershed method
DL=segmentNuclei(zim_dapi);
%filtler for area and background
scr=get(0, 'ScreenSize');
pos=[scr(1:2)+scr(3:4).*0.25,scr(3:4).*0.75];
fig = figure( ...
        'Units', 'pixel', ...
        'Position', pos, ...
        'Name', 'Nucleus Spot Counter', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Visible', 'on');
    
    
ax= axes('Parent', fig,'Units', 'normalized', ...
        'OuterPosition', [.0, .0, 1.0, 1.0]);
 
[nuclei BW]=filterSegmentation(DL,zim_dapi,ax);clear DL;
   axis(ax,'off','image','ij','square');
%%
%filter bad segmentation for 17 and 18
[nuclei BW]=filterSegmentation(BW,zim_dapi,ax,[16]);
%calculate DAPI intensity as the sum of its intensity throughout the stack
%minus the bg 
    for j=1:numel(nuclei);
    tmp=ims.*repmat(BW==j,[1,1,size(ims,3)]);
    nuclei(j).dapi=sum(tmp(:));% correct for bg still missing
    end
clear ims tmp stack_dapi zim_dapi j;
%%
%IMPORTANT:still have to correct for the shift
stacks={'./data/cy5_003.tif','./data/a594_003.tif'};
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
    % cims=LOG_filter(cims,15,1.5);
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


clear Sigma Smax Rmax cims ch j lab stacks c m BW ndots n_nuc i h ax ans

