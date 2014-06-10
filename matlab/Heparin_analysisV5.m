% AUTHOR: MOHAMMAD M. GHASSEMI
% REQUIRES - read_file.m
%          - logitRegress.m and supporting files.
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%READ AND LOAD DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Here we read and load data from any CSV File
for loop = 1
outdir  = uigetdir(pwd,'PLEASE SELECT OUTPUT DIRECTORY');
cd([outdir])
read_file([outdir])
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
for K = 1:numfids
  load(fnames(K).name);
  vars{K} = fnames(K).name(1:end-4)
end
cd ..
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This Section Is reserved for data processing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We may want to convert parts of the data into dummy coded variables
for loop = 1

cd([outdir])

%CONVERT GENDERS TO NUMERIC VALUES - GENDER_N
for loop = 1
GENDER_N = zeros(length(GENDER),1);
for i =1:length(GENDER)
if(GENDER{i} == 'M');
    GENDER_N(i) = 1;
elseif(GENDER{i} == 'F')
    GENDER_N(i) = 0;
else
    GENDER_N(i) = -1;
end
end
save('GENDER_N.mat','GENDER_N')
end

%THE ETHNICITY GENERATION LOOP
for loop =1
    
%Convert the various Ethnicities into dummy coded variables.
ETHNICITY_DESCR_NATIVE = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_ASIAN = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_BLACK = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_HISPANIC = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_MIDEAST = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_MULTI = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_HAWIIAN = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_WHITE = zeros(length(ETHNICITY_DESCR),1);
ETHNICITY_DESCR_OTHER = zeros(length(ETHNICITY_DESCR),1);
 
for i =1:length(ETHNICITY_DESCR)
if(strcmp(ETHNICITY_DESCR{i},'AMERICAN INDIAN/ALASKA NATIVE'))
        ETHNICITY_DESCR_NATIVE(i) = 1;
        E_hist(i)= 1;
elseif( strcmp(ETHNICITY_DESCR{i},'ASIAN') | ...
        strcmp(ETHNICITY_DESCR{i},'ASIAN - CHINESE')| ... 
        strcmp(ETHNICITY_DESCR{i},'ASIAN - KOREAN')| ...
        strcmp(ETHNICITY_DESCR{i},'ASIAN - OTHER'))
        ETHNICITY_DESCR_ASIAN(i) = 1;
        E_hist(i)= 2;
elseif( strcmp(ETHNICITY_DESCR{i},'BLACK/AFRICAN')|...
        strcmp(ETHNICITY_DESCR{i},'BLACK/AFRICAN AMERICAN')|...
        strcmp(ETHNICITY_DESCR{i},'BLACK/CAPE VERDEAN')|...
        strcmp(ETHNICITY_DESCR{i},'BLACK/HAITIAN'))
        ETHNICITY_DESCR_BLACK(i) = 1;
        E_hist(i)= 3;
elseif( strcmp(ETHNICITY_DESCR{i},'HISPANIC OR LATINO')|...
        strcmp(ETHNICITY_DESCR{i},'HISPANIC/LATINO - COLOMBIAN')|...
        strcmp(ETHNICITY_DESCR{i},'HISPANIC/LATINO - DOMINICAN')|...
        strcmp(ETHNICITY_DESCR{i},'HISPANIC/LATINO - GUATEMALAN')|...
        strcmp(ETHNICITY_DESCR{i},'HISPANIC/LATINO - PUERTO RICAN')|...
        strcmp(ETHNICITY_DESCR{i},'HISPANIC/LATINO - SALVADORAN'))
        ETHNICITY_DESCR_HISPANIC(i) = 1;  
         E_hist(i)= 4;
elseif(strcmp(ETHNICITY_DESCR{i},'MIDDLE EASTERN' ))
        ETHNICITY_DESCR_MIDEAST(i) = 1;
         E_hist(i)= 5;
elseif(strcmp(ETHNICITY_DESCR{i},'MULTI RACE ETHNICITY'))
        ETHNICITY_DESCR_MULTI(i) = 1;
         E_hist(i)= 6;
