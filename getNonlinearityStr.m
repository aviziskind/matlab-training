function [nlin_str, nlin_str_nice] = getNonlinearityStr(networkOpts)
    nlin_str = '';
    nlin_str_nice = '';
    
    if isfield(networkOpts, 'nLinType')
       
       if strcmpi(networkOpts.nLinType, 'relu')
           nlin_str = '_rl';
           nlin_str_nice = '(ReLU)';
           
       elseif strcmpi(networkOpts.nLinType, 'tanh')
%            --nLinType_str = 'th'
           nlin_str_nice = '(Tanh)';

       else
            error('Unknown nonlinearity type : %s', networkOpts.nLinType);
       end
    end

    
end