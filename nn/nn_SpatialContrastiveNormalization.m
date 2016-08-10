function Y = nn_SpatialContrastiveNormalization(X, kernel_arg, threshold, doCircular)
    if ~isa(X, 'float')
        X = single(X);
    end

    if nargin < 2
        kernel_arg = 7;
    end
    
    if nargin < 3
        threshold = 0.4;
    end

    if nargin < 4
        doCircular = 0;
    end
    
    if isscalar(kernel_arg) && ~odd(kernel_arg)
        error('Kernel size should be an odd number')
    end
    
    
    if isscalar(kernel_arg)
        nk = kernel_arg;
    else
        nk = length(kernel_arg);
    end
    
    
    if doCircular      
        [X, idx_central] = circPad(X, nk);
    end

    
    Y1 = nn_SpatialSubtractiveNormalization(X, kernel_arg);
    Y = nn_SpatialDivisiveNormalization(Y1, kernel_arg, threshold);
     
    
        
    if doCircular
        if 0
            %%
            figure(8); clf; hold on;
            plot(Y(idx_use), 'b.-')
            plot(nX-pad_n+1 : nX,  Y(1:pad_n), 'ro-')
            plot(1:pad_n, Y(end-pad_n+[1:pad_n]), 'ro-')
            %%
            figure(9); clf;
            plot( log10(abs(Y(idx_use(1:pad_n))-Y(end-pad_n+[1:pad_n]) )), 'b.-');
            %                 plot(1:pad_n, ), 'ro-')
            
            
        end
        Y = Y(idx_central{:}); 
    end
        
    
    
end