function player = create_player(handles)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    player = audioplayer(handles.mdata.x, handles.speed_modifier * handles.mdata.fs);
    is_toggled = get(handles.r_timestamps, 'Value');
    set_ticks(is_toggled, handles);
    
    to_seconds = handles.mdata.xlen_sec / handles.mdata.xlen;
    player.timerFcn = {@show_slider, player, handles.signal_plot, to_seconds};
    player.timerPeriod = 0.005;
end