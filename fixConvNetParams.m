function networkOpts = fixConvNetParams(networkOpts)
     
    if length(networkOpts) > 1 
        for j = 1,length(networkOpts)
            networkOpts(j) = fixNetworkParams(networkOpts(j));
        end
        return
    end
            
     
    defaultParams = getDefaultConvNetParams;
    
    allowPoolStrideGreaterThanPoolSize = false;
    
    if ~isfield(networkOpts, 'nStatesConv')    
        nStates = networkOpts.nStates;
        idx_pos = nStates > 0;
        networkOpts.nStatesConv = nStates(idx_pos);
        networkOpts.nStatesFC = -nStates(~idx_pos);        
    end

    nStatesConv = networkOpts.nStatesConv;
%     nStatesFC =   networkOpts.nStatesFC;

    nConvLayers = length(nStatesConv);

    
%     nStates = networkOpts.nStates;
            
        
    %  if there are any parameters not defined, assume they are the default parameters
    fn_default = fieldnames(defaultParams);
    for i = 1:length(fn_default)
        if ~isfield(networkOpts, fn_default{i})
            networkOpts.(fn_default{i}) = defaultParams.(fn_default{i});
        end
    end
            
    
    networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'filtSizes', nConvLayers);
    
    
    %  if any filtSizes == 0, set corresponding nStates equal to the number of states in the previous layer.
    for i = 1:nConvLayers 
        if networkOpts.filtSizes{i} == 0 
            % print(io.write('setting state %d = %d', i, nStates_ext[i-1]))
            if i == 1
                networkOpts.nStatesConv(i) = 1;
            else
                networkOpts.nStatesConv(i) = networkOpts.nStatesConv(i-1);
            end
        end
    end
    

    %  (2) pooling
    skipAllPooling = ~networkOpts.doPooling;
        
    if skipAllPooling 
        networkOpts.poolSizes = {zeros(1, nConvLayers)};
        networkOpts.poolStrides = {zeros(1, nConvLayers)};
        networkOpts.poolTypes = {zeros(1, nConvLayers)};
        
    else
        % - (1) poolSizes
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolSizes', nConvLayers);
                
        
        % - (2) poolStrides
        if strcmp(networkOpts.poolStrides, 'auto')
            networkOpts.poolStrides = networkOpts.poolSizes;
        end
        
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolStrides', nConvLayers);
        % - (3) poolTypes        
        
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolType', nConvLayers);

        
        %  if any layer has no pooling (poolSize == 0 or 1), set the stride & type to 0
        for i = 1:nConvLayers   
            if (networkOpts.poolSizes{i} == 0) || (networkOpts.poolSizes{i} == 1) 
                networkOpts.poolSizes{i} = 0;
                networkOpts.poolStrides{i} = 0;
                networkOpts.poolType{i} = 0;
            end
            if ~allowPoolStrideGreaterThanPoolSize && (networkOpts.poolStrides{i} > networkOpts.poolSizes{i}) 
                networkOpts.poolStrides{i} = networkOpts.poolSizes{i};
            end
            
        end
        
    end    
    return 
    
    
end


function networkOpts = makeSureFieldIsCorrectLength(networkOpts, fieldName, nConvLayers)
    %  make sure is in table format (if was a number)
    if iscell(networkOpts.(fieldName))
        networkOpts.(fieldName) = [networkOpts.(fieldName){:}];
    end
    if ~iscell(networkOpts.(fieldName)) 
        if ischar( networkOpts.(fieldName) )
            networkOpts.(fieldName) = {networkOpts.(fieldName)};
        else
            networkOpts.(fieldName) = num2cell( networkOpts.(fieldName) );
        end
    end

    %  handle case where length is shorter than number of convolutional layers (repeat)
    nInField = length(networkOpts.(fieldName));

    if nInField < nConvLayers  
        assert(nInField == 1)
        networkOpts.(fieldName) = repmat(networkOpts.(fieldName), 1, nConvLayers);
    end

    %  handle case where length is longer than number of convolutional layers (truncate)
    if nInField > nConvLayers 
        networkOpts.(fieldName)(nConvLayers+1:nInField) = [];
    end

    %  for 'max' pooling, make sure is uppercase ('MAX')
    for i = 1:nConvLayers 
        if ischar(networkOpts.(fieldName){i})
            networkOpts.(fieldName){i} = upper(networkOpts.(fieldName){i});
        end
    end

end
