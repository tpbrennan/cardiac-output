function [results] = cardiac_output_analysis(fcohort,dt,thr)

close all

graphic = true;
figout = true;
stats = false;
results = [];

data_titles = {'Pulse Pressure (mmHg)','Heart Rate (bpm)','Lactic Acid','Urine Output'};
data_labels = {'pulsep','hr','lactate','urine'};
ostrs = {'pp','hr','la','uo'};

clr = {'r','b','k','m','g'};
lightclr = [.5 .2 .2; .2 .2 .5; .2 .2 .2; .5 .3 .5];
ylims = [0 150; 40 150; -5 30; -100 1000];

% load cohort 
[sid,hid,iid,gender,age,los,lvef,mort28d,vp] = ...
    textread(fcohort,'%d%d%d%c%n%n%d%d%d\n','headerlines',1,'delimiter',',');

% load timeseries data 
% [PP,HR,L,U] = load_icustay_timeseries(fdata);
load 'Results/cardiac_output_timeseries.mat'

% data stats
[usid,ia,ic] = unique(sid);
N = length(iid);
tg = gender(ic);

% Subgroups - Gender
tgm = find(tg=='M');
tgf = find(tg=='F');
gmidx = find(gender=='M');
gfidx = find(gender=='F');

% Subgroups - LVEF 
lvef1_id = iid(find(lvef==1));
lvef2_id = iid(find(lvef==2));
lvef3_id = iid(find(lvef==3));
lvef4_id = iid(find(lvef==4));

% Subgroups - survivors
surv_id = iid(find(~mort28d));
died_id = iid(find(mort28d));

% Subgroups - vasopressors
vsp_id = iid(find(vp));
nvsp_id = iid(find(~vp));

if stats,
    
    % Total cohort
    fprintf('Cohort demographics: %d patients\n',length(usid));
    fprintf('\t %d Male %2.1f(%2.1f) - %2.1f\n',length(tgm),mean(age(tgm)),std(age(tgm)),median(los(tgm)));
    fprintf('\t %d Female %2.1f(%2.1f) - %2.1f\n',length(tgf),mean(age(tgf)),std(age(tgf)),median(los(tgf)));

    % Across ICU stays
    fprintf('No. ICU stays: %d\n',length(iid));

    fprintf('Had vasopressors therapy: %d %2.1f(%2.1f) - %2.1f\n',sum(vp),mean(age(vsp_idx)),std(age(vsp_idx)),median(los(vsp_idx)));
    fprintf('No vasopressors: %d %2.1f(%2.1f) - %2.1f\n',sum(~vp),mean(age(nvsp_idx)),std(age(nvsp_idx)),median(los(nvsp_idx)));

    fprintf('LVEF: %d echos\n',length(find(lvef)));
    fprintf('\t%d suppressed %2.1f(%2.1f) - %2.1f\n',sum(lvef==1),mean(age(lvef1_idx)),std(age(lvef1_idx)),median(los(lvef1_idx)));
    fprintf('\t%d mild suppression %2.1f(%2.1f) - %2.1f\n',sum(lvef==2),mean(age(lvef2_idx)),std(age(lvef2_idx)),median(los(lvef2_idx)));
    fprintf('\t%d normal function %2.1f(%2.1f) - %2.1f\n',sum(lvef==3),mean(age(lvef3_idx)),std(age(lvef3_idx)),median(los(lvef3_idx)));
    fprintf('\t%d hyperdynamic %2.1f(%2.1f) - %2.1f\n\n',sum(lvef==4),mean(age(lvef4_idx)),std(age(lvef4_idx)),median(los(lvef4_idx)));

    fprintf('Mortality (28 days):\n');
    fprintf('\t%d Survivors %2.1f(%2.1f) - %2.1f\n',sum(~mort28d),mean(age(surv_idx)),std(age(surv_idx)),median(los(surv_idx)));
    fprintf('\t%d Died %2.1f(%2.1f) - %2.1f\n',sum(mort28d),mean(age(died_idx)),std(age(died_idx)),median(los(died_idx)));
end

%plot hists 
%figure;
%subplot(1,2,1); hist(age); xlabel('Age (yrs)');
%subplot(1,2,2); hist(los); xlabel('Length of stay (days)');
h = [];


% Plots

% loop through data type
for n = 1:4
    X = varargout{n};
    fprintf('%s:\n',data_titles{n});

