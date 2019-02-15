function ret = compute_ticks(t)

    if t <= 10
        ret = 0:t;
    elseif t <= 30
        ret = 0:5:t;
    elseif t <= 60
        ret = 0:10:t;
    else
        ret = 0:20:t;
    end     
end