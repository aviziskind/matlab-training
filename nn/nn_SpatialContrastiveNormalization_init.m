% SpatialContrastiveNormalization, parent = torch.class('nn.SpatialContrastiveNormalization','nn.Module')

function nn_SpatialContrastiveNormalization_init(nInputPlane, kernel, threshold, thresval)

%    -- get args
   if nargin < 1
       nInputPlane = 1;
   end
   self.nInputPlane = nInputPlane;
   
   if nargin < 2
       kernel = ones(9,9);
   end
   self.kernel = kernel;

   if nargin < 3
       threshold = 1e-4;
   end
   self.threshold = threshold;

   if nargin < 4
        thresval = threshold;
   end
   self.thresval = thresval;
   
   kdim = ndims( self.kernel );
   if isvector(self.kernel)
       kdim = 1;
   end

%    -- check args
   if kdim ~= 2 && kdim ~= 1 then
      error('<SpatialContrastiveNormalization> averaging kernel must be 2D or 1D')
   end
   if (mod(size(self.kernel, 1), 2) == 0  || (kdim == 2 && ( mod( size(self.kernel, 2), 2) == 0) )
      error('<SpatialContrastiveNormalization> averaging kernel must have ODD dimensions')
   end

%    -- instantiate sub+div normalization
   self.normalizer = nn.Sequential()
   self.normalizer:add(nn.SpatialSubtractiveNormalization(self.nInputPlane, self.kernel))
   self.normalizer:add(nn.SpatialDivisiveNormalization(self.nInputPlane, self.kernel,
                                                       self.threshold, self.thresval))
end

function nn_SpatialContrastiveNormalization(self, input)
   output = self.normalizer:forward(input)
   return self.output
end

