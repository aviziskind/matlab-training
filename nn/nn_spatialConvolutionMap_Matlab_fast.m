function y_out = nn_spatialConvolutionMap_Matlab_fast(y, bias, weight, dH, dW, connTable)
    
    [kH, kW, nOutputPlanes] = size(weight);
    [h,w,nInputPlanes] = size(y);
    
    h_out = floor( (h-kH) / dH) +1; %% check this
    w_out = floor( (w-kW) / dW) +1; %% check this
        
    y_out = zeros(h_out, w_out, nOutputPlanes);
    
    assert(all(connTable(1,:) <= nInputPlanes));
    assert(all(connTable(2,:) <= nOutputPlanes));

    for k = 1:nOutputPlanes          % sum over all output planes
                        
            all_L = connTable(1, connTable(2,:) == k ); 
            for l = all_L  % sum over all input planes that go to this output plane
%                 c2a = conv2(y(:,:,l), weight(:,:,k,l), 'valid');
                conv_full = conv2(y(:,:,l), weight(:,:,k,l), 'full');
%                 c2 = conv_full(1:h_out, 1:w_out);
%                 3;
                
                y_out(:,:,k) = y_out(:,:,k) + bias(k) + conv_full(1:h_out, 1:w_out);

            end
    end
end