% local SpatialSubtractiveNormalization, parent = torch.class('nn.SpatialSubtractiveNormalization','nn.Module')

function Y = nn_SpatialSubtractiveNormalization(X, kernel_arg, doCircular)
    if ~isa(X, 'float')
        X = single(X);
    end

    if nargin < 2
        kernel_arg = 7;
    end
    
    if nargin < 3
        doCircular = false;
    end

    if isscalar(kernel_arg)
        kernel_size = kernel_arg;
        k_x = image_gaussian1D(kernel_size);
    elseif isvector(kernel_arg)
        k_x = kernel_arg;
    end
    
    
    nk = length(k_x);
    if doCircular      
        [X, idx_central] = circPad(X, nk);
    end
        
    
    k_x = k_x/sum(k_x);

    coef = nn_estimate_mean(ones(size(X)), k_x);

    localsums = nn_estimate_mean(X, k_x);
    adjustedsums = localsums ./ coef;
    
    Y = X - adjustedsums;

    
    if doCircular
        Y = Y(idx_central{:}); 
    end
    
end


        
        
        
        %{

    
    
   if nargin < 2
       kernel = ones(9,9);
   end
   self.kernel = kernel;

   kdim = ndims( self.kernel );
   if isvector(self.kernel)
       kdim = 1;
   end
   %%
   
   norm_kernel_size = 3;
   pad_size = (norm_kernel_size-1)/2;
   
   X = zeros(15,15);
   X(5:11, 5:11) = 10;
   
   
%    w_pq .* xi,j+p, k+q
   k_x = image_gaussian1D(norm_kernel_size);
   k_x = k_x/sum(k_x);
%    K = k_x(:) * k_x(:)';
%    K = K/sum(K(:));

%%
    self_ones = ones(size(X));
    y1 = padarray(self_ones, [pad_size pad_size], 0, 'both');
    y2 = conv2(y1, k_x, 'valid');
    coef = conv2(y2, k_x', 'valid');

    %%

    Y1 = padarray(X, [pad_size pad_size], 0, 'both');
    Y2 = conv2(Y1, k_x, 'valid');
    localsums = conv2(Y2, k_x', 'valid');
    adjustedsums = localsums ./ coef;
    Y = X - adjustedsums;

%    Y = (X - conv2(X, K, 'same') );
   
   
   %%
   
%    -- check args
    if kdim ~= 2 && kdim ~= 1 then

        error('<SpatialSubtractiveNormalization> averaging kernel must be 2D or 1D')
   end
   if (mod(size(self.kernel, 1), 2) == 0  || (kdim == 2 && ( mod( size(self.kernel, 2), 2) == 0) )
      error('<SpatialSubtractiveNormalization> averaging kernel must have ODD dimensions')
   end

%    -- normalize kernel
   self.kernel = self.kernel / (sum(self.kernel(:) * self.nInputPlane);

%    -- padding values
   padH = floor(size(self.kernel, 1)/2);
   padW = padH;
   if kdim == 2 
      padW = floor(size(self.kernel, 2)/2);
   end

%    -- create convolutional mean extractor
   self.meanestimator = nn.Sequential()
   self.meanestimator:add(nn.SpatialZeroPadding(padW, padW, padH, padH))
   if kdim == 2 then
      self.meanestimator:add(nn.SpatialConvolution(self.nInputPlane, 1, self.kernel:size(2), self.kernel:size(1)))
   else
      self.meanestimator:add(nn.SpatialConvolutionMap(nn.tables.oneToOne(self.nInputPlane), self.kernel:size(1), 1))
      self.meanestimator:add(nn.SpatialConvolution(self.nInputPlane, 1, 1, self.kernel:size(1)))
   end
   self.meanestimator:add(nn.Replicate(self.nInputPlane))

   -- set kernel and bias
   if kdim == 2 then
      for i = 1,self.nInputPlane do 
         self.meanestimator.modules[2].weight[1][i] = self.kernel
      end
      self.meanestimator.modules[2].bias:zero()
   else
      for i = 1,self.nInputPlane do 
         self.meanestimator.modules[2].weight[i]:copy(self.kernel)
         self.meanestimator.modules[3].weight[1][i]:copy(self.kernel)
      end
      self.meanestimator.modules[2].bias:zero()
      self.meanestimator.modules[3].bias:zero()
   end

   -- other operation
   self.subtractor = nn.CSubTable()
   self.divider = nn.CDivTable()

   -- coefficient array, to adjust side effects
   self.coef = torch.Tensor(1,1,1)
end

function SpatialSubtractiveNormalization:updateOutput(input)
   -- compute side coefficients
   if (input:size(3) ~= self.coef:size(3)) or (input:size(2) ~= self.coef:size(2)) then
      local ones = input.new():resizeAs(input):fill(1)
      self.coef = self.meanestimator:updateOutput(ones)
      self.coef = self.coef:clone()
   end

   -- compute mean
   self.localsums = self.meanestimator:updateOutput(input)
   self.adjustedsums = self.divider:updateOutput{self.localsums, self.coef}
   self.output = self.subtractor:updateOutput{input, self.adjustedsums}

   -- done
   return self.output
end

function SpatialSubtractiveNormalization:updateGradInput(input, gradOutput)
   -- resize grad
   self.gradInput:resizeAs(input):zero()

   -- backprop through all modules
   local gradsub = self.subtractor:updateGradInput({input, self.adjustedsums}, gradOutput)
   local graddiv = self.divider:updateGradInput({self.localsums, self.coef}, gradsub[2])
   self.gradInput:add(self.meanestimator:updateGradInput(input, graddiv[1]))
   self.gradInput:add(gradsub[1])

   -- done
   return self.gradInput
end

function SpatialSubtractiveNormalization:type(type)
   parent.type(self,type)
   self.meanestimator:type(type)
   self.divider:type(type)
   self.subtractor:type(type)
   return self
end

%}