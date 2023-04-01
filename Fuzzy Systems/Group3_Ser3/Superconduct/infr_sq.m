function [initFis] = infr_sq(D_trn, NR)
    
    infrange_chk = [];
  
    counter =0;
    
    opt = genfisOptions('SubtractiveClustering');
    opt.Verbose = 0;
    infrange = 0.75:-0.01:0.3;
    squash = 1.3;
    st = 1;
    fin = length(infrange);
    id = round((st+fin)/2);
    found =false;

    while found ~= true      
        counter = counter+1;
        opt.SquashFactor = squash;
        opt.ClusterInfluenceRange = infrange(id);
        
        initFis = genfis(D_trn(:,1:end-1), D_trn(:, end), opt);
        
        infrange_chk(counter)= infrange(id);
        
        if size(showrule(initFis),1) == NR
            found =true;
        elseif size(showrule(initFis),1) > NR
            st = st;
            fin = id;
            id = floor((st+fin)/2);
        else
            st = id;
            fin = fin;
            id = ceil((st+fin)/2);
        end
    
        if ismember(infrange(id), infrange_chk)
            squash = squash-0.01;
            id = round((1+length(infrange))/2);
            infrange_chk = [];
            counter = 0;
        end
        fprintf('sq = %f infr = %f, nr = %d\n',squash,infrange(id),size(showrule(initFis),1))
    end
    
    
end    
    