elseif(strcmp(ETHNICITY_DESCR{i},'NATIVE HAWAIIAN OR OTHER PACIFIC ISLAND'))
        ETHNICITY_DESCR_HAWIIAN(i) = 1;
        E_hist(i)= 7;
elseif(strcmp(ETHNICITY_DESCR{i},'PORTUGUESE')|...
        strcmp(ETHNICITY_DESCR{i},'WHITE')|...
        strcmp(ETHNICITY_DESCR{i},'WHITE - BRAZILIAN')|...
        strcmp(ETHNICITY_DESCR{i},'WHITE - EASTERN EUROPEAN')|...
        strcmp(ETHNICITY_DESCR{i},'WHITE - OTHER EUROPEAN')|...
        strcmp(ETHNICITY_DESCR{i},'WHITE - RUSSIAN' ))  
        ETHNICITY_DESCR_WHITE(i) = 1; %% THIS IS THE BASE GUY 
        E_hist(i)= 8;
else
        ETHNICITY_DESCR_OTHER(i) = 1;
        E_hist(i)= 9;
end
end
figure;hist(E_hist)

%Save the ethnicity variables
save('ETHNICITY_DESCR_NATIVE.mat','ETHNICITY_DESCR_NATIVE')
save('ETHNICITY_DESCR_ASIAN.mat','ETHNICITY_DESCR_ASIAN')
save('ETHNICITY_DESCR_BLACK.mat','ETHNICITY_DESCR_BLACK')
save('ETHNICITY_DESCR_HISPANIC.mat','ETHNICITY_DESCR_HISPANIC')
save('ETHNICITY_DESCR_MIDEAST.mat','ETHNICITY_DESCR_MIDEAST')
save('ETHNICITY_DESCR_MULTI.mat','ETHNICITY_DESCR_MULTI')
save('ETHNICITY_DESCR_HAWIIAN.mat','ETHNICITY_DESCR_HAWIIAN')
save('ETHNICITY_DESCR_WHITE.mat','ETHNICITY_DESCR_WHITE')
save('ETHNICITY_DESCR_OTHER.mat','ETHNICITY_DESCR_OTHER')
end

%Icustay service dummy coding 
for loop = 1
% ICUSTAY_FIRST_SERVICE_CCU  = zeros(length(ICUSTAY_FIRST_SERVICE),1);
% ICUSTAY_FIRST_SERVICE_CSRU  = zeros(length(ICUSTAY_FIRST_SERVICE),1);
% ICUSTAY_FIRST_SERVICE_FICU  = zeros(length(ICUSTAY_FIRST_SERVICE),1);
% ICUSTAY_FIRST_SERVICE_MICU  = zeros(length(ICUSTAY_FIRST_SERVICE),1);
% ICUSTAY_FIRST_SERVICE_SICU  = zeros(length(ICUSTAY_FIRST_SERVICE),1);
% 
% for i =1:length(ICUSTAY_FIRST_SERVICE)
% if(strcmp(ICUSTAY_FIRST_SERVICE{i},'CCU'))
%         ICUSTAY_FIRST_SERVICE_CCU(i) = 1; %% THE BASE
%         icu_hist(i) = 1;
% elseif(strcmp(ICUSTAY_FIRST_SERVICE{i},'CSRU'))
%         ICUSTAY_FIRST_SERVICE_CSRU(i) = 1;  
%         icu_hist(i) = 2;
% elseif(strcmp(ICUSTAY_FIRST_SERVICE{i},'FICU'))
%         ICUSTAY_FIRST_SERVICE_FICU(i) = 1;
%         icu_hist(i) = 3;
% elseif(strcmp(ICUSTAY_FIRST_SERVICE{i},'MICU'))
%         ICUSTAY_FIRST_SERVICE_MICU(i) = 1; 
%         icu_hist(i) = 4;
% elseif(strcmp(ICUSTAY_FIRST_SERVICE{i},'SICU'))
%         ICUSTAY_FIRST_SERVICE_SICU(i) = 1; 
%         icu_hist(i) = 5;
% end
% end
% figure; hist(icu_hist)
% 
% clear ICUSTAY_FIRST_SERVICE;
% 
% %save icustay service summy codes.
% save('ICUSTAY_FIRST_SERVICE_CCU.mat','ICUSTAY_FIRST_SERVICE_CCU')
% save('ICUSTAY_FIRST_SERVICE_CSRU.mat','ICUSTAY_FIRST_SERVICE_CSRU')
% save('ICUSTAY_FIRST_SERVICE_FICU.mat','ICUSTAY_FIRST_SERVICE_FICU')
% save('ICUSTAY_FIRST_SERVICE_MICU.mat','ICUSTAY_FIRST_SERVICE_MICU')
% save('ICUSTAY_FIRST_SERVICE_SICU.mat','ICUSTAY_FIRST_SERVICE_SICU')
end

