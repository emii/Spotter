function varargout=SpotterUI()    

%Search if the figure exists
gui_singleton=1;
h = findall(0,'tag',mfilename);

    if ((isempty(h) && gui_singleton) || ~gui_singleton)
    %Launch the figure if not created or multiple instances allowed
    scr=get(0, 'ScreenSize');
    pos=[scr(1:2)+scr(3:4).*0.01,scr(3:4).*0.95];
    fig = figure( ...
            'Units', 'pixel', ...
            'Position', pos, ...
            'Name', 'SpotterUI', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
            'NumberTitle', 'off', ...
            'Resize', 'on', ...
            'Visible', 'off',...
            'handlevisibility','callback',...
            'HitTest','off',...
            'CloseRequestFcn',@gui_closereq,...
            'tag',mfilename,...
            'CreateFcn',@gui_OpeningFcn);

    % save all gui object handles as guidata so they can be accessed later
    handles = guidata(fig);
    handles.f=fig;
    
    % settings menu
        %settings_menu = uimenu(fig,'Label','Settings','Parent',fig);
        
    % context menu for deleting and classifying cells
        handles.hcmenu = uicontextmenu('Parent',fig);
        uimenu(handles.hcmenu, 'Label', 'delete', 'Callback', @rmNuclei_Callback2);
        uimenu(handles.hcmenu, 'Label', 'mark', 'Callback', @add_Class_Callback);
        %uimenu(handles.hcmenu, 'Label', 'subsegment', 'Callback', '');
        %uimenu(handles.hcmenu, 'Label', 'threshold', 'Callback', '');
        
    %the toolbar
        
        toolbarh = uitoolbar(fig);
        
        
        icon=utilities.get_icon('open_set.ico');
        tb.open=uipushtool(toolbarh,'CData',icon,...
            'TooltipString','open stack set',...
            'ClickedCallback',@open_imStack_Callback,...
            'BusyAction', 'cancel');
        
        icon=utilities.get_icon('save_counts.ico');
        tb.save=uipushtool(toolbarh,'CData',icon,...
            'TooltipString','save counts',...
            'ClickedCallback',@saveCounts_Callback,...
            'Enable','off',...
            'BusyAction', 'cancel');
 
        icon=utilities.get_icon('z_project.ico');
        tb.project=uipushtool(toolbarh,'CData',icon,...
            'TooltipString','z-project',...
            'ClickedCallback',@project_imStack_Callback,...
            'Enable','off',...
            'BusyAction', 'cancel');
        
        icon=utilities.get_icon('auto_segment.ico');
        tb.segment=uipushtool(toolbarh,'CData',icon,...
            'TooltipString','auto segment',...
            'ClickedCallback',@autoSegment_Callback,...
            'Enable','off',...
            'BusyAction', 'cancel');
        
        icon=utilities.get_icon('count_dots2.ico');
        tb.count=uipushtool(toolbarh,'CData',icon,...
            'TooltipString','count dots',...
            'Enable','off',...
            'ClickedCallback',@countDots_Callback);
        handles.tb=tb;
