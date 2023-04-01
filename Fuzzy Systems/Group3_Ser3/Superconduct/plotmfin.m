function plotmfin(initFis, string)


%plot input
for i=1:4
    figure('visible', 'off');
    plotmf(initFis, 'input', i);
    hold on
    titlee = [string num2str(length(initFis.output.mf)) num2str(i)];
    saveas(gcf, join(['optModplots/',titlee,'.png']));
    hold off

end
