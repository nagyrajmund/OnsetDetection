  function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help gui
%
% Last Modified by GUIDE v2.5 26-Dec-2018 02:35:35

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @gui_OpeningFcn, ...
        'gui_OutputFcn',  @gui_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT
end

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(~, ~, ~)
end

function s_playbackspeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_playbackspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end
% ------------------------ END  ------------------------

% ------------------------ OPENING FUNCTION ------------------------

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)
    addpath('algo', '-end');
    addpath('state', '-end');
    % workaround to set screen size as there's no documented way
    % of setting the window to full screen by default
    windowsize = get(0,'ScreenSize') - [0, 0, 100, 200];
    set(gcf, 'Units', 'Pixels', 'Position', windowsize);
    
    handles.output         = hObject; %choose default command line output
    handles.mdata          = struct;
    handles.signal_plot    = findobj('Tag', 'signal_plot');
    handles.df_plot        = findobj('Tag', 'df_plot');
    handles.speed_modifier = 1;
    handles.f_mdata        = 'mdata.dat';
    handles.f_preferences  = 'params.mat';

    handles.state.signal_is_shown           = false;
    handles.state.df_is_shown               = false;
    handles.state.signal_onsets_is_shown    = false;
    handles.state.df_onsets_is_shown        = false;
    handles.state.analysis_is_done          = false;
    handles.state.threshold_is_shown        = false;

    set(handles.df_plot, 'ytick', []);
    set(handles.df_plot, 'xtick', []);
    
    set(handles.signal_plot, 'ytick', []);
    set(handles.signal_plot, 'xtick', []);
    
    h = zoom;
    h.Motion = 'horizontal';
    
    
    if exist(handles.f_preferences, 'file')
        handles.opt                 = load(handles.f_preferences);
        disp('Loaded');
    else
        handles.opt.nfft            = 4096;
        handles.opt.wlen_ms         = 20;
        handles.opt.overlap_pct     = 75;
        handles.opt.minpeakdist_ms  = 50;
        handles.opt.thr_maxk        = 15;
        handles.opt.thr_div         = 6;
    end
    
    guidata(hObject, handles);

    options = {'NFFT', 'WLEN', 'OVERLAP', 'MINPEAKDIST', 'THR_MAXK', 'THR_DIV'};
    set(handles.optionlist, 'String', sprintf('%s\n', options{:}));

    update_option_values(handles);
    update_status(handles, 'Welcome! Open a file to begin.');

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure);
end

% ------------------------ END  ------------------------

% ------------------------ AUDIO PLAYER CALLBACKS ------------------------

% --- Executes on button press in b_play.
function b_play_Callback(~, ~, handles)
% hObject    handle to b_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.state.signal_is_shown || handles.state.signal_onsets_is_shown
        resume(handles.player);
        update_status(handles, 'Audio player state: Playing');
    else
        update_status(handles, 'Signal or its onsets have to be displayed for the audio player!');
    end
end

% --- Executes on button press in b_pause.
function b_pause_Callback(~, ~, handles)
% hObject    handle to b_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.state.signal_is_shown || handles.state.signal_onsets_is_shown
        pause(handles.player);
        update_status(handles, 'Audio player state: Paused');
    else
        update_status(handles, 'Signal or its onsets have to be displayed for the audio player!');
    end
end

% --- Executes on button press in b_stop.
function b_stop_Callback(hObject, eventdata, handles)
% hObject    handle to b_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.state.signal_is_shown || handles.state.signal_onsets_is_shown
        stop(handles.player);
        show_slider(0,0,handles.player, handles.signal_plot, 0);
        update_status(handles, 'Audio player state: Stopped');
    else
        update_status(handles, 'Signal or its onsets have to be displayed for the audio player!');
    end
end

% --- Executes on slider movement.
function s_playbackspeed_Callback(hObject, eventdata, handles)
% hObject    handle to s_playbackspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles.speed_modifier = (get(hObject,'Value') + 0.5) * (get(hObject,'Value') + 0.5);

    change.SampleRate = handles.speed_modifier * handles.mdata.fs;
    set(handles.player,change);
    set(handles.t_playbackspeed, 'String', sprintf('Playback speed: %.2fx', handles.speed_modifier));

    guidata(hObject, handles);  
end

% --- Executes on button press in b_reset_playback_speed.
function b_reset_playback_speed_Callback(hObject, eventdata, handles)
% hObject    handle to b_reset_playback_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.s_playbackspeed, 'Value', 0.5);
    s_playbackspeed_Callback(handles.s_playbackspeed, eventdata, handles);
end

% ------------------------ END  ------------------------

% ------------------------ RESULT PLOTTING CALLBACKS ------------------------

