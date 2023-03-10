%% Read Log
clear all
close all
[fileopen,pathopen]=uigetfile('*.csv','Select Log CSV File');
log=readtable(fullfile(pathopen,fileopen));
if log.PUT_kPa_
    log=renamevars(log,["PUTSP_kPa_" "PUT_kPa_" "ExhFlowFac__" "IntFlowFac__"],["PUTSP_kpa_" "PUT_kpa_" "ExhFlowFactor__" "IntakeFlowFact__"])
end
log.deltaput=log.PUT_kpa_-log.PUTSP_kpa_;
log.WGCL=log.WGP_DValue___+log.WGIValue___
log.WGNEED=log.WGPosFinal___-log.deltaput.*0.0065
WOT=log;
WOT(log.PedalPos___<80,:) = [];
WOTO=WOT;
WOTO(WOTO.WGPosFinal___>98,:) = [];
WOT_VVL1=WOTO;
WOT_VVL1(WOT_VVL1.ValveLiftPos__~=1,:) = [];
WOT_VVL0=WOTO;
WOT_VVL0(WOT_VVL0.ValveLiftPos__~=0,:) = [];
% % log.deltaput(log.deltaput>10)=10;

exhaxis=[0.00	0.25 0.35 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.90 1.05 1.20 1.35 1.50 1.80];
intaxis=[0.00	0.15 0.30 0.45 0.60 0.75 0.90 1.05 1.35 1.70];

xedges(1)=exhaxis(1);
xedges(length(exhaxis)+1)=exhaxis(length(exhaxis))+2;
for i=1:length(exhaxis)-1;
    xedges(i+1)=(exhaxis(i)+exhaxis(i+1))/2;
end

yedges(1)=intaxis(1);
yedges(length(intaxis)+1)=intaxis(length(intaxis))+2;
for i=1:length(intaxis)-1;
    yedges(i+1)=(intaxis(i)+intaxis(i+1))/2;
end

SUM1=zeros(length(intaxis),length(exhaxis));
COUNT1=SUM1;
SUM0=SUM1
COUNT0=SUM1

X1=discretize(WOT_VVL1.ExhFlowFactor__,xedges);
Y1=discretize(WOT_VVL1.IntakeFlowFact__,yedges);
for i=1:height(WOT_VVL1)
   SUM1(Y1(i),X1(i))=SUM1(Y1(i),X1(i))+WOT_VVL1.WGNEED(i);
   COUNT1(Y1(i),X1(i))=COUNT1(Y1(i),X1(i))+1;
end
AVG1=SUM1./COUNT1

X0=discretize(WOT_VVL0.ExhFlowFactor__,xedges);
Y0=discretize(WOT_VVL0.IntakeFlowFact__,yedges);
for i=1:height(WOT_VVL0)
   SUM0(Y0(i),X0(i))=SUM0(Y0(i),X0(i))+WOT_VVL0.WGNEED(i);
   COUNT0(Y0(i),X0(i))=COUNT0(Y0(i),X0(i))+1;
end
AVG0=SUM0./COUNT0

f1=tiledlayout(2,1)
nexttile
hold on
for i=1:height(WOT)
    if WOT.ValveLiftPos__(i)==1
        if WOT.WGPosFinal___(i)>98
            c1=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.deltaput(i),"^","filled");
        else
            o1=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.deltaput(i),"^");
        end
    else
        if WOT.WGPosFinal___(i)>98
            c0=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.deltaput(i),"o","filled");
        else
            o0=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.deltaput(i),"o");
        end
    end
end
  
lgd = [c1 o1 o0];
leglabels = legend(lgd,'WG closed - VVL1','WG open - VVL1','WG open - VVL0');

mycolormap = customcolormap([0 .25 .5 .75 1], {'#9d0142','#f66e45','#ffffff','#65c0ae','#5e4f9f'});
c = colorbar;
c.Label.String = 'PUT - PUT SP';
colormap(mycolormap);
clim([-15 15]);
set(gca, 'Ydir', 'reverse');
xlabel('Exh Flow Factor') ;
ylabel('Int Flow Factor') ;
% set(gca,'TickLength',[1 1])
grid on;
set(gca,"XAxisLocation","top");
xticks(exhaxis);
yticks(intaxis);
rows=[find(WOT.EngineSpeed_rpm_>2000,1) find(WOT.EngineSpeed_rpm_>3000,1) find(WOT.EngineSpeed_rpm_>4000,1) find(WOT.EngineSpeed_rpm_>5000,1)];
lscatter(WOT.ExhFlowFactor__(rows),WOT.IntakeFlowFact__(rows),[2000 3000 4000 5000]);
hold off

nexttile
hold on
for i=1:height(WOT)
    if WOT.ValveLiftPos__(i)==1
        if WOT.WGPosFinal___(i)>98
            c1p=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.WGCL(i),"^","filled");
        else
            o1p=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.WGCL(i),"^");
        end
    else
        if WOT.WGPosFinal___(i)>98
            c0p=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.WGCL(i),"o","filled");
        else
            o0p=scatter(WOT.ExhFlowFactor__(i),WOT.IntakeFlowFact__(i),100,WOT.WGCL(i),"o");
        end
    end
end
  
lgd = [c1p o1p o0p];
leglabels = legend(lgd,'WG closed - VVL1','WG open - VVL1','WG open - VVL0');

mycolormap = customcolormap([0 .25 .5 .75 1], {'#9d0142','#f66e45','#ffffff','#65c0ae','#5e4f9f'});
c = colorbar;
c.Label.String = 'WG CL';
colormap(mycolormap);
clim([-10 10]);
set(gca, 'Ydir', 'reverse');
xlabel('Exh Flow Factor') ;
ylabel('Int Flow Factor') ;
% set(gca,'TickLength',[1 1])
grid on;
set(gca,"XAxisLocation","top");
xticks(exhaxis);
yticks(intaxis);
rows=[find(WOT.EngineSpeed_rpm_>2000,1) find(WOT.EngineSpeed_rpm_>3000,1) find(WOT.EngineSpeed_rpm_>4000,1) find(WOT.EngineSpeed_rpm_>5000,1)];
lscatter(WOT.ExhFlowFactor__(rows),WOT.IntakeFlowFact__(rows),[2000 3000 4000 5000]);

hold off

Xnames=["RPM" "Int Flow Factor" "Exh Flow Factor" "WG I" "WG PD" "WG Final" "PUT delta"];
comparison=[WOTO.EngineSpeed_rpm_ WOTO.IntakeFlowFact__ WOTO.ExhFlowFactor__ WOTO.WGIValue___ WOTO.WGP_DValue___ WOTO.WGPosFinal___ WOTO.deltaput];
f2=figure;
gplotmatrix(comparison,[],WOTO.ValveLiftPos__,[],[],[],'on','stairs',Xnames);