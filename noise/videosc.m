function videosc(X)
%     figure(1);
    glob_col_lims = lims(X(:));
    n = size(X,3);
    for i = 1:n
        imagesc(X(:,:,i)); 
        caxis(glob_col_lims); colorbar;
        title(sprintf('%d / %d', i, n));
        drawnow;
    end
    
end