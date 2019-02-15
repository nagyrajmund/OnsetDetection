function handles = process_file(hObject, handles, path)
    update_status(handles, 'Reading the file...');
    
    [handles.mdata.x, handles.mdata.fs] = audioread(path);
    handles.mdata.x         = handles.mdata.x(:, 1);    %get first channel

    guidata(hObject, handles);
    update_status(handles, 'Starting onset detection...');
    
    handles.mdata                   = detect_onsets(handles);
    
    handles.player                  = create_player(handles);
    
    handles.state.analysis_is_done  = true;
    guidata(hObject, handles);
    show_analysis_buttons(handles);
    show_player_buttons(handles);
end
