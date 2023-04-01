clear;
load CCPP.dat;
D_trn = CCPP(1:round(0.6*size(CCPP,1)),:);
D_val = CCPP(size(D_trn,1)+1:round(0.8*size(CCPP,1)),:);
D_chk = CCPP(size(D_trn,1)+size(D_val,1)+1 : end, :);

mf = [2 3 2 3];

prompt = 'enter model\n';
model = input(prompt);

if (model == 1)
    outmftype = 'constant';
    numMfs = mf(model)* ones(size(CCPP,2)-1,1);
elseif(model == 2)
    outmftype = 'constant';
    numMfs = mf(model)* ones(size(CCPP,2)-1,1);
elseif(model == 3)
    outmftype = 'linear';
    numMfs = mf(model)* ones(size(CCPP,2)-1,1);
else
    outmftype = 'linear';
    numMfs = mf(model)* ones(size(CCPP,2)-1,1);
end

inmfType = char('gbellmf', 'gbellmf', 'gbellmf', 'gbellmf');

initFis = genfis1(D_trn, numMfs, inmfType, outmftype);

plotmfin_CCPP(initFis);

anfis_options = anfisOptions('InitialFIS',initFis,'EpochNumber',350, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'ValidationData', D_val);

[trainfis, trainError, stepSize, chkFIS, chkError] = anfis(D_trn, anfis_options);
% plot errors 
figure;
x_tr = 1:length(trainError);
plot(x_tr,trainError);
hold on
plot(x_tr,chkError);
legend('TrainError','CheckError');

plotmfin_CCPP(chkFIS);

x = D_chk(:,1:end-1);
anfisOutput = evalfis(x,chkFIS);
figure;
plot(x,D_chk(:,end),'*r',x,anfisOutput,'.b');
figure;
plot(D_chk(:,end)-anfisOutput);
    
%Errors
MSE = mean((D_chk(:,end) - anfisOutput).^2);
RMSE = sqrt(MSE);

SS_re = sum((D_chk(:,end) - anfisOutput).^2);
SS_tot = sum((D_chk(:,end) - mean(D_chk(:,end))).^2);
R = 1 - SS_re/SS_tot ;

Se_sq = sum((D_chk(:,end) - anfisOutput).^2);
Sx_sq = sum((D_chk(:,end) - mean(D_chk(:,end))).^2);
NMSE = Se_sq/Sx_sq;
NDEI = sqrt(NMSE);


