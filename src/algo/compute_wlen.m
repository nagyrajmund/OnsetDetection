function [ wlen, hop ] = compute_wlen( xlen, fs, frame_ms, overlap )
%Determine window length and hop size in frames.
%
%Input parameters:     xlen           - length of signal
%                      fs             - sampling rate
%                      frame_ms       - desired window length in ms
%                      overlap        - overlap 
%
%Output parameters:    wlen           - window length in frames
%                      hop            - hop size in frames

%TODO: input check
time_ms = 1000 * double(xlen / fs);
wlen = xlen / (time_ms / frame_ms);
hop  = wlen * (1-overlap);

wlen = 2^nextpow2(wlen);  % round up to next power of two
hop  = 2^nextpow2(hop);   % round up to next power of two

end

