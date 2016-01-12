function [convNet_str, convNet_str_nice] = getConvNetStr(networkOpts, niceOutputFields)

    defaultPoolStrideIsAuto = true;
    
    defaultParams = fixConvNetParams( getDefaultConvNetParams() );

    makeNiceString = nargout >= 2 && nargin >= 2;
    makefullNiceStr = makeNiceString && any(strcmpi(niceOutputFields, 'all'));
    
%     niceOutputFields = niceOutputFields || 'all'
    
    networkOpts = fixConvNetParams(networkOpts);
    
    nConvLayers = length(networkOpts.nStatesConv);
    nFCLayers = length(networkOpts.nStatesFC);

    convFunction = networkOpts.convFunction;
    
    convFcn_str = '';
    convFcn_str_nice = '';
    switch convFunction
        case {'SpatialConvolutionMap', 'SpatialConvolutionMM'}, convFcn_str = '';
        case 'SpatialConvolution', convFcn_str = 'f';  % = 'fully connected'
        case 'SpatialConvolutionCUDA', convFcn_str = 'c'; 
        otherwise, error('Unknown spatial convolution function : %s', convFunction);
    end

    
    nStates_str = toList( networkOpts.nStatesConv );
    nStates_str_nice = '';
    if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'nStates', 7)))
        nStates_str_nice = ['nFilt=' toList(networkOpts.nStatesConv, [], ',') '.'];
    end
    
    if nFCLayers > 0
        nStates_str = [nStates_str '_F' toList( networkOpts.nStatesFC) ];
        if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'nStates', 7)))
            nStates_str_nice = [nStates_str_nice, 'nFC=' toList(networkOpts.nStatesFC, [], ',') '.'];
        end
    end
    
    
    
    % (1) filtsizes
    
    filtSizes_str = '';
    filtSizes_str_nice = '';
    if ~isequalUpTo(networkOpts.filtSizes, defaultParams.filtSizes, nConvLayers)        
        if isequalUpTo(networkOpts.filtSizes, repmat({0},1, nConvLayers), nConvLayers)
            filtSizes_str = '_nofilt';
        else
            filtSizes_str = ['_fs' toList(networkOpts.filtSizes, nConvLayers)];
        end
    end
    if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'filtSizes', 8)))
        if isequalUpTo(networkOpts.filtSizes, repmat({0},1, nConvLayers), nConvLayers)
            filtSizes_str_nice = ' No Filter.';
        else
            
            filtSizes_x = cellfun(@(fsz) sprintf('%dx%d', fsz, fsz), networkOpts.filtSizes, 'un', 0);
            convFiltSizeStr = toList(filtSizes_x, nConvLayers, ', ');
            filtSizes_str_nice = [' FilterSize='  convFiltSizeStr  '.'];
            
        end
    end

    % (2) pooling
    skipAllPooling = ~networkOpts.doPooling;
    nLayersWithPooling = 0;
    for i = 1:nConvLayers
        if all(networkOpts.poolSizes{i} > 0) && (~skipAllPooling) 
            nLayersWithPooling = nLayersWithPooling + 1 ;
        end
    end
    skipAllPooling = skipAllPooling || (nLayersWithPooling == 0);
                    
    
    doPooling_str = '';    
    doPooling_str_nice = '';
    poolSizes_str = '';
    poolSizes_str_nice = '';
    poolType_str = '';
    poolType_str_nice = '';
    poolStrides_str = '';
    poolStrides_str_nice = '';
    
    
    if skipAllPooling
        doPooling_str = '_nopool';
        if makeNiceString && (makefullNiceStr || any(strcmpi(niceOutputFields, 'doPooling')) || any(strncmpi(niceOutputFields, 'pool', 4)) )
           doPooling_str_nice = ' No Pooling';
        end
        
    else
        % assuming that the default is to pooling.
        
        % 2a. Pooling Present in each layer 
        if makeNiceString && (makefullNiceStr || any(strcmpi(niceOutputFields, 'doPooling')) )
           doPooling_str_nice = ' Pooling: ';
        end
        if nLayersWithPooling < nConvLayers
                            
            for layer_i = 1:nConvLayers
%                doPooling_i = (networkOpts.poolSizes{layer_i} == 0) ;
%                doPooling_str = [doPooling_str iff(doPooling_i, '_pool', '_nopool') ];
                
                if  makeNiceString && (makefullNiceStr || any(strcmpi(niceOutputFields, 'doPooling')) )
                    % doPooling_str_nice =doPooling_str_nice .. iff(doPooling_i, 'Yes', 'No') .. iff(layer_i < nConvLayers, '/', '')
                end
            end
                
        end
                    
                
        % 2b. Pool Size(s)
        if ~isequalUpTo(networkOpts.poolSizes, defaultParams.poolSizes, nConvLayers)
            poolSizes_str = ['_psz' toList(networkOpts.poolSizes, nConvLayers)];
        end
        if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'poolSizes', 8)) )
