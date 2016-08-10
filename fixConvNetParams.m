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
        idx_conv = nStates > 0;
        networkOpts.nStatesConv = nStates(idx_conv);
        networkOpts.nStatesFC = -nStates(~idx_conv);        
    end

    nStatesConv = networkOpts.nStatesConv;
    nConvLayers = length(nStatesConv);

          
        
    %  if there are any parameters not defined, assume they are the default parameters
    fn_default = fieldnames(defaultParams);
    for i = 1:length(fn_default)
        if ~isfield(networkOpts, fn_default{i})
            networkOpts.(fn_default{i}) = defaultParams.(fn_default{i});
        end
    end
            
    
    
    networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'filtSizes', @isnumeric);
   
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
        networkOpts.poolSizes =  num2cell(zeros(1, nConvLayers)) ;
        networkOpts.poolStrides =  num2cell( zeros(1, nConvLayers) );
        networkOpts.poolTypes =  num2cell(zeros(1, nConvLayers));
        
    else
        % - (1) poolSizes
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolSizes', @isnumeric);
                
        
        % - (2) poolStrides
        if strcmp(networkOpts.poolStrides, 'auto')
            networkOpts.poolStrides = networkOpts.poolSizes;
        end
        
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolStrides', @isnumeric);
        % - (3) poolTypes        
        
        isValidPoolType = @(x) isnumeric(x) ||  strcmp(x, 'MAX');
        networkOpts = makeSureFieldIsCorrectLength(networkOpts, 'poolTypes', isValidPoolType);

        
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
    
    
    allSpatialNormTypes = {'Subtr', 'Div'};
    validNormTypes = {'Gauss'};
    for norm_type_idx = 1:length(allSpatialNormTypes)
        normType = allSpatialNormTypes{norm_type_idx};
        
        masterNormFlagField = ['doSpat' normType  'Norm'];
        normTypeField       = ['spat'  normType   'NormType'];
        normWidthField      = ['spat'  normType   'NormWidth'];
        
    
        % -- (3a) check if master flag is set to 0
        skipAllNorm = ~isfield(networkOpts, masterNormFlagField) || (networkOpts.(masterNormFlagField) == false ) || ...
            isempty(networkOpts.(normTypeField))  || isempty(networkOpts.(normWidthField));
        
        
%         -- (3b) check if master flag is set to 0
        if skipAllNorm 
            networkOpts.(normTypeField)   = repmat({'none'}, 1, nConvLayers);
            networkOpts.(normWidthField)  = zeros(1, nConvLayers);
            
        else
            
            isValidSpatialNormType = @(x) any(strcmp(x, validNormTypes));    
            networkOpts = makeSureFieldIsCorrectLength(networkOpts, normTypeField,  isValidSpatialNormType);
            
            networkOpts = makeSureFieldIsCorrectLength(networkOpts, normWidthField, @isnumeric);
        end
        
        
%         -- (3c) if no normalization at all, set the master flag to 0, and set all other parameters accordingly
        normInAnyLayers = false;
        for i = 1:nConvLayers 
            if (networkOpts.(normWidthField)(i) > 0) 
                normInAnyLayers = true;
            end
        end
        networkOpts.(masterNormFlagField) = normInAnyLayers && ~skipAllNorm;
        
        if ~normInAnyLayers 
            networkOpts.(normTypeField)   = repmat({'none'}, 1, nConvLayers);
            networkOpts.(normWidthField)  = zeros(1, nConvLayers);
        end
        
        
    end    
    
    

    
    
end


function networkOpts = makeSureFieldIsCorrectLength(networkOpts, fieldName, isValid_func)
    nConvLayers = length(networkOpts.nStatesConv);
    %  make sure is in vector format (if is a cell array)
    if iscell(networkOpts.(fieldName))
        networkOpts.(fieldName) = [networkOpts.(fieldName){:}];
    end
    
    %  make sure is in cell array format (if numeric)
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

    if exist('isValid_func', 'var')
        for i = 1:nConvLayers 
            if ~isValid_func( networkOpts.(fieldName){i} ) 
                error('Error for field %s: %s\n  (did not satisfy criteria function)', fieldName, tostring(networkOpts.(fieldName){i}) ) ;
            end
        end

    end   
end
