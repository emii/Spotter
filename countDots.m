function [UData adots ]=countDots(UserData,selection)
stacks=UserData.files(selection)
nuclei=UserData.nuclei;
tform=UserData.tform;
Sigma=UserData.Sigma;
BW=UserData.BW;
UData=struct('Sigma',[],'Stacks',[],'R',[]);
c=0;
fig=figure();
    n_nuc=numel(nuclei);
    adots=struct('Centroid',[],'coord',[],'numdots',[],'Label',[],'dotVol',[]);
    adots(n_nuc).Label=NaN;%preallocate structure array
    
    for ch = 1:numel(stacks);
        stacks{ch}
        stackfile= fullfile(UserData.dirpath,stacks{ch});
        %parse stack and correct shift if tfrom given
        if ~isempty(tform{ch})
            cims=parse_stack(stackfile,1,40,tform{ch});
        else
           cims=parse_stack(stackfile,1,40);
        end
        %filter ims
        cims=LOG_filter(cims,15,1.5);
        % Normalize ims
        cims = cims/max(cims(:));
        %Assess Sigma
        [ndots Rmax Smax lab m]=sigma_threshold(cims,BW,nuclei,Sigma,ch);
        subplot(3,2,ch+c);plot(Sigma,[m.R],'r-');title('R_sigma')
        c=c+1;
        subplot(3,2,ch+c);plot(Sigma,[m.tndots],'r-');title('total num spots')
        %use sigma maximizing R
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
end