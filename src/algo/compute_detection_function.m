function [difflog, time, energy, loc_x] = compute_detection_function(handles, x, wlen, hop, nfft, fs)
%Calculate onset detection function and its time vector
%using linear regression.
%
%Input parameters:      x    - the music signal
%                       wlen - window length in frames
%                       hop  - hop size in frames
%                       nfft - number of fft points
%                       fs   - file sampling rate in Hz
%
%Output parameters:     difflog - the detection function
%                       time    - the corresponding time vector
    xlen    = length(x);
    win     = hamming(wlen, 'periodic');
    rown    = ceil(nfft/2);
    coln    = floor((xlen-wlen)/hop); 
    energy  = zeros(1, coln);
    index   = uint32(1);
    %the maximum signal values in the peak location windows
    loc_x   = zeros(1, coln);
    
    % We will update the user four times to give a sense of progress
    % The loop is broken up this way because updating the status in every
    % iteration significantly slows the process down
    F = floor(coln/4);
    
    update_status(handles, 'Transforming the signal... ([ ] [ ] [ ] [ ])');
    for col = 1:F
        xw = x(index:index+wlen-1).*win; 
        X  = fft(xw, nfft);
        energy(col) = sum(abs(X(1:rown)));
        loc_x(col) = max(abs(x(index:index+wlen-1)));
        index = index + hop;
    end
    update_status(handles, 'Transforming the signal... ([X] [ ] [ ] [ ])');
    
    for col = F+1:2*F
        xw = x(index:index+wlen-1).*win; 
        X  = fft(xw, nfft);
        energy(col) = sum(abs(X(1:rown)));
        loc_x(col) = max(abs(x(index:index+wlen-1)));
        index = index + hop;
    end
    update_status(handles, 'Transforming the signal... ([X] [X] [ ] [ ])');
    
    for col = 2*F+1:3*F
        xw = x(index:index+wlen-1).*win; 
        X  = fft(xw, nfft);
        energy(col) = sum(abs(X(1:rown)));
        loc_x(col) = max(abs(x(index:index+wlen-1)));
        index = index + hop;
    end
    update_status(handles, 'Transforming the signal... ([X] [X] [X] [ ])');
    
    for col = 3*F+1:coln
        xw = x(index:index+wlen-1).*win; 
        X  = fft(xw, nfft);
        energy(col) = sum(abs(X(1:rown)));
        loc_x(col) = max(abs(x(index:index+wlen-1)));
        index = index + hop;
    end
    update_status(handles, 'Transforming the signal... ([X] [X] [X] [X])');
    
    diff    = zeros(1, coln);
    difflog = zeros(1, coln);
    %square the energy in order to gain the envelope
    %energy = energy.*energy;
    energy(energy<0.1) = 0.1; %avoid division by zero
    for i = 2:coln-1
        diff(i)    = (energy(i+1) - energy(i-1)) / 3;
        difflog(i) = diff(i)/energy(i);        
    end
    
    %the time of each value will be the middle of its window
    time = (double(wlen)/2:double(hop):double(wlen)/2 + double(coln)*double(hop)-1) / double(fs);
  
end