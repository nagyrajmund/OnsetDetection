function handles = clear_plots(handles)
    cla(handles.df_plot);
    handles.state.df_is_shown               = false;
    handles.state.df_onsets_is_shown        = false;

    cla(handles.signal_plot);
    set(handles.signal_plot, 'XTick', []);
    
    handles.state.signal_is_shown           = false;
    handles.state.signal_onsets_is_shown    = false;
    
    update_status(handles, 'Plots cleared!');
    set_visibility(handles.r_timestamps, 'Off');
end