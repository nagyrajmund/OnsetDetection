function I = maxk_ind(A,k)
    [~, temp] = sort(A, 'descend');
    I = temp(1:k);
end