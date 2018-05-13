% Figure 2: Impact of Incumbent Tax. This figure is illustrative.

function [] = graphDistIncumbentTax()
    global alg eq p
    factH     = 2.5;
    fractQmin = 1.2;

    xL       = linspace(eq.qmin(1),3,1000);
    xH       = linspace(eq.qmin(2),3,1000);
    xmin1    = linspace(eq.qmin(1),eq.qmin(1)*fractQmin,100); 
    xmin2    = linspace(eq.qmin(2),eq.qmin(2)*fractQmin,100); 
    [~,yH]   = deval(eq.solFH,xH);
    [~,yHL]  = deval(eq.solFH,xL);
    [~,yAll] = deval(eq.solFAll,xL);

    yL   = yAll - yHL*factH;
    yH   = yH*factH;



    [~,yHarea1]   = deval(eq.solFH,xmin1);
    [~,yHarea2]   = deval(eq.solFH,xmin2);
    [~,yAllarea1] = deval(eq.solFAll,xmin1);
    yLarea        = yAllarea1 - yHarea1*factH;
    yHarea        = yHarea2*factH;


    [~,yHqmin]    = deval(eq.solFH,eq.qmin(2));
    [~,yHqminL]   = deval(eq.solFH,eq.qmin(1));
    [~,yALLqmin]  = deval(eq.solFAll,eq.qmin(1));
    yHqmin        = yHqmin*factH;
    yLqmin        = yALLqmin - yHqminL*factH;


    [~,yHqminE]    = deval(eq.solFH,eq.qmin(2)*fractQmin);
    [~,yHqminLE]   = deval(eq.solFH,eq.qmin(1)*fractQmin);
    [~,yALLqminE]  = deval(eq.solFAll,eq.qmin(1)*fractQmin);

    yHqminE = yHqminE*factH;
    yLqminE = yALLqminE - yHqminLE*factH;

    f2 = figure();
    h0 = area(xmin1,yLarea);
    hold all
    h00 = area(xmin2,yHarea);
    hold all
    h5 = plot([eq.qmin(1)*fractQmin eq.qmin(1)*fractQmin], [0,yLqminE],'k-.','LineWidth',2);
    hold all
    h6 = plot([eq.qmin(2)*fractQmin eq.qmin(2)*fractQmin], [0,yHqminE],'r-.','LineWidth',2);
    hold all
    h1 = plot(xL,yL,'k-','LineWidth',3);
    hold all
    h2 = plot([eq.qmin(1) eq.qmin(1)], [yHqminL*factH,yLqmin],'k-.','LineWidth',2);
    hold all
    h3 = plot(xH,yH,'r-','LineWidth',3);
    hold all
    h4 = plot([eq.qmin(2) eq.qmin(2)], [0,yHqmin],'r-.','LineWidth',2);

    hold all

    xlim([1.2 3]);
    ylim([0.0 .9]);

    text(eq.qmin(1)+.08,yLqmin*.5,'$\hat{q}_{l,min}$','Color','k','FontSize',19,'Interpreter','latex')
    annotation('textarrow',[0.09,.2]+.17,[0.45,.45]);
    text(eq.qmin(2)+.05,yHqmin*.5,'$\hat{q}_{h,min}$','Color','r','FontSize',19,'Interpreter','latex')
    annotation('textarrow',[0.09,.19]+.092,[0.18,.18])
    	
    lg=legend([h1,h3],'Low Type','High Type');

    xlab = xlabel('$\hat{q}$');
    ylab = ylabel('Density');
    set(lg,'Box','off');

    set([xlab],'FontSize',16,'Interpreter','latex');

    set(h0,'FaceColor',	[90 90 90]/100);
    set(h00,'FaceColor',[90 80 80]/90);

    set(gca,'FontSize',16);

    print(f2,'-dpdf',['output' filesep 'distQualIncumbentTax.pdf']);
    close all
end    