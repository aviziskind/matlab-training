function Y = nn_LogSoftMax(X, dim)
    % a = sum (exp(X))
    % Y = log (  exp(X) / a )
    
    if nargin < 2
        dim = find(size(X) > 1, 1);
    end
    
    expX = exp(X);
    a = sum ( expX, dim );
    
    Y = log( bsxfun(@rdivide, expX, a) );
     
end