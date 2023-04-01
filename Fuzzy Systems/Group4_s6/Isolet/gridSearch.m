mkdir plots
clear;
load isolet.dat;

NF = [5, 10, 15, 20];
NR = [5, 10, 15, 20, 25];

[D_trn, D_val, D_chk, oriomax, oriomin] = creatSet(isolet);
%save('D_trn');
%save('D_val');
%save('D_chk');

tab = tabulate(isolet(:,end));

k = 60;
[ranks, ~] = relieff(isolet(:, 1:end - 1), isolet(:, end), k, 'method', 'classification');
save("ranks.mat", "ranks");

%shuffle sets
pos = randperm(size(D_trn, 1));
D_trn = D_trn(pos, :);
pos = randperm(size(D_val, 1));
D_val = D_val(pos,:);
pos = randperm(size(D_chk, 1));
D_chk = D_chk(pos,:);

model = 1;

for nf = 1:length(NF)
   for nr = 1:length(NR)
      [idxtrn, idxtest] = mypartition(D_trn);
      for k =1:5
           trainingF = D_trn(idxtrn{:,k}, ranks(1:NF(nf)));
           training_out = D_trn(idxtrn{:,k}, end);
           trainingD = [trainingF training_out];
           
           testF = D_trn(idxtest{:,k}, ranks(1:NF(nf)));
           test_out = D_trn(idxtest{:,k}, end);
           testD = [testF test_out];   
           
           %generate and train fis
           opt = genfisOptions('FCMClustering');
           opt.NumClusters = NR(nr);
           opt.Verbose = 0;
           
           initFis = genfis(trainingD(:,1:end-1), trainingD(:, end), opt);
           
           for j = 1 : length(initFis.output.mf)
             initFis.output.mf(j).type = 'constant';
             initFis.output.mf(j).params = (tab(1,1)+tab(end,1))/2;
           end
           
           anfopt = anfisOptions('InitialFIS', initFis, 'EpochNumber', 100, 'DisplayANFISInformation', 0, 'DisplayErrorValues', 0, 'DisplayStepSize', 0, 'DisplayFinalResults', 0, 'ValidationData', testD);
           [trainFis, trainError, ~, chkFis, chkError] = anfis(trainingD, anfopt);
           fprintf("Sum of NaN = %d, NF = %d, NR = %d \n", sum(isnan(chkError)), NF(nf), NR(nr));
           figure('visible', 'off');
           plot(trainError);
           hold on
           plot(chkError);
           legend('TrainError','CheckError');
           hold off
           titlee = ['Model', num2str(NF(nf)), '_', num2str(NR(nr)), num2str(k)];
           saveas(gcf,join(['plots/',titlee,'.png']))
           
           y_pred = evalfis(D_val(:, ranks(1:NF(nf))), chkFis);
           y = D_val(:, end);
           
           y_pred = round(y_pred);
    
          for f=1:length(y_pred)
             if y_pred(f)>oriomax
                y_pred(f) = oriomax;
             elseif y_pred(f)<oriomin
                y_pred(f) = oriomin;
             end
          end
          
          MSE(k) = mean((y - y_pred).^2);
      end
      modelMSE(nf, nr) = mean(MSE);
      model = model + 1;  
       
   end
    
    
end

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

function [idxtrn, idxtest] = mypartition(D_trn)
    [~, idx] = sort(D_trn(:, end));
    tab = tabulate(D_trn(:,end));

    for i=1:5
        idtr = [];
        idtest = [];
        id = 1;
        for j=1:size(tab,1)
            pos = randperm(tab(j, 2));
            idtr = [idtr; idx(id:id-1+round(0.8*length(pos)))];
            idtest = [idtest; idx(id+round(0.8*length(pos)):length(pos)+id-1)];
            id = id +length(pos);
        end
        shuf = randperm(length(idtr));
        idtr = idtr(shuf);
        
        shuft = randperm(length(idtest));
        idtest = idtest(shuft);
        
        idxtrn(:,i)={idtr};
        idxtest(:,i)={idtest};
    end
        
    
    
end
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