function gauss = image_gaussian1D(size, sigma, amplitude, normalize, mean)
%       'image.gaussian1D',
%       'returns a 1D gaussian kernel',
    if nargin < 1
        size = 3;
    end
    if nargin < 2
        sigma = 0.25;
    end
    if nargin< 3
        amplitude = 1;
    end
    if nargin < 4
        normalize = false;
    end
    if nargin < 5
        mean = 0.5;
    end
%       {arg='size', type='number', help='size the kernel', default=3},
%       {arg='sigma', type='number', help='Sigma', default=0.25},
%       {arg='amplitude', type='number', help='Amplitute of the gaussian (max value)', default=1},
%       {arg='normalize', type='number', help='Normalize kernel (exc Amplitude)', default=false},
%       {arg='mean', type='number', help='Mean', default=0.5}
%    )

%    local vars
    center = mean * size + 0.5;
   
%    -- generate kernel
    gauss = zeros(1, size);
    for i=1:size
        gauss(i) = amplitude * exp(-( (  (i-center)/(sigma*size) )^2) /2);
    end
    if normalize
        gauss = gauss / sum(gauss);
    end
   
end
