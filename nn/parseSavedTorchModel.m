
function S_model = parseSavedTorchModel(S_model)
    %%
    fn = fieldnames(S_model);
    S_model.moduleNames = {};
    for i = 1:length(fn)
        if ~isempty(strfind(fn{i}, 'str'))
            S_model.(fn{i}) = char(S_model.(fn{i})');
        end
    end
    %%
    S_model.modules_strC = strsplit(S_model.modules_str(:)', ';');
    
    S_model = orderfields(S_model);
    % transpose CUDA convolutional filters
    for i = 1:S_model.nModules
        if strcmp(S_model.(sprintf('m%d_str', i)), 'SpatialConvolutionCUDA')
%             fprintf('layer %d: permuting CUDA filters\n', i);
            wgt_field = sprintf('m%d_weight', i);
            wgt = S_model.(wgt_field);
            if ndims(wgt) == 3  % first layer:  nOutMaps x h x w --> h x w x nOutMaps
                S_model.(wgt_field) = permute(wgt, [2 3 1]);
            elseif ndims(wgt) == 4 % subsequent layers: nOutMaps x h x w x nInputMaps --> h x w x nOutputMaps x nInputMapx
                S_model.(wgt_field) = permute(wgt, [2 3 1 4]);  
            end
        end
    end
    
    
end
