--created by mpimentel, Cardiac Output project 
-- Last Updated: October 2013

drop table cardiac_output_ccu_nonsepsis;
create table cardiac_output_ccu_nonsepsis as 

with cohort as (
  select * from TBRENNAN.cardiac_output_labs
)
--select count(*) from cohort; -- 8476
--select * from cohort order by 1;







-- %%%%%%%%%%%%%% SYSTOLIC BLOOD PRESSURE

, sysbp1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 3
)
--select * from sysbp1;

, sysbp2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from sysbp2;

, sysbp3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from sysbp3;






-- %%%%%%%%%%%%%% DIASTOLIC BLOOD PRESSURE

, diabp1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from diabp1;

, diabp2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime + 1 and fc.icustay_intime + 2
)
--select * from diabp2;

, diabp3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime + 2 and fc.icustay_intime + 3
)
--select * from diabp3;






-- %%%%%%%%%%%%%% PULSE PRESSURE

, pulsep1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num-ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from pulsep1;

, pulsep2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num-ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime + 1 and fc.icustay_intime + 2
)
--select * from pulsep2;

, pulsep3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num-ce.value2num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (442, 455, 51) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.value2num <> 0
      and ce.value2num is not null
      and ce.charttime between fc.icustay_intime + 2 and fc.icustay_intime + 3
)
--select * from pulsep3;







-- %%%%%%%%%%%%%% HEART RATE

, hr1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (211)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from hr1;

, hr2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (211)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime + 1 and fc.icustay_intime + 2
)
--select * from hr2;

, hr3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (211)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime + 2 and fc.icustay_intime + 3
)
--select * from hr3;






-- %%%%%%%%%%%%%% RESPIRATORY RATE

, rr1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (614, 615, 618, 1635, 1884, 3603, 3337) 
      -- resp. rate (1635 only appears for one patient; 
      --             1884 values are crazy and only appears for 2 or 3 patients)
      --             3603 values look somehow elevated (check if it corresponds to neonates)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from rr1;

, rr2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (614, 615, 618, 1635, 1884, 3603, 3337) 
      -- resp. rate (1635 only appears for one patient; 
      --             1884 values are crazy and only appears for 2 or 3 patients)
      --             3603 values look somehow elevated (check if it corresponds to neonates)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from rr2;

, rr3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (614, 615, 618, 1635, 1884, 3603, 3337) 
      -- resp. rate (1635 only appears for one patient; 
      --             1884 values are crazy and only appears for 2 or 3 patients)
      --             3603 values look somehow elevated (check if it corresponds to neonates)
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from rr3;







-- %%%%%%%%%%%%%% PERIPHERAL OXYGEN SATURATION

, spo21 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (646, 834) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from spo21;

, spo22 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (646, 834) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from spo22;

, spo23 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (646, 834) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from spo23;







-- %%%%%%%%%%%%%% TEMPERATURE

, temp1_raw as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , case 
              when ce.itemid in (676, 677) then ce.value1num * 1.8 +32 
              when ce.itemid in (678, 679) then ce.value1num
            else null 
          end as val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (676, 677, 678, 679) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from temp1_raw;
, temp1 as (
  select distinct subject_id, icustay_id, hadm_id,
      round(median(val) over (partition by icustay_id),2) val
    from temp1_raw
)
--select * from temp1;
, temp2_raw as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , case 
              when ce.itemid in (676, 677) then ce.value1num * 1.8 +32 
              when ce.itemid in (678, 679) then ce.value1num
            else null 
          end as val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (676, 677, 678, 679) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from temp2_raw;
, temp2 as (
  select distinct subject_id, icustay_id, hadm_id,
      round(median(val) over (partition by icustay_id),2) val
    from temp2_raw
)
--select * from temp2;
, temp3_raw as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , case 
              when ce.itemid in (676, 677) then ce.value1num * 1.8 +32 
              when ce.itemid in (678, 679) then ce.value1num
            else null 
          end as val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (676, 677, 678, 679) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime + 3
)
--select * from temp3_raw;
, temp3 as (
  select distinct subject_id, icustay_id, hadm_id,
      round(median(val) over (partition by icustay_id),2) val
    from temp1_raw
)
--select * from temp3;









-- %%%%%%%%%%%%%% URINE OUTPUT

, uo1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , sum(ce.volume) over (partition by fc.icustay_id) val
    from cohort fc
    left join mimic2v26.ioevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405,
                       428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
                       3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592,
                       2676, 3966, 3987, 4132, 4253, 5927)
      and ce.volume is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from uo1;

, uo2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , sum(ce.volume) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.ioevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405,
                       428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
                       3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592,
                       2676, 3966, 3987, 4132, 4253, 5927)
      and ce.volume is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from uo2;

, uo3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , sum(ce.volume) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.ioevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405,
                       428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
                       3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592,
                       2676, 3966, 3987, 4132, 4253, 5927)
      and ce.volume is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from uo3;








-- %%%%%%%%%%%%%% ARTERIAL pH

, ph1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (1126, 780, 4753) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from ph1;

, ph2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (1126, 780, 4753) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from ph2;

, ph3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (1126, 780, 4753) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from ph3;







