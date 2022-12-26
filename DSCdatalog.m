function DSCdatalog()
close all;
skipplots='false';

    %% INPUT T1
    [filenew,pathopen]=uigetfile('*.pmed','Select New Datalog',getcurrentdir);
    T = readtable(fullfile(pathopen,filenew),"FileType","text","Delimiter",' ');
    fid = fopen(fullfile(pathopen,filenew));
    list = textscan(fid,'%s','Delimiter',' ','MultipleDelimsAsOne',true);
    T1vars = regexprep(list{1,1},'[\d"]','');
    T1vars = regexprep(T1vars,'-','');
    index = cellfun(@isempty, T1vars) == 0;
    T1vars = T1vars(index);
    T1vars{1,1}='Time';
    T = renamevars(T,1:width(T),T1vars);
    T ( any(ismissing(T),2), :) = [];
    
    %% Create pitch/roll
    %T = addvars(T,['Pitch','Roll'])
    wheelbase=2631;
    trackwidth=1791;
    T.Pitch = smoothdata(180*(T.LF_RH_travel_mm-T.LR_RH_travel_mm)/(wheelbase*pi),'gaussian',20);
    T.Roll = smoothdata(180*(T.LF_RH_travel_mm-T.RF_RH_travel_mm)/(trackwidth*pi),'gaussian',20);
    
    
    %% Unit Convert
    
    T.Time=T.Time/1000;
    T.Glat_cnv=T.Glat_cnv/100;
    T.Glng_cnv=T.Glng_cnv/100;
    T.LF_RH_Velocity=T.LF_RH_Velocity/10;
    T.RF_RH_Velocity=T.RF_RH_Velocity/10;
    T.LR_RH_Velocity=T.LR_RH_Velocity/10;
    T.RR_RH_Velocity=T.RR_RH_Velocity/10;
    
    
    %% INPUT T2
    [fileold,pathold]=uigetfile('*.pmed','Select Old Datalog',fullfile(pathopen));
    Told = readtable(fullfile(pathold,fileold),"FileType","text","Delimiter",' ');
    fid = fopen(fullfile(pathold,fileold));
    list = textscan(fid,'%s','Delimiter',' ','MultipleDelimsAsOne',true);
    T2vars = regexprep(list{1,1},'[\d"]','');
    T2vars = regexprep(T2vars,'-','');
    index = cellfun(@isempty, T2vars) == 0;
    T2vars = T2vars(index);
    T2vars{1,1}='Time';
    Told = renamevars(Told,1:width(Told),T2vars);
    Told ( any(ismissing(Told),2), :) = [];
    Told.LF_RH_Velocity=Told.LF_RH_Velocity/10;
    Told.RF_RH_Velocity=Told.RF_RH_Velocity/10;
    Told.LR_RH_Velocity=Told.LR_RH_Velocity/10;
    Told.RR_RH_Velocity=Told.RR_RH_Velocity/10;
    
    %% Options
    
    veloptions = inputdlg({'Trim all data below speed (mph):'},'Log Trimming',[1 35],{'10'});
    zeroes = questdlg('Remove zero velocity values from histograms?','Zeroes','Yes','No','Yes');
    minspeed = str2double(veloptions{1});
    
    %% Prepare Velocities Histogram
    T(~T.Speed,:) = [];
    Told(~Told.Speed,:) = [];
    T(T.Speed<minspeed,:) = [];
    Told(Told.Speed<minspeed,:) = [];
    
    Tnew=T
    
    %Remove Zeroes
        if strcmpi(zeroes,'Yes')
            Tnew(~Tnew.LF_RH_Velocity,:) = [];
            Tnew(~Tnew.RF_RH_Velocity,:) = [];
            Tnew(~Tnew.LR_RH_Velocity,:) = [];
            Told(~Told.LF_RH_Velocity,:) = [];
            Told(~Told.RF_RH_Velocity,:) = [];
            Told(~Told.LR_RH_Velocity,:) = [];
        end
    
    prcts = [invprctile(Tnew.LF_RH_Velocity,-4:2:-0); invprctile(Told.LF_RH_Velocity,-4:2:-0); invprctile(Tnew.RF_RH_Velocity,-4:2:-0); invprctile(Told.RF_RH_Velocity,-4:2:-0); invprctile(Tnew.RR_RH_Velocity,-4:2:-0); invprctile(Told.LR_RH_Velocity,-4:2:-0)];
    prcts =[prcts,[100-invprctile(Tnew.LF_RH_Velocity,0:2:4); 100-invprctile(Told.LF_RH_Velocity,0:2:4); 100-invprctile(Tnew.RF_RH_Velocity,0:2:4); 100-invprctile(Told.RF_RH_Velocity,0:2:4); 100-invprctile(Tnew.RR_RH_Velocity,0:2:4); 100-invprctile(Told.LR_RH_Velocity,0:2:4)]];
    prcts = round(prcts,1);
    prcts = array2table(prcts,"RowNames",["LF New","LF Old","RF New","RF Old","RR New","RR Old"],"VariableNames",["R Fast","R Med","R Slow","C Slow","C Med","C Fast"]);
    fig=uifigure("Name",'Distribution');
    uit=uitable(fig,'Data',prcts);
    
    plotdata(T,Told,Tnew)

    %% Export CSV
    export = questdlg('Do you want to save .csv?','Save CSV','Yes','No','Yes');
        if strcmpi(export,'Yes')
            filename=strrep(filenew,'.csv','.pmed');
            [filesave,pathsave]=uiputfile({'*.csv','CSV Log File'},'Save Tune',fullfile(pathopen,filename));
            writetable(T,fullfile(pathsave,filesave));
        end



    function plotdata(T,Told,Tnew)
        maxv = 6.15
        
        %% Velocity Histograms
        h1=figure('Name','Wheel Velocities','NumberTitle','off');
        tiledlayout(2,2);
        
        LF=nexttile(1);
        hold (LF,"on");
        histogram(Told.LF_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        histogram(Tnew.LF_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        title('LF');
        xline([-4],'-',{'Fast Reb'},'LabelHorizontalAlignment','left');
        xline([-4:2:4],'-',{'Medium Reb','Slow Reb','Slow Comp','Medium Comp','Fast Comp'});
        hold (LF,"off");
        
        RF=nexttile(2);
        hold (RF,"on");
        histogram(Told.RF_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        histogram(Tnew.RF_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        title('RF');
        xline([-4],'-',{'Fast Reb'},'LabelHorizontalAlignment','left');
        xline([-4:2:4],'-',{'Medium Reb','Slow Reb','Slow Comp','Medium Comp','Fast Comp'});
        
        LR=nexttile(3);
        hold (LR,"on");
        histogram(Told.LR_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        histogram(Tnew.LR_RH_Velocity,'BinEdges',[-maxv:0.3:-0.15 0.15:0.3:maxv],'Normalization','probability');
        title('LR');
        xline([-4],'-',{'Fast Reb'},'LabelHorizontalAlignment','left');
        xline([-4:2:4],'-',{'Medium Reb','Slow Reb','Slow Comp','Medium Comp','Fast Comp'});
        
        
        lgd=legend('Old','New');
        lgd.Layout.Tile=4;
        hold off;
        
        %% G and Body plot
        
        h2=figure;
        tiledlayout(2,2);
        gplot=nexttile;
        hold on;
        histogram2(T.Glat_cnv,T.Glng_cnv,[15 15],"DisplayStyle","tile");
        plot(T.Glat_cnv,T.Glng_cnv);
        set(gca, 'YDir','reverse');
        xlabel('G Lat');
        ylabel('G Lng');
        title('G plot');
        hold off;
        
        %h3=figure('Name','Roll/Heave Plot','NumberTitle','off')
        bodyplot=nexttile;
        hold on;
        histogram2(T.Roll,T.Pitch,[15 15],"DisplayStyle","tile");
        plot(T.Roll,T.Pitch);
        set(gca, 'YDir','reverse');
        xlabel('Roll');
        ylabel('Pitch');
        title('Body Motion');
        hold off;
        
        %h4=figure('Name','G influence','NumberTitle','off')
        ginf=nexttile;
        hold on;
        scatter(T.Glng_cnv,T.Pitch,'blue');
        scatter(T.Glat_cnv,T.Roll,'red');
        plot(T.Glng_cnv,T.Pitch,'blue');
        plot(T.Glat_cnv,T.Roll,'red');
        legend('Pitch','Roll');
        xlabel('G');
        ylabel('Angle');
        title('G Influence');
        
    end
    
    



end
