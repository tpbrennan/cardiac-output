--create table cardiac_output_final_nbp_3d as 

with sysbp as (
  select fc.icustay_id, 
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val,
          ce.value1uom unit,
          '1' datatype
    from mimic2v26.chartevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (442, 455) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from sysbp;




-- non-invasive diastolic blood pressure
, diabp as (
  select fc.icustay_id,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value2num val,
          ce.value2uom unit,
          '2' datatype
    from mimic2v26.chartevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (442,455) --noninvasive & invasive blood pressure
      and ce.value2num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4

)
--select * from diabp;





-- mean arterial blood pressure blood prssure
, mbp as ( 
  select fc.icustay_id,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          round(ce.value1num,2) val, 
          ce.value1uom unit,
          '3' datatype
    from mimic2v26.chartevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where itemid in (443, 456) -- invasive (52, 224)
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from mbp;





-- pulse pressure
, pulsep as (
  select fc.icustay_id, 
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num - ce.value2num val,
          ce.value1uom unit,
          '4' datatype
    from mimic2v26.chartevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (442,455) --noninvasive & invasive blood pressure
      and ce.value2num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4

)
--select * from pulsep;






-- get heart rate 
, hr as ( 
  select fc.icustay_id, 
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '5' datatype
    from mimic2v26.chartevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid = 211 --heart rate
      and ce.value1num <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from hr;






-- lactic acid 
, lactate as (
  select fc.icustay_id, 
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.valuenum val, 
          ce.valueuom unit,
          '6' datatype
    from mimic2v26.labevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid = 50010 --lactic acid
      and ce.valuenum <> 0
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from lactate;






-- urine output in ml
, urine_output as (
  select fc.icustay_id, 
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.volume val, 
          ce.volumeuom unit,
          '7' datatype
    from mimic2v26.ioevents ce
    join tbrennan.cardiac_output_sepsis_cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405,
                       428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859,
                       3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592,
                       2676, 3966, 3987, 4132, 4253, 5927)    
      and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from urine_output;





-- systolic BP: daily avg & stddev
, sbpd1 as (
  select sbp.icustay_id,
    round(avg(sbp.val),2) as sbpmd1,
    round(stddev(sbp.val),2) as sbpsd1
    from sysbp sbp
    where min_post_adm < 1440
    group by icustay_id
)
--select * from sbpd2;

, sbpd2 as (
  select sbp.icustay_id,
    round(avg(sbp.val),2) as sbpmd2,
    round(stddev(sbp.val),2) as sbpsd2
    from sysbp sbp
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from sbpd2;

, sbpd3 as (
  select sbp.icustay_id,
    round(avg(sbp.val),2) as sbpmd3,
    round(stddev(sbp.val),2) as sbpsd3
    from sysbp sbp
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select count(distinct icustay_id) from sbpd3;





-- diastolic BP: daily avg & stddev
, dbpd1 as (
  select dbp.icustay_id,
    round(avg(dbp.val),2) as dbpmd1,
    round(stddev(dbp.val),2) as dbpsd1
    from diabp dbp
    where min_post_adm < 1440
    group by icustay_id
)
--select * from dbpd2;

, dbpd2 as (
  select dbp.icustay_id,
    round(avg(dbp.val),2) as dbpmd2,
    round(stddev(dbp.val),2) as dbpsd2
    from diabp dbp
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from dbpd2;

, dbpd3 as (
  select dbp.icustay_id,
    round(avg(dbp.val),2) as dbpmd3,
    round(stddev(dbp.val),2) as dbpsd3
    from diabp dbp
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select count(distinct icustay_id) from dbpd3;




--- mean blood pressure: daily avg & stddev
, mbpd1 as (
  select mbp.icustay_id,
    round(avg(mbp.val),2) as mbpmd1,
    round(stddev(mbp.val),2) as mbpsd1
    from mbp
    where min_post_adm < 1440
    group by icustay_id
)
--select * from mbpd2;

, mbpd2 as (
  select mbp.icustay_id,
    round(avg(mbp.val),2) as mbpmd2,
    round(stddev(mbp.val),2) as mbpsd2
    from mbp
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from mbpd2;

, mbpd3 as (
  select mbp.icustay_id,
    round(avg(mbp.val),2) as mbpmd3,
    round(stddev(mbp.val),2) as mbpsd3
    from mbp
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select * from mbpd3;






-- pulse pressure: daily avg & stddev
, ppd1 as (
  select pp.icustay_id,
    round(avg(pp.val),2) as ppmd1,
    round(stddev(pp.val),2) as ppsd1
    from pulsep pp
    where min_post_adm < 1440
    group by icustay_id
)
--select * from ppd1;

, ppd2 as (
  select pp.icustay_id,
    round(avg(pp.val),2) as ppmd2,
    round(stddev(pp.val),2) as ppsd2
    from pulsep pp
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from ppd2;

, ppd3 as (
  select pp.icustay_id,
    round(avg(pp.val),2) as ppmd3,
    round(stddev(pp.val),2) as ppsd3
    from pulsep pp
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select * from ppd3;



-- heart rate: daily avg & stddev
, hrd1 as (
  select hr.icustay_id,
    round(avg(hr.val),2) as hrmd1,
    round(stddev(hr.val),2) as hrsd1
    from hr
    where min_post_adm < 1440
    group by icustay_id
)
--select * from hrd2;

, hrd2 as (
  select hr.icustay_id,
    round(avg(hr.val),2) as hrmd2,
    round(stddev(hr.val),2) as hrsd2
    from hr
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from hrd2;

, hrd3 as (
  select hr.icustay_id,
    round(avg(hr.val),2) as hrmd3,
    round(stddev(hr.val),2) as hrsd3
    from hr
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select count(distinct icustay_id) from hrd3;







--lactate: daily avg & stddev
, ld1 as (
  select l.icustay_id,
    round(avg(l.val),2) as lmd1,
    round(stddev(l.val),2) as lsd1
    from lactate l
    where min_post_adm < 1440
    group by icustay_id
)
--select * from ld2;

, ld2 as (
  select l.icustay_id,
    round(avg(l.val),2) as lmd2,
    round(stddev(l.val),2) as lsd2
    from lactate l
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from ld2;

, ld3 as (
  select l.icustay_id,
    round(avg(l.val),2) as lmd3,
    round(stddev(l.val),2) as lsd3
    from lactate l
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select count(distinct icustay_id) from ld3;






-- urine output - daily totals
, uod1 as (
  select uo.icustay_id,
    sum(uo.val) as uod1
    from urine_output uo
    where min_post_adm < 1440
    group by icustay_id
)
--select * from uod1;
    
  , uod2 as (
  select uo.icustay_id,
    sum(uo.val) as uod2
    from urine_output uo
    where min_post_adm > 1440 and min_post_adm < 2880
    group by icustay_id
)
--select * from uod2;  

  , uod3 as (
  select uo.icustay_id,
    sum(uo.val) as uod3
    from urine_output uo
    where min_post_adm > 2880 and min_post_adm < 4320
    group by icustay_id
)
--select count(distinct icustay_id) from uod3; 




-- final assembly
, final_assemble as (
  select fc.*,
    sbpd1.sbpmd1,
    sbpd1.sbpsd1,
    sbpd2.sbpmd2,
    sbpd2.sbpsd2,
    sbpd3.sbpmd3,
    sbpd3.sbpsd3,

    dbpd1.dbpmd1,
    dbpd1.dbpsd1,
    dbpd2.dbpmd2,
    dbpd2.dbpsd2,
    dbpd3.dbpmd3,
    dbpd3.dbpsd3,

    mbpd1.mbpmd1,
    mbpd1.mbpsd1,
    mbpd2.mbpmd2,
    mbpd2.mbpsd2,
    mbpd3.mbpmd3,
    mbpd3.mbpsd3,

    ppd1.ppmd1,
    ppd1.ppsd1,
    ppd2.ppmd2,
    ppd2.ppsd2,
    ppd3.ppmd3,
    ppd3.ppsd3,

    hrd1.hrmd1,
    hrd1.hrsd1,
    hrd2.hrmd2,
    hrd2.hrsd2,
    hrd3.hrmd3,
    hrd3.hrsd3,

    ld1.lmd1,
    ld1.lsd1,
    ld2.lmd2,
    ld2.lsd2,
    ld3.lmd3,
    ld3.lsd3,

    uod1.uod1,
    uod2.uod2,
    uod3.uod3
    
    from tbrennan.cardiac_output_sepsis_cohort fc
    left join sbpd1 on fc.icustay_id = sbpd1.icustay_id
    left join sbpd2 on fc.icustay_id = sbpd2.icustay_id
    left join sbpd3 on fc.icustay_id = sbpd3.icustay_id

    left join dbpd1 on fc.icustay_id = dbpd1.icustay_id
    left join dbpd2 on fc.icustay_id = dbpd2.icustay_id
    left join dbpd3 on fc.icustay_id = dbpd3.icustay_id

    left join mbpd1 on fc.icustay_id = mbpd1.icustay_id
    left join mbpd2 on fc.icustay_id = mbpd2.icustay_id
    left join mbpd3 on fc.icustay_id = mbpd3.icustay_id

    left join ppd1 on fc.icustay_id = ppd1.icustay_id
    left join ppd2 on fc.icustay_id = ppd2.icustay_id
    left join ppd3 on fc.icustay_id = ppd3.icustay_id

    left join hrd1 on fc.icustay_id = hrd1.icustay_id
    left join hrd2 on fc.icustay_id = hrd2.icustay_id
    left join hrd3 on fc.icustay_id = hrd3.icustay_id

    left join ld1 on fc.icustay_id = ld1.icustay_id
    left join ld2 on fc.icustay_id = ld2.icustay_id
    left join ld3 on fc.icustay_id = ld3.icustay_id
    
    left join uod1 on fc.icustay_id = uod1.icustay_id
    left join uod2 on fc.icustay_id = uod2.icustay_id
    left join uod3 on fc.icustay_id = uod3.icustay_id
)
select * from final_assemble;


/* full assembly
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
  select * from urine;
*/