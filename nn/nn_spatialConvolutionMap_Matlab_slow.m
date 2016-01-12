function y_out = nn_spatialConvolutionMap_Matlab_slow(y, bias, weight, dH, dW, connTable)
    
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

            for i = 1:h_out     % sum over x,y positions of outputs
                for j = 1:w_out

                    weight_conv_input = 0;
                    for s = 1:kH  % convolution sum
                        for t = 1:kW
                            weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                        end
                    end
                    y_out(i,j,k) = y_out(i,j,k) + bias(k) + weight_conv_input;
                end

            end
        end
    end

    
        
end