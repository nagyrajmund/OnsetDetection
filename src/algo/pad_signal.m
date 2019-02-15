function x = pad_signal(x, hop)
    pad_len = double(int32(hop - rem(length(x), hop)));
    x = padarray(x, pad_len);
end