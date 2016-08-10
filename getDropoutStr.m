function dropout_str = getDropoutStr(networkOpts)
    
    dropout_str = '';
    
    dropout_default = -0.5;
    if isfield(networkOpts, 'dropoutPs') && ~isempty(networkOpts.dropoutPs)
        
        if isfield(networkOpts, 'spatialDropout') && isequal(networkOpts.spatialDropout, 1);
            dropout_str = '_SDr';
        else
            dropout_str = '_Dr';
        end
        
        if ~isequal(networkOpts.dropoutPs, dropout_default)
            dropout_str = [dropout_str  tostring_nodot( toList(networkOpts.dropoutPs) )];
        end
    end
    
    
    
    
    
end