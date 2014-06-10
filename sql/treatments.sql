drop table cardiac_output_treatments;
create table cardiac_output_treatments as

with final_cohort as (
  select * from tbrennan.cardiac_output_cohort
)



-- mechanical ventilation
, vntd1 as (
  select distinct fc.icustay_id,
     case when v.begin_time between fc.icustay_intime and fc.icustay_intime+1 then 1
      else 0
     end as vntd1
  from final_cohort fc 
  left join mimic2devel.ventilation v 
    on fc.icustay_id = v.icustay_id 
) 
--select * from vntd1;
, vntd2 as (
  select distinct fc.icustay_id,
     case when v.begin_time between fc.icustay_intime+1 and fc.icustay_intime+2 then 1
      else 0
     end as vntd2
  from final_cohort fc 
  left join mimic2devel.ventilation v 
    on fc.icustay_id = v.icustay_id 
) 
--select * from vntd1;
, vntd3 as (
  select distinct fc.icustay_id,
     case when v.begin_time between fc.icustay_intime+2 and fc.icustay_intime+3 then 1
      else 0
     end as vntd3
  from final_cohort fc 
  left join mimic2devel.ventilation v 
    on fc.icustay_id = v.icustay_id 
) 
--select * from vntd1;

-- daily vasopressor usage 
, vspd1_raw as (
  select distinct cd.icustay_id,
    case when m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306, 307, 309) then 1
      else 0
    end as vspd1,
    m.itemid
    from final_cohort cd
    join mimic2v26.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) < 1
      and m.dose <> 0
)
--select * from vspd1_raw;
, vspd1 as (
  select icustay_id, sum(vspd1) as vspd1
    from vspd1_raw
    group by icustay_id
  )
--select * from vspd1; 

, vspd2_raw as (
  select distinct cd.icustay_id,    
    case when m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306, 307, 309) then 1
      else 0
    end as vspd2,
    m.itemid
    from final_cohort cd
    join mimic2v26.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) = 1
)
--select * from vspd2;
, vspd2 as (
  select icustay_id, sum(vspd2) as vspd2
    from vspd2_raw
    group by icustay_id
  )
--select * from vspd2;

, vspd3_raw as (
  select distinct cd.icustay_id,    
    case when m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306, 307, 309) then 1
      else 0
    end as vspd3,
    m.itemid
    from final_cohort cd
    join mimic2v26.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) = 2
)
--select * from vspd3;
, vspd3 as (
  select icustay_id, sum(vspd3) as vspd3
    from vspd3_raw
    group by icustay_id
  )
--select * from vspd3;






-- dailiy sedatives usage
, sdd1_raw as (
  select distinct cd.icustay_id,
    case when (lower(m.label) like '%clonazepam%' or
              lower(m.label) like '%diazepam%' or
              lower(m.label) like '%estazolam%' or
              lower(m.label) like '%flunitrazepam%' or
              lower(m.label) like '%lorazepam%' or
              lower(m.label) like '%midazolam%' or
              lower(m.label) like '%nitrazepam%' or
              lower(m.label) like '%oxazepam%' or
              lower(m.label) like '%triazolam%' or
              lower(m.label) like '%temazepam%' or
              lower(m.label) like '%chlordiazepoxide%' or
              lower(m.label) like '%alprazolam%' or
              lower(m.label) like '%amobarbital%' or
              lower(m.label) like '%pentobarbital%' or
              lower(m.label) like '%secobarbital%' or
              lower(m.label) like '%phenobarbitol%' or 
              lower(m.label) like '%fentanyl%' or 
              lower(m.label) like '%dilaudid%' or
              lower(m.label) like '%propofol%' or
              lower(m.label) like '%dexmedetomidine%'
              ) then 1
      else 0
    end as sdd1,
    m.itemid
    from final_cohort cd
    join mimic2v30.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) < 1
      and m.value <> 0
)
--select * from sdd1_raw;
, sdd1 as (
  select icustay_id, max(sdd1) as sdd1
    from sdd1_raw
    group by icustay_id
  )
