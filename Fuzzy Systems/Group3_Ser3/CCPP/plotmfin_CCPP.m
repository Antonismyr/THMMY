function plotmfin_CCPP(initFis)

%plot input
for i=1:4
    figure;
    plotmf(initFis, 'input', i);
end
