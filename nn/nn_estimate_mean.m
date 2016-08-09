function Y = nn_estimate_mean(X, kx)
    kernel_size = length(kx);
    pad_size = (kernel_size-1)/2;

    if isvector(X)
        y1 = padarray(X(:), pad_size, 0, 'both');
        Y = conv2(y1(:), kx(:), 'valid');
        if isrow(X)
            Y = Y';
        end
        
    elseif ismatrix(X)
        y1 = padarray(X, [pad_size pad_size], 0, 'both');
        y2 = conv2(y1, kx, 'valid');
        Y  = conv2(y2, kx', 'valid');
    end
end

