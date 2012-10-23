classdef Stack
%Storage class for an image stack wich holds info for:
%- complete stack
%- calibration
%- z-projection
%- segmentation
% e.g dapi=object.Stack('dapi_001.tif',1,50,tform)
    properties
        filePath;
        ims=[];
        slicecount=[];
        channelName=[];
        projectMethod='max';
        enhanceMethod='imadjust';
        zprojection=[];
        tform=[];
        calibration=0;
        scale=[];
        first=[];
        last=[]
        segmentation=[];
    end
    
    methods
        function obj = Stack(filePath,tfrom1)
        %constructor: open and parse file with calibration if specified
            if nargin == 0; return; end
            
            if not(exist(filePath, 'file'))
                error('object:Stack:NoStackFile', ...
                    'the given image file \"%s\" does not exists', filePath)
            else
                info=imfinfo(filePath);
                obj.filePath=filePath;
                obj.slicecount=length(info);
                stack=zeros(info(1).Height,info(1).Width,obj.slicecount);
                
                if nargin == 2
                    for i=1:obj.slicecount
                        obj.tform=tform1;
                        tmp = imread(filePath,i,'info',info);%returns double
                        stack(:,:,i) = imtransform(tmp, obj.tform, ...
                        'XData', [1, size(stack, 2)], ...
                        'YData', [1, size(stack, 1)]);
                    end
                else
                    for i=1:obj.slicecount,
                        stack(:,:,i) = imread(filePath,i,'info',info);%returns double
                    end
                end
                obj.ims=stack;
            end
        end
    end

       
        
        
end
    