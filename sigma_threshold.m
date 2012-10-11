function [ndots Rmax Smax lab m]=sigma_threshold(ims,BW,nuclei,Sigma,ch)

    m=struct('R',[],'tndots',[],'p',[]);
    m(length(Sigma)).tndots=NaN;
    c=1;
    for s=Sigma
        s
    %for all cells_nucleus
        n_nuc=size(nuclei,1);
        ndots=struct('Centroid',[],'coord',[],'numdots',[],'Label',[],'dotVol',[]);
        %ndots=struct('Centroid',[],'boundaries',[],'BW',[],'coord',[],'numdots',[],'Label',[]);
        ndots(n_nuc).Label=NaN;%preallocate structure array
        nd=NaN(n_nuc,1);
        %for each cell_nucleus
        for i = 1:n_nuc;
            %isolate each nucleus
            [n_ims snuc]=crop_cell(ims,BW,nuclei(i));%plotBoundaries(ims(:,:,24),snuc,'g');
            %count dots for each nucleus given sigma
            [lab,num_dots,coord,vol]=count_dots(n_ims,snuc,s);
            ndots(i).coord=[coord ch.*ones(num_dots,1)];
            ndots(i).numdots=[num_dots ch];
            ndots(i).Centroid=snuc.Centroid;
            %ndots(i).boundaries=snuc.boundaries;
            %ndots(i).BW=snuc.BW;
            ndots(i).Label=snuc.Label;
            ndots(i).dotVol=[vol ch.*ones(num_dots,1)];
            nd(i)=num_dots;
        end
    %--end for each cell
    %end for all nuclei
    %areas=[nuclei.dapi];%make dorrelation between either Area or DAPI signal
    areas=[nuclei.Area];
    [sa aidx]=sort(areas);
    sa=sa(:);
    nd=nd(aidx);
    %m(c).vol=mean([ndots(aidx).dotVol]);
    m(c).tndots=sum(nd);
    R=corrcoef(sa,nd);
    m(c).R=R(1,2);
    p=polyfit(sa,nd,1);
    m(c).p=p;
    c=c+1;
    end
    Rmax=max([m.R]);
    Smax=Sigma([m.R]==Rmax);