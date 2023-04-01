clear;
mkdir optModelPlots

load isolet.dat;
load optimumModel.mat;
load ranks.mat;

nf = optimumModel(1);
nr = optimumModel(2);

class = isolet(:,end);
isolet = isolet(:, ranks(1:nf));
isolet = [isolet class];

tab = tabulate(isolet(:,end));

[D_trn, D_val, D_chk, oriomax, oriomin] = creatSet(isolet);


%shuffle sets
pos = randperm(size(D_trn, 1));
D_trn = D_trn(pos, :);
pos = randperm(size(D_val, 1));
D_val = D_val(pos,:);
pos = randperm(size(D_chk, 1));
D_chk = D_chk(pos,:);

opt = genfisOptions('FCMClustering');
opt.NumClusters = nr;
opt.Verbose = 0;
           
initFis = genfis(D_trn(:,1:end-1), D_trn(:, end), opt);

plotmfin(initFis, 'mf');

for j = 1 : length(initFis.output.mf)
    initFis.output.mf(j).type = 'constant';
    initFis.output.mf(j).params = (tab(1,1)+tab(end,1))/2;
end

anfopt = anfisOptions('InitialFIS', initFis, 'EpochNumber', 250, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', D_val);
[trainFis, trainError, ~, chkFis, chkError] = anfis(D_trn, anfopt);

fprintf("Sum of NaN = %d, NF = %d, NR = %d \n", sum(isnan(chkError)), nf, nr);
plotmfin(chkFis, 'mfT');

figure('visible', 'off');
plot(trainError);
hold on
plot(chkError);
legend('TrainError','CheckError');
hold off
titlee = ['Model', num2str(nf), '_', num2str(nr)];

saveas(gcf,join(['optModelPlots/',titlee,'.png']))
           
y_pred = evalfis(D_chk(:, 1:end-1), chkFis);
y = D_chk(:, end);
           
y_pred = round(y_pred);
    
for f=1:length(y_pred)
   if y_pred(f)>oriomax
       y_pred(f) = oriomax;
   elseif y_pred(f)<oriomin
       y_pred(f) = oriomin;
   end
end

%metrikes
conf_mat = confusionmat(y, y_pred);
    
accuracy = (sum(diag(conf_mat)))/size(D_chk,1);
    
for j=1:length(tab(:,1))
   prod_acc(j) = conf_mat(j, j)/sum(conf_mat(:,j));
   user_acc(j) = conf_mat(j, j)/sum(conf_mat(j,:));
end
    
   
for k = 1 : length(tab(:,1))
   Xirc(k) = ( sum(conf_mat(k,:)) * sum(conf_mat(:,k)) ) /size(D_chk,1)^2; 
end
    
% k_hat
kh = (accuracy - sum(Xirc)) / (1 - sum(Xirc));

figure('visible', 'off');
plot(y_pred, '*r');
hold on
plot(y, '.b');
titlee = ['Output', num2str(nf), '_', num2str(nr)];

saveas(gcf,join(['optModelPlots/',titlee,'.png']))

function [D_trn, D_val, D_chk, oriomax, oriomin] = creatSet(isolet)
    [~, idx] = sort(isolet(:, end));
    isoletS = isolet(idx,:);
    
    tab = tabulate(isoletS(:, end));
    oriomax = max(tab(:,1));
    oriomin = min(tab(:,1));
    idav = 0;
    idt =0;
    idv = 0;
    idc = 0;
    for i=1:max(isoletS(:, end))
        pos = randperm(tab(i,2));
   
        %training set
        for j=1:round(0.6*tab(i,2))
            D_trn(j+idt, :) = isoletS(pos(j)+idav, :);
        end
        idt = idt+j;
        %validation set
        for k=1:round(0.2*tab(i,2))
            D_val(k+idv, :) = isoletS(pos(k+j)+idav, :);
        end
        idv = idv+k;
        %check set
        for z=1:(tab(i,2)-round(0.6*tab(i,2))-round(0.2*tab(i,2)))
            D_chk(z+idc, :) = isoletS(pos(z+k+j)+idav, :);
        end
        idc = idc+z;
   
        idav = idav+max(pos);
    end
end
