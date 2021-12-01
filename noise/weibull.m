function w = weibull(beta, c, gamma)

    % beta(1) is the maximum pct correct (set to 1 if observer can do 100% at high contrast)
    % beta(2) is the threshold
    % beta(3) is the slope parameter
    % gamma is the guessing rate (fixed) 
    % c is the (input) contrast.
    
    w = (beta(1) - (beta(1)-gamma).* exp (- (( (c) ./abs(beta(2))).^(abs(beta(3))) ) ) );
    if any(imag(w) > 0)
        3;
    end
    
end
%         weibull_log = @(beta, c) (beta(1) - (beta(1)-gamma).* exp (- (( ( 10.^(c) ) ./beta(2)).^(beta(3)) ) ) );