-- %%%%%%%%%%%%%% ARTERIAL OXYGEN CONCENTRATION (PaO2)

, pao21 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (779) -- ABG lab event 50019
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from pao21;

, pao21 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.valuenum) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.labevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (50019) -- ABG lab event 50019
      and ce.valuenum <> 0
      and ce.valuenum is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from pao21;

, pao22 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.valuenum) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.labevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (50019) -- ABG lab event 50019
      and ce.valuenum <> 0
      and ce.valuenum is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from pa022;

, pao23 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.valuenum) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.labevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (50019) -- ABG lab event 50019
      and ce.valuenum <> 0
      and ce.valuenum is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from pao23;







-- %%%%%%%%%%%%%% ARTERIAL OXYGEN CONCENTRATION (PaO2)

, hemog1 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (814) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime and fc.icustay_intime + 1
)
--select * from hemog1;

, hemog2 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (814) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+1 and fc.icustay_intime+2
)
--select * from hemog2;

, hemog3 as (
  select distinct
          fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , median(ce.value1num) over (partition by fc.icustay_id) val
    from cohort fc 
    left join mimic2v26.chartevents ce
      on ce.icustay_id = fc.icustay_id
      and ce.itemid in (814) 
      and ce.value1num <> 0
      and ce.value1num is not null
      and ce.charttime between fc.icustay_intime+2 and fc.icustay_intime+3
)
--select * from hemog3;









, physiological_variables as (
   select distinct fc.*
    , sys1.val sbp_d1, sys2.val sbp_d2, sys3.val sbp_d3
    , dia1.val dbp_d1, dia2.val dbp_d2, dia3.val dbp_d3
    , pp1.val bpp_d1, pp2.val bpp_d2, pp3.val bpp_d3
    , hr1.val hr_d1, hr2.val hr_d2, hr3.val hr_d3
    , rr1.val rr_d1, rr2.val rr_d2, rr3.val rr_d3
    , spo21.val spo2_d1, spo22.val spo2_d2, spo23.val spo2_d3
    , temp1.val temp_d1, temp2.val temp_d2, temp3.val temp_d3
    , uo1.val uo_d1, uo2.val uo_d2, uo3.val uo_d3
    , ph1.val ph_d1, ph2.val ph_d2, ph3.val ph_d3
    , pao21.val pao2_d1, pao22.val pao2_d2, pao23.val pao2_d3
    , hemog1.val hemog_d1, hemog2.val hemog_d2, hemog3.val hemog_d3
    from cohort fc
      left join sysbp1 sys1 on fc.icustay_id = sys1.icustay_id
      left join sysbp2 sys2 on fc.icustay_id = sys2.icustay_id
      left join sysbp3 sys3 on fc.icustay_id = sys3.icustay_id
      left join diabp1 dia1 on fc.icustay_id = dia1.icustay_id
      left join diabp2 dia2 on fc.icustay_id = dia2.icustay_id
      left join diabp3 dia3 on fc.icustay_id = dia3.icustay_id
      left join pulsep1 pp1 on fc.icustay_id = pp1.icustay_id
      left join pulsep2 pp2 on fc.icustay_id = pp2.icustay_id
      left join pulsep3 pp3 on fc.icustay_id = pp3.icustay_id
      left join hr1 hr1 on fc.icustay_id = hr1.icustay_id
      left join hr2 hr2 on fc.icustay_id = hr2.icustay_id
      left join hr3 hr3 on fc.icustay_id = hr3.icustay_id
      left join rr1 rr1 on fc.icustay_id = rr1.icustay_id
      left join rr2 rr2 on fc.icustay_id = rr2.icustay_id
      left join rr3 rr3 on fc.icustay_id = rr3.icustay_id
      left join spo21 spo21 on fc.icustay_id = spo21.icustay_id
      left join spo22 spo22 on fc.icustay_id = spo22.icustay_id
      left join spo23 spo23 on fc.icustay_id = spo23.icustay_id
      left join temp1 temp1 on fc.icustay_id = temp1.icustay_id
      left join temp2 temp2 on fc.icustay_id = temp2.icustay_id
      left join temp3 temp3 on fc.icustay_id = temp3.icustay_id
      left join uo1 uo1 on fc.icustay_id = uo1.icustay_id
      left join uo2 uo2 on fc.icustay_id = uo2.icustay_id
      left join uo3 uo3 on fc.icustay_id = uo3.icustay_id
      left join ph1 ph1 on fc.icustay_id = ph1.icustay_id
      left join ph2 ph2 on fc.icustay_id = ph2.icustay_id
      left join ph3 ph3 on fc.icustay_id = ph3.icustay_id
      left join pao21 pao21 on fc.icustay_id = pao21.icustay_id
      left join pao22 pao22 on fc.icustay_id = pao22.icustay_id
      left join pao23 pao23 on fc.icustay_id = pao23.icustay_id
      left join hemog1 hemog1 on fc.icustay_id = hemog1.icustay_id
      left join hemog2 hemog2 on fc.icustay_id = hemog2.icustay_id
      left join hemog3 hemog3 on fc.icustay_id = hemog3.icustay_id
)
select * from physiological_variables;