%             str_func = @(i) sprintf('%dx%d', i);
            poolSizes_x = cellfun(@(psz) sprintf('%dx%d', psz, psz), networkOpts.poolSizes, 'un', 0);
            convPoolSizeStr = toList(poolSizes_x, nConvLayers, ', ');
            poolSizes_str_nice = [' PoolSize='  convPoolSizeStr   '.'];
        end
        
        % 2b. Pool Type(s) (pnorm)
        if ~isequalUpTo(networkOpts.poolType, defaultParams.poolType, nConvLayers)
            % print('filtSizes', networkOpts.filtSizes, filtSizes_default)
            if nUnique(networkOpts.poolType) > 1
                poolType_str = ['_pt'  toList(networkOpts.poolType,nConvLayers)];
            else
                poolType_str = ['_pt' num2str(networkOpts.poolType{1})];
            end
        end       
        if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'poolType', 8)) ) 
            if nUnique(networkOpts.poolType) > 1
                poolType_str_nice = [' Pnorm='  toList(networkOpts.poolType, nConvLayers, ',')  '.'];
            else
                poolType_str_nice = [' Pnorm='  num2str(networkOpts.poolType{1})  '.'];
            end
        
        end
        
        % 2c. PoolStrides(s)
        %{
        defaultPoolStrides = defaultParams.poolStrides;
        if strcmpi(defaultPoolStrides, 'auto')
            defaultPoolStrides = networkOpts.poolSizes; % use poolSize of current network
        end
        
        currentPoolStrides = networkOpts.poolStrides;
        if strcmpi(currentPoolStrides, 'auto')
            currentPoolStrides = networkOpts.poolSizes;
        end
        
        if ~isequalUpTo(currentPoolStrides, defaultPoolStrides, nConvLayers)
            poolStrides_str = ['_pst' toList(currentPoolStrides, nConvLayers)];
        end
        %}
        assert(defaultPoolStrideIsAuto)
        if ~isequalUpTo(networkOpts.poolSizes, networkOpts.poolStrides, nConvLayers)
            poolStrides_str = ['_pst' toList(networkOpts.poolStrides, nConvLayers)];
        end
        if makeNiceString && (makefullNiceStr || any(strncmpi(niceOutputFields, 'poolStrides', 10)) ) 
            poolStrides_str_nice = [' PoolStrd=' toList(networkOpts.poolStrides, nConvLayers, ',')  '.'];
        end
        
    end
    
       
    
    gpu_str = '';
    gpu_str_nice = '';
    useCUDAmodules = ~isempty(strfind(networkOpts.convFunction, 'CUDA'));
    if isfield(networkOpts, 'trainOnGPU') && networkOpts.trainOnGPU 
        gpu_str = '_GPU';
        if useCUDAmodules && networkOpts.GPU_batchSize > 1
            gpu_str = sprintf('_GPU%d', networkOpts.GPU_batchSize);
        end
        
        if makeNiceString && (makefullNiceStr || any(strcmpi(niceOutputFields, 'GPU')) ) 
            gpu_str_nice = ' (GPU)';
        end
        
    end

    convNet_str      = [convFcn_str      nStates_str      filtSizes_str       doPooling_str      poolSizes_str      poolType_str      poolStrides_str       gpu_str];
    convNet_str_nice = [convFcn_str_nice nStates_str_nice filtSizes_str_nice  doPooling_str_nice poolSizes_str_nice poolType_str_nice poolStrides_str_nice  gpu_str_nice];
    
end



