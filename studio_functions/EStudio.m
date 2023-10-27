% New GUI Layout -ERPLAB Studio
%
% Author: Guanghui Zhang & Steve J. Luck & Andrew Stewart
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022-2024

% ERPLAB Studio Toolbox
%

%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Reqs:
% - data loaded in valid ERPset and EEGset
% - GUI Layout Toolbox
% - ERPLAB
% - EEGLAB

%
% Demo to explore an ERP Viewer using the new GUI Layout Toolbox
% Now with more in nested functions


function [] = EStudio()

%%close EEGLAB
try
    W_MAIN = findobj('tag', 'EEGLAB');
    close(W_MAIN);
    clearvars ALLCOM;
    
    LASTCOM = [];
    %     eeglab;
    global ALLCOM;
    ALLCOM =[];
    eegh('EStudio;');
    evalin('base', 'eeg_global;');
    eeg_global;
catch
end


EStudioversion = 10.02;
erplab_running_version('Version',EStudioversion,'tooltype','EStudio');
try
    clearvars observe_EEGDAT;
    clearvars observe_ERPDAT;
    clearvars viewer_ERPDAT;
catch
end

% global CURRENTERP;
global observe_EEGDAT;
global observe_ERPDAT;
global viewer_ERPDAT;
global EStudio_gui_erp_totl
viewer_ERPDAT = v_ERPDAT;


%%---------------ADD FOLDER TO PATH-------------------
estudiopath = which('EStudio','-all');
if length(estudiopath)>1
    fprintf('\nEStudio WARNING: More than one EStudio folder was found.\n\n');
end
estudiopath = estudiopath{1};
estudiopath= estudiopath(1:findstr(estudiopath,'EStudio.m')-1);
% add all ERPLAB subfolders
addpath(genpath(estudiopath));

%%-------------------------------------------------------------------------
%%-----------add path for each folder that contained in EStudio------------
%%-------------------------------------------------------------------------
%%Layout Toolbox
% myaddpath( estudiopath, 'layoutRoot.m',   [ 'GUI Layout Toolbox' filesep 'layout']);
% myaddpath( estudiopath, 'BoxPanel.m',   [ 'GUI Layout Toolbox' filesep 'layout',filesep,'+uiextras']);
% myaddpath( estudiopath, 'Box.m',   [ 'GUI Layout Toolbox' filesep 'layout',filesep,'+uix']);
% myaddpath( estudiopath, 'Container.m',   [ 'GUI Layout Toolbox' filesep 'layout',filesep,'+uix',filesep,'+mixin']);

%%functions
myaddpath( estudiopath, 'EStudio_EEG_Tab.m',   [ 'Functions' filesep 'EStudio',filesep,'EEG Tab']);
myaddpath( estudiopath, 'EStudio_ERP_Tab.m',   [ 'Functions' filesep 'EStudio',filesep,'ERP Tab']);
myaddpath( estudiopath, 'ERPLAB_ERP_Viewer.m',   [ 'Functions' filesep 'EStudio',filesep,'ERP Tab',filesep,'ERP wave viewer']);
%%GUIs
myaddpath( estudiopath, 'f_EEG_avg_erp_GUI.m',   [ 'GUIs' filesep 'EEG Tab']);
myaddpath( estudiopath, 'f_ERP_append_GUI.m',   [ 'GUIs' filesep 'ERP Tab']);



SignalProcessingToolboxCheck;

if exist('memoryerpstudiopanels.erpm','file')==2
    iserpmem = 1; % file for memory exists
else
    iserpmem = 0; % does not exist file for memory
end
if iserpmem==0
    p1 = which('o_ERPDAT');
    p1 = p1(1:findstr(p1,'o_ERPDAT.m')-1);
    save(fullfile(p1,'memoryerpstudiopanels.erpm'),'EStudioversion')
end



if exist('memoryerpstudio.erpm','file')==2
    iserpmem = 1; % file for memory exists
else
    iserpmem = 0; % does not exist file for memory
