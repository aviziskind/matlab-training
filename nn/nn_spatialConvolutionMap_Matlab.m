function y_out = nn_spatialConvolutionMap_Matlab_slow(y, bias, weight, dH, dW, connTable)
    
    [kH, kW, nOutputPlanes] = size(weight);
    useMatlabConv = dH == 1 && dW == 1 && 0;
    
    h_out = floor( (size(y, 1)-kH) / dH) +1; %% check this
    w_out = floor( (size(y, 2)-kW) / dW) +1; %% check this
    
    
    y_out = zeros(h_out, w_out, nOutputPlanes);
    
%     if useMatlabConv
%         for ci = 1:size(connTable,2)
%             p_from = connTable(1,ci);
%             p_to = connTable(2,ci);
%                         
%             y_out(:,:,p_to) = y_out(:,:,p_to) + bias(p_to) + conv2(y(:,:,p_from), weight(:,:,p_to), 'valid');
%         end
        
        
%     else
%         for ci = 1:size(connTable,2)
%             p_from = connTable(1,ci);
%             p_to = connTable(2,ci);
            
            y_out = zeros(h_out, w_out, nOutputPlanes);

            for k = 1:nOutputPlanes          % sum over all output planes
                        
                all_L = connTable(1, connTable(2,:) == k ); 
                for l = all_L  % sum over all input planes that go to this output plane

                    y_out(:,:,k) = y_out(:,:,k) + bias(k) + conv2(y(:,:,l), weight(:,:,k,l), 'valid');
                    
                    
%                     for i = 1:h_out     % sum over x,y positions of outputs
%                         for j = 1:w_out
% 
% 
%                             weight_conv_input = 0;
%                             for s = 1:kW  % convolution sum
%                                 for t = 1:kH
%                                     weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dW*(i-1)+s, dH*(j-1)+t, l );
%                                 end
%                             end
%                             y_out(i,j,k) = y_out(i,j,k) + bias(k) + weight_conv_input;
%                         end
%                     end
                    
                    
                end
            end


            y_out1 = zeros(h_out, w_out, nOutputPlanes);

            for i = 1:h_out     % sum over x,y positions of outputs
                for j = 1:w_out
                    for k = 1:nOutputPlanes          % sum over all output planes
                        
                        all_L = connTable(1, connTable(2,:) == k ); 
                        for l = all_L  % sum over all input planes that go to this output plane
                        
                            weight_conv_input = 0;
                            for s = 1:kH  % convolution sum
                                for t = 1:kW
                                    weight_conv_input = weight_conv_input + weight(s,t, k,l) * y( dH*(i-1)+s, dW*(j-1)+t, l );
                                end
                            end
                            y_out1(i,j,k) = y_out1(i,j,k) + bias(k) + weight_conv_input;
                        end
                        
                    end
                end
            end
            
            
            y_out2 = zeros(h_out, w_out, nOutputPlanes);

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
                            y_out2(i,j,k) = y_out2(i,j,k) + bias(k) + weight_conv_input;
                        end
                        
                    end
                end
            end

            assert(isequal(y_out1, y_out2));
            
            
%         assert(isequal(y_out, y_out1));
            
            
           y_out3  = nn_spatialConvolutionMap_c(double(y), bias, weight, dH, dW, connTable);
           
        
        assert(isequal(y_out, y_out3));
        
%     end
    3;
    
        
end