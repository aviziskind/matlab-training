function [mlp_str, mlp_str_nice] = getMLPstr(networkOpts, niceOutput_fields)
    HU = networkOpts.nHiddenUnits;
    mlp_str_nice = '';
    doNiceStr = exist('niceOutput_fields', 'var') && ~isempty(niceOutput_fields);
    
%     nUnits_str = '';
    if isempty(HU)
        nUnits_str = 'X';
        if doNiceStr
%             str_nice = '(1 layer)';
            mlp_str_nice = '(no hidden layer)';
        end
    else
        %%
        nLayers = length(HU);
        nUnits_str = toList(HU);
        if doNiceStr
%             str_nice = sprintf('(2 layers: %s Hidden Units)', toList(HU, [], ','));
            mlp_str_nice = sprintf('(%d hidden layers: %s HU)', nLayers, toList(HU, [], ','));
        end
    end
    
    [nLinType_str, nLinType_str_nice] = getNonlinearityStr(networkOpts);
    
    gpu_str = getTrainOnGPUStr(networkOpts);
    
    mlp_str      = [nUnits_str   nLinType_str  gpu_str];
    
    
    
    
end