%{


function [convNetStr, convNetStr_nice] = getConvNetStr(networkOpts, niceOutputFields)

    defaultParams = getDefaultConvNetParams();

    makeNiceString = nargout >= 2 && nargin >= 2;
        
%     nStates_str = table.concat(networkOpts.nStates, '_');
    nStates_str = toList( networkOpts.nStates, [], '_' );
    nStates_str_nice = '';
    if makeNiceString && any(strcmpi(niceOutputFields, 'nStates'))        
        nStates_str_nice = [toList( networkOpts.nStates, [], ',' ) '.'];
    end
%     nStates_str = cellstr2csslist( cellnum2cellstr( nStates_C ), '_');
    
    nConvLayers = length(networkOpts.nStates)-1;

    % filtsizes
    filtSizes_str = '';
    filtSizes_str_nice = '';
    if isfield(networkOpts, 'filtSizes') && ~isequalUpTo(networkOpts.filtSizes, defaultParams.filtSizes, nConvLayers)
        filtSizes_str = ['_fs' toList(networkOpts.filtSizes, nConvLayers, '_')];
    end
    if makeNiceString && any(strcmpi(niceOutputFields, 'filtSizes'))        
        filtSizes_str_nice = [' FiltSz=' toList(networkOpts.filtSizes, nConvLayers, ',') '.'];
    end
    
    % pooling
    % (1) pooling at all?
   Pooling = defaultParams.doPooling;
   doPooling_str = '';
   doPooling_str_nice = '';
    if isfield(networkOpts, 'doPooling') && (networkOpts.doPooling ~= defaultParams.doPooling) || ...
       isfield(networkOpts, 'poolSizes') && (defaultParams.doPooling == 1 && isequalUpTo(networkOpts.poolSizes, 0))
       Pooling = networkOpts.doPooling && (networkOpts.poolSizes ~= 0);
       doPooling_str = iff(doPooling, '_pool', '_nopool');
    end
    if makeNiceString && any(strcmpi(niceOutputFields, 'doPooling'))
       doPooling_str_nice = iff(doPooling, ' ', ' No pooling');
%        doPooling_str_nice = iff(doPooling, '(with Pooling)', ' (no pooling)');
    end
    
    poolSizes_str = '';     poolSizes_str_nice = '';
    poolType_str = '';      poolType_str_nice = '';
    poolStrides_str = '';   poolStrides_str_nice = '';
    ifPooling
    
        % (2) pool Size
        if isfield(networkOpts, 'poolSizes') && ~isequalUpTo(networkOpts.poolSizes, defaultParams.poolSizes, nConvLayers)
            poolSizes_str = sprintf('_psz%s', toList( networkOpts.poolSizes, nConvLayers) );
        end
        if makeNiceString && any(strcmpi(niceOutputFields, 'poolSizes'))
            poolSizes_x = arrayfun(@(s) sprintf('%dx%d', s, s), networkOpts.poolSizes(1:nConvLayers), 'un', 0);
            poolSizes_str_nice = [' Pooling size = ' toList(poolSizes_x, ',') '.'];
        end
        
        % (3) pooling type (p = 2, p = inf [=max pooling])
        if isfield(networkOpts, 'poolType') && ~isequalUpTo(networkOpts.poolType, defaultParams.poolType)
            poolType_str = sprintf('_pt%s', num2str(networkOpts.poolType));
        end
        if makeNiceString && any(strcmpi(niceOutputFields, 'poolType'))
            poolSizes_str_nice = [' Pnorm=' iff(isnumeric(networkOpts.poolType), num2str(networkOpts.poolType), 'inf') '.'];
        end
        
        % (3) pool Strides
        if isfield(networkOpts, 'poolStrides') 
            defaultPoolStrides = defaultParams.poolStrides;
            if strcmpi(defaultPoolStrides, 'auto')
                defaultPoolStrides = networkOpts.poolSizes;
            end
            currentPoolStrides = networkOpts.poolStrides;
            if strcmpi(currentPoolStrides, 'auto')
                currentPoolStrides = networkOpts.poolSizes;
            end
            if ~isequalUpTo(currentPoolStrides, defaultPoolStrides, nConvLayers) 
                poolStrides_str = sprintf('_pst%s', toList(currentPoolStrides, nConvLayers, '_'));
            end
            if makeNiceString && any(strcmpi(niceOutputFields, 'poolStrides'))
                if strcmpi(networkOpts.poolStrides, 'auto')
                    poolStrides_str_nice = [' PoolStrd=auto' ];
                else
                    poolStrides_str_nice = [' PoolStrd=' toList(currentPoolStrides, nConvLayers, ',') '.'];
                end
            end
        end

        
    
    end    
    
    convNetStr = [nStates_str   filtSizes_str  doPooling_str poolSizes_str poolType_str poolStrides_str];
    convNetStr_nice = [nStates_str_nice   filtSizes_str_nice  doPooling_str_nice poolSizes_str_nice poolType_str_nice poolStrides_str_nice];
    while strncmp(convNetStr_nice, ' ', 1)
        convNetStr_nice = convNetStr_nice(2:end);
    end
        
    
end
%}

function tf = isequalUpTo(x,y,maxN)

    haveMaxN = nargin >= 3;
    
    if haveMaxN && (maxN < 1) 
        error('Undefined behavior')
    end

    if length(x) > maxN
        x = x(1:maxN);
    end
    if length(y) > maxN
        y = y(1:maxN);
    end
    
    tf = isequal(x,y);
        
end



