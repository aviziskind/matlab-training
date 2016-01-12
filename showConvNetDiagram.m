function showConvNetDiagram

    netType = 'ConvNet';
%     netType = 'MLP';
    
    if strcmp(netType, 'ConvNet')
    %     allNStates = {{24,120}};
        allNStates = {{6,15,15}};
        allFiltSizes = {5, 5};
        allPoolSizes_C = {2, 2};
        allPoolTypes = {2, 2};

          allNStates_6_X = {  {6, 8}, {6, 15}, {6, 30}, {6,60}, {6,120} };
          allNStates_X_15 = {  {3, 15}, {6, 15}, {12, 15}, {24,15}, };
    %%
        multiple_networks = '';
    % %     multiple_networks = 'nStates1';
    %     multiple_networks = 'nStates2';
    %     multiple_networks = 'filtSizes';
    %     multiple_networks = 'poolSizes';
    %     multiple_networks = 'poolTypes';

        switch multiple_networks
            case '',
            case 'nStates1',  allNStates =  allNStates_X_15;
            case 'nStates2',  allNStates =  allNStates_6_X;
            case 'filtSizes', allFiltSizes = {2,4,5,10,20};
    %         case 'filtSizes', allFiltSizes = {10};
            case 'poolSizes', allPoolSizes_C = {1,2,4,6,8};
    %         case 'poolSizes', allPoolSizes_C = {1};
            case 'poolTypes', allPoolTypes = {1,2,'MAX'};

        end
        allNStates = cellcell2cellarray(allNStates);
          allConvNetOptions = struct('netType', 'ConvNet', ...
                                     'tbl_nStates', {allNStates}, ...
                                      'tbl_filtSizes', {allFiltSizes}, ...
                                      'doPooling', 1, ...
                                      'tbl_poolSizes', {allPoolSizes_C}, ...
                                      'tbl_poolType', {allPoolTypes}, ...
                                      'poolStrides', 'auto' ... 
                                          );
           allNetworks = expandOptionsToList(allConvNetOptions);
        fprintf('\n--- %s ---\n', multiple_networks);
    
    elseif strcmp(netType, 'MLP')
%         nHiddenUnits = {  {5}, {10}, {15}, {30}, {60}, {120}, {}  };
        nHiddenUnits = {  {15} };
        allNetOptions = struct('netType', 'MLP', ...
                               'tbl_nHiddenUnits', {nHiddenUnits} ...
                                );
       allNetworks = expandOptionsToList(allNetOptions);
        
    end
    
    S = load('sampleImage.mat');
    sampleImage = S.X;
    
    
    for net_i = 1:length(allNetworks)
        
    
        network_i = allNetworks(net_i);
        [net_i_str, net_i_nice_str] = getNetworkStr(network_i);
        fprintf('%s : %s \n', net_i_str, net_i_nice_str);
        
        showConvNet(network_i, sampleImage, net_i, net_i_str);
    end

end


function showConvNet(p, X, figId, net_title)
    %%
