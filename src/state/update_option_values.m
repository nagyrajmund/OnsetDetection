function update_option_values(handles)
    values = ...
        {
        handles.opt.nfft,           ...
        handles.opt.wlen_ms,        ...
        handles.opt.overlap_pct,    ...
        handles.opt.minpeakdist_ms, ...
        handles.opt.thr_maxk,       ...
        handles.opt.thr_div;        ...
        '',' ms', '%','','',''      ...
        };
    
    label = sprintf('%d%s\n',values{:});
    set(handles.t_optionvalues, 'String', label);
end