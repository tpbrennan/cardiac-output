create table cardiac_output_data_ibp as 

with sysbp as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val,
          ce.value1uom unit,
          '1' datatype
    from mimic2v26.chartevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (51) --invasive blood pressure (51)
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from sysbp order by 5;

, diabp as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value2num val,
          ce.value2uom unit,
          '2' datatype
    from mimic2v26.chartevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (51) --invasive blood pressure
      and ce.value2num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4

)
--select * from diabp;

-- get mean arterial blood pressure blood prssure
, mbp as ( 
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '3' datatype
    from mimic2v26.chartevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where itemid in (52) -- invasive
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from mbp order by 5;

, pulsep as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num - ce.value2num val,
          ce.value1uom unit,
          '4' datatype
    from mimic2v26.chartevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (51) --invasive blood pressure
      and ce.value2num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4

)
--select * from pulsep;

-- get heart rate for icustay
, hr as ( 
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '5' datatype
    from mimic2v26.chartevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid = 211 --heart rate
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from hr;

-- get lactic acid for first 12 hours
, lactate as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.valuenum val, 
          ce.valueuom unit,
          '6' datatype
    from mimic2v26.labevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid = 50010 --lactic acid
      and ce.valuenum <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from lactate order by 5;


-- get first 6 hours of urine output in ml
, urine_output as (
  select fc.subject_id, fc.icustay_id, fc.hadm_id, fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.volume val, 
          ce.volumeuom unit,
          '7' datatype
    from mimic2v26.ioevents ce
    --join tbrennan.sepsis_cardiac_output_cohort fc 
    join tbrennan.sepsis_cardiac_output_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405,
                       428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
                       3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592,
                       2676, 3966, 3987, 4132, 4253, 5927)              
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from urine_output;

-- finally, assemble

  select * from sysbp 
  union
  select * from diabp
  union
  select * from mbp
  union 
  select * from pulsep
  union 
  select * from hr 
  union 
  select * from lactate 
  union 
  select * from urine;