--select * from sdd1; 
, sdd2_raw as (
  select distinct cd.icustay_id,
    case when (lower(m.label) like '%clonazepam%' or
              lower(m.label) like '%diazepam%' or
              lower(m.label) like '%estazolam%' or
              lower(m.label) like '%flunitrazepam%' or
              lower(m.label) like '%lorazepam%' or
              lower(m.label) like '%midazolam%' or
              lower(m.label) like '%nitrazepam%' or
              lower(m.label) like '%oxazepam%' or
              lower(m.label) like '%triazolam%' or
              lower(m.label) like '%temazepam%' or
              lower(m.label) like '%chlordiazepoxide%' or
              lower(m.label) like '%alprazolam%' or
              lower(m.label) like '%amobarbital%' or
              lower(m.label) like '%pentobarbital%' or
              lower(m.label) like '%secobarbital%' or
              lower(m.label) like '%phenobarbitol%' or 
              lower(m.label) like '%fentanyl%' or 
              lower(m.label) like '%dilaudid%' or
              lower(m.label) like '%propofol%' or
              lower(m.label) like '%dexmedetomidine%'
              ) then 1
      else 0
    end as sdd2,
    m.itemid
    from final_cohort cd
    join mimic2v30.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) = 1
      and m.value <> 0
)
--select * from sdd2_raw;
, sdd2 as (
  select icustay_id, max(sdd2) as sdd2
    from sdd2_raw
    group by icustay_id
  )
--select * from sdd2; 
, sdd3_raw as (
  select distinct cd.icustay_id,
    case when (lower(m.label) like '%clonazepam%' or
              lower(m.label) like '%diazepam%' or
              lower(m.label) like '%estazolam%' or
              lower(m.label) like '%flunitrazepam%' or
              lower(m.label) like '%lorazepam%' or
              lower(m.label) like '%midazolam%' or
              lower(m.label) like '%nitrazepam%' or
              lower(m.label) like '%oxazepam%' or
              lower(m.label) like '%triazolam%' or
              lower(m.label) like '%temazepam%' or
              lower(m.label) like '%chlordiazepoxide%' or
              lower(m.label) like '%alprazolam%' or
              lower(m.label) like '%amobarbital%' or
              lower(m.label) like '%pentobarbital%' or
              lower(m.label) like '%secobarbital%' or
              lower(m.label) like '%phenobarbitol%' or 
              lower(m.label) like '%fentanyl%' or 
              lower(m.label) like '%dilaudid%' or
              lower(m.label) like '%propofol%' or
              lower(m.label) like '%dexmedetomidine%'
              ) then 1
      else 0
    end as sdd3,
    m.itemid
    from final_cohort cd
    join mimic2v30.medevents m
    on cd.icustay_id = m.icustay_id
      where extract(day from m.charttime - cd.icustay_intime) = 2
      and m.value <> 0
)
--select * from sdd3_raw;
, sdd3 as (
  select icustay_id, max(sdd3) as sdd3
    from sdd3_raw
    group by icustay_id
  )
--select * from sdd3; 








-- daily beta-blocker usage
, bbd1_raw as (
  select distinct cd.icustay_id,
    case when (lower(m.medication) like '%acebutolol%' or
              lower(m.medication) like '%atenolol%' or
              lower(m.medication) like '%carvedilol%' or
              lower(m.medication) like '%labetalol%' or
              lower(m.medication) like '%esmolol%' or
              lower(m.medication) like '%metoprolol%' or
              lower(m.medication) like '%propranolol%') then 1
      else 0
    end as bbd1
    from final_cohort cd
    join mimic2v26.poe_order m
    on cd.icustay_id = m.icustay_id
      where (m.start_dt between cd.icustay_intime and cd.icustay_intime+1 or 
             m.stop_dt between cd.icustay_intime and cd.icustay_intime+1) 
)
--select * from bbd1_raw;
, bbd1 as (
  select icustay_id, max(bbd1) as bbd1
    from bbd1_raw
    group by icustay_id
  )
