function [arg_out, gain_factor] = fourierMask(imSize_arg, freqRange, freqRange_type, opt)

    if nargin < 4
        opt = struct;
    end
    if ~isfield(opt, 'applyFourierMaskGainFactor')
        opt.applyFourierMaskGainFactor = 0;
    end

    if numel(imSize_arg) <= 2
        imSize = imSize_arg;
        haveData = 0;
    else
        haveData = 1;
        X = imSize_arg;
        imSize = size(X);
    end

    do1Dvector = any(imSize == 1) || length(imSize) == 1; %% 1D vector;
    if do1Dvector
        N = prod(imSize);
        pix_per_image = N;
    else
        M = imSize(1);
        N = imSize(2);
        pix_per_image = min(M,N);
    end
    
    if nargin < 3
        freqRange_type = 'band_cycPerPix';
    end
    
    switch freqRange_type
        case 'band_cycPerPix',
            maskType = 'band';
            cycPerPix_range = freqRange;
            cycPerImage_range = sort( cycPerPix_range .* pix_per_image );
            
        case 'band_pixPerCycle',
            maskType = 'band';
            pixPerCycle_range = freqRange;
            cycPerPix_range = sort( 1./pixPerCycle_range );
    
            cycPerImage_range = cycPerPix_range .* pix_per_image;
            
            
        case 'band_cycPerImage', 
            maskType = 'band';
            cycPerImage_range = sort(freqRange);
            
        case '1/f',
            maskType = '1/f';
            n_mask = freqRange;
            
        otherwise,
            error('Unknown type');
    end
    
%     cycPerImage_range = sort(cycPerImage_range);  
        
%     cycPerPix_range = sort( 1./pix_per_cycle_range );
%     
%     cycPerImage_range = cycPerPix_range .* pix_per_image;

    
    if do1Dvector %% 1D vector

        nMid = floor(N/2)+1;
        
%         pix_per_cycle_range = [50, 50];
%         cycPerPix_range = sort( 1./pix_per_cycle_range ); 
        
%         cycPerImage_range = cycPerPix_range .* pix_per_image;

        r = abs([1:N] - nMid);
        
        switch maskType 
            case 'band',
                cyc_range = cycPerImage_range; %[3,6];

                mask_lo = cosineDecay(r, cyc_range(2));
                mask_hi = 1-cosineDecay(r, cyc_range(1));

                mask = mask_lo .* mask_hi;
            case '1/f',
                mask = 1 ./ (r.^ n_mask);
                mask(r==0) = 0;
                
        end
        
        
        if haveData
            Xf = fftshift(fft( X ));
            X_filtered = ifft( ifftshift( Xf .* mask), 'symmetric') ;

%             gain_factor = sqrt( 1/ (sum(mask(:).^2)/numel(mask)) );            

            gain_factor = 1;
            arg_out = X_filtered * gain_factor;
            
        else
            arg_out = mask;
        end
        
        
        
    elseif all(imSize > 1)  %% 2D matrix
        
%         pix_per_cycle_range = [4, 8];
        
        % cyc_per_image_range = ./ [M, N];
        % pix_per_image_x = M;
        % pix_per_image_y = N;
        %
        % cyc_per_image_range_x = cyc_per_pix_range .* pix_per_image_x;
        % cyc_per_image_range_y = cyc_per_pix_range .* pix_per_image_y;
               
        
        nMid_x = floor(M/2)+1;
        nMid_y = floor(N/2)+1;

        
        % cyc_per_image = [2,2];
        
        if M >= N
            x_scale = N/M;
            y_scale = 1;
        else
            x_scale = 1;
            y_scale = M/N;
        end
                
        [x_idx, y_idx] = meshgrid(1:M, 1:N);
        r = sqrt( (x_scale*(x_idx' - nMid_x)).^2 + (y_scale*(y_idx' - nMid_y)).^2 );
        
        cycPerImageRange_arg = [];
        switch maskType
            case 'band',
                mask = fourierAnnulus(r, cycPerImage_range);
                %%
                cycPerImageRange_arg = cycPerImage_range;
                
            case '1/f',
                mask = 1 ./ (r.^ (n_mask));
                mask(r==0) = 0;
                                
%                 mask = mask ./ r;
                
        end
        
        gain_factor = fourierMaskCorrectionFactor(mask, cycPerImageRange_arg);
        
        if opt.applyFourierMaskGainFactor
            mask = mask * gain_factor;
        end
        
        if haveData
            Xf = fftshift( fftshift(fft2( X), 1), 2);
            n3 = size(Xf, 3);
            for i = 1:n3
                X_filtered(:,:,i) = ifft2( ifftshift( Xf(:,:,i) .* mask), 'symmetric') ;
            end
            
            arg_out = X_filtered; % * gain_factor; (already multiplied the mask by the gain factor)
            
        else
            arg_out = mask;
        end

        
        
    end

    
    
    
%     
%     
%     
% 
%     if nargin < 3 
%         if length(r0) == 2
%             filterType = 'band';
%         else
%             filterType = 'low';
%         end
%     end
%     
%     switch filterType
%         case 'band'
%             %%
%             assert(length(r0) == 2);
%             y_lo = cosineDecay(r, r0(2), decay_width);
%             y_hi = 1-cosineDecay(r, r0(1), decay_width);
%             y = y_lo .* y_hi;
%             
%         case 'low',
%             assert(length(r0) == 1);
%             y = cosineDecay(r, r0, decay_width);
%             
%         case 'high',
%             assert(length(r0) == 1);
%             
%             y = 1-cosineDecay(r, r0, decay_width);
% 
%         otherwise
%             error('Unknown filterType : %s', filtertype);
%     end
                
end