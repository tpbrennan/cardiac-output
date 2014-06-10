drop table cardiac_output_cohort;
--create table cardiac_output_cohort as

with population as (

  select id.subject_id, id.icustay_id, id.hadm_id, 
      id.icustay_intime,
      id.subject_icustay_seq seq,
      id.gender, 
      id.weight_first weight,
      round(id.icustay_admit_age,2) as age, 
      round(id.icustay_los/(60*24),2) as icu_los

    from mimic2v26.icustay_detail id 
    
    --join mimic2devel.martin_sepsis_admissions sa
    join tbrennan.angus_sepsis_cohort sa --1484 rows
      on id.hadm_id = sa.hadm_id
      where id.icustay_admit_age < 90
        and id.icustay_id is not null
        and id.gender is not null
        and id.icustay_age_group = 'adult'
)
-- final cohort, exclude pacemakers
, final_cohort as (
  select p.* from population p where not exists (select * from tbrennan.pacemaker_cohort pc where p.subject_id = pc.subject_id and p.hadm_id = pc.hadm_id)
)
--select count(distinct icustay_id) from final_cohort; -- 9,566 icustay_id





, echo_reports as (
  select ne.subject_id, ne.icustay_id, 
    substr(ne.text,regexp_instr(ne.text,'[[:digit:]]{2}\%')-1,4) lvef_range,
    replace(replace(ne.text, chr(13), ''), chr(10), '') text
    from final_cohort fc
    join  mimic2v25.noteevents ne on fc.icustay_id = ne.icustay_id
      where ne.category like 'ECHO_REPORT'
)
--select count(distinct icustay_id) from echo_reports; -- 256 icustay_ids
, lvef_group as (
  select er.subject_id, er.icustay_id,
   case when er.lvef_range like '%10%'
          or er.lvef_range like '%15%'
          or er.lvef_range like '%20%'
          or er.lvef_range like '%25%'
          or er.lvef_range like '%30%'
          or er.lvef_range like '-35%'
          or er.lvef_range like '35%'
          or lower(er.text) like '%systolic function is severely depressed%'
          or lower(er.text) like '%systolic function appears severely depressed%'
          or lower(er.text) like '%severe%systolic dysfunction%'
          or lower(er.text) like '%severe%left ventricular hypokinesis%'
          or lower(er.text) like '%severe%LV hypokinesis%'
    then 1 
    when er.lvef_range like '>35'
          or er.lvef_range like '?35'
          or er.lvef_range like '%39%'
          or er.lvef_range like '%40%'
          or er.lvef_range like '%45%'
          or er.lvef_range like '%50%'
          or er.lvef_range like '-55%'
          or lower(er.text) like '%systolic function is midly depressed%'
          or lower(er.text) like '%systolic function appears midly depressed%'
          or lower(er.text) like '%systolic function is moderately depressed%'
          or lower(er.text) like '%systolic function appears moderately depressed%'
          or lower(er.text) like '%systolic function appears broadly depressed%'
          or lower(er.text) like '%mild%systolic dysfunction%'
          or lower(er.text) like '%moderate%systolic dysfunction%'
    then 2 
    when er.lvef_range like '%55%'
          or er.lvef_range like '50%'
          or er.lvef_range like '%60%'
          or er.lvef_range like '%65%'
          or er.lvef_range like '%-70'
          or lower(er.text) like '%systolic function is normal%'
          or lower(er.text) like '%systolic function appears normal%'
    then 3 
    when er.lvef_range like '>70%'
          or er.lvef_range like '%75%'
          or er.lvef_range like '%80%'
          or er.lvef_range like '%85%'
          or lower(er.text) like '%%hyperdynamic%'
          or lower(er.text) like '%%hypercontractile%'
          or lower(er.text) like '%hyperkinetic%'
    then 4 else 0 end as lvef_group,
    er.text
  from echo_reports er 
)
--select * from lvef_group;
, lvef as (
  select distinct icustay_id, 
    max(lvef_group) lvef
    from lvef_group
    group by icustay_id
)
--select count(*) from lvef;







, elixhauser as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id,
     ep.twenty_eight_day_mort_pt elix28dpt
    from final_cohort fc
    join mimic2devel.elixhauser_points ep 
      on fc.subject_id = ep.subject_id and fc.hadm_id = ep.hadm_id
)
--select * from elixhauser;
    



    
    

, demographics as (
  select fc.subject_id, fc.hadm_id, fc.icustay_id,
          
          case 
            when dd.ethnicity_descr  like '%WHITE%' then 'WHITE' 
            when dd.ethnicity_descr like '%BLACK%' then 'BLACK'
            when dd.ethnicity_descr like '%HISPANIC%' then 'HISPANIC'
            when dd.ethnicity_descr like '%ASIAN%' then 'ASIAN'
          else 'OTHER'
          end as ethnicity

    from final_cohort fc
    join mimic2v26.demographic_detail dd
      on fc.hadm_id = dd.hadm_id
)
--select * from demographics;



, mortality as (
  select distinct fc.icustay_id, extract(day from id.dod - id.icustay_intime) survival_days,
    case when extract(day from id.dod - id.icustay_intime) < 29 then 1
      else 0
    end as mortality28d,
    case when extract(day from id.dod - id.icustay_intime) < 366 then 1
      else 0
    end as mortality1yr,         
    case when hospital_expire_flg = 'N' then 0
      else 1
    end as hospmort,
    case when icustay_expire_flg = 'N' then 0 
      else 1
    end as icumort
    from final_cohort fc
    join mimic2v26.icustay_detail id
      on fc.icustay_id = id.icustay_id
)
--select * from mortality;




-- finally, assemble
, assemble as (
  select distinct fcd.*,
         d.ethnicity,
         e.elix28dpt,
         l.lvef,
         m.mortality28d,
         m.mortality1yr,
         m.hospmort,
         m.icumort
    from final_cohort fcd
    left join demographics d on fcd.icustay_id = d.icustay_id 
    left join elixhauser e on fcd.icustay_id = e.icustay_id 
    left join lvef l on fcd.icustay_id = l.icustay_id 
    left join mortality m on fcd.icustay_id = m.icustay_id 

)
select * from assemble; --1,220 rows



