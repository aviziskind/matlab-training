function testSpatialConvolutionMap
%%

%     y = reshape(1:100, 10, 10);
    weight = zeros(3,3); %[1 1 1; 1 2 1; 1 1 1]; %(3,3);
%     weight(1,1:2) = 1;

    y = randn(10, 10);
    nPlane = 4;
    weight = randn(3,3,nPlane);

    bias = randn(nPlane,1);
    dH = 1; dW = 1;
    connTable = [ones(1, nPlane); 1:nPlane];
    
    
    y_out = nn_spatialConvolutionMap_Matlab_slow(y, bias, weight, dH, dW, connTable);
            
    y_out2 = nn_spatialConvolutionMap_Matlab_fast(y, bias, weight, dH, dW, connTable);

            
            
   y_out3  = nn_spatialConvolutionMap_c(double(y), bias, weight, dH, dW, connTable);
           
   ok2 = max( abs(y_out(:) - y_out2(:)) ) < 1e-10;
   ok3 = max( abs(y_out(:) - y_out3(:)) ) < 1e-10

%    [ok2, ok3]
%     assert(ok2);
    assert(ok3);
    
    
    
    
    
    
end