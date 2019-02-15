function f = apply_threshold(f, hop, k, div)
%Apply a threshold to the function in order to 
%remove insignificant peaks
%
%Input parameters:      f    - the function
%                       hop  - hop size in frames
%						k    - the amount of peaks to select for reference
%						div  - the divisor in the algorithm
%Output parameters:     f    - the thresholded function

    ind   = maxk_ind(f,k);  
    avg   = movmedian(f,hop);
    delta = mean(f(ind) - avg(ind));
    
    f(f < avg + delta/double(div)) = 0;
end

