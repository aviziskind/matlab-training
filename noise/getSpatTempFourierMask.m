function [mask, mask_fftshifted] = getSpatTempFourierMask(im_size, mask_orientation, decay_width_deg, margin_deg)
    %%
    if nargin < 1
        im_size = [64, 64];
    end
    if nargin < 2
        mask_orientation = 'vert';
    end
    if nargin < 3
        decay_width_deg = 30;
    end
    if nargin < 3
        margin_deg = -10;
    end

    %%
    if 0
        %%
        im_size = [64, 128];
        vertHoriz = 'vert';
%         vertHoriz = 'horiz';
        p = 3/4;
        
    end
    
    do2Dmask = length(im_size) == 2;
    do3Dmask = length(im_size) == 3;
    
    if do2Dmask
        
        [ny, nx] = deal(im_size(1), im_size(2));

        nMid_y = floor(ny/2)+1;
        nMid_x = floor(nx/2)+1;

        if ny >= nx
            x_scale = nx/ny;
            y_scale = 1;
        else
            x_scale = 1;
            y_scale = ny/nx;
        end

        [x_idx, y_idx] = meshgrid(1:ny, 1:nx);
        X = (x_scale*(x_idx' - nMid_y));
        Y = (y_scale*(y_idx' - nMid_x));
        r = sqrt( X.^2 + Y.^2 );
        theta = atan2(Y, X);

        %%
    %     p = 3/4;
    %     decay_width = 1/sqrt(2);
        decay_width_rad  = deg2rad(decay_width_deg);

    %     assert(length(r0) == 2);
        margin_rad = deg2rad(margin_deg);

        if strcmp(mask_orientation, 'vert')
            margin_rad = -margin_rad;
        end
    

        y_hi1 = cosineDecay(theta, (pi/4)*(1) - margin_rad, decay_width_rad);
        y_hi2 = 1-cosineDecay(theta, (pi/4)*(-1) + margin_rad, decay_width_rad);
        y_hi = (y_hi1 .* y_hi2);


        y_lo1 = 1-cosineDecay(theta, (pi/4)*(-3) - margin_rad, decay_width_rad);
        y_lo2 = cosineDecay(theta, (pi/4)*(3) + margin_rad, decay_width_rad);
        y_lo = 1-(y_lo1 .* y_lo2);

        y = max(y_hi, y_lo);

        
        
         switch mask_orientation
            case 'horiz'
                mask = y;
            case 'vert'
                mask = 1-y;
         end

         mask_fftshifted = fftshift(mask);
    %     mask = ifftshift(mask_fftshifted);

    elseif do3Dmask
        
        
        [ny, nx, nz] = deal(im_size(1), im_size(2), im_size(3));

        nMid_y = floor(ny/2)+1;
        nMid_x = floor(nx/2)+1;
        nMid_z = floor(nz/2)+1;

        if ny >= nx
            x_scale = nx/ny;
            y_scale = 1;
            z_scale = 1;
        else
            x_scale = 1;
            y_scale = ny/nx;
            z_scale = 1;
        end

        [y_idx, x_idx, z_idx] = meshgrid(1:ny, 1:nx, 1:nz);
        X = (x_scale*(x_idx - nMid_y));
        Y = (y_scale*(y_idx - nMid_x));
        Z = (z_scale*(z_idx - nMid_z));
        
        r_im = sqrt( X.^2 + Y.^2 );
        theta = atan2(Z, r_im);

        %%
    %     p = 3/4;
    %     decay_width = 1/sqrt(2);
        decay_width_rad  = deg2rad(decay_width_deg);

    %     assert(length(r0) == 2);

        margin_rad = deg2rad(margin_deg);

        if strcmp(mask_orientation, 'temporal')
            margin_rad = -margin_rad;
        end

        y_hi1 = cosineDecay(theta, (pi/4)*(1) - margin_rad, decay_width_rad);
        y_hi2 = 1-cosineDecay(theta, (pi/4)*(-1) + margin_rad, decay_width_rad);
        y_hi = (y_hi1 .* y_hi2);


        y_lo1 = 1-cosineDecay(theta, (pi/4)*(-3) - margin_rad, decay_width_rad);
        y_lo2 = cosineDecay(theta, (pi/4)*(3) + margin_rad, decay_width_rad);
        y_lo = 1-(y_lo1 .* y_lo2);

        y = max(y_hi, y_lo);

         switch mask_orientation
            case 'spatial'
                mask = y;
            case 'temporal'
                mask = 1-y;
         end

         mask_fftshifted = fftshift(mask);
    %     mask = ifftshift(mask_fftshifted);
        
        
        
        
        
        
        
        
    end
    
    
    return;
    
    
%     y = (1-y);
    
    subplot(2,4,1); imagesc(theta); axis image;
    subplot(2,4,2); imagesc(y_hi1); axis image;
    subplot(2,4,3); imagesc(y_hi2); axis image;
    subplot(2,4,4); imagesc(y_hi);axis image;


    subplot(2,4,5); imagesc(y ); axis image;
    subplot(2,4,6); imagesc(y_lo1); axis image;
    subplot(2,4,7); imagesc(y_lo2); axis image;
    subplot(2,4,8); imagesc(y_lo);axis image;

    %%

    corner_size = im_size / 2;
    
%     slope = 1;
    corner_mask = zeros(corner_size);
    [M, N] = deal(corner_size(1), corner_size(2));
    
    m_slope = N/M;
    

    switch vertHoriz
        case 'vert'
            
            for i = 1:M
                c = m_slope*i ;
                corner_mask(i,:) = 1-cosineDecay(1:N, c, c^(p) );
            end
            
        case 'horiz'
            for j = 1:N
                c = j/m_slope;
                corner_mask(:,j) = 1-cosineDecay(1:M, c, c^(p) );
            end
            
    end

    
    
    msk = [        (corner_mask),    fliplr(corner_mask);
           flipud([(corner_mask),    fliplr(corner_mask)]) ];

   msk = fftshift(msk);
    
   show = 0;
   if show
        figure(1); clf;
        subplot(1,3,1);
        imagesc(corner_mask);
        axis image xy;
        colormap(gray);

        subplot(1,3,2);
        imagesc(msk);
        axis image xy;
        colormap(gray);

        subplot(1,3,3);
        imagesc(ifftshift(msk));
        axis image xy;
        colormap(gray);


   end
    %%

    
    
    
    
    
    
    
    
    
end