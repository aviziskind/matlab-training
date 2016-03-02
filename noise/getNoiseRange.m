
function noise_range = getNoiseRange(noiseFilter)
    units = {'cycPerLet', 'cycPerPix', 'pixPerCycle'};
%     vals = {'centFreq', 'cutOffFreq'};
    
    for ui = 1:length(units)
        unit_str = units{ui};
        if isfield(noiseFilter, [unit_str '_centFreq']) 
            centFreq = noiseFilter.([unit_str '_centFreq']);
        elseif isfield(noiseFilter, [unit_str '_cutOffFreq']);
            cutoffFreq = noiseFilter.([unit_str '_cutOffFreq']);
        end        
    end

    if any(strcmp (noiseFilter.filterType, {'band', 'lo', 'hi'}))
        switch noiseFilter.filterType
            case 'band', noise_range = centFreq * [1/sqrt(2), sqrt(2)];
            case 'lo',   noise_range = [0, cutoffFreq];
            case 'hi',   noise_range = [cutoffFreq, inf];
        end

    end
end