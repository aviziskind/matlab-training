function n = generateNoiseSamples(nNoiseSamples, noiseType, rand_seed)

    if ~exist('nNoiseSamples', 'var') || isempty(nNoiseSamples)
        nNoiseSamples = 1e5;
    end
    
    if ~exist('noiseType', 'var') || isempty(noiseType)
        noiseType = 'gaussian';
    end
    
    if exist('rand_seed', 'var') && ~isempty(rand_seed)
        rng(rand_seed);
    end

    n.noiseType = noiseType;
    switch noiseType
        case 'gaussian',
            n.noiseBound=2;
            temp=randn([1,nNoiseSamples]);
            n.noiseList=find(sign(temp.^2-n.noiseBound^2)-1);
            n.noiseList=temp(n.noiseList);
            clear temp;
            n.noiseList=n.noiseList/std(n.noiseList);
        case 'uniform',
            n.noiseBound=1;
            n.noiseList=-1:1/1024:1;
        case 'binary',
            n.noiseBound=1;
            n.noiseList=[-1 1];
        otherwise,
            error('Unknown noiseType ''%s''',n.noiseType);
    end
    
end    
    
