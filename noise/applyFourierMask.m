function im_filtered = applyFourierMask(mask, im_raw, gain_factor)

    if size(mask,1) ~= size(im_raw,1) || size(mask,2) ~= size(im_raw,2)
        error('2D dimensions of mask and image must match')
    end

    im_filtered = ifft2( bsxfun(@times, mask, fft2(im_raw)), 'symmetric');

    if nargin >= 3
         im_filtered = im_filtered * gain_factor;
    end
                
end