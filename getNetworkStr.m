function [str, str_nice] = getNetworkStr(networkOpts, varargin)

    if strcmp(networkOpts.netType, 'ConvNet')
        
        [convStr, convStr_nice] = getConvNetStr(networkOpts, varargin{:});
        str = ['Conv_' convStr];
        str_nice = ['ConvNet; ' convStr_nice];
%         str_nice = [convStr_nice];
    elseif strcmp(networkOpts.netType, 'MLP')
        [mlpStr, mlpStr_nice] = getMLPstr(networkOpts, varargin{:});
        str = ['MLP_' mlpStr];
        str_nice = ['MLP; ' mlpStr_nice];
    else
        error(['Unknown network type : ' networkOpts.netType]);
    end

    
    
    if isfield(networkOpts, 'trainConfig')  && ~isempty(networkOpts.trainConfig)
        [trainConfig_str, trainConfig_str_nice] = getTrainConfig_str(networkOpts.trainConfig);
        str = [str trainConfig_str];
        if ~isempty(trainConfig_str_nice)
            str_nice = [str_nice ' (' trainConfig_str_nice ')'];
        end
    end

    
    if isfield(networkOpts, 'partModelOpts') && ~isempty(networkOpts.partModelOpts)
        partModelOpts_str = getPartModelOptStr(networkOpts.partModelOpts);  %  -- e.g. indep_90 (independent scales, 90x90 input)
%         netStr = netStr .. partModelOpts_str
        if ~isempty(partModelOpts_str)
            str = [str '_' partModelOpts_str];
        end
    end
    
    
    if isfield(networkOpts, 'nConfidenceUnits') && networkOpts.nConfidenceUnits > 0
        str = [str  sprintf('_Conf%d', networkOpts.nConfidenceUnits)];
    end

    if isfield(networkOpts, 'trialId') && ~isequal(networkOpts.trialId, 1)
        str = [str  '__tr' num2str(networkOpts.trialId)];
    end
    
end