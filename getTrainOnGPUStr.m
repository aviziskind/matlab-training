function gpu_str = getTrainOnGPUStr(networkOpts)
    gpu_str = '';
%     useCUDAmodules = isfield(networkOpts, 'convFunction') && ~isempty(strfind(networkOpts.convFunction, 'CUDA'));

    if isfield(networkOpts, 'trainOnGPU') && networkOpts.trainOnGPU
        gpu_str = '_GPU';
        if (networkOpts.gpuBatchSize > 1) 
            gpu_str = ['_GPU' tostring(networkOpts.gpuBatchSize)];
        end
    end
    
    
end
