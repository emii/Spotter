function SpotterUI()    
scr=get(0, 'ScreenSize');
pos=[scr(1:2)+scr(3:4).*0.01,scr(3:4).*0.95];
fig = figure( ...
        'Units', 'pixel', ...
        'Position', pos, ...
        'Name', 'Nucleus Spot Counter', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
        'NumberTitle', 'off', ...
        'Resize', 'on', ...
        'Visible', 'off');
    
% save all gui object handles as guidata so they can be accessed later
handles = guidata(fig);
handles.f=fig;
% slice the display up into separate panels to organize the controls
    panelMessage= uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.22, 0.82, 0.4, 0.17], ...
        'Title', 'Message');
    
    panelImageStack = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.12, 0.01, 0.5, 0.81], ...
        'Title', 'Image');
    
    panelNucleiList = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.12, .82, .10, .17], ...
        'Title', 'Nuclei Selection');
    
    panelMenu = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .49, .1, .50], ...
        'Title', 'Menu');

    handles.panelSettings = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .1, .47], ...
        'Title', 'Settings');
    
    panelThresholds = uipanel( ...
        'Parent', fig, ...
        'Units', 'normalized', ...
        'Position', [.63, .01, .36, .98], ...
        'Title', 'Thresholds');
    
    %panelMessage: message text
    handles.uiMessage = uicontrol(...
        'Parent', panelMessage, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .9, .9], ...
        'FontSize',16,...
        'String', 'Load an image stack or start calibration');
    
      % panelThresholds: axes for Threshold selection
    handles.ax = cell(3, 1);
    handles.ax{3} = axes( ...
        'Parent', panelThresholds, ...
        'Units', 'normalized', ...
        'Position', [.01, .01, .73, .4], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren', ...
        'FontSize', 8);
    
    handles.ax{2} = axes( ...
        'Parent', panelThresholds, ...
        'Units', 'normalized', ...
        'Position', [.06, .45, .92, .2], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren',...
        'FontSize', 8);
    
    handles.ax{1} = axes( ...
        'Parent', panelThresholds, ...
        'Units', 'normalized', ...
        'Position', [.06, .69, .92, .27], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren',...
        'FontSize', 8);
    
    handles.countNext = uicontrol( ...
        'Parent', panelThresholds, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.75, .3, .2, .1], ...
        'String', 'Next', ...
        'UserData',0,...
        'Callback', @countNext_Callback, ...
        'BusyAction', 'cancel');
    
    
    % panelImageStack: axes for Image Stack
    handles.imStack = axes( ...
        'Parent', panelImageStack, ...
        'Units', 'normalized', ...
        'OuterPosition', [.0, .0, 1.0, 1.0], ...
        'Position', [.01, .01, .99, .98], ...
        'HandleVisibility', 'callback', ...
        'NextPlot', 'replacechildren');
    axis(handles.imStack,'off','image','ij');
    
    
    % panelMenu: buttons for all accessible actions
    uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .85, .9, .1], ...
        'String', 'Open Stack Set', ...
        'Callback', @open_imStack_Callback, ...
        'BusyAction', 'cancel');
    
    handles.zProject = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .75, .9, .1], ...
        'String', 'Z-projection (max)', ...
        'Callback', @project_imStack_Callback, ...
        'BusyAction', 'cancel');
    
    handles.autoSegment = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .65, .9, .1], ...
        'String', 'Auto Segment', ...
        'Callback', @autoSegment_Callback, ...
        'BusyAction', 'cancel');
    
    handles.ChannelList = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.05, .25, .9, .2], ...
        'Callback', '', ...
        'BusyAction', 'cancel', ...
        'HorizontalAlignment','center',...
        'FontName','courier',...
        'Max', 2, 'Min', 0); % this allows multiple selections
    
    handles.uiCount = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .15, .9, .1], ...
        'String', 'Count Dots', ...
        'Callback', @countDots_Callback, ...
        'BusyAction', 'cancel');
    
    handles.uiSave = uicontrol( ...
        'Parent', panelMenu, ...
        'Style', 'pushbutton', ...
        'Units', 'normalized', ...
        'Position', [.05, .05, .9, .1], ...
        'String', 'Save Counts', ...
        'Callback', @saveCounts_Callback, ...
        'BusyAction', 'cancel');
    
    % panelNucleiList: listbox showing the available channels
    handles.NucleiList = uicontrol( ...
        'Parent', panelNucleiList, ...
        'Style', 'listbox', ...
        'String', '', ...
        'Units','normalized',...
        'Position', [.05, .201, .9, .8], ...
        'Callback', @rmNucleiList_Callback, ...
        'BusyAction', 'cancel', ...
        'HorizontalAlignment','right',...
        'Max', 2, 'Min', 0); % this allows multiple selections
    handles.rmNuclei = uicontrol( ...
        'Parent', panelNucleiList, ...
        'Style', 'pushbutton', ...
        'String', 'Remove Nuclei', ...
        'Units','normalized',...
        'Position', [.05, .01, .9 .2], ...
        'Callback', @rmNuclei_Callback, ...
        'BusyAction', 'cancel'); % this allows multiple selections

    % setting visibility to "on" only now speeds up the window creation
    set(fig, 'Visible', 'on');
    %store the hanldes in guidata
    guidata(fig, handles);
    % use guidata only for handles related to the actual user interface
    % use appdata to store the actual data
    %TODO initialize values
