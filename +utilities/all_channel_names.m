function [files channels]=all_channel_names(dirname,file_index)
% find files with specified file_index in the directory dirname.

d=dir([dirname '*.tif']);
if length(d)==0,
    d=dir([dirname '*.stk']);
end

channels={};
files={};
for i=1:length(d),
    index = d(i).name((end-6):(end-4));
    if strcmp(file_index,index)
        channels=[channels d(i).name(1:end-7)];
        files=[files d(i).name];
    end
end