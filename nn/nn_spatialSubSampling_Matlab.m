function y_out = nn_spatialSubSampling_Matlab(y, kH, kW, dH, dW, maxFlag)
    [h, w, nOutputPlanes] = size(y);
    
    doMaxPooling = exist('maxFlag', 'var') && isequal(maxFlag, 1);

    h_out = floor( (h-kH)/dH ) + 1;
    w_out = floor( (w-kW)/dW ) + 1;
    
    h_idxs = arrayfun( @(i_start) i_start : i_start+kH-1,  1 : dH: h-kH+1, 'un', 0 );
    w_idxs = arrayfun( @(j_start) j_start : j_start+kW-1,  1 : dW: w-kW+1, 'un', 0 );
    
    assert(length(h_idxs) == h_out);
    assert(length(w_idxs) == w_out);
    %%
    y_out = zeros(h_out, w_out, nOutputPlanes);
    
    
    for p_i = 1:nOutputPlanes
        for i = 1:h_out
            
            for j = 1:w_out
                if doMaxPooling
                    y_out(i,j, p_i) = max(max(y(h_idxs{i}, w_idxs{j}, p_i)));
                else
                    y_out(i,j, p_i) = sum(sum(y(h_idxs{i}, w_idxs{j}, p_i)));
                end
                
            end
        end
    end
    
end