--select * from bbd1; 
, bbd2_raw as (
  select distinct cd.icustay_id,
      case when (lower(m.medication) like '%acebutolol%' or
              lower(m.medication) like '%atenolol%' or
              lower(m.medication) like '%carvedilol%' or
              lower(m.medication) like '%labetalol%' or
              lower(m.medication) like '%esmolol%' or
              lower(m.medication) like '%metoprolol%' or
              lower(m.medication) like '%propranolol%') then 1
      else 0
    end as bbd2
    from final_cohort cd
    join mimic2v26.poe_order m
    on cd.icustay_id = m.icustay_id
      where (m.start_dt between cd.icustay_intime+1 and cd.icustay_intime+2 or 
             m.stop_dt between cd.icustay_intime+1 and cd.icustay_intime+2) 
)
--select * from bbd2_raw;
, bbd2 as (
  select icustay_id, max(bbd2) as bbd2
    from bbd2_raw
    group by icustay_id
  )
--select * from bbd2; 
, bbd3_raw as (
  select distinct cd.icustay_id,
        case when (lower(m.medication) like '%acebutolol%' or
              lower(m.medication) like '%atenolol%' or
              lower(m.medication) like '%carvedilol%' or
              lower(m.medication) like '%labetalol%' or
              lower(m.medication) like '%esmolol%' or
              lower(m.medication) like '%metoprolol%' or
              lower(m.medication) like '%propranolol%') then 1
      else 0
    end as bbd3
    from final_cohort cd
    join mimic2v26.poe_order m
    on cd.icustay_id = m.icustay_id
      where (m.start_dt between cd.icustay_intime+2 and cd.icustay_intime+3 or 
             m.stop_dt between cd.icustay_intime+2 and cd.icustay_intime+3) 
             
)
--select * from bbd3_raw;
, bbd3 as (
  select icustay_id, max(bbd3) as bbd3
    from bbd3_raw
    group by icustay_id
  )
--select * from bbd3; 







-- finally, assemble
, assemble as (
  select distinct fcd.*,
    
         case when v1.vntd1 is null then 0 else v1.vntd1 end as vnt_d1,
         case when v2.vntd2 is null then 0 else v2.vntd2 end as vnt_d2,
         case when v3.vntd3 is null then 0 else v3.vntd3 end as vnt_d3,
         
         case when v1.vspd1 is null then 0 else v1.vspd1 end as vsp_d1,
         case when v2.vspd2 is null then 0 else v2.vspd2 end as vsp_d2,
         case when v3.vspd3 is null then 0 else v3.vspd3 end as vsp_d3,
         
         case when s1.sdd1 is null then 0 else s1.sdd1 end as sd_d1,
         case when s2.sdd2 is null then 0 else s2.sdd2 end as sd_d2,
         case when s3.sdd3 is null then 0 else s3.sdd3 end as sd_d3,
         
         case when b1.bbd1 is null then 0 else b1.bbd1 end as bb_d1,
         case when b2.bbd2 is null then 0 else b2.bbd2 end as bb_d2,
         case when b3.bbd3 is null then 0 else b3.bbd3 end as bb_d3
    
    from final_cohort fcd

    left join vntd1 v1 on fcd.icustay_id = v1.icustay_id 
    left join vntd2 v2 on fcd.icustay_id = v2.icustay_id 
    left join vntd3 v3 on fcd.icustay_id = v3.icustay_id 

    left join vspd1 v1 on fcd.icustay_id = v1.icustay_id 
    left join vspd2 v2 on fcd.icustay_id = v2.icustay_id 
    left join vspd3 v3 on fcd.icustay_id = v3.icustay_id 

    left join sdd1 s1 on fcd.icustay_id = s1.icustay_id 
    left join sdd2 s2 on fcd.icustay_id = s2.icustay_id 
    left join sdd3 s3 on fcd.icustay_id = s3.icustay_id 

    left join bbd1 b1 on fcd.icustay_id = b1.icustay_id 
    left join bbd2 b2 on fcd.icustay_id = b2.icustay_id 
    left join bbd3 b3 on fcd.icustay_id = b3.icustay_id 

)
select * from assemble; --2946 rows

