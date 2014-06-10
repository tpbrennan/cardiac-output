/* created by mpimentel and tbrennan 2013 */
/* Last updated Aug 2013 */

--drop table cohort_lactate_01Aug
create materialized view cohort_general as 

/************* Definition of cohort  ****************************/
-- over entire mimic-2 cohort, adult patients' 1st icu stay
with cohort as (
  select distinct
  subject_id
  , hadm_id
  , icustay_id
  , icustay_intime      
  , icustay_outtime    
  , gender
  , weight_first as weight
  , round(icustay_admit_age,2) as age
  , round(icustay_los/(60*24),2) as ilos
  , icustay_first_careunit as careunit
  , icustay_first_service as servtype
    from mimic2v26.icustay_detail 
    where icustay_age_group = 'adult'
--    and icustay_id<1000 
)
--select count(*) from cohort; --32,332 icu_admissions
--select * from cohort;

, martin_sepsis_cohort as (
  select distinct fc.icustay_id, 
    case when (fc.hadm_id = sp.hadm_id and fc.subject_id = sp.subject_id) then 1
    else 0
    end as sepsis_martin
  from cohort fc
  left join mimic2devel.martin_sepsis_admissions sp
    on fc.subject_id = sp.subject_id
    and fc.hadm_id = sp.hadm_id
)
--select sum(sepsis_martin) from martin_sepsis_cohort;   --3931 icu_admissions

, rrt_info as (
  select distinct
    co.icustay_id
    , rc.rrt
    from cohort co
    left join tbrennan.rrt_cohort rc 
      on rc.icustay_id = co.icustay_id
)
--select sum(rrt) from rrt_info;   --2430 icu_admissions

, vent_duration as (
  select co.icustay_id,
    sum(round((extract(day from (v.end_time-v.begin_time))+
      extract(hour from (v.end_time-v.begin_time))/24+
      extract(minute from (v.end_time-v.begin_time))/60/24), 3)) vent_duration
  from cohort co 
  left join mimic2devel.ventilation v
    on co.icustay_id = v.icustay_id 
    --where v.begin_time between co.icustay_intime and co.icustay_intime + 3
  group by co.icustay_id
) 

, ventilated as (
  select v.icustay_id, 
      case when v.vent_duration is null or v.vent_duration = 0
        then 0 else 1 
      end as ventilated,
      v.vent_duration
    from vent_duration v
)
--select sum(ventilated) from ventilated; --14848 icu_admissions

-- vasopressors therapy
, usedpressors as (
  select distinct cd.icustay_id, 
--      cd.icustay_intime,
--      m.itemid,
--      m.charttime,
      case when m.charttime is null
        then 0 else 1
      end as usedvp
--      round(m.dose,2) dose,
--      m.doseuom
    from cohort cd 
    left join mimic2v26.medevents m
         on cd.icustay_id = m.icustay_id 
         and m.itemid in (42, 43, 44, 47, 51, 119, 120, 125, 127, 128) 
         and m.dose<>0
         and m.charttime between cd.icustay_intime and cd.icustay_intime + 3
)
--select sum(usedvp) from usedpressors;  --9974 icu_admissions

--patient SOFA scores
, pt_sofa as (
    select distinct cd.icustay_id, 
    cd.hadm_id,
    FIRST_VALUE(value1num) OVER (partition by cd.icustay_id ORDER BY charttime) sofa_score
    from cohort cd
    left join mimic2v26.chartevents ce
         on cd.icustay_id = ce.icustay_id
   where itemid = '20009'
)
--select sofa_score from pt_sofa; -- 23,294
--select count(distinct icustay_id) from pt_sofa; -- 23,294

--patient SAPS scores
, pt_saps as (
    select distinct cd.icustay_id, 
    cd.hadm_id, 
    FIRST_VALUE(value1num) OVER (partition by cd.icustay_id ORDER BY charttime) saps_score
    from cohort cd
    left join mimic2v26.chartevents ce
         on cd.icustay_id = ce.icustay_id
   where itemid = '20001'
)
--select * from pt_saps;

--get elixhauser score 
, elixhauser as (
  select co.icustay_id,
         ep.*
  from cohort co
  left join mimic2devel.elixhauser_revised ep 
       on co.hadm_id = ep.hadm_id
)

, elixpoints as (
  select co.icustay_id
         , ep.*
  from cohort co
  left join mimic2devel.elixhauser_points ep 
       on co.hadm_id = ep.hadm_id
)
--select * from elixpoints;

--gather 28-day, 1-year, and 2-year mortality, hospital mortality flag, and icustay mortality flag
, outcomes as (
  select fc.icustay_id, 
  id.icustay_intime, 
  EXTRACT(DAY FROM id.dod - id.icustay_intime) death_after_icustay,
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
--select sum(mort_icu) from outcomes;



/*************** Final Table ***********/

select distinct 
  co.*
  , sof.sofa_score
  , sap.saps_score
  , pr.usedvp
  , v.ventilated
  , sep.sepsis_martin
  , rt.rrt
  , mort.mort_icu, mort.mort_hos, mort.mort_28d, mort.mort_1y, mort.mort_2y
  , ep.hospital_mort_pt, ep.twenty_eight_day_mort_pt, ep.one_yr_mort_pt, ep.two_yr_mort_pt
  from cohort co
    left join pt_sofa sof on sof.icustay_id=co.icustay_id
    left join pt_saps sap on sap.icustay_id=co.icustay_id
    left join usedpressors pr on pr.icustay_id=co.icustay_id
    left join ventilated v on v.icustay_id=co.icustay_id
    left join martin_sepsis_cohort sep on sep.icustay_id=co.icustay_id
    left join rrt_info rt on rt.icustay_id=co.icustay_id
    left join outcomes mort on mort.icustay_id=co.icustay_id
    left join elixpoints ep on ep.hadm_id=co.hadm_id
--  where co.hadm_id is not null
--  and co.age is not null
--  and co.gender is not null
--  and co.servtype is not null
--  and sof.sofa_score is not null
--  and sap.saps_score is not null
--  and ep.hospital_mort_pt is not null
--  and ep.twenty_eight_day_mort_pt is not null
--  and pr.usedvp is not null
--  and v.ventilated is not null
;