% --- Executes on button press in b_showdf.
function b_showdf_Callback(hObject, eventdata, handles)
% hObject    handle to b_showdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ~handles.state.df_is_shown
        m = handles.mdata;
        ylim = get(gca, 'YLim');
        scale = ylim(2) / (max(abs(m.df))); 
        
        axes(handles.df_plot);
        plot(m.time,m.df*scale,'r');
        axes(handles.signal_plot);
        handles.state.df_is_shown = true;
        guidata(hObject, handles);
        handles.mdata
        handles.opt
        handles.state
        disp('this is temporary in showdf')
    else
        update_status(handles, 'The detection function is already shown!');
    end
end

% --- Executes on button press in b_showplot.
function b_showsignal_Callback(hObject, eventdata, handles)
% hObject    handle to b_showplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ~handles.state.signal_is_shown
        update_status(handles, 'Plotting the signal...');
        axes(handles.signal_plot);
        
       	m = handles.mdata;
        
        xlim = get(gca, 'XLim');
        ylim = get(gca, 'YLim');
        scale = ylim(2) / (2 * max(abs(m.x)));
        
        timestamps_on = get(handles.r_timestamps, 'Value');
        set_ticks(timestamps_on, handles);
        t = 1:m.xlen;
        plot(t / m.xlen * m.xlen_sec, m.x * scale + ylim(2)/2, 'Color', [0.3,0.3,0.3]);
        plot(xlim, [0.5, 0.5], 'Color', [0,0,0]);
        
        handles.state.signal_is_shown = true;
        guidata(hObject, handles);
    else
        update_status(handles, 'The signal is already shown!');
    end

end
% --- Executes on button press in b_clear.
function b_clear_Callback(hObject, eventdata, handles)
% hObject    handle to b_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    b_stop_Callback(hObject, eventdata, handles);
    handles = clear_plots(handles);
    guidata(hObject, handles);
end

% --- Executes on button press in r_timestamps.
function r_timestamps_Callback(hObject, eventdata, handles)
% hObject    handle to r_timestamps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of r_timestamps
    is_toggled = get(hObject, 'Value');    
    set_ticks(is_toggled, handles);
end

% --- Executes on button press in b_set_threshold.
function b_clear_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to b_set_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.mdata.loc_thresholded = handles.mdata.loc;
    delete_color(gca, 'r');
    update_status(handles, 'Threshold cleared!');

    guidata(hObject, handles);
end

% ------------------------ END ------------------------

% ------------------------ MENU CALLBACKS ------------------------

function m_saveresults_Callback(hObject, eventdata, handles)
% hObject    handle to m_saveresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structur1e with handles and user data (see GUIDATA)
    if ~handles.state.analysis_is_done
        update_status(handles, 'There are no available results yet, cannot save!');
        return
    end
    
    filter = {'*.mat'};
    [file, ~] = uiputfile(filter);
    
    if file == 0
        return;
    end
    
    [~,~, extension] = fileparts(fullfile(path, file));
    if ~strcmp(extension,'.mat')
        update_status(handles, sprintf('Invalid file extension: %s', file));
        return
    end
    
    update_status(handles, sprintf('Saving analysis results to %s...', file));
    
    mdata = handles.mdata;
    save(file, 'mdata');
    
    update_status(handles, sprintf('Saved analysis results to %s!', file));
end

function m_loadresults_Callback(hObject, eventdata, handles)
% hObject    handle to m_loadresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %clear;
    update_status(handles, 'Choosing result file to load...');

    filter = {'*.mat'};
    [file, path] = uigetfile(filter);
    
    if file == 0
        return;
    end
    
    [~,~, extension] = fileparts(fullfile(path, file));
    if ~strcmp(extension,'.mat')
        update_status(handles, sprintf('Invalid file extension: %s', file));
        return
    end
   
    update_status(handles, sprintf('Loading analysis results from %s...', file));
        
    temp = load(file);
    if ~isfield(temp, 'mdata')
        update_status(handles, sprintf('%s contains no analysis data!', file));
        return;
    else
        handles.mdata = temp.mdata;
        set(handles.t_input_name, 'String', sprintf('Working with result file %s', file));
    end
    
    stop_player(handles);
    handles = clear_plots(handles);
    
    handles.player = create_player(handles);
   
    if ~handles.state.analysis_is_done
        show_analysis_buttons(handles);
        show_player_buttons(handles);
        handles.state.analysis_is_done = true;
    end
        
    update_status(handles, 'Succesfully loaded analysis results!');
    guidata(hObject,handles);
end

function stop_player(handles)
    if handles.state.signal_is_shown || handles.state.signal_onsets_is_shown
        stop(handles.player);
        show_slider(0,0,handles.player, handles.signal_plot, 0);
    end
