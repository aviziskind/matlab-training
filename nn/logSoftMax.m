function lsm = logSoftMax(y)
    
    a = sum (exp(y));
    
    lsm = log( (1 / a) * exp(y) );
    
end