%SAPS Composite
for loop = 1
% Y_label = {'PTT_AFTER_HEPARIN'};
% 
% X_label = { ...
% 'AIDS',... 
% 'ALCOHOL_ABUSE',... 
% 'BLOOD_LOSS_ANEMIA',... 
% 'CARDIAC_ARRHYTHMIAS',...
% 'CHRONIC_PULMONARY',... 
% 'COAGULOPATHY',... 
% 'CONGESTIVE_HEART_FAILURE', ...
% 'DEFICIENCY_ANEMIAS', ...
% 'DEPRESSION', ...
% 'DIABETES_COMPLICATED', ...
% 'DIABETES_UNCOMPLICATED', ...
% 'DRUG_ABUSE', ...
% 'FLUID_ELECTROLYTE',... 
% 'HYPERTENSION',... 
% 'HYPOTHYROIDISM',... 
% 'LIVER_DISEASE',... 
% 'LYMPHOMA',...
% 'METASTATIC_CANCER',... 
% 'OBESITY',... 
% 'OTHER_NEUROLOGICAL',... 
% 'PARALYSIS',... 
% 'PEPTIC_ULCER',... 
% 'PERIPHERAL_VASCULAR',... 
% 'PSYCHOSES',... 
% 'PULMONARY_CIRCULATION',... 
% 'RENAL_FAILURE',...
% 'RHEUMATOID_ARTHRITIS',... 
% 'SOLID_TUMOR',...
% 'VALVULAR_DISEASE',... 
% 'WEIGHT_LOSS'
% }
% extra_text = '';
% 
% %% Perform Logistic Regression
% clear Y;
% Y = PTT_AFTER_HEPARIN > 100;
% y_index = [1:size(ICUSTAY_ID,1)];
% %y_index = find((PTT_AFTER_HEPARIN > 100));
% %Y = [Y,ones(length(Y),1)]
% savename = ['PTT_GT_100_Cockcroft.csv'] 
%  
% for i = length(X_label)
%     i
%     % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
%     cd([outdir]);
%     fnames = dir('*.mat');
%     numfids = length(fnames);
%     vals = cell(1,numfids);
%     for K = 1:numfids
%     load(fnames(K).name);
%     vars{K} = fnames(K).name(1:end-4);
%     end
%     cd ..  
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Compute an index by ORing the descending parameters
%     index = [1:size(ICUSTAY_ID,1)];
%     for(k=1:i)
%     index = intersect(index, eval(['find(' X_label{k} '> -1)']));
%     end
%     index = intersect(index,y_index)
%     
%     % Reduce the parameters
%     % X ---
%     files = X_label;
%     for k=1:size(files,2)
%         eval([extra_text files{k} '=' files{k} '(index);']);   
%     end
%     
%     %CREATE Y
%     Y = Y(intersect(index,y_index),:)
%     
%     %CREATE X - we read things using X-label, hence it is in order.
%     clear X;
%     X = [];
%     for k=1:length(X_label)
%         X = [X X_label{k} ','];
%     end
%     X = X(1:end-1);
%     eval(['X_vals=[' X '];']);
%     
%    %X_vals(find((PTT_AFTER_HEPARIN > 100))
%    
%    %SELECT 1:i X vars, recall that x_vars is ordered. 
%    warning off 
%    X_sub = X_vals(:,[1:i]);
%    eval(['all_res=logitRegress(X_sub,Y,10);']);
% end
% 
%  % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
%     cd([outdir]);
%     fnames = dir('*.mat');
%     numfids = length(fnames);
%     vals = cell(1,numfids);
%     for K = 1:numfids
%     load(fnames(K).name);
%     vars{K} = fnames(K).name(1:end-4);
%     end
%     cd .. 
%     
%     
% saps_X = [ ...
% AIDS,... 
% ALCOHOL_ABUSE,... 
% BLOOD_LOSS_ANEMIA,... 
% CARDIAC_ARRHYTHMIAS,...
% CHRONIC_PULMONARY,... 
% COAGULOPATHY,... 
% CONGESTIVE_HEART_FAILURE, ...
% DEFICIENCY_ANEMIAS, ...
% DEPRESSION, ...
% DIABETES_COMPLICATED, ...
% DIABETES_UNCOMPLICATED, ...
% DRUG_ABUSE, ...
% FLUID_ELECTROLYTE,... 
% HYPERTENSION,... 
% HYPOTHYROIDISM,... 
% LIVER_DISEASE,... 
% LYMPHOMA,...
% METASTATIC_CANCER,... 
% OBESITY,... 
% OTHER_NEUROLOGICAL,... 
% PARALYSIS,... 
% PEPTIC_ULCER,... 
% PERIPHERAL_VASCULAR,... 
% PSYCHOSES,... 
% PULMONARY_CIRCULATION,... 
% RENAL_FAILURE,...
% RHEUMATOID_ARTHRITIS,... 
% SOLID_TUMOR,...
% VALVULAR_DISEASE,... 
% WEIGHT_LOSS
% ]
% 
% for koo = 1:length(saps_X)
% AGG_ELIX(koo)=sum(saps_X(koo,:) .* all_res.b(2:end)');
% end
% 
% AGG_ELIX = AGG_ELIX';
% 
% AGG_ELIX = AGG_ELIX - min(AGG_ELIX);
% save('AGG_ELIX.mat','AGG_ELIX')
end


ICUSTAY_GROUP_MICU_CICU_FICU = ~ICUSTAY_GROUP_CSRU_SICU
save('ICUSTAY_GROUP_MICU_CICU_FICU.mat','ICUSTAY_GROUP_MICU_CICU_FICU')

CREATININ_BEFORE_GT1p6 = CREATININ_BEFORE > 1.6
save('CREATININ_BEFORE_GT1p6.mat','CREATININ_BEFORE_GT1p6')

CREATININ_BEFORE_LTE1p1 = CREATININ_BEFORE <= 1.1
save('CREATININ_BEFORE_LTE1p1.mat','CREATININ_BEFORE_LTE1p1')

CREATININ_BEFORE_GT1p2_AND_LT1p6 = CREATININ_BEFORE > 1.2 & CREATININ_BEFORE < 1.6
save('CREATININ_BEFORE_GT1p2_AND_LT1p6.mat','CREATININ_BEFORE_GT1p2_AND_LT1p6')



%Reload the variables.
fnames = dir('*.mat');
numfids = length(fnames);
vals = cell(1,numfids);
for K = 1:numfids
  load(fnames(K).name);
  vars{K} = fnames(K).name(1:end-4)
end
cd .. 


end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% SELECT CONDITIONS    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This is the List of high level Conditions we want to impose on the data
% This will be usefull when you want to partition the data and run agian.
%For instance, selecting by ICU SERVICE TYPE.
%--------------------------------------------------------------------------
%-------------------------------------------------------------------------
for loop = 1
%Indicate the conditions you want to apply to the data.

%index = intersect(intersect( ...
%    find(CREATININ_AFTER < 4), ...
%    find(SAPS >= 0)), ...
%    find(WEIGHT_FIRST >= 0));

%Indicate a new label you would like to apply to data, 
%or leave blank to modify the files with selected conditions
extra_text = '';

%Indicate any Variables you want to apply these conditions to
%NOTE: I reccomend you leave this as is, unless you have very large data

files = vars;

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%for i=1:size(files,2)  
%   eval([extra_text files{i} '=' files{i} '(index);']); 
%end
end
%% SELECTING INPUTS AND OUTPUTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please indicate your outcome variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GFR STUFF - you don't have to run it unless you have GFR. 
GFR_MDRD_sorted = sort(GFR_MDRD)
start = max(find(sort(GFR_MDRD) == -1))
GFR_range_finder = GFR_MDRD_sorted(start+1:end,1)
q_range = round(size(GFR_range_finder)/4)
q(1:4) = GFR_range_finder([716        1432        2148        2863])
GFR_1q = zeros(length(GFR_MDRD),1);
GFR_2q = GFR_MDRD > q(1) & GFR_MDRD <= q(2);
GFR_3q = GFR_MDRD > q(2) & GFR_MDRD <= q(3);
GFR_4q = GFR_MDRD > q(3) & GFR_MDRD <= q(4);
%sum(GFR_1q .* GFR_2q .* GFR_3q .* GFR_4q) -- To make sure things went
%right.


for lpl = 6
    for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'GFR_2q',...
            'GFR_3q',...
            'GFR_4q',...
            'ELIXHAUSER_PT',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_6HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }  
extra_text = '';


%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '> 100;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
length(PTT_6HR_TIME_FROM_HEP)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_GT_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    %This is the index of the reduced parameters.
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

for lpl = 24
    for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'GFR_2q',...
            'GFR_3q',...
            'GFR_4q',...
            'ELIXHAUSER_PT',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_24HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }  
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '> 100;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
length(PTT_6HR_TIME_FROM_HEP)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_GT_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
        index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    %This is the index of the reduced parameters.
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end