end

function m_openfile_Callback(hObject, eventdata, handles)
% hObject    handle to m_openfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if handles.state.analysis_is_done
        handles.player.pause();
    end
    
    origstatus = get(handles.t_status, 'String');
    update_status(handles, 'Opening a file...');
    
    [filename, path] = uigetfile({'*.wav;*.flac;*.mp3' 'Sound files';'*.*' 'All files'});
    
    if isequal(filename,0)
        update_status(handles, origstatus);
        return;
    end
    
    handles.path = fullfile(path, filename);
    set(handles.t_input_name, 'String', sprintf('Currently open: %s', filename));
     
    %reset axes
    b_clear_Callback(hObject, 0, handles);
 
    %process the file and start analysis
    handles = process_file(hObject, handles, handles.path);

    set(handles.signal_plot, 'xtick', []);
    handles.state.signal_is_shown = false;
    handles.state.signal_onsets_is_shown = false;
    handles.state.df_is_shown = false;
    handles.state.df_onsets_is_shown = false;

    guidata(hObject, handles);
end

function m_preferences_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)    
    update_status(handles, 'Setting preferences...');
    
    prompt  = ...
    {
        'Number of FFT points:',     ...
        'Window length in ms:',      ...
        'Window overlap percentage', ...
        'Minimum peak distance',     ...
        'T_maxk',                    ...
        'T_div'
    };
    
    values = ...
    {
        handles.opt.nfft,           ...
        handles.opt.wlen_ms,        ...
        handles.opt.overlap_pct,    ...
        handles.opt.minpeakdist_ms, ...
        handles.opt.thr_maxk,       ...
        handles.opt.thr_div;        ...
    };

    default          = cellfun(@num2str, values, 'UniformOutput',false);
    opts.WindowStyle = 'modal';
    opts.Resize      = 'On';
    settings         = double(str2double(inputdlg(prompt,'', [1,30], default, opts)));
    
    if isempty(settings) 
        update_status(handles, 'Dialog closed.');
        return;
    else
        for i = 1:length(settings)
            if settings(i) <= 0
                settings(i) = values{i};
            end
        end
    end
    
    handles.opt = set_preferences(handles, settings); 
    update_option_values(handles);
    
    if handles.state.analysis_is_done 
        %if a file has already been loaded, perform the analysis
        process_file(hObject, handles, handles.path);
    else
        update_status(handles, 'Succesfully updated the preferences!');
    end
    
end

function show_onsets(hObject, eventdata, handles, is_signal)
% hObject    handle to b_show_signal_onsets 
%                   or b_show_df_onsets  (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% is_signal  a boolean variable indicating whether 
%            the top button was clicked or not
    if is_signal
        axes(handles.signal_plot);
        handles.state.signal_onsets_is_shown = true;
    else
        axes(handles.df_plot);
        handles.state.df_onsets_is_shown     = true;
    end
    
    guidata(hObject, handles);
    update_status(handles, 'Removing old onsets...');
    
    old_marker = findobj(gca, 'Color', 'b');
    delete(old_marker);
    
    update_status(handles, 'Plotting new onsets...');

    ylim = get(gca, 'YLim');
    for x = handles.mdata.loc_thresholded
        plot([x, x], ylim, 'b', handles.mdata.time(end), 0);
    end
    
	set_visibility(handles.r_timestamps, 'On');
    update_status(handles, 'Onsets were successfully plotted!');

    axes(handles.signal_plot); %reset to axes to signal_plot
end

function set_threshold(hObject, eventdata, handles)
    if ~handles.state.signal_is_shown
        update_status(handles, 'The signal must be plotted first in order to set threshold!');
        return;
    end
    
    [~,y] = ginput(1);
    delete_color(gca, 'r');
    
    update_status(handles, 'Calculating threshold...');
    if y < 0.5
        handles.opt.threshold = abs(handles.mdata.x_min) * (0.5 - y)*2;
    else
        handles.opt.threshold = handles.mdata.x_max * (y - 0.5) * 2;
    end
    
    handles.threshold_y = y;
    plot(get(gca, 'XLim'), [y,y], 'r');
    plot(get(gca, 'XLim'), [1-y, 1-y], 'r');
    
    set(handles.t_threshold, 'String', sprintf('Threshold: %.2f %', y));
     
    X = handles.mdata.loc_x(handles.mdata.loc_indices);
    
    handles.mdata.loc_thresholded ...
        = handles.mdata.loc(find(X >= handles.opt.threshold)); 
    
    show_onsets(hObject, eventdata, handles, true);
    
    guidata(hObject, handles);
end