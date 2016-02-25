function dropout_str = getDropoutStr(networkOpts)
    
    dropout_str = '';
    if isfield(networkOpts, 'dropoutPs') && ~isempty(networkOpts.dropoutPs)
        dropout_str = ['_Dr' toList(networkOpts.dropoutPs)];
    end
    
end