end
% --- Executes just before imagem is made visible------------------
%TODO

%---------GUI callback functions-----------------------------------'
%open image stack
function open_imStack_Callback(hObject,eventdata)
     h=guidata(hObject);
     UserData=[];
     [imname, impath, imfilter_index] = uigetfile('*.tif','Open an image file (.tif)');
     if imfilter_index   
     file_index=imname((end-6):(end-4));        
        [files,channels]=utilities.all_channel_names(impath,file_index);
        set(h.ChannelList,'String',files); 
     
         ims=parse_stack([impath 'dapi_' file_index '.tif'],1,40);
         front=ims(:,:,1);
         imagesc(front,'Parent',h.imStack);colormap gray;axis square;axis off;axis image
     
    h=setSettingsControls(h,channels);
    %store the hanldes in guidata
     guidata(h.f,h);
    %store UserData
     UserData.index=file_index;
     UserData.dirpath=impath;
     UserData.I=ims;
     UserData.files=files;
     UserData.channels=channels;
     UserData.tform=cell(numel(channels),1);
     UserData.L=cell(numel(channels),1);
     dt=clock;
     dt=fix(dt);
     UserData.dt=datestr(dt,'dd-mm-yyyy-HH-MM');
     set(h.f,'UserData',UserData);
     ui.message(h,['Loaded DAPI channel from selected stack set: ' file_index]);
     else
         return 
     end
     
end
%project image stack
function project_imStack_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    zim=zproject(UserData.I);
    imagesc(zim,'Parent',h.imStack);colormap gray;
    UserData.I2=zim;
    set(h.f,'Userdata',UserData);
    ui.message(h,'Z-projection using max()...done');
end
%segment nuclei
function autoSegment_Callback(hObject,eventdata)
    h=guidata(hObject);
    ui.message(h,'Performing segmentation, please wait...');
    UserData=get(h.f,'UserData');
    DL=segmentNuclei(UserData.I2);
    %filtler for area and background
    [nuclei BW]=filterSegmentation(DL,UserData.I2,h.imStack);
    UserData.nuclei=nuclei;
    UserData.BW=BW;
    set(h.f,'Userdata',UserData);
    nuclei_Labels={nuclei.Label};
    set(h.NucleiList,'String',nuclei_Labels,'Value',[1]);
    ui.message(h,'Segmentation ... done, select wrong segmented nuclei -> to be removed');
end
%remove segmented nuclei
function rmNuclei_Callback(hObject,eventdata)
    h=guidata(hObject);
    set(h.NucleiList,'String','');
    cla(h.imStack);
    UserData=get(h.f,'UserData');
    selection=get(h.NucleiList,'Value');
    ui.message(h,['Removing the folowing nuclei: ' num2str(selection) 'please wait ...']);
    [nuclei BW]=filterSegmentation(UserData.BW,UserData.I2,h.imStack,selection);
    UserData.nuclei=nuclei;
    UserData.BW=BW;
    set(h.f,'Userdata',UserData);
    nuclei_Labels={nuclei.Label};
    set(h.NucleiList,'String',nuclei_Labels,'Value',[1]);
    ui.message(h,['Nuclei removed, ' num2str(numel(nuclei)) 'nuclei re-labeled']);
