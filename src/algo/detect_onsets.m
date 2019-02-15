function mdata = detect_onsets(handles)
    update_status(handles, 'Initializing...');
    
    % set user-given variables
    NFFT            = handles.opt.nfft;
    WLEN_MS         = handles.opt.wlen_ms;
    OVERLAP         = (0.01 * double(handles.opt.overlap_pct));
    MINPEAKDIST_MS  = handles.opt.minpeakdist_ms;

    % sampling rate
    fs              = handles.mdata.fs;
    % compute the window length and pad the signal accordingly
    [wlen, hop]     = compute_wlen(length(handles.mdata.x), fs, WLEN_MS, OVERLAP);
    
    % we only store the length after padding - this will not be the 
    % original length of the audio file but the difference is negligible
    x               = pad_signal(handles.mdata.x, hop);
    xlen            = length(x);
    xlen_sec        = length(x) / fs;
    
    update_status(handles, 'Transforming the signal...');
     
    [detfunc, time, energy, loc_x] = compute_detection_function(handles, x, wlen, hop, NFFT, fs);

    update_status(handles, 'Thresholding...');
    
    detfunc         = apply_threshold(detfunc, hop, handles.opt.thr_maxk, handles.opt.thr_div);
    
    update_status(handles, 'Picking the peaks...');
    drawnow();
    
    minpeakdist     = MINPEAKDIST_MS * length(detfunc) / (xlen_sec * 1000);    
    [peaks, loc]      = findpeaks(detfunc, 'MinPeakDistance', minpeakdist);
    
    update_status(handles, 'Finishing up...');
    drawnow();
    
    mdata.x         = x;
    mdata.xlen_sec  = xlen_sec;
    mdata.xlen      = xlen;
    mdata.fs        = fs;
    mdata.peaks     = peaks;
    mdata.loc       = loc / length(detfunc) * xlen_sec;
    mdata.df        = detfunc;
    mdata.time      = time;
    mdata.energy    = energy;
    mdata.ticks     = compute_ticks(xlen_sec);
    mdata.x_max     = max(x);
    mdata.x_min     = min(x);

    mdata.loc_indices  = loc;
    mdata.loc_x        = loc_x;
        
    %we keep the original locations in mdata.loc
    %whenever we adjust the user-defined threshold, 
    %it will be applied to mdata.loc and the result is stored in
    %loc_thresholded
    mdata.loc_thresholded = mdata.loc; 
    
    statusmsg = 'Analysis complete! Results can be saved now,';
    update_status(handles, sprintf('%s\nor you can open a new file for analyzation.', statusmsg));
end
