function [filtStr, filtStr_nice] = getFilterStr(filt, wForWhiteFlag)
    doNiceStr = nargout > 1;

    addFexpToNiceStrIfNot1 = 1;
    
    if strcmp(filt, 'same')
        [filtStr, filtStr_nice] = deal('same');
        return;
    end
    
    
    if strncmp(filt.filterType, '1/f', 3)
        
        f_exp_std_str = '';
        f_exp_std_str_nice = '';
        if isfield(filt, 'f_exp_std') && filt.f_exp_std > 0
            f_exp_std_str = sprintf('s%.0f', filt.f_exp_std*100);
            f_exp_std_str_nice = sprintf(' (sd=%.1f)', filt.f_exp_std);
        end
        
        if isfield(filt, 'ratio') 
            if isinf(filt.ratio)
                filt.filterType = '1/f';
            elseif filt.ratio == 0;
                filt.filterType = 'white';
            end
        end
        
        if doNiceStr
        
            if addFexpToNiceStrIfNot1 || (filt.f_exp ~= 1)
                f_exp_str_nice = sprintf('^{%.1f}', filt.f_exp);
    %             f_exp_str = '';
            else
                f_exp_str_nice = '';
            end
        end
    end

%     default_filter = struct('filterType', 'white');
%     if isempty(filt)
%         filt = default_filter;
%     end
    
    applyFourierMaskGainFactor_default = 0;
    if strcmp(filt.filterType, 'white')
        applyFourierMaskGainFactor = 0;
    elseif isfield(filt, 'applyFourierMaskGainFactor')
        applyFourierMaskGainFactor = filt.applyFourierMaskGainFactor;
    else
        applyFourierMaskGainFactor = applyFourierMaskGainFactor_default;
    end
    norm_str = iff(applyFourierMaskGainFactor, 'N', '');
    
    
    
    
    switch filt.filterType
        case 'white',
            if exist('wForWhiteFlag', 'var') && isequal(wForWhiteFlag, 1)
                filtStr = 'w';
            else
                filtStr = '';
            end
            if doNiceStr
                filtStr_nice = 'White noise^{ }';
            end
            norm_str = '';
            
        case 'band',
            if isfield(filt, 'cycPerLet_centFreq')
                
                filtStr = sprintf('Nband%.0f', filt.cycPerLet_centFreq*10);
                if doNiceStr
                    filtStr_nice = sprintf('Band noise: %.1f c/l', filt.cycPerLet_centFreq);
                end
            elseif isfield(filt, 'pixPerCycle_centFreq')
                
                filtStr = sprintf('Nband%.0fppc', filt.pixPerCycle_centFreq);
                
            elseif isfield(filt, 'cycPerPix_centFreq')
                
                filtStr = sprintf('Nband%.0fcpp', filt.cycPerPix_centFreq);
            end
            
   
            
         case 'hi',
            filtStr = sprintf('Nhi%.0f', filt.cycPerLet_cutOffFreq*10);
            if doNiceStr
                filtStr_nice = sprintf('Hi-pass noise: %.1f c/l', filt.cycPerLet_cutOffFreq);
            end
            
        case 'lo',
            filtStr = sprintf('Nlo%.0f', filt.cycPerLet_cutOffFreq*10);
            if doNiceStr
                filtStr_nice = sprintf('Lo-pass noise: %.1f c/l', filt.cycPerLet_cutOffFreq);
            end

        case '1/f',
            
            filtStr = sprintf('Npink%.0f%s', filt.f_exp*10, f_exp_std_str);
            if doNiceStr
%                 filtStr_nice = sprintf('Pink Noise: 1/f^{%.1f}', filt.f_exp);
                filtStr_nice = sprintf('1/f%s%s noise', f_exp_str_nice, f_exp_std_str_nice);

            end
            
        case {'1/fPwhite', '1/fOwhite'}
            f_exp = filt.f_exp;
            f_exp_default = 1.0;
            f_exp_str = '';
            pinkWhiteRatio = filt.ratio;
            
            pinkExtraStr = '';
            whiteExtraStr = '';
            if pinkWhiteRatio > 1
                pinkExtraStr = sprintf('%.0f', pinkWhiteRatio * 10);
            elseif pinkWhiteRatio < 1
                whiteExtraStr = sprintf('%.0f', (1/pinkWhiteRatio)*10 );
            end
            
            if f_exp ~= f_exp_default
                f_exp_str = sprintf('%.0f', f_exp*10);
            end
            
            plus_or_str = switchh(filt.filterType, {'1/fPwhite','1/fOwhite'}, {'P', 'O'});
            plus_or_str_nice = switchh(filt.filterType, {'1/fPwhite','1/fOwhite'}, {' + ', ' & '});
            
            filtStr = sprintf('N%spink%s%s%sw%s', pinkExtraStr, f_exp_str, f_exp_std_str, plus_or_str, whiteExtraStr);
            if doNiceStr                
                if pinkWhiteRatio ~= 1
                    ratio_str = sprintf('(r=%s)', num2str(pinkWhiteRatio));
                else
                    ratio_str = '';
                end
                filtStr_nice = sprintf('1/f%s%s %s White %s noise', f_exp_str_nice, f_exp_std_str_nice, plus_or_str_nice, ratio_str);
%                     filtStr_nice = sprintf('1/f Noise');
            end
                        

    end
    filtStr = [filtStr norm_str];

end
