function [id,gender,age,icudays,vp] = load_cardiac_output_cohort(fin)

%  SUBJECT_ID,ICUSTAY_ID,GENDER,AGE,DAYS_IN_ICU,HYPERDYNAMIC,
%     MORTALITY_28D,VSP_PRESENT

% load cohort 
[sid,iid,gender,age,los,hyperd,mort28d,vp] = ...
    textread(fin,'%d%d%s%n%n%d%d%d\n','headerlines',1,'delimiter',',');
    
% load data


% vasopressor cohort
