% Figure 2: Productivity Distribution and Obsolescence
function [] = graphDist()
    global eq

    x = 0.0001:0.001:3;
    xmin1 = 0.0001:0.001:eq.qmin(1); 
    xmin2 = 0.0001:0.001:eq.qmin(2); 
    [~,yH]   = deval(eq.solFH,x);
    [~,yAll] = deval(eq.solFAll,x);

    [~,yHarea1]   = deval(eq.solFH,xmin1);
    [~,yHarea2]   = deval(eq.solFH,xmin2);
    [~,yAllarea1] = deval(eq.solFAll,xmin1);
    yLarea = yAllarea1 - yHarea1;
    [~,yHqmin]   = deval(eq.solFH,eq.qmin(2));
    [~,yHqminL]   = deval(eq.solFH,eq.qmin(1));
    [~,yALLqmin]  = deval(eq.solFAll,eq.qmin(1));
    yLqmin = yALLqmin - yHqminL;

    yL = yAll - yH;
    
    f1 = figure();
    h0 = area(xmin1,yLarea);
    hold all
    h00 = area(xmin2,yHarea2);
    hold all
    h1 = plot(x,yL,'k-','LineWidth',3);
    hold all
    h2 = plot([eq.qmin(1) eq.qmin(1)], [0,yLqmin],'k-.','LineWidth',2);
    hold all
    h3 = plot(x,yH,'r-','LineWidth',3);
    hold all
    h4 = plot([eq.qmin(2) eq.qmin(2)], [0,yHqmin],'r-.','LineWidth',2);

    xlab = xlabel('$\hat{q}$');
    ylab = ylabel('Density');

     set([xlab],'FontSize',16,'Interpreter','latex');


    text(eq.qmin(1)-.02,-.02,'$\hat{q}_{l,min}$','Color','k','FontSize',14,'Interpreter','latex')
    text(eq.qmin(2)-.09,-.02,'$\hat{q}_{h,min}$','Color','r','FontSize',14,'Interpreter','latex')
     


    lg = legend([h1,h3],'Low Type','High Type');
    xlim([0.5 3]);
    ylim([0.0 .9]);

    set(h0,'FaceColor',	[90 90 90]/100)
    set(h00,'FaceColor',[90 60 60]/100)
    set(lg,'Box','off');

    set(gca,'FontSize',16,'XTick', 0.5:2.5:3);

    print(f1,'-dpdf',['output' filesep 'distQualUnNormalized.pdf']);
    close all;
end