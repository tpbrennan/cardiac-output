create table sepsis_cardiac_output_cohort as

-- get sepsis admissions
with population as (
  select id.subject_id, id.icustay_id, id.hadm_id, id.icustay_intime
    from mimic2v26.icustay_detail id 
    join mimic2devel.martin_sepsis_admissions sa --1484 rows
      on id.hadm_id = sa.hadm_id
      where id.icustay_age_group = 'adult'
      and id.icustay_admit_age < 90
)
--select * from population; 

-- final cohort, exclude pacemakers
, final_cohort as (
  select p.* from population p where not exists (select hadm_id from tbrennan.pacemaker_cohort pc where p.hadm_id = pc.hadm_id)
)
--select * from final_cohort; --3576 rows

-- get icustay details
, final_cohort_detail as(
select fc.*, icud.gender, 
  round(icud.icustay_admit_age,2) as age, 
  round(icud.icustay_los/(60*24),2) as los
  from final_cohort fc, mimic2v26.icustay_detail icud
    where fc.icustay_id = icud.icustay_id
      
)
--select count(distinct icustay_id) from final_cohort_detail; -- 3,400 icu adm

, vasopressors as (
  select distinct cd.icustay_id,    
    case when (m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306, 307, 309) and m.dose<>0 and m.charttime is not null) then 1
      else 0
    end as vsp_present          
    from final_cohort cd, mimic2v26.medevents m
      where cd.icustay_id = m.icustay_id  
)
, vsp as (
  select icustay_id, max(vsp_present) as vsp_present
    from vasopressors
    group by icustay_id
  )
--select * from vasopressors; 

, mortality as (
  select distinct fc.icustay_id, extract(day from id.dod - id.icustay_intime) death_after_icustay,
         case when extract(day from id.dod - id.icustay_intime) < 29 then 1
              else 0
         end as mortality_28d,
         case when extract(day from id.dod - id.icustay_intime) < 366 then 1
              else 0
         end as mortality_1yr,         
         hospital_expire_flg,
         icustay_expire_flg
    from final_cohort fc
    join mimic2v26.icustay_detail id
      on fc.icustay_id = id.icustay_id
)
--select * from mortality;

-- finally, assemble
, assemble as (
  select distinct fcd.subject_id,
         fcd.hadm_id,
         fcd.icustay_id,
         fcd.gender,
         fcd.age,
         fcd.los,
         fcd.icustay_intime,
         m.mortality_28d,
         m.mortality_1yr,
         m.hospital_expire_flg,
         m.icustay_expire_flg,
         case when vv.vsp_present is null then 0 else vv.vsp_present end as vsp_present
    from final_cohort_detail fcd
    left join mortality m on fcd.icustay_id = m.icustay_id 
    left join vsp vv on fcd.icustay_id = vv.icustay_id 
)
select * from assemble; --2946 rows

