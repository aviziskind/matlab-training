function [signalContrast, noiseContrast, logE, logN] = getSignalNoiseContrast(logEoverN, params)
    if nargin < 2
        params = struct;
    end
    if isfield(params, 'pixPerDeg')
        pixPerDeg = params.pixPerDeg;
    else
        pixPerDeg = 1;
    end
    
    if isfield(params, 'signalContrast')
        signalContrast=params.signalContrast;
    else
        signalContrast = 'signal';
    end
    
    logE=mean(params.logE1)+2*log10(params.signalContrast);    
    
    logN=logE-logEoverN;
    
    noiseContrast=sqrt((10^logN)*(pixPerDeg)^2);
    
    % default is to vary the contrast of the noise, but can manually set
    % varyContrast = 'signal' to change this.
    if isfield(params, 'varyContrast') && strcmp(params.varyContrast, 'signal')
        snr = signalContrast/noiseContrast;
        noiseContrast = 1;
        signalContrast = snr;
    end

    
end