%Creatinin - 6,12,24 hrs GT 100
for lpl = 6
    for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_6HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }  
extra_text = '';


%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '> 100;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
length(PTT_6HR_TIME_FROM_HEP)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_GT_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    %This is the index of the reduced parameters.
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

for lpl = 24
    for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_24HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }  
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '> 100;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
length(PTT_6HR_TIME_FROM_HEP)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_GT_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
        index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    %This is the index of the reduced parameters.
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

%Let's see a histogram of the Dose-by-Weight.

%Creatinin - 6,12,24, LT 50
for lpl = [6] 
for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_6HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }    
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '< 50;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_LT_50.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

for lpl = [24] 
for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'TRANSFER_FLAG',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_24HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }    
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '< 50;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_LT_50.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

%Creatinin - 6,12,24 50 < PTT < 100
for lpl = [6]
for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'TRANSFER_FLAG',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_6HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }   
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '>= 50 & ' Y_label{1} '<= 150;'])
%y_index = [1:size(ICUSTAY_ID,1)];
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_BET_50_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

for lpl = [24]
for loop = 1
Y_label = {['PTT_VAL_' num2str(lpl) 'HR']};
X_label = { 
            ...%'AGG_ELIX',...
            'AGE',...
            'GENDER_N',...
            'SOFA_ADJUSTED',...
            'CREATININ_BEFORE_LTE1p1',...
            'ELIXHAUSER_PT',...
            'TRANSFER_FLAG',...
            'ICUSTAY_GROUP_MICU_CICU_FICU',...
            'DOSE_BY_WEIGHT',...                    
            'PTT_24HR_TIME_FROM_HEP',...
            'ETHNICITY_DESCR_WHITE',...
            }   
