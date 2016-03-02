function y = cosineDecay(x, x0, decay_width)

    if nargin < 3
        decay_width = 1/sqrt(2);
    end

    x1 = x0-decay_width;
    x2 = x0+decay_width;
    
    idx_1 = x < x1;
    idx_0 = x > x2;
    idx_mid = ibetween(x, x1, x2);
    
    y = zeros(size(x));
    y(idx_1) = 1;
    y(idx_0) = 0;
    y(idx_mid) = 0.5 + 0.5 * cos(  (x(idx_mid)-x1)/(x2-x1)*pi );
    
    if x0 == 0
        y(x==0) = 1;  %% always set DC to 0.
    end
    
end