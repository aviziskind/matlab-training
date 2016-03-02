function g = fourierMaskCorrectionFactor(mask, cycPerImage_range)
%     global norm_factors
%     g = sqrt( 1/ (sum(mask(:).^2)/numel(mask)) );    
    size_factor = sqrt(numel(mask));

    
    if exist('cycPerImage_range', 'var') && ~isempty(cycPerImage_range)
        maskIntegral = pi*(cycPerImage_range(2)^2-cycPerImage_range(1)^2);    
    else
        maskIntegral = sum(mask(:).^2);
    end

    norm_factor = 1 / sqrt(maskIntegral);
%     norm_factor = 1;
    
    g = size_factor * norm_factor;
    
    
%     norm_factors = [norm_factors norm_factor];
    3;
end

%     norm_factor = sqrt( 1/ (sum(mask(:).^2)));
%     size_factor = sqrt(numel(mask)) ;    
%     
%     g = norm_factor * size_factor;
