fname = 'export_output_descriptors.csv';
[sub_id,icu_id,hos_id,cotype,gender,age,elix,ilos,servtype, ...
    mort_28d,mort_1yr,mort_2yr,mort_hos,mort_icu,c,icd9, ...
    cm_diabetes,cm_chf,cm_alcohol_abuse,cm_arrhythmias, ...
    cm_valvular_disease,cm_hypertension,cm_renal_failure, ...
    cm_chronic_pulmonary,cm_liver_disease,cm_cancer, ...
    cm_psychosis,cm_depression,sofa_d1s,sofa_d2s,sofa_d3s, ...
    sapsi_d1s, sapsi_d2s, sapsi_d3s] = ...
    textread(fname,'%d%d%d%s%s%s%s%s%s%d%d%d%d%d%s%s%d%d%d%d%d%d%d%d%d%d%d%d%s%s%s%s%s%s','headerlines',1,'delimiter',',');

N = length(sub_id);
cotypen = zeros(N,1);
gendern = zeros(N,1);
agen = zeros(N,1);
ilosn = zeros(N,1);
servtypen = zeros(N,1);
icd9n = zeros(N,1);
elixn = zeros(N,1);
sofa_d1 = zeros(N,1); sofa_d2 = zeros(N,1); sofa_d3 = zeros(N,1);
sapsi_d1 = zeros(N,1); sapsi_d2 = zeros(N,1); sapsi_d3 = zeros(N,1);

for i = 1 : N
    cotypen(i) = str2double(cotype{i}(2));
    if strcmp(gender{i},'"M"')
        gendern(i) = 1;
    end
    agen(i) = str2double(age{i});
    elixn(i) = str2double(elix{i});
    ilosn(i) = str2double(ilos{i});
    sofa_d1(i) = str2double(sofa_d1s{i});
    sofa_d2(i) = str2double(sofa_d2s{i});
    sofa_d3(i) = str2double(sofa_d3s{i});
    sapsi_d1(i) = str2double(sapsi_d1s{i});
    sapsi_d2(i) = str2double(sapsi_d2s{i});
    sapsi_d3(i) = str2double(sapsi_d3s{i});
    if strcmp(servtype{i},'"MICU"') || strcmp(servtype{i},'"FICU"') 
        servtypen(i) = 1;
    elseif strcmp(servtype{i},'"CCU"')
        servtypen(i) = 2;
    elseif strcmp(servtype{i},'"SICU"')
        servtypen(i) = 3;
    elseif strcmp(servtype{i},'"CSRU"')
        servtypen(i) = 4;    
    end
    if strcmp(icd9{i},'"CARDIOVASCULAR"') 
        icd9n(i) = 2;
    elseif strcmp(icd9{i},'"CANCER"')
        icd9n(i) = 1;
    elseif strcmp(icd9{i},'"RESPIRATORY"')
        icd9n(i) = 3;
    elseif strcmp(icd9{i},'"ENDOCRINE_METABOLIC"')
        icd9n(i) = 4;    
    elseif strcmp(icd9{i},'"OTHER"') 
        icd9n(i) = 5;
    elseif strcmp(icd9{i},'"GI"')
        icd9n(i) = 6;
    elseif strcmp(icd9{i},'"GU"')
        icd9n(i) = 7;
    elseif strcmp(icd9{i},'"TRAUMA"')
        icd9n(i) = 8;
    elseif strcmp(icd9{i},'"TREATMENT"')
        icd9n(i) = 9;
    end
end


%% Perform some statistics

cellM = {'Nr. Patients'; ...
    ''; ...
    'Age, yrs'; ...
    'Gender (males)'; ...
    '~~~MICU'; ...
    '~~~CCU'; ...
    '~~~SICU'; ...
    '~~~CSRU'; ...
    '~~~ICU Mortality'; ...
    '~~~Hosptial Mortality'; ...
    '~~~28-day Mortality'; ...
    '~~~1-year Mortality'; ...
    '~~~2-year Mortality'; ...
    '~~~ICU Length-of-stay, days'; ...
    'ElixHauser Score'; ...
    '~~~Cancer'; ...
    '~~~Cardiovascular'; ...
    '~~~Respiratory'; ...
    '~~~Endocrine metabolic'; ...
    '~~~Other'; ...
    '~~~GI'; ...
    '~~~GU'; ...
    '~~~Trauma'; ...
    '~~~Treatment'; ...
    '~~~Diabetes'; ...
    '~~~CHF'; ...
    '~~~Alcohol abuse'; ...
    '~~~Arrhythmias'; ...
    '~~~Valvular disease'; ...
    '~~~Hypertension'; ...
    '~~~Renal failure'; ...
    '~~~Chronic Pulmonary'; ...
    '~~~Liver disease'; ...
    '~~~Cancer'; ...
    '~~~Psychosis'; ...
    '~~~Depression'; ...
    'SOFA Day 1'; ...
    'SOFA Day 2'; ...
    'SOFA Day 3'; ...
    'SAPS-I Day 1'; ...
    'SAPS-I Day 2'; ...
    'SAPS-I Day 3'};

