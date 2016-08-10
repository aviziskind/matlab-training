function Y = nn_SpatialDivisiveNormalization(X, kernel_arg, threshold)
    if ~isa(X, 'float')
        X = single(X);
    end

    if nargin < 2
        kernel_arg = 7;
    end
    
    if nargin < 3
        threshold = 0.4;
    end
    
    
    if isscalar(kernel_arg)
        kernel_size = kernel_arg;
        k_x = image_gaussian1D(kernel_size);
    elseif isvector(kernel_arg)
        k_x = kernel_arg;
    end
    
    if nargin < 3
        threshold = 0.4;
    end
    
    k_x = k_x/sum(k_x);

    coef = nn_estimate_mean(ones(size(X)), k_x);

    localstds = nn_estimate_std(X, k_x);
    adjustedstds = localstds ./ coef;
    thresholdedstds = applyThreshold(adjustedstds, threshold);
    
    Y = X ./ thresholdedstds;
   
end

% 
% function Y = estimate_mean(X, kx)
%     kernel_size = length(kx);
%     pad_size = (kernel_size-1)/2;
% 
%     y1 = padarray(X, [pad_size pad_size], 0, 'both');
%     y2 = conv2(y1, kx, 'valid');
%     Y  = conv2(y2, kx', 'valid');
% end


function Y = nn_estimate_std(X, kx)
    Y = sqrt( nn_estimate_mean( X.^2, kx ) );
end

function X = applyThreshold(X, th)
    X(X < th) = th;
end