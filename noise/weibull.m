function w = weibull(beta, c, gamma)
    
    w = (beta(1) - (beta(1)-gamma).* exp (- (( (c) ./abs(beta(2))).^(abs(beta(3))) ) ) );
    if any(imag(w) > 0)
        3;
    end
    
end
%         weibull_log = @(beta, c) (beta(1) - (beta(1)-gamma).* exp (- (( ( 10.^(c) ) ./beta(2)).^(beta(3)) ) ) );