%         
%         icon=utilities.get_icon('open_single.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','open single stack',...
%             'ClickedCallback','');
%         
%         icon=utilities.get_icon('new_calib2.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','new calibration',...
%             'ClickedCallback','');
%         
%         icon=utilities.get_icon('manual_segment.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','manual segment',...
%             'ClickedCallback','');
%                 
%         icon=utilities.get_icon('settings.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','settings',...
%             'ClickedCallback','');
%         
%          icon=utilities.get_icon('pref2.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','settings',...
%             'ClickedCallback','');
%         
%         icon=utilities.get_icon('stack_crop.ico');
%         uipushtool(toolbarh,'CData',icon,...
%             'TooltipString','crop stack',...
%             'ClickedCallback','');
        

        
        set(toolbarh,'HandleVisibility','off')
        toolhandles = get(toolbarh,'Children');
        set(toolhandles,'HandleVisibility','off')
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

        panelChannelList = uipanel( ...
            'Parent', fig, ...
            'Units', 'normalized', ...
            'Position', [.12, .82, .10, .17], ...
            'Title', 'Channel Selection');

        handles.panelSettings = uipanel( ...
            'Parent', fig, ...
            'Units', 'normalized', ...
            'Position', [.01, .01, .1, .98], ...
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
        
       handles.ChannelList = uicontrol( ...
            'Parent', panelChannelList, ...
            'Style', 'listbox', ...
            'String', '', ...
            'Units','normalized',...
            'Position', [.05, .201, .9, .8], ...
            'Callback', '', ...
            'BusyAction', 'cancel', ...
            'HorizontalAlignment','center',...
            'FontName','courier',...
            'Max', 2, 'Min', 0); % this allows multiple selections

          % panelThresholds: axes for Threshold selection
        handles.ax = cell(4, 1);
        handles.ax{3} = axes( ...
            'Parent', panelThresholds, ...
            'Units', 'normalized', ...
            'Position', [.01, .01, .73, .4], ...
            'HandleVisibility', 'callback', ...
            'NextPlot', 'replacechildren', ...
            'Visible','off',...
            'Tag','thresholding',...
            'FontSize', 8);

        handles.ax{2} = axes( ...
            'Parent', panelThresholds, ...
            'Units', 'normalized', ...
            'Position', [.06, .45, .92, .2], ...
            'HandleVisibility', 'callback', ...
            'NextPlot', 'replacechildren',...
            'Visible','off',...
            'Tag','thresholding',...
            'FontSize', 8);
        handles.ax{4} = axes( ...
            'YAxisLocation','right',...
            'YColor','m',...
            'Parent', panelThresholds, ...
            'Units', 'normalized', ...
            'Position', [.06, .45, .92, .2], ...
            'HandleVisibility', 'callback', ...
            'NextPlot', 'replacechildren',...
            'Visible','off',...
            'Tag','thresholding',...
            'FontSize', 8,'Xtick',[],'Color','none');

        handles.ax{1} = axes( ...
            'Parent', panelThresholds, ...
            'Units', 'normalized', ...
            'Position', [.06, .69, .92, .27], ...
            'HandleVisibility', 'callback', ...
            'NextPlot', 'replacechildren',...
            'Visible','off',...
            'Tag','thresholding',...
            'FontSize', 8);

        handles.countNext = uicontrol( ...
            'Parent', panelThresholds, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [.75, .3, .2, .1], ...
            'String', 'Next', ...
            'UserData',0,...
            'Callback', 'set(gcbo,''UserData'',1)', ...
            'Visible','off',...
            'Enable','off',...
            'Tag','thresholding',...
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
        % setting visibility to "on" only now speeds up the window creation
        set(fig, 'Visible', 'on');
        %TODO initialize values
        handles=initialize(fig,handles);
        %store the hanldes in guidata
        guidata(fig, handles);
  
    else
        %Figure exists so bring Figure to the focus
        %and make sure to return the handles
        figure(h);
        handles=guidata(h);
        display([get(h,'Name') ' already launched...']);
    end
    if nargout
        [varargout{1:nargout}]=handles;
    end
end

function gui_OpeningFcn(hObject, eventdata)
% --- Executes just before imagem is made visible------------------
    if strcmp(get(hObject,'Visible'),'off')
       display('SpotterUI')
    end
end


function h=initialize(fig,h)
    
        % use guidata only for handles related to the actual user interface
        % use appdata to store internal data and settings
        % use userdata to store the measurements

    
    dt=clock;
    dt=fix(dt);
    
    
    if isempty(getappdata(fig,'settings'))
    %===============================================
    %=============Settings/Parameters===============
    default.name='Counts';
    default.date=datestr(dt,'dd-mm-yyyy-HH-MM');
    default.dirpath=pwd;
    default.stack_range=[1,100];
    default.ref_channel='dapi_';
    default.proj_method='max';
    default.segmentation_method='auto';
    default.NucleiAreaThreshold=11000;
    default.NucleiAreaFilter=[500 25000];
    default.filter_size=[11 11 11];
    default.filter_sigma=[1.4 1.4 1.4];
    default.thr_number=100;
    default.thr_window=5;
    default.thr_penalty=0.1; 
    default.voxelSizeuM=[0.125 0.125 0.250];
    %===============================================
    setappdata(fig,'settings',default);
    current_settings=default;
    h=setSettingsControls(h);   
    else
    h=setSettingsControls(h);   
    current_settings=getappdata(fig,'settings');
    end
    
    
    
    
    %===============================================
    %=============Status============================
    status.loaded=0;
    status.projected=0;
    status.enhanced=0;
    status.cropped=0;
    status.segmented=0;
    status.counted=0;
    status.changed=0;
    status.saved=0;
    %===============================================
    
    
    
    %===============================================
    %=============UserData==========================
    DefaultData.index='000';
    DefaultData.dirpath=pwd;
    DefaultData.I=[];
    DefaultData.files=[];
    DefaultData.channels=[];
    DefaultData.tform=[];
    DefaultData.L=[];
    DefaultData.dt=current_settings.date;
    DefaultData.I2=[];
    DefaultData.nuclei=[];
    DefaultData.BW=[];
    DefaultData.Counted=[];
    %===============================================
    
    
    set(h.uiMessage,'string','Load an image stack or start calibration')
   
    %Controls
    set(h.tb.project,'Enable','off')
    set(h.tb.segment,'Enable','off')
    set(h.tb.save,'Enable','off')
    set(h.tb.count,'Enable','off')
    set(h.countNext,'Visible','off','Enable','off')
    
    %Axes/Figure/List/Buttons
    set(h.f,'WindowButtonUpFcn','')
    
    set(h.ax{1},'Visible','off')
    set(h.ax{2},'Visible','off')
    set(h.ax{3},'Visible','off')
    set(h.ax{4},'Visible','off')
    
    set(h.ax{1},'NextPlot','replaceChildren');
    set(h.ax{2},'NextPlot','replaceChildren');
    set(h.imStack,'NextPlot','replaceChildren');
    set(h.ax{3},'NextPlot','replaceChildren');
    set(h.ax{4},'NextPlot','replaceChildren');
    
    delete(allchild(h.imStack)); 
    delete(allchild(h.ax{1})); 
    delete(allchild(h.ax{2})); 
    delete(allchild(h.ax{3})); 
    delete(allchild(h.ax{4}));
    
    set(h.countNext,'UserData',0)
    set(h.ChannelList,'String','','Value',[]);


  
        
    set(fig,'UserData',DefaultData);
    setappdata(fig,'status',status);
    setappdata(fig,'settings', current_settings)

end

function gui_closereq(hObject,eventdata)
% User-defined close request function 
% to display a question dialog box 
   h=guidata(hObject);
   selection = questdlg(['Close ', get(hObject,'Name'),'?',', all unsaved information will be lost.'],...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         %set(h.countNext,'UserData',1);
         delete(hObject)
      case 'No'
      return 
   end
end

    
    %---------Utilities---------------------------------------
%generate controls for the available channels
    function h = setSettingsControls(h)  
    delete(get(h.panelSettings,'Children'));
    settings=getappdata(h.f,'settings');
    settings_names=fieldnames(settings);
    h.settings = cell(numel(settings_names),1);
     for i = 1:numel(settings_names)
        %panelSettings: buttons for settings and calibration
        ypos=.93-.045*(i-1);
        
       uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style','text', ...
            'Units', 'normalized', ...
            'Position', [.02, ypos, .96, .025], ...
            'String',settings_names{i} , ...
            'HorizontalAlignment', 'left');
        
        if ischar(settings.(settings_names{i}))
            val=settings.(settings_names{i});
            h.settings{i}=uicontrol('Parent', h.panelSettings,...
           'Units','normalized',...
           'Style', 'edit',...
           'String', val,...
           'Position', [.02 ypos-.02 .96 .03],...
           'Callback', '',...
           'Enable','off',...
           'tag',settings_names{i});
        else 
            if numel(settings.(settings_names{i}))==1;
            val=num2str(settings.(settings_names{i}));
            h.settings{i}=uicontrol('Parent', h.panelSettings,...
           'Units','normalized',...
           'Style', 'edit',...
           'String', val,...
           'Position', [.02 ypos-.02 .96 .03],...
           'Callback', '',...
           'Enable','off',...
           'tag',settings_names{i});
            else
                box_handles=nan(numel(settings.(settings_names{i})),1);
                w=.97/numel(settings.(settings_names{i}));
                x=0.01;
                for j=1:numel(settings.(settings_names{i}))
                    val=settings.(settings_names{i});
                    box_handles(j)=uicontrol('Parent', h.panelSettings,...
                   'Units','normalized',...
                   'Style', 'edit',...
                   'String', num2str(val(j)),...
                   'Position', [x ypos-.02 w .03],...
                   'Callback', '',...
                   'Enable','off',...
                   'tag',settings_names{i});
                    x=w*j;
                    
                end
                h.settings{i}=box_handles;
            end
        end
        
       
       if i==1
           
        h.editSettings=uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [.02, .96, .49, .03], ...
            'String', 'Edit', ...
            'Callback', '', ...
            'BusyAction', 'cancel');
        
        h.saveSettings=uicontrol( ...
            'Parent', h.panelSettings, ...
            'Style', 'pushbutton', ...
            'Units', 'normalized', ...
            'Position', [.51, .96, .49, .03], ...
            'String', 'Save', ...
            'Callback', '', ...
            'BusyAction', 'cancel');
       end
     end
    end

%---------GUI callback functions-----------------------------------'
%open image stack
function open_imStack_Callback(hObject,eventdata) 
     h=guidata(hObject);
     
     old_st=getappdata(h.f,'status');
     
      if old_st.loaded
        % ask user to confirm for closing the software
        selection = questdlg('Open new stack set? all unsaved information will be lost.',...
            'Open...',...
            'Yes','No','Yes');
        if strcmp(selection,'No')
            % exit if canceled
            return;
        end
        
      end
         old_settings=getappdata(h.f,'settings');
         new_settings=old_settings;
         [imname, impath, imfilter_index] = uigetfile('*.tif','Open an image file (.tif)',old_settings.dirpath);
         new_settings.dirpath=impath;
         setappdata(h.f,'settings',new_settings)
         h=initialize(h.f,h);
        if imfilter_index   
             file_index=imname((end-6):(end-4));        
             [files,channels]=utilities.all_channel_names(impath,file_index);
             set(h.ChannelList,'String',files); 
             info=imfinfo([impath old_settings.ref_channel file_index '.tif']);   
             ims=parse_stack([impath old_settings.ref_channel file_index '.tif'],1,numel(info));
             front=ims(:,:,1);
             imagesc(front,'Parent',h.imStack);axes(h.imStack);colormap gray;axis square;axis off;axis image
   
%         h=setSettingsControls(h,channels);
        %store the hanldes in guidata
         guidata(h.f,h);
        %store UserData
        
         dt=clock;
         dt=fix(dt);
         UserData.dt=datestr(dt,'dd-mm-yyyy-HH-MM');
         UserData.index=file_index;
         UserData.dirpath=impath;
         UserData.I=ims;
         UserData.files=files;
         UserData.channels=channels;
         UserData.tform=cell(numel(channels),1);
         UserData.L=cell(numel(channels),1);
         UserData.BW=ones(size(ims,1),size(ims,2));
         UserData.Counted=false(1,numel(channels));
         
            tmp=bwboundaries(UserData.BW,8,'noholes');
            nuclei.Label='0';
            nuclei.boundaries = tmp{1};	
            nuclei.Centroid=[size(ims,1)/2,size(ims,1)/2];
            nuclei.nd=[];
            nuclei.thr=[];
            nuclei.dots=[];
            nuclei.intensity=[];
            nuclei.Dapi=[];
            nuclei.vol=[];
            nuclei.class=1;
            UserData.nuclei=nuclei;
         
         
         
         
         st=getappdata(h.f,'status');
         st.loaded=1;
         st.counted=zeros(1,numel(channels));
         
         set(h.f,'UserData',UserData);
         setappdata(h.f,'status',st)
         
         setappdata(h.f,'settings',new_settings)
         
         set(h.tb.project,'Enable','on');
         
         ui.message(h,['Loaded DAPI channel from selected stack set: ' file_index]);
         %gui_enable(h.f,st);
         else
             return 
         end
end
%project image stack
function project_imStack_Callback(hObject,eventdata)

    h=guidata(hObject);
    st=getappdata(h.f,'status');
    settings=getappdata(h.f,'settings');
    
    UserData=get(h.f,'UserData');
    zim=zproject(UserData.I,settings.proj_method);
    imagesc(zim,'Parent',h.imStack);colormap gray;
    UserData.I2=zim;
    st.projected=1;
    set(h.tb.segment,'Enable','on');
    set(h.tb.count,'Enable','on');
    set(h.f,'Userdata',UserData);
    setappdata(h.f,'status',st);
    ui.message(h,['Z-projection using ' settings.proj_method ' projection method... done']);
end
%segment nuclei
function autoSegment_Callback(hObject,eventdata)

    h=guidata(hObject);
    st=getappdata(h.f,'status');
    settings=getappdata(h.f,'settings');
    
    ui.message(h,'Performing segmentation, please wait...');
    UserData=get(h.f,'UserData');
    DL=segmentNuclei(UserData.I2,settings.NucleiAreaFilter);
    %filtler for area and background
    [nuclei, BW]=filterSegmentation(DL,UserData.I2,h.imStack,settings.NucleiAreaFilter);
    UserData.nuclei=nuclei;
    UserData.BW=BW;
    set(h.f,'Userdata',UserData);
    st.segmented=1;
    set(h.tb.project,'Enable','off');
    im=findobj(get(h.imStack,'Children'),'Type','image');
    set(im,'uicontextmenu',h.hcmenu);
    setappdata(h.f,'status',st);
    ui.message(h,'Segmentation ... done, select wrong segmented nuclei -> to be removed');
end

%remove segmented nuclei
function rmNuclei_Callback2(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    settings=getappdata(h.f,'settings');
    
    xy = get(h.imStack,'CurrentPoint');
        selection = UserData.BW(round(xy(1,2)),round(xy(1,1)));
        if selection ==0;
            ui.message(h,'click inside the nuclei!')
            return
        end
    cla(h.imStack);
    ui.message(h,['Removing the following nuclei: ' num2str(selection) 'please wait ...']);
    [nuclei, BW]=filterSegmentation(UserData.BW,UserData.I2,h.imStack,settings.NucleiAreaFilter,selection);
    im=findobj(get(h.imStack,'Children'),'Type','image');
    set(im,'uicontextmenu',h.hcmenu);
    UserData.nuclei=nuclei;
    UserData.BW=BW;
    set(h.f,'Userdata',UserData);
    ui.message(h,['Nuclei removed, ' num2str(numel(nuclei)) 'nuclei re-labeled']);
end

function add_Class_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    xy = get(h.imStack,'CurrentPoint');
        selection = UserData.BW(round(xy(1,2)),round(xy(1,1)));
        if selection ==0;
            ui.message(h,'click inside the nuclei!')
            return
        end

    set(h.imStack,'NextPlot','add');
    nuc=UserData.nuclei(selection);
    plot(h.imStack,nuc(1).boundaries(:,2),nuc(1).boundaries(:,1),'m')
    UserData.nuclei(selection).class=2;
    set(h.f,'Userdata',UserData);
    ui.message(h,['Added class to nuclei: ' num2str(selection)]);
    set(h.imStack,'NextPlot','Replacechildren');
end

function countDots_Callback(hObject, eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');

    selection=get(h.ChannelList,'Value');
    if isempty(selection)
        ui.message(h,'select channels from list');
        return
    end
    set(h.countNext,'Visible','on');
    set(h.tb.segment,'Enable','off');
    set(h.tb.project,'Enable','off');
    set(h.ax{1},'Visible','on');
    set(h.ax{2},'Visible','on');
    set(h.ax{3},'Visible','on');
    set(h.ax{4},'Visible','on');
    
    UserData=thresholdDots(UserData,h,selection);
    
    try
    set(h.f,'Userdata',UserData);
    catch err
        display(err.identifier)
        display('Unexpected close of the program while selecting a threshold')
       
    end
end
%save User Data
function saveCounts_Callback(hObject,eventdata)
    h=guidata(hObject);
    UserData=get(h.f,'UserData');
    ui.message(h,'Wait, calculating DAPI intensity...');
    UserData=setDapiIntensity(UserData);
    dt=clock;
    dt=fix(dt);
    dt=datestr(dt,'ddmmyyyy');
    [svName,svPath,FilterIndex] = uiputfile('*.mat','Save your calibration',...
        [UserData.dirpath 'Counts_' UserData.index '_' dt]);
    if FilterIndex
        %TODO calculate dpi intensity?
        UserData.I=UserData.I2;
        svFullPath=fullfile(svPath, svName);
        save(svFullPath,'-mat','UserData')
        
        h=initialize(h.f,h);
        
        ui.message(h,['Data Saved!, Channels counted:' UserData.channels(UserData.Counted)])
        
        
        
    else
        return
    end
end









