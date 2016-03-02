function [noiseMasks, noiseMasks_fftshifted, all_f_exp] = getNoiseMask(noiseFilter, imageSize)
    noiseMasks_fftshifted = {[]};
    filtType = noiseFilter.filterType;
    
    all_f_exp = [];
    if strcmp(filtType, 'white')
        whiteMask = ones(imageSize);    
        noiseMasks = {whiteMask};
        noiseMasks_fftshifted = {whiteMask};
        
    elseif any(strcmp(filtType, {'band', 'lo', 'hi'}))
            %%
        cycPerPix_range = noiseFilter.cycPerPix_range;
        mask_fftshifted = fourierMask(imageSize, cycPerPix_range, 'band_cycPerPix', noiseFilter);
        bandMask = ifftshift(mask_fftshifted);
        noiseMasks = {bandMask};
        noiseMasks_fftshifted = {mask_fftshifted};
                        
            
    elseif ~isempty(strfind(filtType, '1/f'))
        f_exp = noiseFilter.f_exp;
        f_exp_std = 0;
        if isfield(noiseFilter, 'f_exp_std')
            f_exp_std = noiseFilter.f_exp_std;
        end
            
        if strcmp(filtType, '1/f')
        
            if f_exp_std > 0
                nMasks = 1000;
                pinkNoiseMasks = cell(1,nMasks);
                all_f_exp = f_exp + randn(1,nMasks)*f_exp_std;
                for mask_i = 1:nMasks
                    mask_fftshifted = fourierMask(imageSize, all_f_exp(mask_i), '1/f', noiseFilter);
                    pinkNoiseMasks{mask_i} = ifftshift(mask_fftshifted);
                end

            else
                nMasks = 1;
                mask_fftshifted = fourierMask(imageSize, f_exp, '1/f', noiseFilter);
                noiseMasks_fftshifted = {mask_fftshifted};
                pinkNoiseMasks = { ifftshift(mask_fftshifted) };
            end

             noiseMasks = pinkNoiseMasks;

        elseif any(strcmp(filtType, {'1/fPwhite', '1/fOwhite'}))
            pinkWhiteRatio = noiseFilter.ratio;
            
            pink_mask_fftshifted = fourierMask(imageSize, f_exp, '1/f', noiseFilter);
            pinkMask = ifftshift(pink_mask_fftshifted);
            whiteMask = ones(imageSize);    
               
            if strcmp(filtType, '1/fOwhite')
                if pinkWhiteRatio == 1
                    nPink  = 1;
                    nWhite = 1;
                elseif pinkWhiteRatio > 1
                    nPink  = pinkWhiteRatio;
                    nWhite = 1;
                elseif pinkWhiteRatio < 1
                    nPink  = 1;
                    nWhite = 1/pinkWhiteRatio;
                end
                
%                 nMasks = nPink+nWhite;
                noiseMasks = [repmat({pinkMask}, 1, nPink), repmat({whiteMask}, 1, nWhite)];
                
            elseif strcmp(filtType, '1/fPwhite')
%                 nMasks = 1;
                maskSum = pinkMask * pinkWhiteRatio + whiteMask;
                maskSum_rescaled = maskSum * fourierMaskCorrectionFactor(maskSum);
                noiseMasks{1} = maskSum_rescaled;
                                
            end
                
        end
                
%                         allPinkPlusWhiteNoiseFilters = arrayfun(@(f) struct('filterType', '1/fPwhite', 'f_exp', f), allF_exps, 'un', 0);
%         allPinkOrWhiteNoiseFilters = arrayfun(@(f) struct('filterType',   '1/fOwhite', 'f_exp', f), allF_exps, 'un', 0);
                
    end    
        
        

end
    
%{
    filtType = noiseFilter.filterType;
        
    if strcmp(filtType, 'band')
        cycPerLet_range = getCycPerLet_range(noiseFilter);
%         cycPerPix_range = noiseFilter.cycPerPix_range;
        mask_fftshifted = fourierMask(imageSize, cycPerPix_range, 'band_cycPerPix', params);
        mask = ifftshift(mask_fftshifted);

    elseif any(strcmp(filtType, {'lo', 'hi'}))
            %%
        cycPerPix_range = noiseFilter.cycPerPix_range;
        mask_fftshifted = fourierMask(imageSize, cycPerPix_range, 'band_cycPerPix', params);
        mask = ifftshift(mask_fftshifted);
                                    
    elseif ~isempty(strfind(filtType, '1/f'))
            f_exp = params.noiseFilter.f_exp;
            
            mask_fftshifted = fourierMask(imageSize, f_exp, '1/f', params);
            mask = ifftshift(mask_fftshifted);
            
    elseif strcmp(filtType, 'white')
        mask = ones(imageSize);
        mask_fftshifted = mask;
    end
    
end


%}