%     figId = 10;
    figure(figId);
    if nargin < 4
        net_title = '';
    end
    set(figId, 'name', net_title);
    clf;
    
    

    scl = 5;

    
    
    conv_color = 'b';
    pool_color = 'r';
     
    if strcmp(p.netType, 'ConvNet')
        Wtot = 1000;
        Htot = 300;
    
        props.image = 80;
        props.conv = 120;
        props.pool = 80;
        props.fcu = 60;
        props.class = 20;
        
    elseif strcmp(p.netType, 'MLP')
        Wtot = 800;
        Htot = 300;

        props.image = 180;
        if ~isempty(p.nHiddenUnits)
            props.fcu = 260;
        else
            Wtot = 600 * (80+20)/(80+20+60);
        end
        props.class = 20;
        
    end
        
    dbug = 0;
    if dbug
         rectanglePix([0, 0, Wtot, Htot]);
    end
        
    prop_fields = fieldnames(props);
    all_props = structfun(@(x) x, props);
    all_fracs = all_props / sum(all_props);
    
    fracs = structfun(@(x) x/sum(all_props), props, 'un', 0);
    nPix = structfun(@(x) round(x/sum(all_props)*Wtot), props, 'un', 0);
    cumNpix = cumsum([0, structfun(@(x) x, nPix)']);
    
    for i = 1:length(prop_fields)
        pixStart.(prop_fields{i}) = cumNpix(i);
        if dbug
            
            annotation('line', [0 0], [1, 1], 'units', 'pixels', 'x', cumNpix(i)*[1,1], 'y', [0, Htot]);
        end
    end

    doConv = isfield(props, 'conv');
    doPool = isfield(props, 'pool');
    doFCU = isfield(props, 'fcu');

    
    v_line = @(x) annotation('line', [0 0], [1, 1], 'units', 'pixels', 'x', x*[1,1], 'y', [0, Htot]);

    h_line = @(yy) annotation('line', [0 0], [1, 1], 'units', 'pixels', 'x', [0, Wtot], 'y', yy*[1,1]);

    %% 1. Original Image
    imSz = size(X,1);

    imageArea_width_npix = round(Wtot*fracs.image);
%     imPosition = ;
    
    ax_pos = floor([imageArea_width_npix/2 - (scl*imSz)/2,   Htot/2 - (scl*imSz)/2,     scl*imSz, scl*imSz]);
%     rectanglePix(ax_pos);
    h_im_ax = axes('units', 'pixels', 'position', ax_pos);
    
    imagesc(  X );
    ticksOff(h_im_ax);
    colormap('gray');
    caxis([-10, 10])

    

     if doConv && doPool
    %%  1b. ConvFilterOnImage
         line_w = 2; line_w_real = floor(1.6*line_w);     
    %      x = [1,2,3,4,5,6,9,10];
    %      y = [1,3,4,6,8,9,14,16]

         %%
    %      imageFilter_xy = [15, 25];
         imageFilterLT = [12, 6];
         image_align_offset = [-2, -2];
         imageFilterBoxLB = image_align_offset + ax_pos(1:2) +  [imageFilterLT(1), size(X,1)-imageFilterLT(2)-p.filtSizes+2]*scl;
         imageFilterBoxWH = p.filtSizes*scl*[1, 1];
         h_filtRect = rectanglePix([imageFilterBoxLB - line_w_real,  imageFilterBoxWH + line_w_real ]);
         set(h_filtRect, 'linewidth', line_w, 'color', conv_color);
    %     
        %% 2. Convolutional banks    
        convBankSize = (imSz - p.filtSizes + 1);
        convBankSize_pix = convBankSize*scl;

        stack_spacing = 5;
        convBankSize_stack_pix = convBankSize_pix + (p.nStates(1)-1)*stack_spacing;

        conv_L_margin = floor((nPix.conv - convBankSize_stack_pix)/2);
        conv_B_margin = floor((Htot - convBankSize_stack_pix)/2);

        convBank_L = pixStart.conv + conv_L_margin + p.nStates(1)*stack_spacing;

        [h_convBank, convBankBox] = rectangleSet(convBank_L, conv_B_margin, convBankSize_pix, convBankSize_pix, 5, p.nStates(1));


        %% 2b. square on conv bank:  
    %      align_offset = [-2, -2];
         convFilterBoxLB = [convBank_L, conv_B_margin] + [imageFilterLT(1), convBankSize-imageFilterLT(2)-1]*scl;
         convFilterBoxWH = scl*[1,1];
         h_convRect = rectanglePix([convFilterBoxLB - line_w_real, convFilterBoxWH + line_w_real]);
         set(h_convRect, 'color', conv_color, 'linewidth', line_w)

        %% 1b - > 2b. line from square from image to conv bank

        h_ic(1) = linePix( [imageFilterBoxLB(1) + imageFilterBoxWH(1),  convFilterBoxLB(1)], [imageFilterBoxLB(2) + imageFilterBoxWH(2), convFilterBoxLB(2)+scl], 'linestyle', ':', 'linewidth', 2);
        h_ic(2) = linePix( [imageFilterBoxLB(1) + imageFilterBoxWH(1),  convFilterBoxLB(1)], [imageFilterBoxLB(2)-scl, convFilterBoxLB(2)], 'linestyle', ':', 'linewidth', 2);





        %% 3. Pooling banks

        poolBankSize = floor( convBankSize / p.poolSizes);
        poolBankSize_pix = poolBankSize *scl;

        poolBankSize_stack_pix = poolBankSize_pix + (p.nStates(1)*stack_spacing);

        pool_L_margin = floor((nPix.pool - poolBankSize_stack_pix)/2);
        pool_B_margin = floor((Htot - poolBankSize_stack_pix)/2);

        poolBank_L = pixStart.pool + pool_L_margin + p.nStates(1)*stack_spacing;

        [h_poolBank, poolBounds] = rectangleSet(poolBank_L, pool_B_margin, poolBankSize_pix, poolBankSize_pix, 5, p.nStates(1));

      %% 2c. pooling step: square on conv filter for pooling

        line_w = 2; line_w_real = floor(1.6*line_w);     
    %      x = [1,2,3,4,5,6,9,10];
    %      y = [1,3,4,6,8,9,14,16]

    %     convFilterLT = p.poolSizes*[2,3];
        convFilterLT = convBankSize * [1/3, (2/3)];
        convFilterLT = floor(convFilterLT/p.poolSizes) * p.poolSizes;

        convFilterPoolOffset = [2, 0];
        convFilterPoolBoxLB = [convBank_L, conv_B_margin] + convFilterPoolOffset + [convFilterLT(1)-1, convBankSize - convFilterLT(2)-p.poolSizes+1]*scl;
        convFilterPoolBoxWH = p.poolSizes*scl*[1,1];
    %      h_filtRect = rectanglePix([filterBoxLB, p.filtSizes*scl*[1, 1]]);se
         h_convPoolRect = rectanglePix([convFilterPoolBoxLB - line_w_real, convFilterPoolBoxWH + line_w_real ]);
        set(h_convPoolRect, 'color', pool_color, 'linewidth', line_w)     
        %%
        if p.poolSizes > 1
            for i = 1: p.poolSizes-1
                h_poolLine(i,1) = linePix( convFilterPoolBoxLB(1)+[-1, convFilterPoolBoxWH(1)],  convFilterPoolBoxLB(2)*[1,1] + scl*i-1 );
                h_poolLine(i,2) = linePix( convFilterPoolBoxLB(1)*[1,1] + scl*i-2, convFilterPoolBoxLB(2) + [-1, convFilterPoolBoxWH(2)] );
            end    
            set(h_poolLine, 'color', [1,1,1]*.6);
        end

        %% 3b. square on pooling bank

    %      imageFilterLT = [12, 12];
    %      align_offset = [-2, -2];
        convFilterPoolLT = floor(convFilterLT / p.poolSizes);

        poolBoxOffset = [-2, 0];

         poolBoxLB = [poolBank_L, pool_B_margin] + poolBoxOffset + [convFilterPoolLT(1), poolBankSize-convFilterPoolLT(2)]*scl;
         poolBoxWH = scl*[1,1];
    %      h_filtRect = rectanglePix([filterBoxLB, p.filtSizes*scl*[1, 1]]);se
         h_poolRect = rectanglePix([poolBoxLB-line_w_real, poolBoxWH+line_w_real]);
        set(h_poolRect, 'color', pool_color, 'linewidth', line_w)

        3;

         %% 2c -> 3b. Line to indicate pooling operation.
    %     p.filtSizes = 20;
    %      imageFilter_xy = [15, 25];
        conv_pool_lines_x = [convFilterPoolBoxLB(1) + convFilterPoolBoxWH(1),  poolBoxLB(1)]; 
        conv_pool_lines_y_top = [convFilterPoolBoxLB(2) + convFilterPoolBoxWH(2), poolBoxLB(2)+scl];
        conv_pool_lines_y_bot = [convFilterPoolBoxLB(2)-scl, poolBoxLB(2)];

        h_cp(1) = linePix( conv_pool_lines_x, conv_pool_lines_y_top, 'linestyle', ':', 'linewidth', 2);
        h_cp(2) = linePix( conv_pool_lines_x, conv_pool_lines_y_bot, 'linestyle', ':', 'linewidth', 2);

        %%
        
              
        prevBounds_top = [poolBounds(3) - (p.nStates(1)-1)*stack_spacing,  poolBounds(4)];
        prevBounds_bot = [poolBounds(3),  poolBounds(2)];

     else
         
         
        prevBounds_top = [ax_pos(1) + ax_pos(3), ax_pos(2) + ax_pos(4)];
        prevBounds_bot = [ax_pos(1) + ax_pos(3), ax_pos(2)];

         
     end
    
     %% 4. Fully connected units
     if doFCU

         if strcmp(p.netType, 'ConvNet')
             nfcu = p.nStates(2);

         else
             nfcu = p.nHiddenUnits{1};
         end


         fcu_m = min(nfcu, 15);
    %      fcu_n = 8;     
         fcu_nCols = ceil( nfcu / fcu_m);


         fcu_size = 9;
         fcu_space = 4;

         fcu_width = fcu_nCols * fcu_size + (fcu_nCols-1)*fcu_space;
         fcu_height = fcu_m * fcu_size + (fcu_m-1)*fcu_space;

         fcu_L_margin = floor( (nPix.fcu - fcu_width)/2 );
    %      conv_B_margin = (Htot - fcu_height)/2;

         fcu_L = pixStart.fcu + fcu_L_margin; % + p.nStates(1)*spc;

    %      h_fcu = circleBank(L,B, fcu_m, fcu_n, fcu_size, fcu_space, p.nStates(2);

         [h_fcu, fcu_bnd] = circleBank(fcu_L, Htot/2, fcu_m, fcu_nCols, fcu_size, fcu_space, nfcu);
         3;

        %% 3 --> 4  Lines connecting pooling bank to FCU


        pf_pool_x_top = prevBounds_top(1); 
        pf_fcu_x_top = fcu_bnd(1);

        pf_pool_x_bot = prevBounds_bot(1);
        pf_fcu_x_bot = fcu_bnd(1);

        pf_pool_y_top = prevBounds_top(2);
        pf_fcu_y_top = fcu_bnd(4) - floor(fcu_size/2);

        pf_pool_y_bot = prevBounds_bot(2);
        pf_fcu_y_bot = fcu_bnd(2) +  floor(fcu_size/2);
        %%
        h_pf(1) = linePix( [pf_pool_x_top, pf_fcu_x_top], [pf_pool_y_top, pf_fcu_y_top]);
        h_pf(2) = linePix( [pf_pool_x_top, pf_fcu_x_bot], [pf_pool_y_top, pf_fcu_y_bot]);
        h_pf(3) = linePix( [pf_pool_x_bot, pf_fcu_x_top], [pf_pool_y_bot, pf_fcu_y_top]);
        h_pf(4) = linePix( [pf_pool_x_bot, pf_fcu_x_bot], [pf_pool_y_bot, pf_fcu_y_bot]);

        set(h_pf, 'linestyle', ':', 'linewidth', 2, 'color', .5*[1, 1, 1])

        %%
        h_parent = get(h_pf(1), 'parent');
        h_siblings = get(h_parent, 'children');
    %     idx_lines = binarySearch(h_siblings, h_pf);
        for i = 1:length(h_pf)
            idx_child(i) = find(h_siblings == h_pf(i)); %#ok<AGROW>
        end
        if any(idx_child) == 1
            h_siblings(idx_child) = [];
            h_siblings = [h_siblings(:); h_pf(:)];
            set(h_parent, 'children', h_siblings);
        end
    %         h_siblings(

    
        prevBounds_top = [fcu_bnd(3), fcu_bnd(4) - floor(fcu_size/2)];
        prevBounds_bot = [fcu_bnd(3), fcu_bnd(2) +  floor(fcu_size/2)];

    
     elseif ~doFCU
         
         
         
     end
     
    %% 5. linear classifier layer
     
     nClass = 26;
     lc_m = nClass;
%      fcu_n = 8;     
     lc_nCols = 1;
     
     lc_size = 20;
     lc_space = 5;
     
     lc_width = lc_nCols * lc_size + (lc_nCols-1)*lc_space;
%      lc_height = lc_m * lc_size + (lc_m-1)*lc_space;
     maxHeight = Htot*(3/4);
     
     class_L_margin = (nPix.class - lc_width)/2;
     
     lc_L = pixStart.class + class_L_margin; % + p.nStates(1)*spc;
     
%      h_lc = circleBank(L,B, lc_m, lc_n, lc_size, lc_space, p.nStates(2);
     [h_lc, classBounds] = circleBankWithLetters(lc_L, Htot/2, lc_size, lc_space, nClass, maxHeight);     
    
     
    %% 4 --> 5  Lines connecting pooling bank to FCU
      
    
    fc_fcu_x_top = prevBounds_top(1); 
    fc_class_x_top = classBounds(1);
    
    fc_fcu_x_bot = prevBounds_bot(1);
    fc_class_x_bot = classBounds(1);
        
    fc_fcu_y_top = prevBounds_top(2);
    fc_class_y_top = classBounds(4) -floor(lc_size/2);
    
    fc_fcu_y_bot = prevBounds_bot(2);
    fc_class_y_bot = classBounds(2) + floor(lc_size/2);
    %%
    h_fc(1) = linePix( [fc_fcu_x_top, fc_class_x_top], [fc_fcu_y_top, fc_class_y_top]);
    h_fc(2) = linePix( [fc_fcu_x_top, fc_class_x_bot], [fc_fcu_y_top, fc_class_y_bot]);
    h_fc(3) = linePix( [fc_fcu_x_bot, fc_class_x_top], [fc_fcu_y_bot, fc_class_y_top]);
    h_fc(4) = linePix( [fc_fcu_x_bot, fc_class_x_bot], [fc_fcu_y_bot, fc_class_y_bot]);

    set(h_fc, 'linestyle', ':', 'linewidth', 2, 'color', .5*[1, 1, 1])
    if ~strcmp(get(gcf, 'WindowStyle'), 'docked')
%     set(gcf, 'position', [200 + figId * 50, 400 - figId * 50, Wtot+10, Htot]);
        set(gcf, 'position', [300, 300,  Wtot+26, Htot+2])
    end
    drawnow;
    3;
end



