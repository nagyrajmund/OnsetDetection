function set_ticks(is_toggled, handles)
    axes(handles.signal_plot);        
    if is_toggled
        set(gca, 'xtick', handles.mdata.loc_thresholded);
        xtickformat('%.1f');
        xtickangle(90);
    else
        set(gca, 'xtick', handles.mdata.ticks);
        xtickformat('%.0f');
        xtickangle(0);
    end
end