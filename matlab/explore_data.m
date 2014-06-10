clear all; close all; clc;

%% Load and get data
data = load_lactate_data;
% data(:,6) = data(:,6)*1000;
% data(:,6) = data(:,6)*1000;
FEATURE_D = {'~~Mean','~~Median','~~Minimum','~~Maximum','~~Slope (-/day)'};
method_D = {'median','median','median','median','median'};
FEATURE_D = [FEATURE_D, FEATURE_D, FEATURE_D, FEATURE_D, ...
    FEATURE_D, FEATURE_D, FEATURE_D];
method_D = [method_D, method_D, method_D, method_D, ...
    method_D, method_D, method_D];
FEATURE_D_LABELS = {'Lactate, mmol/L','Systolic BP, mmHg','Diastolic BP, mmHg', ...
    'Pulse Pressure, mmHg','Mean Arterial Pressure, mmHg','Heart Rate, bpm', 'CO'};
params_D = 2:36;

fname = '../data/export_data_lactate_cohort.csv';
[subject_id, hadm_id, icustay_id, icu_stayintime, icustayouttime, gender, weight, age, ilos, ...
    careunit, servtype, sofa, saps, vp, vt, sepsis, rrt, mort_icu, mort_hos, mort_28d, mort_1yr, mort_2yr, ...
    elix_hos, elix_28d, elix_1yr, elix_2yr] =  ...
    textread(fname,'%d%d%d%s%s%s%f%f%f%s%s%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d', 'headerlines',1,'delimiter',',');

co_details = zeros(size(data,1),18); 
for i = 1 : size(data,1)
    ind = find(icustay_id == data(i,1));
    if length(ind) == 1
        co_details(i,1) = icustay_id(ind);
        co_details(i,2) = strcmp(gender(ind),'"M"'); FEATURE{1} = 'Gender'; method{1} = 'prop';
        co_details(i,3) = age(ind); FEATURE{2} = 'Age'; method{2} = 'median';
        co_details(i,4) = weight(ind); FEATURE{3} = 'Weight'; method{3} = 'median';
        co_details(i,5) = ilos(ind); FEATURE{4} = 'ICU LoS'; method{4} = 'median';
        if strcmp(servtype(ind),'"MICU"') || strcmp(servtype(ind),'"FICU"')
            co_details(i,6) = 1; FEATURE{5} = '~~MICU'; method{5} = 'prop';
        elseif strcmp(servtype(ind),'"CCU"')
            co_details(i,7) = 1; FEATURE{6} = '~~CCU'; method{6} = 'prop';
        elseif strcmp(servtype(ind),'"SICU"')
            co_details(i,8) = 1; FEATURE{7} = '~~SICU'; method{7} = 'prop';
        elseif strcmp(servtype(ind),'"CSRU"')
            co_details(i,9) = 1; FEATURE{8} = '~~CSRU'; method{8} = 'prop';
        end     
        co_details(i,10) = sofa(ind); FEATURE{9} = 'SOFA'; method{9} = 'median';
        co_details(i,11) = saps(ind); FEATURE{10} = 'SAPS-I'; method{10} = 'median';
        co_details(i,12) = vp(ind); FEATURE{11} = 'Vasopressors Used'; method{11} = 'prop';
        co_details(i,13) = vt(ind); FEATURE{12} = 'Ventilation Used'; method{12} = 'prop';
        co_details(i,14) = sepsis(ind); FEATURE{13} = 'Sepsis (Martin Criteria)'; method{13} = 'prop';
        co_details(i,15) = rrt(ind); FEATURE{14} = 'RRT'; method{14} = 'prop';
        co_details(i,16) = mort_icu(ind); FEATURE{15} = '~~Mortality ICU'; method{15} = 'prop';
        co_details(i,17) = mort_hos(ind); FEATURE{16} = '~~Mortality Hosp.'; method{16} = 'prop';
        co_details(i,18) = mort_28d(ind); FEATURE{17} = '~~Mortality 28-Day'; method{17} = 'prop';
    else
        fprintf('There is something wrong!\n');
    end 
end
params = 2:18;

%% Perform analyis on a specific group

%rmInd =  []; % evaluate all patients in selected cohort
rmInd = co_details(:,12);             % evaluate all patients who were not on vasopressors
data(rmInd == 1,:) = [];
co_details(rmInd == 1,:) = [];
group = data(:,end); N1 = sum(group==0); N2 = sum(group==1);

[cell_data] = comparegroups(data,group,params_D,FEATURE_D,method_D);
[cell_details] = comparegroups(co_details,group,params,FEATURE,method);

%filename = 'docs/report/table_all_icumort.tex';
labelname = sprintf('Characteristsics of study patients with no vasopressors (n = %d).',length(group));
%dolatextable(filename,labelname,[N1 N2],cell_demog,cell_elix,cell_scores,cell_testadm,cell_test24,cell_delta,cell_treats,cell_sepsis_rrt);
filename = '../report/table_lactate_novp.tex';
dolatextable(filename,labelname,[N1 N2],cell_data,cell_details);