end
%select segmented nuclei to remove
function rmNucleiList_Callback(hObject,eventdata)
    h=guidata(hObject);
    selection=get(gcbo,'Value'); 
    ui.message(h,['Selected nuclei to be removed: ' num2str(selection)]);    
end
%count dots for selected channels
function countDots_Callback(hObject, eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    UserData.threshold_num=100;
    selection=get(h.ChannelList,'Value');
    UserData=thresholdDots(UserData,h,selection);
%     [UData adots]=countDots(UserData,h,selection,);
%     UserData.UData=UData;
%     UserData.dots=adots;
    set(h.f,'Userdata',UserData);
    
end
%save User Data
function saveCounts_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    dt=clock;
    dt=fix(dt);
    dt=datestr(dt,'ddmmyyyy');
    [svName,svPath,FilterIndex] = uiputfile('*.mat','Save your calibration',...
        [UserData.dirpath 'Stack_' UserData.index '_' dt]);
    if FilterIndex
        UserData.I=UserData.I2;
        svFullPath=fullfile(svPath, svName);
        save(svFullPath,'-mat','UserData')
    else
        return
    end
end
%calibrate images for the shift
function newCalibration_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    c=get(gcbo,'UserData');
    [imname, impath, imfilter_index] = uigetfile([c.name '*.tif'],['Open an beads file (.tif) for channel ' c.name]);
    
    if imfilter_index
        file_index=imname((end-6):(end-4));
        ch_b_file=[impath imname];
        dapi_b_file=[impath 'dapi_' file_index '.tif'];
        tform=calibrateShift(dapi_b_file,ch_b_file);
        [svName,svPath,FilterIndex] = uiputfile('*.mat','Save your calibration',[impath c.name 'calib']);
        
        if FilterIndex
            svFullPath=fullfile(svPath, svName);
            UserData.tform{c.val}=tform;
            set(h.f,'Userdata',UserData);
            save(svFullPath,'-mat','tform')
            set(h.pathCalib{c.val},'String',svName)
            
        else
            %TODO set values to empty
            return
        end
        
    else
        %TODO set values to empty
        return
    end
end
%load previously calculated calibration
function loadCalibration_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    c=get(gcbo,'UserData');
    [mname, mpath, mfilter_index] = uigetfile('*.mat',['Open calibration file for channel ' c.name]);
    if mfilter_index
        mFullPath=fullfile(mpath, mname);
        load(mFullPath,'-mat','tform')
        UserData.tform{c.val}=tform;
        set(h.f,'Userdata',UserData);
        set(h.pathCalib{c.val},'String',mname)
    else
        %TODO set values to empty
        return
    end
end

function countNext_Callback(hObject,eventdata)
    set(gcbo,'UserData',1)
end




%---------Utilities---------------------------------------
%generate controls for the available channels
    function h = setSettingsControls(h,channels)     
    chs=numel(channels);
     for ch = 1:chs
        %panelSettings: buttons for settings and calibration
        %shift calibration for cy5
        h.pathCalibs = cell(chs, 1);
        h.calib = cell(chs, 1);
        h.loadCalib = cell(chs, 1);
        ypos=.92-.21*(ch-1);
        uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', [.02, ypos, .96, .06], ...
            'String', [channels{ch} 'shift calibration'], ...
            'HorizontalAlignment', 'left');
        h.pathCalib{ch} = uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style', 'edit', ...
            'Units', 'normalized', ...
            'Position', [.02, ypos-.05, .96, .06], ...
            'String', '', ...
            'Callback', '', ...
            'BusyAction', 'cancel');
        cn.name=channels{ch};
        cn.val=ch;
        h.calib{ch} = uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [.02, ypos-.15, .49, .1], ...
            'String', 'New', ...
            'Callback', @newCalibration_Callback, ...
            'UserData',cn, ...
            'BusyAction', 'cancel');

        h.loadCalib{ch} = uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [.51, ypos-.15, .47, .1], ...
            'String', 'Load', ...
            'UserData',cn, ...
            'Callback', @loadCalibration_Callback, ...
            'BusyAction', 'cancel');
     end
    end








