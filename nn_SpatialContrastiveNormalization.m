function Y = nn_SpatialContrastiveNormalization(X, kernel_arg, threshold)
    if ~isa(X, 'float')
        X = single(X);
    end

    if nargin < 2
        kernel_arg = 7;
    end
    
    if nargin < 3
        threshold = 0.4;
    end

    if isscalar(kernel_arg) && ~odd(kernel_arg)
        error('Kernel size should be an odd number')
    end
    
    Y1 = nn_SpatialSubtractiveNormalization(X, kernel_arg);
    Y = nn_SpatialDivisiveNormalization(Y1, kernel_arg, threshold);
end