function y = nn_MSECriterion(output, target)
    diffs = output(:) - target(:);
    y = mean (  ( diffs ).^2 );
    
    
end