function abbrev_str = networkLayerStrAbbrev(layerStrFull)
    
    layerAbbrev_tbl = struct('conv', 'Conv', ...
                             'linear', 'Lin', ...
                             'classifier', 'Cls');
                         
    [layerStr, num] = stringAndNumber(layerStrFull);
                                 
    if ~isfield(layerAbbrev_tbl, layerStr)
        error('%s is not one of the correct layers', layerStr);
    end
    abbrev_str = layerAbbrev_tbl.(layerStr);

    if isempty(num) && ~strcmp(layerStr, 'classifier')
        num = 1;
    end
    if ~isempty(num)
        abbrev_str = [abbrev_str num2str(num)];
    end
                     
end