end
if iserpmem==0
    p1 = which('o_ERPDAT');
    p1 = p1(1:findstr(p1,'o_ERPDAT.m')-1);
    save(fullfile(p1,'memoryerpstudio.erpm'),'EStudioversion')
end


% Sanity checks
try
    test = uix.HBoxFlex();
catch
    beep;
    disp('The GUI Layout Toolbox might not be installed. Quitting')
    return
end


%%Try to close existing GUI
% global EStudio_gui_erp_totl_Window
try
    close(EStudio_gui_erp_totl.Window);
catch
end

%%close EStudio if it launched
try
    global EStudio_gui_erp_totl
    close(EStudio_gui_erp_totl.Window);
catch
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-------------------------------EEG-------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
observe_EEGDAT = o_EEGDATA;
observe_ERPDAT = o_ERPDAT;
EEG = [];
ALLEEG = [];
CURRENTSET = 0;
assignin('base','EEG',EEG);
assignin('base','ALLEEG', ALLEEG);
assignin('base','CURRENTSET', CURRENTSET);
% assignin('base','ALLCOM', []);

observe_EEGDAT.ALLEEG = ALLEEG;
observe_EEGDAT.CURRENTSET = CURRENTSET;
observe_EEGDAT.EEG = EEG;
observe_EEGDAT.count_current_eeg = 0;
observe_EEGDAT.eeg_panel_message = 0;
observe_EEGDAT.eeg_two_panels = 0;
observe_EEGDAT.eeg_reset_def_paras = 0;

addlistener(observe_EEGDAT,'alleeg_change',@alleeg_change);
addlistener(observe_EEGDAT,'eeg_change',@eeg_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_reset_def_paras_change',@eeg_reset_def_paras_change);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%---------------------For ERP-------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ERP              = [];  % Start ERP Structure on workspace
ALLERP           = [];    %Start ALLERP Structure on workspace
ALLERPCOM        = [];
CURRENTERP       = 1;
assignin('base','ERP',ERP);
assignin('base','ALLERP', ALLERP);
assignin('base','CURRENTERP', CURRENTERP);
% filepath =  which('dummy.erp');
% [pathstr, fname, ext] = fileparts(filepath);
% [ERP, ALLERP] = pop_loaderp('filename','dummy.erp', 'filepath',pathstr ,'History', 'off');
assignin('base','ALLERP',ALLERP);


observe_ERPDAT.ALLERP = ALLERP;
observe_ERPDAT.CURRENTERP = CURRENTERP;
observe_ERPDAT.ERP = ERP;
observe_ERPDAT.Count_ERP = 0;
observe_ERPDAT.Count_currentERP = 1;
observe_ERPDAT.Process_messg = 0;%0 is the default means there is no message for processing procedure;
observe_ERPDAT.erp_two_panels = 0;
observe_ERPDAT.Two_GUI = 0;

addlistener(observe_ERPDAT,'cerpchange',@indexERP);
addlistener(observe_ERPDAT,'drawui_CB',@onErpChanged);
addlistener(observe_ERPDAT,'erpschange',@allErpChanged);
addlistener(observe_ERPDAT,'Count_ERP_change',@CountErpChanged);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'Messg_change',@Process_messg_change_main);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);



erpworkingmemory('f_EEG_proces_messg_pre',{'',0});
estudioworkingmemory('EStudioColumnNum',1);
erpworkingmemory('Change2epocheeg',0);%%Indicate whether we need to force "Epoched EEG" to be selected in EEGsets panel after epoched EEG.
erpworkingmemory('eegicinspectFlag',0);%%Update the current EEG after Inspect/label ICs.

EStudio_gui_erp_totl = struct();

EStudio_gui_erp_totl = createInterface();

% Update the GUI with current data
% updateInterface();