extra_text = '';

%% Perform Logistic Regression
clear Y;
Y = eval([Y_label{1} '>= 50 & ' Y_label{1} '<= 150;'])
%y_index = [1:size(ICUSTAY_ID,1)];
y_index = find(PTT_6HR_TIME_FROM_HEP ~= -1)
%y_index = intersect(find(TRANSFER_FLAG ==0),find(ESRD_FLAG ==0));
%Y = [Y,ones(length(Y),1)]
savename = [Y_label{1} '_BET_50_100.csv'] 
 
for i = length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    index = intersect(index,y_index)
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    Y = Y(intersect(index,y_index),:)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %X_vals(find((PTT_AFTER_HEPARIN > 100))
   
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['all_res=logitRegress(X_sub,Y,10);']);
end
publishMultivariateLogitRegressResults(all_res,[pwd],savename,X_label,cell2mat(Y_label))

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index
h = figure; 
hist(DOSE_BY_WEIGHT(index),max(DOSE_BY_WEIGHT(index)))
xlabel('Dose(Units)/Weight(Kg)')
ylabel('Number of Patients')
title('Historgram of Initial Heparin Dose by Body Weight')
pubgraph(h,14,2,'w')

set(gcf, 'PaperPositionMode', 'auto');
print -depsc2 finalPlot1.eps












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  LOGISTIC REGRESSION %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% COMPUTE THE AUC FOR A MODEL WITH ONLY EACH PARAMETER INDIVIDUALLY
for i = 1:length(X_label)
    i
    % LOAD THE FILES %%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    clear X;
    clear Y;  
    
    %Compute the index of suitable data
    index = [1:size(ICUSTAY_ID,1)];
    index = intersect(index, eval(['find(' X_label{i} '> -1)']));
    
    %reduce data using the index
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);
    end
    
    % GET Y that satisfies our condition and according to index 
    Y = (PTT_AFTER_HEPARIN > 100);
    Y = Y(index);
    
    % GET X that satisfies our condition and according to index (built in)
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);

    %Create a series of models to test.
    tests = dec2bin([2.^(size(X_vals,2)-[1:size(X_vals,2)])]);
    
    %Run the models
    warning off
    X_sub = X_vals(:,find(tests(i,:) == '1'));
    eval(['res(i)=logitRegress(X_sub,Y,10);']);
    end
    