for i = 1 : 3
    N = sum(cotypen==i);
    % Number of patients
    ind = find(cotypen==i);
    cellM{1,1+i} = sum(cotypen==i); 
    cellM{3,1+i} = sprintf('%.1f (%.1f)',median(agen(ind)),iqr(agen(ind)));
    cellM{4,1+i} = sprintf('%d (%.1f)',sum(gendern(ind)),sum(gendern(ind))/N*100);
    cellM{5,1+i} = sprintf('%d (%.1f)',sum(servtypen(ind)==1),sum(servtypen(ind)==1)/N*100);
    cellM{6,1+i} = sprintf('%d (%.1f)',sum(servtypen(ind)==2),sum(servtypen(ind)==2)/N*100);
    cellM{7,1+i} = sprintf('%d (%.1f)',sum(servtypen(ind)==3),sum(servtypen(ind)==3)/N*100);
    cellM{8,1+i} = sprintf('%d (%.1f)',sum(servtypen(ind)==4),sum(servtypen(ind)==4)/N*100);
    cellM{9,1+i} = sprintf('%d (%.1f)',sum(mort_icu(ind)),sum(mort_icu(ind))/N*100);
    cellM{10,1+i} = sprintf('%d (%.1f)',sum(mort_hos(ind)),sum(mort_hos(ind))/N*100);
    cellM{11,1+i} = sprintf('%d (%.1f)',sum(mort_28d(ind)),sum(mort_28d(ind))/N*100);
    cellM{12,1+i} = sprintf('%d (%.1f)',sum(mort_1yr(ind)),sum(mort_1yr(ind))/N*100);
    cellM{13,1+i} = sprintf('%d (%.1f)',sum(mort_2yr(ind)),sum(mort_2yr(ind))/N*100);
    cellM{14,1+i} = sprintf('%.1f (%.1f)',median(ilosn(ind)),iqr(ilosn(ind)));
    cellM{15,1+i} = sprintf('%.1f (%.1f)',nanmedian(elixn(ind)),iqr(elixn(ind)));
    cellM{16,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==1),sum(icd9n(ind)==1)/N*100);
    cellM{17,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==2),sum(icd9n(ind)==2)/N*100);
    cellM{18,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==3),sum(icd9n(ind)==3)/N*100);
    cellM{19,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==4),sum(icd9n(ind)==4)/N*100);
    cellM{20,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==5),sum(icd9n(ind)==5)/N*100);
    cellM{21,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==6),sum(icd9n(ind)==6)/N*100);
    cellM{22,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==7),sum(icd9n(ind)==7)/N*100);
    cellM{23,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==8),sum(icd9n(ind)==8)/N*100);
    cellM{24,1+i} = sprintf('%d (%.1f)',sum(icd9n(ind)==9),sum(icd9n(ind)==9)/N*100);
    cellM{25,1+i} = sprintf('%d (%.1f)',sum(cm_diabetes(ind)),sum(cm_diabetes(ind))/N*100);
    cellM{26,1+i} = sprintf('%d (%.1f)',sum(cm_chf(ind)),sum(cm_chf(ind))/N*100);
    cellM{27,1+i} = sprintf('%d (%.1f)',sum(cm_alcohol_abuse(ind)),sum(cm_alcohol_abuse(ind))/N*100);
    cellM{28,1+i} = sprintf('%d (%.1f)',sum(cm_arrhythmias(ind)),sum(cm_arrhythmias(ind))/N*100);
    cellM{29,1+i} = sprintf('%d (%.1f)',sum(cm_valvular_disease(ind)),sum(cm_valvular_disease(ind))/N*100);
    cellM{30,1+i} = sprintf('%d (%.1f)',sum(cm_hypertension(ind)),sum(cm_hypertension(ind))/N*100);
    cellM{31,1+i} = sprintf('%d (%.1f)',sum(cm_renal_failure(ind)),sum(cm_renal_failure(ind))/N*100);
    cellM{32,1+i} = sprintf('%d (%.1f)',sum(cm_chronic_pulmonary(ind)),sum(cm_chronic_pulmonary(ind))/N*100);
    cellM{33,1+i} = sprintf('%d (%.1f)',sum(cm_liver_disease(ind)),sum(cm_liver_disease(ind))/N*100); 
    cellM{34,1+i} = sprintf('%d (%.1f)',sum(cm_cancer(ind)),sum(cm_cancer(ind))/N*100);
    cellM{35,1+i} = sprintf('%d (%.1f)',sum(cm_psychosis(ind)),sum(cm_psychosis(ind))/N*100);
    cellM{36,1+i} = sprintf('%d (%.1f)',sum(cm_depression(ind)),sum(cm_alcohol_abuse(ind))/N*100);
    cellM{37,1+i} = sprintf('%.1f (%.1f)',nanmedian(sofa_d1(ind)),iqr(sofa_d1(ind)));
    cellM{38,1+i} = sprintf('%.1f (%.1f)',nanmedian(sofa_d2(ind)),iqr(sofa_d2(ind)));
    cellM{39,1+i} = sprintf('%.1f (%.1f)',nanmedian(sofa_d3(ind)),iqr(sofa_d3(ind)));
    cellM{40,1+i} = sprintf('%.1f (%.1f)',nanmedian(sapsi_d1(ind)),iqr(sapsi_d1(ind)));
    cellM{41,1+i} = sprintf('%.1f (%.1f)',nanmedian(sapsi_d2(ind)),iqr(sapsi_d2(ind)));
    cellM{42,1+i} = sprintf('%.1f (%.1f)',nanmedian(sapsi_d3(ind)),iqr(sapsi_d3(ind)));
end

filename1 = 'table_cohort_descriptors_1.tex';
labelname1 = sprintf('Characteristsics of study cohorts: Demographics and Outcomes.');
filename2 = 'table_cohort_descriptors_2.tex';
labelname2 = sprintf('Characteristsics of study cohorts: ICD-9 codes and Combordities');
groupcaption = {'Septic Cohort','CCU (nonseptic)','GI bleed'};
dolatextable(filename1,labelname1,groupcaption,cellM);
dolatextable2(filename2,labelname2,groupcaption,cellM);