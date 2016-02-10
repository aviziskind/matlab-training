function y_out = nn_spatialConvolution_Matlab(y, bias, weight, dH, dW)
    
    weight_orig = weight;
    
    
%     bias(:) = 0;
    
    [kH, kW, nInputPlanes, nOutputPlanes] = size(weight);
    useMatlabConv = dH == 1 && dW == 1 && 0;
    [yH, yW, nInputPlanes2] = size(y);
    assert(nInputPlanes == nInputPlanes2);
    
    h_out = floor( ( yH-kH) / dH) +1; %% check this
    w_out = floor( ( yW-kW) / dW) +1; %% check this
    
%     y_out = zeros(h_out, w_out, nOutputPlanes);
    
        
    doCheck_slow1 = false;
    doCheck_slow2 = false;
    doCheck_c = true;
        
%     else
%         for ci = 1:size(connTable,2)
%             p_from = connTable(1,ci);
%             p_to = connTable(2,ci);
            %%
    y_out = zeros(h_out, w_out, nOutputPlanes, class(y));

    weight_flipped = flip(flip(weight,1),2);
    for k = 1:nOutputPlanes          % iterate over all output planes

        y_out(:,:,k) = bias(k);
            % sum over all input planes
%                 all_L = connTable(1, connTable(2,:) == k ); 
        for l = 1:nInputPlanes % sum over all input planes that go to this output plane

            y_out(:,:,k) = y_out(:,:,k) + conv2(y(:,:,l), weight_flipped(:,:,l,k), 'valid');
%             y_out(:,:,k) = conv2(y(:,:,l), weight_flipped(:,:,l,k), 'valid');

        end
        
%         y_out(:,:,k) = y_out(:,:,k) + bias(k) + y_out(:,:,k);
    end

    
    if doCheck_slow1
%%
        y_out1 = zeros(h_out, w_out, nOutputPlanes);

        for i = 1:h_out     % sum over x,y positions of outputs
            for j = 1:w_out
                for k = 1:nOutputPlanes          % sum over all output planes
                    y_out1(i,j,k) = bias(k);
                    for l = 1:nInputPlanes % sum over all input planes that go to this output plane

                        weight_conv_input = 0;
                        for s = 1:kH  % convolution sum
                            for t = 1:kW
                                weight_conv_input = weight_conv_input + weight(s,t, l,k) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                            end
                        end
                        y_out1(i,j,k) = y_out1(i,j,k) + weight_conv_input;
                    end

                end
            end
        end
        
        assert(isequalToPrecision(y_out, y_out1, 1e-4))
%         assert(isequal(y_out, y_out1));
    end
    
    if doCheck_slow2
            %%
        y_out2 = zeros(h_out, w_out, nOutputPlanes);

        for k = 1:nOutputPlanes          % sum over all output planes
            y_out2(:,:,k) = bias(k);
%                 all_L = connTable(1, connTable(2,:) == k );
            for l = 1:nInputPlanes % sum over all input planes that go to this output plane

                for i = 1:h_out     % sum over x,y positions of outputs
                    for j = 1:w_out

                        weight_conv_input = 0;
                        for s = 1:kH  % convolution sum
                            for t = 1:kW
                                weight_conv_input = weight_conv_input + weight(s,t,l,k) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                            end
                        end
                        y_out2(i,j,k) = y_out2(i,j,k) + weight_conv_input;
                    end

                end
            end
        end

        assert(isequalToPrecision(y_out, y_out2, 1e-4))
        
    end
    

%             %%
%              y_out4 = zeros(h_out, w_out, nOutputPlanes);
%              kW_x_kH = kW*kH;
%              kW_x_kH_x_nInputPlanes = kW*kH*nInputPlanes;
% %              [h,w] = size(weight)
%              count = 0;
%              for k = 0 : nOutputPlanes-1 
%                 for l = 0 : nInputPlanes-1
% 
%                     for i = 0 : h_out-1
%                         for j = 0 : w_out-1
% 
%                             weight_conv_input = 0;
% 
%                             for s = 0 : kH-1
%                                 for t = 0 : kW-1
%                                     % // weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
%                                     a = weight(s + t*kH + k* kW*kH + l * kW_x_kH_x_nInputPlanes +1);
%                                         b = y( yH*i+s + (dH*j+t)*kH + l*kH*kW +1 );
%                                     weight_conv_input = weight_conv_input + a* b;
%                                                               
%                                                           
%                                   if (count == 0) 
%                                       fprintf('%.4f x %.4f -> %.4f : %.4f\n', a,b, a*b, weight_conv_input);
%                                   end
% 
%                                                           
%                                 end
%                             end
% 
%                             %// y_out(i,j,k) = y_out(i,j,k) + bias(k) + weight_conv_input;    
%                             y_out4(i + j*h_out + k*h_out*w_out  +1) = ... 
%                             y_out4(i + j*h_out + k*h_out*w_out  +1) +  bias(k +1) + weight_conv_input;
%                               if (count == 0) 
%                                   fprintf(' + %.4f --> %.4f \n', bias(k +1), y_out4(i + j*h_out + k*h_out*w_out  +1) );
%                                   count = 1;
%                               end
% 
%                         end
%                     end
% 
%                 end
%              end
            %%
            
            
%         assert(isequal(y_out, y_out1));

    if doCheck_c            
        %%
           y_out3  = nn_spatialConvolution_c(single(y), bias, weight, dH, dW); 
%            y_out3_switched  = nn_spatialConvolution_c(single(y), bias, permute(weight, dH, dW); 
%            y_out3_switched  = nn_spatialConvolution_c(single(y), bias, permute(weight, [2 1 3 4]), dH, dW);
           
        
        assert(isequalToPrecision(y_out, y_out3, 1e-4));
        
    end
        
%     end
    3;
    
        
end