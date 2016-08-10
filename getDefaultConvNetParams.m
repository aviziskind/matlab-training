function params = getDefaultConvNetParams()
    
    % params.nStates = [6,16,-120];
    params.nStatesConv = [6,16];
    params.nStatesFC = [120];
    params.filtSizes = [5,4];
    params.fanin = [1,4,16];

    params.doPooling = true;
    params.poolSizes = [4,2];
    params.poolTypes = 2;
    params.poolStrides = 'auto'; %[2,2];
    params.convFunction = 'SpatialConvolutionMap';
end