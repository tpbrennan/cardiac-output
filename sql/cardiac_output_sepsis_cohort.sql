create table cardiac_output_sepsis_cohort as

with population as (
  select id.subject_id, id.icustay_id, id.hadm_id, id.icustay_intime,id.subject_icustay_seq seq
    from mimic2v26.icustay_detail id 
    join mimic2devel.martin_sepsis_admissions sa --1484 rows
      on id.hadm_id = sa.hadm_id
      where id.icustay_admit_age < 90
)
--select * from population; --3958 rows

-- final cohort, exclude pacemakers
, final_cohort as (
  select p.* from population p where not exists (select hadm_id from tbrennan.pacemaker_cohort pc where p.hadm_id = pc.hadm_id)
)
--select * from final_cohort; --3576 rows

-- get icustay details
, final_cohort_detail as(
  select fc.*, 
    icud.gender, 
    round(icud.icustay_admit_age,2) as age, 
    round(icud.icustay_los/(60*24),2) as los
    from final_cohort fc, mimic2v26.icustay_detail icud
      where fc.icustay_id = icud.icustay_id
      
)
--select count(distinct icustay_id) from final_cohort_detail;







, mortality as (
  select distinct fc.icustay_id, extract(day from id.dod - id.icustay_intime) survival_days,
    case when extract(day from id.dod - id.icustay_intime) < 29 then 1
      else 0
    end as mortality_28d,
    case when extract(day from id.dod - id.icustay_intime) < 366 then 1
      else 0
    end as mortality_1yr,         
    case when hospital_expire_flg = 'N' then 0
      else 1
    end as hospital_mortality,
    case when icustay_expire_flg = 'N' then 0 
      else 1
    end as icustay_mortality
    from final_cohort fc
    join mimic2v26.icustay_detail id
      on fc.icustay_id = id.icustay_id
)
--select * from mortality;





-- finally, assemble
, assemble as (
  select distinct fcd.*,
         m.mortality_28d,
         m.mortality_1yr,
         m.hospital_mortality,
         m.icustay_mortality,
         case when v1.vspd1 is null then 0 else v1.vspd1 end as vspd1,
         case when v2.vspd2 is null then 0 else v2.vspd2 end as vspd2,
         case when v3.vspd3 is null then 0 else v3.vspd3 end as vspd3
    from final_cohort_detail fcd
    left join mortality m on fcd.icustay_id = m.icustay_id 
    left join vspd1 v1 on fcd.icustay_id = v1.icustay_id 
    left join vspd2 v2 on fcd.icustay_id = v2.icustay_id 
    left join vspd3 v3 on fcd.icustay_id = v3.icustay_id 
)
select * from assemble; --2946 rows

