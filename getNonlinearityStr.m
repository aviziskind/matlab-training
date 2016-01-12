function [nlin_str, nlin_str_nice] = getNonlinearityStr(networkOpts)
    nlin_str = '';
    nlin_str_nice = '';
    
    if isfield(networkOpts, 'nLinType')
       nlin_str_nice = networkOpts.nLinType;
       if strcmpi(networkOpts.nLinType, 'relu')
           nlin_str = '_rl';
           
       elseif strcmpi(networkOpts.nLinType, 'tanh')
%            --nLinType_str = 'th'

       else
            error('Unknown nonlinearity type : %s', networkOpts.nLinType);
       end
    end

    
end