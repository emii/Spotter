function readData(varargin)


dirPath='Counts/';
fl=strtrim(ls(dirPath));
fl=regexp(fl,'\s+','split');
[sData sid]= loadData(dirPath,fl);

num_nuc=0;for s = 1:numel(sData)
    num_nuc=num_nuc+numel(sData{s}.nuclei);
end


idxA594=1;
idxCy5=2;

nuc_areas=nan(num_nuc,1);

nd_a594=nan(num_nuc,1);
nd_cy5=nan(num_nuc,1);

thr_a594=nan(num_nuc,1);
thr_cy5=nan(num_nuc,1);

dvols_a594=cell(1,num_nuc);
dvols_cy5=cell(1,num_nuc);

ddist_a594=cell(1,num_nuc);
ddist_cy5=cell(1,num_nuc);
ddist=cell(1,num_nuc);


c=1;
    for s = 1:numel(sData)

        for n = 1:numel(sData{s}.nuclei)

            nuc_areas(c)=sData{s}.nuclei(n).Area;
            nd_a594(c) = sData{s}.nuclei(n).nd(idxA594,1);
            nd_cy5(c) = sData{s}.nuclei(n).nd(idxCy5,1);
            thr_a594(c) = sData{s}.nuclei(n).thr(idxA594,1);
            thr_cy5(c) = sData{s}.nuclei(n).thr(idxCy5,1);
            
            idx=sData{s}.nuclei(n).vols(:,2)==idxA594;
            dvols_a594{c} = sData{s}.nuclei(n).vols(idx,1);
            idx=sData{s}.nuclei(n).vols(:,2)==idxCy5;
            dvols_cy5{c} = sData{s}.nuclei(n).vols(idx,1);

            idx=sData{s}.nuclei(n).dots(:,4)==idxA594;
            ddist_a594{c} = pdist(sData{s}.nuclei(n).dots(idx,1:3));
            idx=sData{s}.nuclei(n).dots(:,4)==idxCy5;
            ddist_cy5{c} = pdist(sData{s}.nuclei(n).dots(idx,1:3));
            ddist{c}=pdist(sData{s}.nuclei(n).dots(:,1:3));

            c=c+1;
        end
    end

figure;
scatter(nd_a594,nd_cy5);hold on
R=corrcoef(nd_a594,nd_cy5);
R=R(1,2);
p=polyfit(nd_a594,nd_cy5,1);
yhat = polyval(p,nd_a594);
plot(nd_a594, yhat,'r-')
text(0.2*max(nd_a594),0.8*max(nd_cy5),['R = ' num2str(R)])
axis square

figure;
[sa ix]=sort(nuc_areas);
scatter(sa,nd_a594(ix),'m');hold on
scatter(sa,nd_cy5,'c')
R=corrcoef(sa,nd_a594(ix));
R=R(1,2);
p=polyfit(sa,nd_a594(ix),1);
yhat = polyval(p,sa);
plot(sa, yhat,'r-')
text(0.2*max(sa),0.8*max(nd_a594(ix)),['R a594 = ' num2str(R)])

R=corrcoef(sa,nd_cy5(ix));
R=R(1,2);
p=polyfit(sa,nd_cy5(ix),1);
yhat = polyval(p,sa);
plot(sa, yhat,'r-')
text(0.2*max(sa),0.9*max(nd_cy5(ix)),['R cy5 = ' num2str(R)])
axis square


figure;

[ni xout] = hist(nd_a594,50);
bar(xout,ni,'FaceColor',[.6 .6 .6])
title('A594')

figure;

[ni xout] = hist(nd_cy5,50);
bar(xout,ni,'FaceColor',[.6 .6 .6])
title('Cy5')


end





function [stackData sid]= loadData(dirPath,fl)
stackData=cell(numel(fl),1);
sid=cell(numel(fl),1);
    for f = 1:numel(fl)
        id=regexp(fl{f},'_','split');
        id=[id{1:2}];
        filePath=fullfile(dirPath,fl{f});
        load(filePath);
        display(['loading ' filePath])
        sid{f}=id;
        %eval([id ' = f;']);
        assignin('caller',id,f);
        stackData{f}=UserData;
        clear UserData
    end
end
