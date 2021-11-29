function y_out =  nn_forward(model, input, idxsModulesOutput)
       
    nModules = model.nModules;
    if nargin >= 3    
        nModules_use = min(nModules, max(idxsModulesOutput));
    else
        nModules_use = nModules;
        idxsModulesOutput = nModules_use;
    end 
    outputMultiple = ~isequal(idxsModulesOutput, nModules_use);

    if outputMultiple
        y_out = cell(1,nModules_use);
    end
    
    y = single(input);
    for mod_i = 1:nModules_use
        m = model.modules{mod_i};
        module_type = strtok(m.type, '(');
        
        if isfield(m, 'padW') && (m.padW > 0 || m.padH > 0)
           y = nn_spatialZeroPadding(y, m.padW, m.padW, m.padH, m.padH);
        end
        
        switch module_type
            
            case 'SpatialConvolution',
                assert(size(y, 3) == m.nInputPlane);
                assert(isequal(size(m.weight), [m.kH, m.kW, m.nInputPlane m.nOutputPlane]))
                y = nn_spatialConvolution(y, m.bias, m.weight, m.dH, m.dW);

            case 'SpatialConvolutionMap',
                assert(size(y, 3) == m.nInputPlane);
                assert(isequal(size(m.weight), [m.kH, m.kW, m.nOutputPlane]))
                y = nn_spatialConvolutionMap(y, m.bias, m.weight, m.dH, m.dW, m.connTable);
                
                
            case 'SpatialZeroPadding',
                y = nn_spatialZeroPadding(y, m.pad_l, m.pad_r, m.pad_t, m.pad_b);
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

            case 'ReLU', 
                y = ReLU(y);
                
            case 'Reshape', 
                y = y(:);
                
            case 'LogSoftMax',
                y = nn_logSoftMax(y);
%                 module_field_names = {};
               

            otherwise,
                error('Unhandled case : module type = %s', module_type)
                
        end
        
      
        if outputMultiple && any(mod_i == idxsModulesOutput) 
            y_out{mod_i} = y;
        end
    end
    
    if ~outputMultiple 
        y_out = y;
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
            
            
            
   y_out  = nn_spatialConvolutionMap_c(single(y), bias, weight, dH, dW, connTable);
           

%    assert( isequal(y_out, y_out3) );
%     assert( isequalToPrecision(y_out, y_out3, 1e-5) );
        
%     end
    3;
    
        
end



function y_out = nn_spatialConvolution(y, bias, weight, dH, dW)
       
            
   y_out  = nn_spatialConvolution_c(single(y), bias, weight, dH, dW);    

%    y_out  = nn_spatialConvolution_Matlab(y, bias, weight, dH, dW);    
        
end


function y_out = nn_spatialSubSampling(y, kH, kW, dH, dW, maxFlag)
    if ~exist('maxFlag', 'var')
        maxFlag = 0;
    end
    %%sudo apt-get install gcc-4.7 g++-4.7
%     maxFlag = 0;
    
        y_out = nn_spatialPooling_c(single(y), single(kH), single(kW), single(dH), single(dW), maxFlag);

%     y_out2 = nn_spatialSubSampling_Matlab(y, kH, kW, dH, dW, maxFlag);
    

%     assert(isequalToPrecision(y_out, y_out2, 1e-5));
end


function y_out = nn_spatialZeroPadding(y, pad_l, pad_r, pad_t, pad_b)
    
    y_out = padarray(y,     double([pad_t, pad_l]), 0, 'pre');
    y_out = padarray(y_out, double([pad_b, pad_r]), 0, 'post');
    
    %{
    nIn = size(y); nOut = nIn;
    nOut(1) = nIn(1)+pad_t + pad_b;
    nOut(2) = nIn(2)+pad_l + pad_r;
    
    y_out2 = zeros(nOut);
    idx1 = pad_t + [1:nIn(1)];
    idx2 = pad_l + [1:nIn(2)];
    y_out2(idx1, idx2, :,:) = y;
    
    assert(isequal(y_out, y_out2));
    %}

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

function y_out = ReLU(y)
    y_out = y;
    y_out (y<0) = 0;
    
end