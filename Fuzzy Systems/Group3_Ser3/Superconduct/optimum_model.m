clear;
mkdir optModplots
 
load superconduct.csv;
load optimumModel.mat
 
NF = optimumModel(1);
NR = optimumModel(2);
 
pos_new = randperm(size(superconduct,1));
 
 
%shuffle dataset
superconductSh = superconduct(pos_new, :);
 
%Datasets
D_trn = superconductSh(1:round(0.6*size(superconductSh,1)),:);
D_val = superconductSh(size(D_trn,1)+1:round(0.8*size(superconductSh,1)),:);
D_chk = superconductSh(size(D_trn,1)+size(D_val,1)+1 : end, :); 
 
 
%relief
load ranks.mat
 
D_trn = [D_trn(:,ranks(1:NF)) D_trn(:,end)];
D_val = [D_val(:,ranks(1:NF)) D_val(:,end)];
D_chk = [D_chk(:,ranks(1:NF)) D_chk(:,end)];
 
[initFis] = infr_sq(D_trn, NR);
 
plotmfin(initFis, "mf");
 
anfopt = anfisOptions('InitialFIS', initFis, 'EpochNumber', 250, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', D_val);
[trainFis, trainError, ~, chkFis, chkError] = anfis(D_trn, anfopt);

fprintf("Sum of NaN = %d, NF = %d, NR = %d \n", sum(isnan(chkError)), NF, NR);
plotmfin(chkFis, 'mfT');

figure('visible', 'off');
plot(trainError);
hold on
plot(chkError);
legend('TrainError','CheckError');
hold off
titlee = ['Model', num2str(NF), '_', num2str(NR)];

saveas(gcf,join(['optModplots/',titlee,'.png']))
           
y_pred = evalfis(D_chk(:, 1:end-1), chkFis);
y = D_chk(:, end);

figure;
plot(y-y_pred);
saveas(gcf,'optModplots/predErr.png')

%metrics
MSE = mean((y - y_pred).^2);
RMSE = sqrt(MSE);

SS_re = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);
R = 1 - SS_re/SS_tot ;

Se_sq = sum((y - y_pred).^2);
Sx_sq = sum((y - mean(y)).^2);
NMSE = Se_sq/Sx_sq;
NDEI = sqrt(NMSE);

