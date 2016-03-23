function Y = nn_SoftMax(X, dim)
    % m = max(X);
    % Y = exp( X - m ) / sum(  exp( X - m) )
    
    if nargin < 2
        dim = find(size(X) > 1, 1);
    end

    maxVal = max(X, [], dim);
    
    exp_X_m_maxVal = exp( bsxfun(@minus, X, maxVal) );

    a = sum ( exp_X_m_maxVal, dim);  %     a = sum ( exp(X-shift), dim);
    
    Y = bsxfun(@rdivide, exp_X_m_maxVal, a) ;
        
end
