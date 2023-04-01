warning('off', 'all');
mkdir plots

clear;
load superconduct.csv;
%NF = [3 9 15 21];
%NR = [4 8 12 16 20];
NF = [3 9 10 16];  
NR = [4 8 9 11 15];

modelMSE = zeros(length(NF), length(NR));
pos_new = randperm(size(superconduct,1));


%shuffle dataset
superconductSh = superconduct(pos_new, :);


%Datasets
D_trn = superconductSh(1:round(0.6*size(superconductSh,1)),:);
D_val = superconductSh(size(D_trn,1)+1:round(0.8*size(superconductSh,1)),:);
D_chk = superconductSh(size(D_trn,1)+size(D_val,1)+1 : end, :); 


%relief
[ranks, ~] = relieff(shuffleD(:, 1:end - 1), shuffleD(:, end), 100, 'method','regression');
save("ranks.mat", "ranks")


model = 1; %model 1-20

for i=1:length(NF)
    for j=1:length(NR)
      
        clear cv;
        cv = cvpartition(D_trn(:, end), "KFold", 5);
        
        for k = 1:5
           
            trainingIdx = cv.training(k);
            testIdx = cv.test(k);
            
            trainingF = D_trn(trainingIdx, ranks(1:NF(i)));
            training_out = D_trn(trainingIdx, end);
            trainingD = [trainingF training_out];
            
            testF = D_trn(testIdx, ranks(1:NF(i)));
            test_out = D_trn(testIdx, end);
            testD = [testF test_out];
            
            [initFis] = infr_sq(trainingD, NR(j));
            
            opt = anfisOptions('InitialFIS', initFis, 'EpochNumber', 100, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', testD);
            
            [trainFis, trainError, ~, chkFis, chkError] = anfis(trainingD, opt);
            fprintf("Sum of NaN = %d, NF = %d, NR = %d ANR = %d\n", sum(isnan(chkError)), NF(i), NR(j), size(showrule(initFis), 1));
            
            figure('visible', 'off');
            plot(trainError);
            hold on
            plot(chkError);
            legend('TrainError','CheckError');
            hold off
            titlee = ['Model', num2str(NF(i)), '_', num2str(NR(j)), num2str(k)];
            saveas(gcf,join(['plots/',titlee,'.png']))
            anfisOutput = evalfis(D_val(:, ranks(1:NF(i))), chkFis);
            y = D_val(:, end);
            MSE(k) = mean((y - anfisOutput).^2);
            
        end
        modelMSE(i, j) = mean(MSE);
       model = model + 1; 
    end
    
end

%plot MSE for each model
for i=1:length(NF)
    
    figure;
    bar(modelMSE(i, :));
    hold on;
    title(['Number of features:', num2str(NF(i))]);
    set(gca, 'xticklabel', string(NR))
    titlee = ['msebar_modelnf' num2str(NF(i)) '.png'];
    saveas(gcf, join(['plots/',titlee,'.png']))
    hold off;
    
end


[min_val,idx]=min(modelMSE(:));
[row,col]=ind2sub(size(modelMSE),idx);
optimumModel = [NF(row) NR(col)];
save('optimumModel.mat', 'optimumModel')
    
    

