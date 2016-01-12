function y =  nn_forward(model, input, nModulesMax)
       
    nModules = model.nModules;
    if nargin >= 3    
        nModules_use = min(nModules, nModulesMax);
    else
        nModules_use = nModules;
    end 

    
    y = input;
    for mod_i = 1:nModules_use
        m = model.modules{mod_i};
        switch m.type
            
            case 'SpatialConvolution',
                assert(size(y, 3) == m.nInputPlane);
                assert(isequal(size(m.weight), [m.kH, m.kW, m.nInputPlane m.nOutputPlane]))
                y = nn_spatialConvolution(y, m.bias, m.weight, m.dH, m.dW);

            case 'SpatialConvolutionMap',
                assert(size(y, 3) == m.nInputPlane);
                assert(isequal(size(m.weight), [m.kH, m.kW, m.nOutputPlane]))
                y = nn_spatialConvolutionMap(y, m.bias, m.weight, m.dH, m.dW, m.connTable);
                
                
%                 module_field_names = {'bias', 'weight', 'nInputPlane', 'nOutputPlane', 'kH', 'kW', 'dH', 'dW', 'connTable'};
                
            case 'SpatialSubSampling',
%                 module_field_names = {'kH', 'kW', 'dH', 'dW'};
                y = nn_spatialSubSampling(y, m.kH, m.kW, m.dH, m.dW);
                
            case 'SpatialMaxPooling', 
%                 module_field_names = {'kH', 'kW', 'dH', 'dW', 'indices'};
                y = nn_spatialSubSampling(y, m.kH, m.kW, m.dH, m.dW, 1);
                
            case 'Linear',
%                 module_field_names = {'bias', 'weight'};
                y = nn_linear(y, m.bias, m.weight);
                
            case 'Square', 
                y = y.^2;
            case 'Sqrt', 
                y = sqrt(y);
                
            case 'Tanh', 
                y = tanh(y);
                
            case 'Reshape', 
                y = y(:);
                
            case 'LogSoftMax',
                y = nn_logSoftMax(y);
%                 module_field_names = {};


            otherwise,
                error('Unhandled case : module type = %s', module_str)
                
        end
        
        
    end
    
        
      


end


function y_out = nn_spatialConvolutionMap(y, bias, weight, dH, dW, connTable)
    
%     [kH, kW, nOutputPlanes] = size(weight);
%     [h,w,nInputPlanes] = size(y);
    
%     h_out = floor( (h-kH) / dH) +1; %% check this
%     w_out = floor( (w-kW) / dW) +1; %% check this
        
%     assert(all(connTable(1,:) <= nInputPlanes));
%     assert(all(connTable(2,:) <= nOutputPlanes));

%     useMatlabConv = dH == 1 && dW == 1 && 0;

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
%     y_out = zeros(h_out, w_out, nOutputPlanes);
    

%     y_out = nn_spatialConvolutionMap_Matlab_slow(y, bias, weight, dH, dW, connTable);
            
%     y_out2 = nn_spatialConvolutionMap_Matlab_fast(y, bias, weight, dH, dW, connTable);

%     assert(isequal(y_out, y_out2));
            
            
            
   y_out  = nn_spatialConvolutionMap_c(y, bias, weight, dH, dW, connTable);
           

%    assert( isequal(y_out, y_out3) );
%     assert( isequalToPrecision(y_out, y_out3, 1e-5) );
        
%     end
    3;
    
        
end



function y_out = nn_spatialConvolution(y, bias, weight, dH, dW)
       
            
   y_out  = nn_spatialConvolution_c(y, bias, weight, dH, dW);    

        
end


function y_out = nn_spatialSubSampling(y, kH, kW, dH, dW, maxFlag)
    if ~exist('maxFlag', 'var')
        maxFlag = 0;
    end
    %%
%     maxFlag = 0;
    
    y_out = nn_spatialPooling_c(y, kH, kW, dH, dW, maxFlag);

%     y_out2 = nn_spatialSubSampling_Matlab(y, kH, kW, dH, dW, maxFlag);
    

%     assert(isequalToPrecision(y_out, y_out2, 1e-5));
end



function y_out = nn_linear(y, bias, weight)
    
    y_out = bias + weight' * y;
    
end


function y_out = nn_logSoftMax(y)

    y_out = logSoftMax(y);
%     a = sum (exp(y));
%     
%     y_out = log( (1 / a) * exp(y) );
    
end