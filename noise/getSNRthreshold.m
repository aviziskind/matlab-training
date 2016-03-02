function [snr_th, bestFitFunc, snr_th_ci, b_best_fit] = getSNRthreshold(allLogSNRs, pcorrect, opt)
    
    if nargin < 3
        opt = struct;
    end
    
    th_pct_correct = 64; % default value;
    if isfield(opt, 'th_pct_correct')
        th_pct_correct = opt.th_pct_correct;
    end
    th_pct_correct_frac =  th_pct_correct / 100;
    
    nClasses = 26;
    if isfield(opt, 'nClasses')
        nClasses = opt.nClasses;
    end

    guessRate = 1/nClasses;
    if isfield(opt, 'guessRate')
        guessRate = opt.guessRate;
    end
    
    assumeMax100pct = 0;
    if isfield(opt, 'assumeMax100pct')
        assumeMax100pct = opt.assumeMax100pct;
    end
    
    nSNRs = length(allLogSNRs);
    if size(pcorrect,1) > 1 && size(pcorrect,2) > 1 
        [nCurves, nSNRs_pcorrect] = size(pcorrect);
        assert(nSNRs_pcorrect == nSNRs);
        snr_th = zeros(1,nCurves); bestFitFunc = cell(1, nCurves);
        for ci = 1:nCurves
            [snr_th(ci), bestFitFunc{ci}] = getSNRthreshold(allLogSNRs, pcorrect(ci,:), opt);
        end
        return;
    end
    
    fitFunc = 'weibull';
    
%     fitFunc = 'sigmoid';
    
%     allSNRs = 10.^allLogSNRs;
       
    gamma = guessRate;
    if assumeMax100pct
%         weibull = @(beta, c) (1 - (1-gamma).* exp (- (( (c) ./beta(1)).^(beta(2)) ) ) );
%         weibull_log = @(beta, c) (1 - (1-gamma).* exp (- (( (log10(c)) ./beta(1)).^(beta(2)) ) ) );
    else
%         weibull = @(beta, c) (beta(1) - (beta(1)-gamma).* exp (- (( (c) ./beta(2)).^(beta(3)) ) ) );
%         weibull_log = @(beta, c) (beta(1) - (beta(1)-gamma).* exp (- (( ( 10.^(c) ) ./beta(2)).^(beta(3)) ) ) );
    end
    
    sigmoid = @(beta, x) gamma + beta(1)./(1+exp( - (x-beta(2))/beta(3)) );
    
%     s = M./(1+exp( - (x-x50)/w) );
    
    
    
    %%

    assert(~any(isnan(pcorrect(:))));
    assert(~any(isnan(allLogSNRs)));

    if any(pcorrect > 1)
        pcorrect = pcorrect / 100;
    end
    
    if (pcorrect(1) > th_pct_correct_frac) && (pcorrect(2) < th_pct_correct_frac)
        pcorrect(1) = pcorrect(2);
    end
        
    
    
    allLogSNRs = allLogSNRs(:);
    allSNRs = 10.^allLogSNRs;
    pcorrect = pcorrect(:);
   
    endIsBelowTh = max(pcorrect) < th_pct_correct / 100;
%     endIsBelowTh = pcorrect(end) < th_pct_correct / 100;

    if max(pcorrect) / pcorrect(end) > 2
        %%
        [maxVal, i_max] = max(pcorrect);
        pcorrect(i_max+1:end) = maxVal;
        3;
    end
    
    startIsAboveTh = pcorrect(1) > (th_pct_correct+5) / 100;
    
    snr_th = nan;
    bestFitFunc = [];
    snr_th_ci = nan(1,2);
    b_best_fit = nan(1, 3);
    if endIsBelowTh
        return;
%         snr_est = allLogSNRs(end);
    elseif startIsAboveTh
        dSNR = max(diff(allLogSNRs));
        snr_th = 10^(allLogSNRs(1)-dSNR);
        return;
    else
    %%
        lo = find(pcorrect >= th_pct_correct/100, 1)-1;
        if lo == 0
            
            log_snr_th_est = allLogSNRs(1);            
        else
            
            hi = lo + 1;
            log_snr_th_est_range = allLogSNRs([lo, hi]);
            assert( isequal( pcorrect([lo, hi]) >= th_pct_correct/100, [0; 1]))
            log_snr_th_est = mean(log_snr_th_est_range);
            
        end
        snr_th_est = 10^log_snr_th_est;
        
    end
    
    
%     snr_est = interp1q(pcorrect([lo, hi]), allSNRs([lo, hi]), 0.64) 
    