%     % Vasopressors
%     idx = {vsp_id,nvsp_id};
%     fname = sprintf('Results/vsp_cohorts_%s.mat',data_labels{n});
%     if exist(fname,'file'),
%         load(fname);
%         fprintf('Loaded %s\n',fname);
%     else
%         [Xd,Xall] = split_timeseries(X,idx,dt);
%         save(fname,'Xd','Xall');
%     end    
%     
%     if graphic,
%         f = figure;
%         for i = 1:length(idx);
%             x = Xall{i};
%             
%             % get timestamps and data
%             t = x(:,1);
%             
%             % limit to max time
%             xthr = x(find(t<thr),:);
%             
%             plot(xthr(:,1)./1440,xthr(:,2),'.','Color',lightclr(i,:)); hold on;
%             
%             [T,Y,E,N] = avg_timeseries(xthr,dt);
%             %[T,Y,E] = median_timeseries(Xall{n},dt,thr);
% 
%             h(i) = errorbar(T./1440,Y,E,clr{i}); hold on;
%             %plot(T./1440,Y,[clr{n}, '.'],'MarkerSize',10); hold on;
% 
%             %figure;plot(T./1440,N,[clr{n}, '.'],'MarkerSize',10); hold on;
%             
%         end
%         
%         title(gca,[data_titles{n}, ' with Vasopressor Use']);
%         xlabel(gca,'Time (days)');
%         ylabel(gca,data_titles{n});
%         legend(h(1:length(idx)),'Vasopressor Therapy','No Vasopressors');
%         xlim([0 thr/1400])
%         ylim(ylims(n,:));
%         if (figout), 
%             fileout = sprintf('%s_vasopressors.png',data_labels{n});
%             print(f,'-dpng',fileout);
%         end
%     end
    
 
    % Survivors
    fname = sprintf('Results/surv_cohorts_%s.mat',data_labels{n});
    if exist(fname,'file'),
        load(fname);
    else
        [Xd,Xall] = split_timeseries(X,{surv_id,died_id},dt);
        save(fname,'Xd','Xall');
    end    
    
    if graphic,
        f = figure;
        for i = 1:length(idx);
            x = Xall{i};
            
            % get timestamps and data
            t = x(:,1);
            
            % limit to max time
            xthr = x(find(t<thr),:);
            
            plot(xthr(:,1)./1440,xthr(:,2),'.','Color',lightclr(i,:)); hold on;
            
            [T,Y,E,N] = avg_timeseries(xthr,dt);
            %[T,Y,E] = median_timeseries(Xall{n},dt,thr);

            h(i) = errorbar(T./1440,Y,E,clr{i}); hold on;
            %plot(T./1440,Y,[clr{n}, '.'],'MarkerSize',10); hold on;

            %figure;plot(T./1440,N,[clr{n}, '.'],'MarkerSize',10); hold on;
            
        end
        
        title(gca,[data_titles{n}, ' with Survivors']);
        xlabel(gca,'Time (days)');
        ylabel(gca,data_titles{n});
        legend(h(1:length(idx)),'Survivors','Non-Survivors');
        xlim([0 thr/1440])
        ylim(ylims(n,:));
        if (figout), 
            fileout = sprintf('%s_survivors.png',data_labels{n});
            print(f,'-dpng',fileout);
        end

    end


    % LVEF
    idx = {lvef1_id,lvef2_id,lvef3_id,lvef4_id};
    fname = sprintf('Results/lvef_cohorts_%s.mat',data_labels{n});
    if exist(fname,'file'),
        load(fname);
    else
        [Xd,Xall] = split_timeseries(X,idx,dt);
        save(fname,'Xd','Xall');
    end 
    
    if graphic,
        f = figure;
        for i = 1:length(idx);
            x = Xall{i};
            
            % get timestamps and data
            t = x(:,1);
            
            % limit to max time
            xthr = x(find(t<thr),:);
            
            plot(xthr(:,1)./1440,xthr(:,2),'.','Color',lightclr(i,:)); hold on;
            
            [T,Y,E,N] = avg_timeseries(xthr,dt);
            %[T,Y,E] = median_timeseries(Xall{n},dt,thr);

            h(i) = errorbar(T./1440,Y,E,clr{i}); hold on;
            %plot(T./1440,Y,[clr{n}, '.'],'MarkerSize',10); hold on;

            %figure;plot(T./1440,N,[clr{n}, '.'],'MarkerSize',10); hold on;
            
        end
        
        title(gca,[data_titles{n}, ' across LVEF ranges']);
        xlabel(gca,'Time (days)');
        ylabel(gca,data_titles{n});
        legend(h(1:length(idx)),'Surppressed','Mild-Suppression','Normal','Hyperdynamic');
        xlim([0 thr/1400])
        ylim(ylims(n,:));
        if (figout), 
            fileout = sprintf('%s_lvef.png',data_labels{n});
            print(f,'-dpng',fileout);
        end

    end

end