%Order the Model parametes by their AUC inthe LogisRegress
[vals ordered] = sort([res.auc],'descend');
X_label = X_label(ordered);

%COMPUTE THE AUC USING MULTIPLE PARAMETERS. 
for i = 1:length(X_label)
    i
    % LOAD THE FILES %%%%%%%%%%%%%%%%%%%%%%%
    cd([outdir]);
    fnames = dir('*.mat');
    numfids = length(fnames);
    vals = cell(1,numfids);
    for K = 1:numfids
    load(fnames(K).name);
    vars{K} = fnames(K).name(1:end-4);
    end
    cd ..  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute an index by ORing the descending parameters
    index = [1:size(ICUSTAY_ID,1)];
    for(k=1:i)
    index = intersect(index, eval(['find(' X_label{k} '> -1)']));
    end
    
    % Reduce the parameters
    % X ---
    files = X_label;
    for k=1:size(files,2)
        eval([extra_text files{k} '=' files{k} '(index);']);   
    end
    
    %CREATE Y
    clear Y;
    Y = (PTT_AFTER_HEPARIN > 100);
    Y = Y(index)
    
    %CREATE X - we read things using X-label, hence it is in order.
    clear X;
    X = [];
    for k=1:length(X_label)
        X = [X X_label{k} ','];
    end
    X = X(1:end-1);
    eval(['X_vals=[' X '];']);
    
   %SELECT 1:i X vars, recall that x_vars is ordered. 
   warning off 
   X_sub = X_vals(:,[1:i]);
   eval(['res(i)=logitRegress(X_sub,Y,10);']);
    
   index_len(i) = length(index);
   
end
  
%Find the best fit with significant pvals and max AUC
clear best_fit;
best_fit = find([res.HLtestp] >0.05);
best_fit_2 = find([res(best_fit).auc] == max([res(best_fit).auc]));
best_fit = best_fit(best_fit_2);

%AUC versus feature Inclusion.
subplot(2,2,1:2); plot([1:57],[res.auc])
xlabel('Number of Model Features')
ylabel('AUC')
title('AUC grow using sorted feature inclusion')
text(9,.698,'\leftarrow Creatinine Before Feature',...
     'HorizontalAlignment','left')


subplot(2,2,3:4); plot([1:57],index_len)
xlabel('Number of Model Features')
ylabel('Cohort Size')
title('Cohort size versus feature inclusion')
text(9,2179,'\leftarrow Creatinine Before Feature',...
     'HorizontalAlignment','left')
%Best Result is when we inlcude everything.
%HL = 0.338287979779446
%AUC = 0.675488370394711

%Publish the results.
publishMultivariateLogitRegressResults(res(best_fit(end)),[pwd],[Y_label '_allfeatures.csv'],X_label,cell2mat(Y_label))