f_redrawEEG_Wave_Viewer();%%Draw EEG waves
f_redrawERP();%%Draw ERP waves

    function EStudio_gui_erp_totl = createInterface()
        
        try
            [version reldate] = geterplabstudioversion;
            erplabstudiover = version;
        catch
            erplabstudiover = '??';
        end
        currvers  = ['ERPLAB Studio ' erplabstudiover];
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        EStudio_gui_erp_totl = struct();
        % First, let's start the window
        EStudio_gui_erp_totl.Window = figure( 'Name', currvers, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'HandleVisibility', 'on', 'tag', 'EStudio');
        
        % set the window size
        %%screen size
        ScreenPos = [];
        new_pos= erpworkingmemory('ERPWaveScreenPos');
        if isempty(new_pos) || numel(new_pos)~=2
            new_pos = [75,75];
            erpworkingmemory('EStudioScreenPos',new_pos);
        end
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        if ~isempty(new_pos(2)) && new_pos(2) >100
            POS4 = (new_pos(2)-1)/100;
            new_pos =[0,0-ScreenPos(4)*POS4,ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100];
        else
            new_pos =[0,0,ScreenPos(3)*new_pos(1)/100,ScreenPos(4)*new_pos(2)/100];
        end
        try
            set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
        catch
            set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
            erpworkingmemory('EStudioScreenPos',[75 75]);
        end
        EStudio_gui_erp_totl.Window.Resize = 0;
        
        % + File menu
        EStudio_gui_erp_totl.FileMenu = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'File');
        uimenu( EStudio_gui_erp_totl.FileMenu, 'Label', 'Exit', 'Callback', @onExit);
        
        % + View menu
        EStudio_gui_erp_totl.ViewMenu = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'ERPLAB Commands' );
        
        %%-----------Setting------------------------------------------------
        EStudio_gui_erp_totl.Setting = uimenu( EStudio_gui_erp_totl.Window, 'Label', 'Setting');
        
        %%ERPStudio Memory
        EStudio_gui_erp_totl.set_ERP_memory = uimenu( EStudio_gui_erp_totl.Setting, 'Label', 'EStudio Memory Setting','separator','off');
        uimenu( EStudio_gui_erp_totl.set_ERP_memory, 'Label', 'Reset EStudio Working Memory', 'Callback', 'erplabstudioamnesia(1)','separator','off');
        uimenu( EStudio_gui_erp_totl.set_ERP_memory, 'Label', 'Save a copy of the current working memory as...', 'Callback', 'working_mem_save_load(1)','separator','off');
        comLoadWM = ['clear vmemoryerp; vmemoryerp = working_mem_save_load(2); assignin(''base'',''vmemoryerp'',vmemoryerp);'];
        uimenu( EStudio_gui_erp_totl.set_ERP_memory,'Label','Load a previous working memory file','CallBack',comLoadWM,'separator','off');
        
        %%window size
        uimenu( EStudio_gui_erp_totl.Setting, 'Label', 'Window Size', 'Callback', @EStudiowinsize);
        
        
        %% Create tabs
        EStudio_gui_erp_totl.context_tabs = uiextras.TabPanel('Parent', EStudio_gui_erp_totl.Window, 'Padding', 5,'BackgroundColor',ColorB_def,'FontSize',14);
        EStudio_gui_erp_totl.tabEEG = uix.HBoxFlex( 'Parent', EStudio_gui_erp_totl.context_tabs, 'Spacing', 10,'BackgroundColor',ColorB_def );
        EStudio_gui_erp_totl.tabERP = uix.HBoxFlex( 'Parent', EStudio_gui_erp_totl.context_tabs, 'Spacing', 10,'BackgroundColor',ColorB_def);
        tab3 = uix.HBoxFlex( 'Parent', EStudio_gui_erp_totl.context_tabs, 'Spacing', 10 );
        
        EStudio_gui_erp_totl.context_tabs.TabNames = {'EEG','ERP', 'MVPA'};
        EStudio_gui_erp_totl.context_tabs.SelectedChild = 1;
        EStudio_gui_erp_totl.context_tabs.HighlightColor = [0 0 0];
        EStudio_gui_erp_totl.context_tabs.FontWeight = 'bold';
        EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/3;
        EStudio_gui_erp_totl.context_tabs.BackgroundColor = ColorB_def;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%------------EEG tab for continous EEG and epoched EEG------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EStudio_gui_erp_totl = EStudio_EEG_Tab(EStudio_gui_erp_totl,ColorB_def);
        FonsizeDefault = f_get_default_fontsize();figbgdColor = [1 1 1];
        EStudio_gui_erp_totl.eegplotgrid = uix.VBox('Parent',EStudio_gui_erp_totl.eegViewContainer,'Padding',0,'Spacing',0,'BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eegpageinfo_box = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eegpageinfo_text = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style','text','String','','FontSize',FonsizeDefault,'FontWeight','bold','BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eegpageinfo_minus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Prev.','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'FontWeight','bold');
        EStudio_gui_erp_totl.eegpageinfo_edit = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'edit', 'String', '','FontSize',FonsizeDefault+2,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eegpageinfo_plus = uicontrol('Parent',EStudio_gui_erp_totl.eegpageinfo_box,'Style', 'pushbutton', 'String', 'Next','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1],'FontWeight','bold');
        EStudio_gui_erp_totl.eeg_plot_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);
        
        EStudio_gui_erp_totl.eegViewAxes = uix.ScrollingPanel( 'Parent', EStudio_gui_erp_totl.eeg_plot_title,'BackgroundColor',figbgdColor);
        EStudio_gui_erp_totl.eeg_plot_button_title = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
        uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eeg_zoom_in_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','|<',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        
        EStudio_gui_erp_totl.eeg_zoom_in_fivesmall = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','<<',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_zoom_in_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','<',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_zoom_edit = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','edit','String','',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_zoom_out_small = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_zoom_out_fivelarge = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>>',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_zoom_out_large = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','>|',...
            'FontSize',FonsizeDefault+5,'BackgroundColor',[1 1 1]);
        uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eeg_figurecommand = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Show Command',...
            'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_figuresaveas = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Save Figure as',...
            'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStudio_gui_erp_totl.eeg_figureout = uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','pushbutton','String','Create Static /Exportable Plot',...
            'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        uicontrol('Parent',EStudio_gui_erp_totl.eeg_plot_button_title,'Style','text','String','','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStudio_gui_erp_totl.eegxaxis_panel = uiextras.HBox( 'Parent', EStudio_gui_erp_totl.eegplotgrid,'BackgroundColor',ColorB_def);%%%Message
        EStudio_gui_erp_totl.eegProcess_messg = uicontrol('Parent',EStudio_gui_erp_totl.eegxaxis_panel,'Style','text','String','','FontSize',FonsizeDefault+2,'FontWeight','bold','BackgroundColor',ColorB_def);
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%---------------set the layouts for ERP Tab-----------------------
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        EStudio_gui_erp_totl = EStudio_ERP_Tab(EStudio_gui_erp_totl,ColorB_def);
    end % createInterface


