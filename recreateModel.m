function model = recreateModel(S_modules)
    
    nModules = S_modules.nModules;
    model = struct;
    model.nModules = nModules;
    model.modeles_str = char(S_modules.modules_str');
    %%
    for mod_i = 1:nModules
        module_type = char( S_modules.(sprintf('m%d_str', mod_i) )');
        module_type= module_type(:)';
        module_i = struct('type', module_type);
        
        
%         getModule = @(module_name) S_modules.(sprintf('m%d_%s', mod_i, module_name) );
        module_type_orig = module_type;
        module_type = strtok(module_type, '(');
        
        switch module_type
            case {'SpatialConvolution', 'SpatialConvolutionMM', 'SpatialConvolutionCUDA'},
                module_field_names = {'bias', 'weight', 'nInputPlane', 'nOutputPlane', 'kH', 'kW', 'dH', 'dW'};
            
            case 'SpatialConvolutionMap',
                module_field_names = {'bias', 'weight', 'nInputPlane', 'nOutputPlane', 'kH', 'kW', 'dH', 'dW', 'connTable'};
                
            case 'SpatialSubSampling',
                module_field_names = {'kH', 'kW', 'dH', 'dW'};
                
            case 'SpatialLPPooling',
                module_field_names = {};

            case {'SpatialMaxPooling', 'SpatialAveragePooling'},
                module_field_names = {'kH', 'kW', 'dH', 'dW', 'indices'};
                
            case 'Linear',
                module_field_names = {'bias', 'weight'};
                
            case {'Square', 'Sqrt', 'Tanh', 'Reshape', 'LogSoftMax', 'ReLU'},
                module_field_names = {};
                
            case {'SpatialZeroPadding'}
                module_field_names = {'pad_l', 'pad_r', 'pad_t', 'pad_b'};
                
            otherwise,
                error('Unhandled case : module type = %s', module_type)
                
        end
        
        for mf_i = 1:length(module_field_names)
            module_i.(module_field_names{mf_i}) = single( S_modules.(sprintf('m%d_%s', mod_i, module_field_names{mf_i}) ) );
        end
                
        model.modules{mod_i} = module_i;
        model.moduleNames{mod_i} = module_type;

    end
    
    
end

    %{
                    
                    net[ 'm' .. j .. '_bias'] = module_i.bias:double()
                    net[ 'm' .. j .. '_weight'] = module_i.weight:double()
                    net[ 'm' .. j .. '_nInputPlane'] = torch.DoubleTensor({module_i.nInputPlane})
                    net[ 'm' .. j .. '_nOutputPlane'] = torch.DoubleTensor({module_i.nOutputPlane})
                    net[ 'm' .. j .. '_kH'] = torch.DoubleTensor({module_i.kH})
                    net[ 'm' .. j .. '_kW'] = torch.DoubleTensor({module_i.kW})
                    net[ 'm' .. j .. '_dH'] = torch.DoubleTensor({module_i.dH})
                    net[ 'm' .. j .. '_dW'] = torch.DoubleTensor({module_i.dW})
                    net[ 'm' .. j .. '_connTable'] = module_i.connTable:double()
                    
                    module_name_str = 'Conv'
                
                elseif (module_str == 'SpatialSubSampling') then                    
                    net[ 'm' .. j .. '_kH'] = torch.DoubleTensor({module_i.kH})
                    net[ 'm' .. j .. '_kW'] = torch.DoubleTensor({module_i.kW})
                    net[ 'm' .. j .. '_dH'] = torch.DoubleTensor({module_i.dH})
                    net[ 'm' .. j .. '_dW'] = torch.DoubleTensor({module_i.dW})
                    net[ 'm' .. j .. '_connTable'] = module_i.connTable
                    
                    module_name_str = 'SubSamp'
                    
                elseif (module_str == 'SpatialMaxPooling') then                    
                    net[ 'm' .. j .. '_kH'] = torch.DoubleTensor({module_i.kH})
                    net[ 'm' .. j .. '_kW'] = torch.DoubleTensor({module_i.kW})
                    net[ 'm' .. j .. '_dH'] = torch.DoubleTensor({module_i.dH})
                    net[ 'm' .. j .. '_dW'] = torch.DoubleTensor({module_i.dW})
                    net[ 'm' .. j .. '_indices'] = module_i.indices:double()
                    
                    module_name_str = 'MaxPool'
%}