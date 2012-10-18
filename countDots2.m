function [UData adots]=countDots2(UserData,selection)
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
        [nout,thresholds] = BW_multithreshstack(cims,BW,200);
        subplot(1,numel(stacks),ch);plot(thresholds,nout);title(stacks{ch})
   
    end
end