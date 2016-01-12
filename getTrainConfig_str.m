function [str, str_nice] = getTrainConfig_str(trainConfig)
    
    if isfield(trainConfig, 'adaptiveMethod')
        adaptiveMethod = lower(trainConfig.adaptiveMethod);
        isAdadelta = strcmp(adaptiveMethod, 'adadelta');
        isRMSprop  = strcmp(adaptiveMethod, 'rmsprop');
        isVSGD     = strcmp(adaptiveMethod, 'vsgd');

        if isAdadelta || isRMSprop 
            rho_default = 0.95;
            epsilon_default = 1e-6;
            
            rho = rho_default;
            if isfield(trainConfig, 'rho')
                rho = trainConfig.rho;
            end
            
            rho_str = '';
            if rho ~= rho_default 
                rho_str = ['_r' fracPart(rho)];
            end

            
            epsilon = epsilon_default;
            if isfield(trainConfig, 'epsilon')
                epsilon = trainConfig.epsilon;
            end

            epsilon_str = '';
            if epsilon ~= epsilon_default 
                epsilon_str = ['_e' logValueStr(epsilon)];
            end
            if isAdadelta 
                str = ['__AD'  rho_str  epsilon_str];
            elseif isRMSprop 
                str = ['__RMS' rho_str  epsilon_str];
            end
            
        elseif isVSGD 
            str = '__vSGD';
                
        end
    else
        learningRate_default = 1e-3;
        learningRateDecay_default = 1e-4;
        momentum_default = 0; %-- 0.95;
        
        learningRate = learningRate_default;
        if isfield(trainConfig, 'learningRate')
            learningRate = trainConfig.learningRate;
        end
            
       
        learningRate_str = '';
        if learningRate ~= learningRate_default;
            learningRate_str = logValueStr(trainConfig.learningRate);
        end
        
        learningRateDecay = learningRateDecay_default;
        if isfield(trainConfig, 'learningRateDecay')
            learningRateDecay = trainConfig.learningRateDecay;
        end
        
        learningRateDecay_str = '';
        if learningRateDecay ~= learningRateDecay_default 
            learningRateDecay_str = ['_ld' logValueStr(trainConfig.learningRateDecay)];
        end
        
        
        momentum = momentum_default;
        if isfield(trainConfig, 'momentum')
            momentum = trainConfig.momentum;
        end
        momentum_str = '';
        if momentum ~= momentum_default 
            momentum_str = ['_m' fracPart(trainConfig.momentum)];
            
            if isfield(trainConfig, 'nesterov') && isequal(trainConfig.nesterov, 1)
                momentum_str = [momentum_str 'n'];
            end
        end
        
        
        str = ['__SGD' learningRate_str  learningRateDecay_str momentum_str];
        
    end
    
    str_nice = strrep(str, '__', '');
    str_nice = strrep(str_nice, '_', '-');
    str_nice = '';
    
end


function str = logValueStr(x)
    if x > 0 
        str = num2str(-math.log10(x));
    else
        str = 'X';
    end
end

function str = fracPart(x)
    str = num2str(x);
    i = strfind(str, '.')+1;
    str = str(i:end);
end
