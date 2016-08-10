
%     Y = rand(1,100)+([1:100]/100*5);
    Y = gaussSmooth( rand(1,100), 2, [], 1);
    Y = (Y-mean(Y))/std(Y);
%     for i = 1:40
        w = 3;
        Y_nrm          = nn_SpatialContrastiveNormalization(Y, 15, .1); 
        Y_nrm_circ     = nn_SpatialContrastiveNormalization(Y, 15, .1, 1); 

%         Y_sm_fft      = gaussSmooth(Y, w, 1,  0, 1); 
%         Y_sm_circ_fft = gaussSmooth(Y, w, 1,  1, 1); 
%         Y_sm          = gaussSmooth(Y, w, 1,  0); 
%         Y_sm_circ     = gaussSmooth(Y, w, 1,  1); 
% 
%         Y_sm_fft      = gaussSmooth(Y, w, 1,  0, 1); 
%         Y_sm_circ_fft = gaussSmooth(Y, w, 1,  1, 1); 
%     end    
%      profile viewer;
    %%
    
    figure(1); clf;
    plot(Y, 'b.-');
    hold on;
    plot([Y_nrm; Y_nrm(1)], 'r.-')
    plot([Y_nrm_circ; Y_nrm_circ(1)], 'go-')
