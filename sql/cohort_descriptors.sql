--created by mpimentel, Cardiac Output project 
-- Last Updated: October 2013

with cohort as (
    select subject_id
      , icustay_id
      , hadm_id      
      , '1' cohort
      , gender
      , age
      , elix_28d_pt
      , icu_los ilos
      from marco.cardiac_output_cohort_1
  UNION
    select subject_id
      , icustay_id
      , hadm_id
      , '2' cohort
      , gender
      , age
      , elix_28d_pt
      , icu_los ilos
      from marco.cardiac_output_cohort_2
  UNION
    select subject_id
      , icustay_id
      , hadm_id
      , '3' cohort
      , gender
      , age
      , elix_28d_pt
      , icu_los ilos
      from marco.cardiac_output_cohort_3
)
--select count(*) from final_cohort; --14410


-- GET OUTCOMES
, final_cohort as (
 select 
  fc.*,
  id.icustay_first_service careunit,
  --EXTRACT(DAY FROM id.dod - id.icustay_intime) death_after_icustay,
  CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 29 
  THEN 1 ELSE 0 END AS mort_28d,
  CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 366 
  THEN 1 ELSE 0 END AS mort_1y,
  CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 731 
  THEN 1 ELSE 0 END AS mort_2y,
  CASE WHEN hospital_expire_flg = 'Y'
  THEN 1 ELSE 0 END AS mort_hos, 
  CASE WHEN icustay_expire_flg = 'Y'
  THEN 1 ELSE 0 END AS mort_icu
  from cohort fc
  join mimic2v26.icustay_detail id
    on fc.icustay_id = id.icustay_id
)
--select count(*) from outcomes; --14410

-- ICD9 scores
, patient_icd9 as (
  select distinct c.*,
        i.code first_ICD9,
        case 
          when i.code < '240' then 'CANCER'
          when i.code >= '390' and i.code < '460' then 'CARDIOVASCULAR'
          when i.code >= '460' and i.code < '520' then 'RESPIRATORY'
          when i.code >= '240' and i.code < '280' then 'ENDOCRINE_METABOLIC'
          when (i.code >= '280' and i.code <= '390') or (i.code >= '630' AND i.code < '800') or (lower(i.code) like '%v%') then 'OTHER'
          when i.code >= '520' and i.code < '580' then 'GI'
          when i.code >= '580' and i.code <= '629' then 'GU'
          when i.code >= '800' and i.code < '999' then 'TRAUMA'
          when i.code > '999' and i.code <= '999.99' then 'TREATMENT'
        end as icd9_group
    from final_cohort c
      left join mimic2v26.icd9 i 
      on c.hadm_id = i.hadm_id and i.sequence = 1
) 
--select count(*) from patient_icd9;  -- 14,410


-- elixhauser comorbidities
, comorbidities as (
  select distinct cd.icustay_id,
         CASE WHEN DIABETES_UNCOMPLICATED = 1 or DIABETES_COMPLICATED = 1 THEN 1
              ELSE 0
         END AS CM_DIABETES,
         CASE WHEN CONGESTIVE_HEART_FAILURE = 1 THEN 1
              ELSE 0
         END AS CM_CHF,
         CASE WHEN ALCOHOL_ABUSE = 1 THEN 1
              ELSE 0
         END AS CM_ALCOHOL_ABUSE,
         CASE WHEN CARDIAC_ARRHYTHMIAS = 1 THEN 1
              ELSE 0
         END AS CM_ARRHYTHMIAS,
         CASE WHEN VALVULAR_DISEASE = 1 THEN 1
              ELSE 0
         END AS CM_VALVULAR_DISEASE,
         CASE WHEN HYPERTENSION = 1 THEN 1
              ELSE 0
         END AS CM_HYPERTENSION,
         CASE WHEN RENAL_FAILURE = 1 THEN 1
              ELSE 0
         END AS CM_RENAL_FAILURE,
         CASE WHEN CHRONIC_PULMONARY = 1 THEN 1
              ELSE 0
         END AS CM_CHRONIC_PULMONARY,
         CASE WHEN LIVER_DISEASE = 1 THEN 1
              ELSE 0
         END AS CM_LIVER_DISEASE,
         CASE WHEN METASTATIC_CANCER = 1 THEN 1
              ELSE 0
         END AS CM_CANCER,
         CASE WHEN PSYCHOSES = 1 THEN 1
              ELSE 0
         END AS CM_PSYCHOSIS,
         CASE WHEN DEPRESSION = 1 THEN 1
              ELSE 0
         END AS CM_DEPRESSION
    from final_cohort cd
    left join mimic2devel.elixhauser_revised er 
        on cd.subject_id = er.subject_id
)
--select * from comorbidities order by icustay_id;