%     beta0_1 = allSNRS(snr_est 
    warningsToIgnore = {'stats:nlinfit:IllConditionedJacobian', 'stats:nlinfit:IterationLimitExceeded', 'stats:nlinfit:ModelConstantWRTParam', 'MATLAB:nearlySingularMatrix'};
    for i = 1:length(warningsToIgnore)
        warning('off', warningsToIgnore{i})
    end
    lastwarn('');
    
    if strcmp(fitFunc, 'weibull')
        %%
        beta0 = [snr_th_est, 1.0];
        if ~assumeMax100pct
            
        end
        
        if assumeMax100pct
            weibull_func = @(beta, x) weibull([1, beta], x, gamma);
        else
            beta0 = [1 beta0];
            weibull_func = @(beta, x) weibull(beta, x, gamma);
        end
        
        
        [b_best_fit, resid,J,Sigma,mse] = nlinfit(allSNRs, pcorrect, weibull_func, beta0) ;
        b_best_fit = abs(b_best_fit);
        
        if assumeMax100pct
%             b_best_fit = [1, b_best_fit];
        end
        
        [msg_str,msg_id] = lastwarn;
        if ~isempty(msg_id) && ~any(strcmp(msg_id, warningsToIgnore))
            3;
        end
%         [b_best_fit2, resid,J,Sigma,mse] = nlinfit(allLogSNRs, pcorrect, weibull_log, beta0) ;
        
        bestFitFunc = @(x) weibull_func(b_best_fit, x) * 100 ;% weibull(b_best_fit, x, gamma)*100;

    elseif strcmp(fitFunc, 'sigmoid')
        
        beta0 = [1, log_snr_th_est, 1.0];
        [b_best_fit, resid,J,Sigma,mse] = nlinfit(allLogSNRs, pcorrect, sigmoid, beta0) ;
       

        bestFitFunc = @(x) sigmoid(b_best_fit, x)*100;

    end
    for i = 1:length(warningsToIgnore)
        warning('on', warningsToIgnore{i})
    end

        
    
    [msg_str,msg_id] = lastwarn;
    if ~isempty(msg_id) && ~any(strcmp(msg_id, warningsToIgnore))
        3;
%         fprintf('%s\n', msg);
%         lastwarn('');
    end

    calcCI = nargout >= 3;
    allSNRs_fine = logspace(allLogSNRs(1), allLogSNRs(end), 200)';

    allSNR_lims = lims(allSNRs, 0.2, [], 1);
    
    if endIsBelowTh
        snr_th = nan;
    elseif bestFitFunc(allSNR_lims(2)) < th_pct_correct || bestFitFunc(allSNR_lims(1)) > th_pct_correct
        snr_th = nan;
    else        
        [snr_th, fev, exit_flag, output] = fzero(@(x) bestFitFunc(x) - th_pct_correct, allSNR_lims );
        if exit_flag < 0
            3;
        end
        
        if calcCI 
            %%
            [ypred, delta] = nlpredci(weibull_func,allSNRs_fine,b_best_fit,resid,'covar',Sigma);
            pcorrect_lo = (ypred(:) - delta(:))*100;
            pcorrect_hi = (ypred(:) + delta(:))*100;
            
%             interp1q(
            
            snr_lo_idx = find(pcorrect_lo > th_pct_correct, 1);
            if ~isempty(snr_lo_idx)
                idx_around_lo = snr_lo_idx + [-1:1];
                if idx_around_lo(1) > 0 && idx_around_lo(end) < length(allSNRs_fine)
                    snr_lo = interp1q(pcorrect_lo(idx_around_lo), allSNRs_fine(idx_around_lo), th_pct_correct);
                else
                    snr_lo = allSNRs_fine(snr_lo_idx);
                end
            else
                snr_lo = nan;
            end

            
            snr_hi_idx = find(pcorrect_hi > th_pct_correct, 1);
            if ~isempty(snr_hi_idx)
                idx_around_hi = snr_hi_idx + [-1:1];
                if idx_around_hi(1) > 0 && idx_around_hi(end) < length(allSNRs_fine)
                    snr_hi = interp1q(pcorrect_hi(idx_around_hi), allSNRs_fine(idx_around_hi), th_pct_correct);
                else
                    snr_hi = allSNRs_fine(snr_hi_idx);
                end
            else
                snr_hi = nan;
            end
            snr_th_ci = [snr_hi, snr_lo];
            
                        
        end
        
    end
    
    3;
    show = 0;
    if show
       %% 
%        b_best_fit = [1 1.2407    0.8981];

       bestFitFunc = @(x) weibull(b_best_fit, x, gamma)*100;
       
       figure(55); clf; hold on;
       plot(allSNRs, pcorrect*100, 'bo');
       xlims = lims(allSNRs, .01, 1, 1);
       set(gca, 'xscale', 'log', 'xlim', xlims, 'ylim', [0, 101]);
       
       
       if ~isnan(snr_th)
           line([xlims(1), snr_th], [th_pct_correct]*[1, 1], 'color', 'r', 'linestyle', '--');
           line([snr_th]*[1,1], [0, th_pct_correct], 'color', 'r', 'linestyle', '--');
       end
       
       pcorrect_fine = bestFitFunc(allSNRs_fine);
        plot(allSNRs_fine,pcorrect_fine, ['b-'], 'linewidth', 1)
        
        if calcCI
            plot(allSNRs_fine, pcorrect_lo, 'ro:')
            plot(allSNRs_fine, pcorrect_hi, 'ro:');
            line(snr_th_ci, 64*[1, 1], 'color', 'k');
        end
        3;
        %%
%         allLogSNRs_ext = [-5,-4, -3, allLogSNRs];
% 3;
%         b_best_fit2 = nlinfit([allLogSNRs], [pcorrect], weibull, beta0) ;
% 
%         weibull_fit2 = @(x) weibull(b_best_fit2, x)*100;
%        [xx2,yy2] = fplot(weibull_fit, [0, 4]);
%         plot(xx2,yy2, ['r:'], 'linewidth', 1)

        3;

        
    end
    
        
end