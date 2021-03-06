function [convNet_str, convNet_str_nice] = getConvNetStr(networkOpts, niceOutputFields)

    defaultPoolStrideIsAuto = true;
    
    defaultParams = fixConvNetParams( getDefaultConvNetParams() );

    makeNiceString = nargout >= 2 && nargin >= 2;
    makefullNiceStr = makeNiceString && any(strcmpi(niceOutputFields, 'all'));
    
%     niceOutputFields = niceOutputFields || 'all'
    
    networkOpts = fixConvNetParams(networkOpts);
    
    nConvLayers = length(networkOpts.nStatesConv);
    nFCLayers   = length(networkOpts.nStatesFC);

    convFunction = networkOpts.convFunction;
    
    
    convFcn_str = '';
    convFcn_str_nice = '';
    
    switch convFunction
        case 'SpatialConvolution', convFcn_str = 'f';  % = 'fully connected'
        case 'SpatialConvolutionMM', convFcn_str = 'm';
        case 'SpatialConvolutionMap', convFcn_str = '';
        case 'SpatialConvolutionCUDNN', convFcn_str = 'cd'; 
        case 'SpatialConvolutionCUDA', convFcn_str = 'c'; 
        otherwise, error('Unknown spatial convolution function : %s', convFunction);
    end
    
    
    convPad_str = '';
    convPad_str_nice = '';
    % default is : DON'T add zeroPadding before convolutions
    if isfield(networkOpts, 'zeroPadForConvolutions') && (networkOpts.zeroPadForConvolutions == true) 
        convPad_str = 'P';
        convPad_str_nice = '(P)';
    end
    
    
    poolPad_str = '';
    poolPad_str_nice = '';
    %  default is : DO add zeroPadding before pooling
    if isfield(networkOpts, 'zeroPadForPooling') && (networkOpts.zeroPadForPooling == false) 
        poolPad_str = 'NP';
        poolPad_str_nice = '(NP)';
    end    
    
    
    nStates_str = toList( networkOpts.nStatesConv, [], '_');
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
    
    
    
    propertyOpts.filtSizes = struct('prefix', 'fs',   'prefix_nice', 'FilterSz',   'suffix', convPad_str,  'suffix_nice', convPad_str_nice,  ...
                                    'str_NA', 'nofilt', 'str_NA_nice', 'No Filter', 'is2D', true);
    propertyOpts.poolSizes = struct('prefix', 'psz', 'prefix_nice', 'PoolSize',  'suffix', poolPad_str,  'suffix_nice', poolPad_str_nice, ...
                                    'str_NA', 'nopool', 'str_NA_nice', 'No Pooling', 'is2D', true);
    propertyOpts.poolTypes = struct('prefix', 'pt',   'prefix_nice', 'Pnorm',  'suffix', '',  'suffix_nice',  '', ...
                                    'str_NA', '',       'str_NA_nice', '',  'is2D', false);
    propertyOpts.poolStrides = struct('prefix', 'pst', 'prefix_nice', 'PoolStrides',  'suffix', '',  'suffix_nice', '',  ...
                                    'str_NA', '',       'str_NA_nice', '', 'is2D', true);

    networkPropertyStr = @(fieldName)  getNetworkPropertyStr(fieldName, networkOpts, defaultParams, propertyOpts);
    % (1) filtsizes
    
    [filtSizes_str, filtSizes_str_nice] = networkPropertyStr('filtSizes');


    % (2) pooling
    skipAllPooling = ~networkOpts.doPooling;
    nLayersWithPooling = 0;
    for i = 1:nConvLayers
        if all(networkOpts.poolSizes{i} > 0) && (~skipAllPooling) 
            nLayersWithPooling = nLayersWithPooling + 1 ;
        end
    end
    skipAllPooling = skipAllPooling || (nLayersWithPooling == 0);
                    
    
    [doPooling_str,      poolSizes_str,       poolTypes_str,      poolStrides_str]      = deal('');    
    [doPooling_str_nice, poolSizes_str_nice,  poolTypes_str_nice, poolStrides_str_nice] = deal('');
    
    
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
                    
        [poolSizes_str, poolSizes_str_nice] = networkPropertyStr('poolSizes');
        
        [poolTypes_str, poolTypes_str_nice] = networkPropertyStr('poolTypes');       
                
        assert(defaultPoolStrideIsAuto)
        if ~isequalUpTo(networkOpts.poolSizes, networkOpts.poolStrides, nConvLayers)
            [poolStrides_str, poolStrides_str_nice] = networkPropertyStr('poolStrides');
        end
        
    end
    
    
    [nLinType_str, nLinType_str_nice] =  getNonlinearityStr(networkOpts);
       
    gpu_str = getTrainOnGPUStr(networkOpts);

    dropout_str = getDropoutStr(networkOpts);
    
    
    convNet_str      = [convFcn_str      nStates_str      filtSizes_str       ...
                        doPooling_str      poolSizes_str      poolTypes_str      poolStrides_str       ...
                        nLinType_str      dropout_str  gpu_str];
    convNet_str_nice = [convFcn_str_nice nStates_str_nice filtSizes_str_nice  ...
                        doPooling_str_nice poolSizes_str_nice poolTypes_str_nice poolStrides_str_nice  ...
                        nLinType_str_nice dropout_str gpu_str];
    
        
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


function [property_str,property_str_nice] = getNetworkPropertyStr(fieldName, networkOpts, defaultParams, propertyOpts)  %-- fieldPrefix, fldAbbrev_nice, str_NA, str_NA_nice, is2D
    nConvLayers = length(networkOpts.nStatesConv);
    networkProp = networkOpts.(fieldName);
    networkProp_str = cellfun(@num2str, networkProp, 'un', 0);
    defaultProp = defaultParams.(fieldName);
    property_str = '';
    property_str_nice = '';
    opt = propertyOpts.(fieldName);

    function s_ext = extendProp(s)
        if opt.is2D 
            s_ext = [s 'x' s];
        else
            s_ext = num2str(s);
        end
    end

    assert(length(networkProp) == nConvLayers)
    if ~isequalUpTo(networkProp, defaultProp, nConvLayers) 
        if isequalUpTo(networkProp, num2cell(zeros(1, nConvLayers)), nConvLayers) 
            property_str =      ['_'  opt.str_NA];
            property_str_nice = [ opt.str_NA_nice '. '];

        elseif (nUnique(networkProp)) == 1 % 
            property_str = ['_'  opt.prefix networkProp_str{1}  opt.suffix];
            prop_str_nice = extendProp(networkProp_str{1});
            property_str_nice = [opt.prefix_nice '='  prop_str_nice  opt.suffix_nice '. '];

        else
            
            if ischar( networkProp{1} )
                list_str = strjoin( networkProp_str, '_');
                list_str_long = list_str;
            else
                list_str = abbrevList(  [networkProp{:}] );
                list_str_long = abbrevList([networkProp{:}], '_', -1);
            end

            property_str = ['_'  opt.prefix  list_str opt.suffix];

            tbl_vals = strsplit(list_str_long, '_');
            tbl_ext_vals = cellfun(@extendProp, tbl_vals, 'un', 0);
            list_nice_ext = strjoin( tbl_ext_vals, ',');

            property_str_nice =  [opt.prefix_nice  '='  list_nice_ext  opt.suffix_nice  '. '];

        end
    end

   
end
    