, elix_comorb as (
  select distinct icustay_id,
      first_value(cm_diabetes) over (partition by icustay_id order by cm_diabetes desc) cm_diabetes,
      first_value(cm_chf) over (partition by icustay_id order by cm_chf desc) cm_chf,
      first_value(cm_alcohol_abuse) over (partition by icustay_id order by cm_alcohol_abuse desc) cm_alcohol_abuse,
      first_value(cm_arrhythmias) over (partition by icustay_id order by cm_arrhythmias desc) cm_arrhythmias,
      first_value(cm_valvular_disease) over (partition by icustay_id order by cm_valvular_disease desc) cm_valvular_disease,
      first_value(cm_hypertension) over (partition by icustay_id order by cm_hypertension desc) cm_hypertension,
      first_value(cm_renal_failure) over (partition by icustay_id order by cm_renal_failure desc) cm_renal_failure,
      first_value(cm_chronic_pulmonary) over (partition by icustay_id order by cm_chronic_pulmonary desc) cm_chronic_pulmonary,
      first_value(cm_liver_disease) over (partition by icustay_id order by cm_liver_disease desc) cm_liver_disease,
      first_value(cm_cancer) over (partition by icustay_id order by cm_cancer desc) cm_cancer,
      first_value(cm_psychosis) over (partition by icustay_id order by cm_psychosis desc) cm_psychosis,
      first_value(cm_depression) over (partition by icustay_id order by cm_depression desc) cm_depression
      from comorbidities
)
--select count(icustay_id) from elix_comorb;

, sofa as (
  select distinct co.icustay_id,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 0 then value1num
    end as sofa_d1,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 1 then value1num
    end as sofa_d2,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 2 then value1num
    end as sofa_d3
    from final_cohort co
    left join mimic2v26.icustay_detail id
      on id.icustay_id = co.icustay_id
    left join mimic2v26.chartevents ce
      on co.icustay_id = ce.icustay_id
      where itemid = '20009'
      and ce.charttime < id.icustay_intime + 3
)
--select * from sofa;

, max_sofa as (
  select icustay_id, 
    max(sofa_d1) sofa_d1,
    max(sofa_d2) sofa_d2,
    max(sofa_d3) sofa_d3
    from sofa
    group by icustay_id
  ) 
--select * from max_sofa;

, sapsi as (
  select distinct co.icustay_id,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 0 then value1num
    end as sapsi_d1,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 1 then value1num
    end as sapsi_d2,
    case 
      when extract(day from ce.charttime - id.icustay_intime) = 2 then value1num
    end as sapsi_d3
    from final_cohort co
    left join mimic2v26.icustay_detail id
      on id.icustay_id = co.icustay_id
    left join mimic2v26.chartevents ce
      on co.icustay_id = ce.icustay_id
      where itemid = '20001'
      and ce.charttime < id.icustay_intime + 3
)
--select * from sapsi;

, max_sapsi as (
  select icustay_id, 
    max(sapsi_d1) sapsi_d1,
    max(sapsi_d2) sapsi_d2,
    max(sapsi_d3) sapsi_d3
    from sapsi
    group by icustay_id
  ) 
--select * from max_sapsi;

, assemble_table as (
    select distinct
          c.*
         , el.cm_diabetes
         , el.cm_chf
         , el.cm_alcohol_abuse
         , el.cm_arrhythmias
         , el.cm_valvular_disease
         , el.cm_hypertension
         , el.cm_renal_failure
         , el.cm_chronic_pulmonary
         , el.cm_liver_disease
         , el.cm_cancer
         , el.cm_psychosis
         , el.cm_depression
         , so.sofa_d1, so.sofa_d2, so.sofa_d3
         , sa.sapsi_d1, sa.sapsi_d2, sa.sapsi_d3 
    from patient_icd9 c
      left join elix_comorb el on c.icustay_id = el.icustay_id
      left join max_sofa so on so.icustay_id = c.icustay_id
      left join max_sapsi sa on sa.icustay_id = c.icustay_id
)
select * from assemble_table;

