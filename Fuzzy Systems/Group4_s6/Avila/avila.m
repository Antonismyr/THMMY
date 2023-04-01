clear;
mkdir plots
avilaD = load('avila.txt');

NR = [4 8 12 16 20];
sqsh = [0.85 0.7 0.5 0.45 0.42];
infrng = [0.4 0.24 0.22 0.4 0.58];

[D_trn, D_val, D_chk, oriomax, oriomin] = creatSet(avilaD);

pos = randperm(size(D_trn, 1));
D_trn = D_trn(pos, :);
pos = randperm(size(D_val, 1));
D_val = D_val(pos,:);
pos = randperm(size(D_chk, 1));
D_chk = D_chk(pos,:);

accuracy = zeros(length(NR),1);
tab = tabulate(avilaD(:,end));

%train models
for i=1:length(NR)
   
    opt = genfisOptions('SubtractiveClustering');
    opt.ClusterInfluenceRange = infrng(i);
    opt.SquashFactor = sqsh(i);
    opt.Verbose = 0;
    
    initFis = genfis(D_trn(:,1:end-1), D_trn(:, end), opt);
    fprintf("NR = %d, ANR = %d \n", NR(i), size(showrule(initFis), 1));
    
    for j=1:length(initFis.output.mf)
       initFis.output.mf(j).type = 'constant';
       initFis.output.mf(j).params = (tab(1,1)+tab(end,1))/2;
    end
    
    plotmfin(initFis, 'mf_NR');
    pause(0.01);
    anopt = anfisOptions('InitialFIS', initFis, 'EpochNumber', 100, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', D_val);
    
    % Train generated FIS
    [trnFis, trnError, ~, chkFis, chkError] = anfis(D_trn, anopt);
    
    plotmfin(chkFis, 'mfT_NR');
    fprintf("Sum of NaN = %d, NR = %d \n", sum(isnan(chkError)), NR(i));
    
    figure('visible', 'off');
    plot(trnError);
    hold on
    plot(chkError);
    legend('TrainError','CheckError');
    hold off
    titlee = ['Model', '_', num2str(NR(i))];
    saveas(gcf,join(['plots/',titlee,'.png']));
    
    y_pred = evalfis(D_chk(:, 1:end-1), chkFis);
    y = D_chk(:, end);
    
    y_pred = round(y_pred);
    
    for k=1:length(y_pred)
        if y_pred(k)>oriomax
            y_pred(k) = oriomax;
        elseif y_pred(k)<oriomin
            y_pred(k) = oriomin;
        end
    end
    
    %metrikes
    conf_mat(i, :) = {confusionmat(y, y_pred)};
        
    accuracy(i) = (sum(diag(conf_mat{i,:})))/size(D_chk,1);
    
    for j=1:length(tab(:,1))
        prod_acc(i,j) = conf_mat{i,:}(j, j)/sum(conf_mat{i,:}(:,j));
        user_acc(i,j) = conf_mat{i,:}(j, j)/sum(conf_mat{i,:}(j,:));
    end
    
   
    for k = 1 : length(tab(:,1))
        Xirc(k) = ( sum(conf_mat{i,:}(k,:)) * sum(conf_mat{i,:}(:,k)) ) /size(D_chk,1)^2; 
    end
    
    % k_hat
    kh(i) = (accuracy(i) - sum(Xirc)) / (1 - sum(Xirc));
    
    
end


function [D_trn, D_val, D_chk, oriomax, oriomin] = creatSet(avilaD)
    [~, idx] = sort(avilaD(:, end));
    avilaS = avilaD(idx,:);
    
    tab = tabulate(avilaS(:, end));
    oriomax = max(tab(:,1));
    oriomin = min(tab(:,1));
    idav = 0;
    idt =0;
    idv = 0;
    idc = 0;
    for i=1:max(avilaS(:, end))
        pos = randperm(tab(i,2));
   
        %training set
        for j=1:round(0.6*tab(i,2))
            D_trn(j+idt, :) = avilaS(pos(j)+idav, :);
        end
        idt = idt+j;
        %validation set
        for k=1:round(0.2*tab(i,2))
            D_val(k+idv, :) = avilaS(pos(k+j)+idav, :);
        end
        idv = idv+k;
        %check set
        for z=1:(tab(i,2)-round(0.6*tab(i,2))-round(0.2*tab(i,2)))
            D_chk(z+idc, :) = avilaS(pos(z+k+j)+idav, :);
        end
        idc = idc+z;
   
        idav = idav+max(pos);
    end
end