%%---------------------------------allEEG-------------------------------------
    function alleeg_change(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
    end

%%---------------------------------EEG-------------------------------------
    function eeg_change(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        assignin('base','EEG',observe_EEGDAT.EEG);
    end

    function count_current_eeg_change(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        return;
    end

%------------------------------------ERP-----------------------------------
    function onErpChanged( ~, ~ )
        assignin('base','ERP',observe_ERPDAT.ERP);
    end


    function indexERP( ~, ~ )
        assignin('base','CURRENTERP',observe_ERPDAT.CURRENTERP);
        if ~strcmp(observe_ERPDAT.CURRENTERP,CURRENTERP)
            CURRENTERP = observe_ERPDAT.CURRENTERP;
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
    end

    function allErpChanged(~,~)
        assignin('base','ALLERP',observe_ERPDAT.ALLERP);
    end


    function Count_currentERPChanged(~,~)
        S_ws_geterpset= estudioworkingmemory('selectederpstudio');
        if isempty(S_ws_geterpset)
            S_ws_geterpset = observe_ERPDAT.CURRENTERP;
            
            if isempty(S_ws_geterpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,S_ws_geterpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        S_ws_getbinchan =  estudioworkingmemory('geterpbinchan');
        
        if length(S_ws_geterpset) ==1
            Enable_minus = 'off';
            Enable_plus = 'off';
        else
            if S_ws_getbinchan.Select_index ==1
                Enable_minus = 'off';
                Enable_plus = 'on';
            elseif  S_ws_getbinchan.Select_index == length(S_ws_geterpset)
                Enable_minus = 'on';
                Enable_plus = 'off';
            else
                Enable_minus = 'on';
                Enable_plus = 'on';
            end
        end
        
        EStudio_gui_erp_totl.pageinfo_minus.Enable = Enable_minus;
        EStudio_gui_erp_totl.pageinfo_plus.Enable = Enable_plus;
        
        try
            try
                S_ws_geterpvalues =  estudioworkingmemory('geterpvalues');
                S_ws_viewer = S_ws_geterpvalues.Viewer;
            catch
                S_ws_viewer = 'off';
            end
            moption = S_ws_geterpvalues.Measure;
            latency = S_ws_geterpvalues.latency;
            if strcmp(S_ws_viewer,'on')
                if isempty(moption)
                    msgboxText = ['EStudio says: User must specify a type of measurement.'];
                    title = 'EStudio: ERP measurement tool- "Measurement type".';
                    errorfound(msgboxText, title);
                    return;
                end
                if ismember_bc2({moption}, {'instabl', 'areazt','areazp','areazn', 'nintegz'})
                    if length(latency)~=1
                        msgboxText = ['EStudio says: ' moption ' only needs 1 latency value.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    end
                else
                    if length(latency)~=2
                        msgboxText = ['EStudio says: ' moption ' needs 2 latency values.'];
                        title = 'EStudio: ERP measurement tool- "Measurement type".';
                        errorfound(msgboxText, title);
                        return;
                    else
                        if latency(1)>=latency(2)
                            msgboxText = ['For latency range, lower time limit must be on the left.\n'...
                                'Additionally, lower time limit must be at least 1/samplerate seconds lesser than the higher one.'];
                            title = 'EStudio: ERP measurement tool-Measurement window';
                            errorfound(sprintf(msgboxText), title);
                            return
                        end
                    end
                end
                f_redrawERP_mt_viewer();
            else
                f_redrawERP();
            end
            
        catch
            f_redrawERP();
        end
    end


%%------------------------Message panel------------------------------------
    function eeg_panel_change_message(~,~)
        return;
    end



% %%%Display the processing procedure for some panels (e.g., Filter)------------------------
    function Process_messg_change_main(~,~)
        if observe_ERPDAT.Process_messg==0
            return;
        end
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        Processed_Method=erpworkingmemory('f_ERP_proces_messg');
        EStudio_gui_erp_totl.Process_messg.FontSize = 14;
        if observe_ERPDAT.Process_messg ==1
            EStudio_gui_erp_totl.Process_messg.String = strcat('1- ',Processed_Method,': Running....');
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [0 0 0];
        elseif observe_ERPDAT.Process_messg==2
            EStudio_gui_erp_totl.Process_messg.String = strcat('2- ',Processed_Method,': Complete');
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [0 0.5 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
            %             pause(2);
            %             EStudio_gui_erp_totl.Process_messg.String = '';
            %             EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
        elseif observe_ERPDAT.Process_messg ==3
            EStudio_gui_erp_totl.Process_messg.String = strcat('2- ',Processed_Method,': Error');
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [1 0 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
        elseif observe_ERPDAT.Process_messg ==4
            EStudio_gui_erp_totl.Process_messg.String = strcat('Warning: ',32,Processed_Method);
            EStudio_gui_erp_totl.Process_messg.ForegroundColor = [1 0 0];
            EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[1 1 1];
        else
            
        end
        pause(0.1);
        EStudio_gui_erp_totl.Process_messg.String = '';
        EStudio_gui_erp_totl.Process_messg.BackgroundColor = ColorB_def;%[0.95 0.95 0.95];
    end

%%--------------------Function to close the toolbox------------------------
    function onExit(~,~)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ['Are you sure to quit EStudio?'];
        title = 'Exit';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Cancel','No', 'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        if strcmpi(button,'Yes')
            try
                close(EStudio_gui_erp_totl.Window);
            catch
                return;
            end
            warning('on');
        else
            return;
        end
    end

%%--------------------Setting for EStudio window size----------------------
    function EStudiowinsize(~,~)
        try
            ScreenPos =  get( groot, 'Screensize' );
        catch
            ScreenPos =  get( 0, 'Screensize' );
        end
        try
            New_pos = EStudio_gui_erp_totl.Window.Position;
        catch
            return;
        end
        try
            New_posin = erpworkingmemory('ERPWaveScreenPos');
        catch
            New_posin = [75,75];
        end
        if isempty(New_posin) ||numel(New_posin)~=2
            New_posin = [75,75];
        end
        New_posin(2) = abs(New_posin(2));
        
        app = feval('EStudio_pos_gui',New_posin);
        waitfor(app,'Finishbutton',1);
        try
            New_pos1 = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.5); %wait for app to leave
        catch
            disp('User selected Cancel');
            return;
        end
        try New_pos1(2) = abs(New_pos1(2));catch; end;
        
        if isempty(New_pos1) || numel(New_pos1)~=2
            erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        erpworkingmemory('ERPWaveScreenPos',New_pos1);
        try
            POS4 = (New_pos1(2)-New_posin(2))/100;
            new_pos =[New_pos(1),New_pos(2)-ScreenPos(4)*POS4,ScreenPos(3)*New_pos1(1)/100,ScreenPos(4)*New_pos1(2)/100];
            if new_pos(2) <  -abs(new_pos(4))%%if
                
            end
            set(EStudio_gui_erp_totl.Window, 'Position', new_pos);
        catch
            erpworkingmemory('f_EEG_proces_messg',['The defined Window Size for EStudio is invalid and it must be two numbers']);
            observe_EEGDAT.eeg_panel_message =4;
            set(EStudio_gui_erp_totl.Window, 'Position', [0 0 0.75*ScreenPos(3) 0.75*ScreenPos(4)]);
            erpworkingmemory('ERPWaveScreenPos',[75 75]);
        end
        try
            f_redrawEEG_Wave_Viewer();%%Draw EEG waves
            f_redrawERP();%%Draw ERP waves
        catch
        end
        EStudio_gui_erp_totl.context_tabs.TabSize = (new_pos(3)-20)/3;
    end

%%%%%%%%%%%%%%%%%%%%%%%
end % end of the function


%%-------------------------------------------------------------------------
%%-------------------------------borrow from eeglab------------------------
%%-------------------------------------------------------------------------

% find a function path and add path if not present
% ------------------------------------------------
function myaddpath(estudiopath, functionname, pathtoadd)

tmpp = mywhich(functionname);
tmpnewpath = [ estudiopath pathtoadd ];
if ~isempty(tmpp)
    tmpp = tmpp(1:end-length(functionname));
    if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end % remove trailing filesep
    if length(tmpp) > length(tmpnewpath), tmpp = tmpp(1:end-1); end % remove trailing filesep
    %disp([ tmpp '     ||        ' tmpnewpath '(' num2str(~strcmpi(tmpnewpath, tmpp)) ')' ]);
    if ~strcmpi(tmpnewpath, tmpp)
        warning('off', 'MATLAB:dispatcher:nameConflict');
        addpath(tmpnewpath);
        warning('on', 'MATLAB:dispatcher:nameConflict');
    end
else
    %disp([ 'Adding new path ' tmpnewpath ]);
    addpathifnotinlist(tmpnewpath);
end

end


function res = mywhich(varargin)
try
    res = which(varargin{:});
catch
    fprintf('Warning: permission error accessing %s\n', varargin{1});
end
end



function addpathifnotinlist(newpath)

comp = computer;
if strcmpi(comp(1:2), 'PC')
    newpathtest = [ newpath ';' ];
else
    newpathtest = [ newpath ':' ];
end
p = path;
ind = strfind(p, newpathtest);
if isempty(ind)
    if exist(newpath) == 7
        addpath(newpath);
    end
end

end