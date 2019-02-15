function options = set_preferences(handles, settings) 
    
    options.nfft = uint32(settings(1));
    options.wlen_ms = uint32(settings(2));
    options.overlap_pct = uint32(settings(3));
    options.minpeakdist_ms = uint32(settings(4));
    options.thr_maxk = uint32(settings(5));
    options.thr_div = uint32(settings(6));
    
    save(handles.f_preferences,'-struct','options');
end