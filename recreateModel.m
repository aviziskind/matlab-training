function model = recreateModel(S_modules)
    
    nModules = S_modules.nModules;
    model = struct;
    model.nModules = nModules;
    model.modeles_str = char(S_modules.modules_str');
    all_module_field_names = fieldnames(S_modules);
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
                module_field_names_need = {'bias', 'weight', 'nInputPlane', 'nOutputPlane', 'kH', 'kW', 'dH', 'dW'};
            
            case 'SpatialConvolutionMap',
                module_field_names_need = {'bias', 'weight', 'nInputPlane', 'nOutputPlane', 'kH', 'kW', 'dH', 'dW', 'connTable'};
                
            case 'SpatialSubSampling',
                module_field_names_need = {'kH', 'kW', 'dH', 'dW'};
                
            case 'SpatialLPPooling',
                module_field_names_need = {};

            case {'SpatialMaxPooling', 'SpatialAveragePooling'},
                module_field_names_need = {'kH', 'kW', 'dH', 'dW', 'indices'};
                
            case 'Linear',
                module_field_names_need = {'bias', 'weight'};
                
            case {'Square', 'Sqrt', 'Tanh', 'Reshape', 'LogSoftMax', 'ReLU'},
                module_field_names_need = {};
                
            case {'SpatialZeroPadding'}
                module_field_names_need = {'pad_l', 'pad_r', 'pad_t', 'pad_b'};
                
            otherwise,
                error('Unhandled case : module type = %s', module_type)
                
        end
        
        mod_i_str = sprintf('m%d_', mod_i);
        idxs_thisModule = find(strncmp(all_module_field_names, mod_i_str, length(mod_i_str)));
        
        module_field_names_use_full = all_module_field_names(idxs_thisModule); %#ok<FNDSB>
        module_field_names_use = cellfun(@(s) s(length(mod_i_str)+1:end), module_field_names_use_full, 'un', 0);
        assert(isempty(setdiff(module_field_names_need, module_field_names_use)))
        
        for mf_i = 1:length(module_field_names_use)
            mod_i_name_full = module_field_names_use_full{mf_i};
            mod_i_name_use = module_field_names_use{mf_i};
            if strcmp(mod_i_name_use, 'str')
                module_i.(mod_i_name_use) = char( S_modules.(mod_i_name_full)(:)' );
            else
                module_i.(mod_i_name_use) = single( S_modules.(mod_i_name_full) );
            end
        end
        
        if strncmp(module_type, 'SpatialConvolution', 18)
%            if module_i.nInputPlane == 0
%                module_i.nInputPlane = size(module_i,3);
%                module_i.nOutputPlane = size(module_i,4);
%                module_i.kH = size(module_i,1);
%                module_i.kW = size(module_i,2);
%                module_i.dW = 1;
%                module_i.dH = 1;
%            end
            
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