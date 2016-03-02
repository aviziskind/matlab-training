function y = fourierAnnulus(r, r0, filterType, decay_width)

    if nargin < 4
        decay_width = 1/sqrt(2);
    end

    if nargin < 3 
        if length(r0) == 2
            filterType = 'band';
        else
            filterType = 'low';
        end
    end
    
    switch filterType
        case 'band'
            %%
            assert(length(r0) == 2);
            y_lo = cosineDecay(r, r0(2), decay_width);
            y_hi = 1-cosineDecay(r, r0(1), decay_width);
            y = y_lo .* y_hi;
            
        case 'low',
            assert(length(r0) == 1);
            y = cosineDecay(r, r0, decay_width);
            
        case 'high',
            assert(length(r0) == 1);
            
            y = 1-cosineDecay(r, r0, decay_width);

        otherwise
            error('Unknown filterType : %s', filtertype);
    end
                
end