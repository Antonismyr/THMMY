function plotmfin(initFis, string)

figure('visible', 'off');
%plot input
for i=1:length(initFis.input)
    plotmf(initFis, 'input', i);
end
hold on
titlee = [string num2str(length(initFis.output.mf))];
saveas(gcf, join(['plots/',titlee,'.png']));
hold off
