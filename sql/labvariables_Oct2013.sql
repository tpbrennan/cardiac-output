--created by mpimentel, Cardiac Output project 
-- Last Updated: October 2013

drop table cardiac_output_labs;
create table cardiac_output_labs as

with cohort as (
  select * from TBRENNAN.cardiac_output_treatments
)
--select count(*) from cohort; -- 8476
--select * from cohort order by 1;

-- %%%%%%%%%% Collect all variables

, lab_data as
(select
    co.icustay_id
  , co.icustay_intime
  , lab.charttime
  , lab.itemid
  , lab.valuenum
  , (case when lab.itemid in (50025,50022,50172) then 'tco2' 
        when lab.itemid=50090 then 'creatinine'
        when lab.itemid=50083 then 'chloride'
        when lab.itemid=50159 then 'sodium'
        when lab.itemid=50149 then 'potassium'
        when lab.itemid=50079 then 'calcium'
        when lab.itemid=50140 then 'magnesium'
        when lab.itemid=50177 then 'bun'
        when lab.itemid in (50316, 50468) then 'wbc'
        when lab.itemid=50010 then 'lactate'
        when lab.itemid=50195 then 'bnp' -- Confirm this (BNP ?= proBNP)
        when lab.itemid=50062 then 'alt' -- ALT (SGPT)
        when lab.itemid=50073 then 'ast' -- AST (SGOT)
        else null end) as test_name
from cohort co
join mimic2v26.labevents lab 
on lab.icustay_id=co.icustay_id 
and lab.charttime between co.icustay_intime and co.icustay_intime + 72/24
and lab.itemid in (50025,50022,50172,50090,50083,50159,50149,50177,50316,50468,50010,50079,50140,50195,50062,50073)
)
--select * from lab_data;

, lab_d1 as (
    select distinct
        icustay_id
        , extract(day from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))*24
          + extract(hour from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))
          + round(extract(minute from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))/60, 2) as hr_to_adm
        , median(valuenum) over (partition by icustay_id, test_name) as val
        , first_value(test_name) over (partition by icustay_id, test_name) as test_name
    from lab_data
    where charttime between icustay_intime and icustay_intime + 1
    order by 1
)
--select * from lab_d1;

, lab_d1_pivot as (
    select * from (select icustay_id, val, test_name from lab_d1)
      pivot (max(val) as d1
      for test_name in ('tco2' as tco2, 'creatinine' as creatinine, 'potassium' as potassium, 'chloride' as chloride, 'sodium' as sodium, 'bun' as bun, 'calcium' as calcium, 'magnesium' as magnesium, 'wbc' as wbc, 'bnp' as bnp, 'lactate' as lactate, 'alt' as alt, 'ast' as ast))
)
--select * from lab_d1_pivot;

, lab_d2 as (
    select distinct
        icustay_id
        , extract(day from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))*24
          + extract(hour from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))
          + round(extract(minute from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))/60, 2) as hr_to_adm
        , median(valuenum) over (partition by icustay_id, test_name) as val
        , first_value(test_name) over (partition by icustay_id, test_name) as test_name
    from lab_data
    where charttime between icustay_intime + 1 and icustay_intime + 2
    order by 1
)
--select * from lab_d2;

, lab_d2_pivot as (
    select * from (select icustay_id, val, test_name from lab_d2)
      pivot (max(val) as d2
      for test_name in ('tco2' as tco2, 'creatinine' as creatinine, 'potassium' as potassium, 'chloride' as chloride, 'sodium' as sodium, 'bun' as bun, 'calcium' as calcium, 'magnesium' as magnesium, 'wbc' as wbc, 'bnp' as bnp, 'lactate' as lactate, 'alt' as alt, 'ast' as ast))
)
--select * from lab_d2_pivot;

, lab_d3 as (
    select distinct
        icustay_id
        , extract(day from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))*24
          + extract(hour from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))
          + round(extract(minute from (first_value(charttime) over (partition by icustay_id, test_name order by charttime asc) - icustay_intime))/60, 2) as hr_to_adm
        , median(valuenum) over (partition by icustay_id, test_name) as val
        , first_value(test_name) over (partition by icustay_id, test_name) as test_name
    from lab_data
    where charttime between icustay_intime + 2 and icustay_intime + 3
    order by 1
)
--select * from lab_d2;

, lab_d3_pivot as (
    select * from (select icustay_id, val, test_name from lab_d3)
      pivot (max(val) as d3
      for test_name in ('tco2' as tco2, 'creatinine' as creatinine, 'potassium' as potassium, 'chloride' as chloride, 'sodium' as sodium, 'bun' as bun, 'calcium' as calcium, 'magnesium' as magnesium, 'wbc' as wbc, 'bnp' as bnp, 'lactate' as lactate, 'alt' as alt, 'ast' as ast))
)
--select * from lab_d3_pivot;

, lab_variables as (
   select distinct fc.*
    , l1.tco2_d1, l2.tco2_d2, l3.tco2_d3
    , l1.creatinine_d1, l2.creatinine_d2, l3.creatinine_d3
    , l1.potassium_d1, l2.potassium_d2, l3.potassium_d3
    , l1.chloride_d1, l2.chloride_d2, l3.chloride_d3
    , l1.sodium_d1, l2.sodium_d2, l3.sodium_d3
    , l1.bun_d1, l2.bun_d2, l3.bun_d3
    , l1.calcium_d1, l2.calcium_d2, l3.calcium_d3
    , l1.magnesium_d1, l2.magnesium_d2, l3.magnesium_d3
    , l1.wbc_d1, l2.wbc_d2, l3.wbc_d3
    , l1.bnp_d1, l2.bnp_d2, l3.bnp_d3
    , l1.lactate_d1, l2.lactate_d2, l3.lactate_d3
    , l1.alt_d1, l2.alt_d2, l3.alt_d3
    , l1.ast_d1, l2.ast_d2, l3.ast_d3
    from cohort fc
      left join lab_d1_pivot l1 on fc.icustay_id = l1.icustay_id
      left join lab_d2_pivot l2 on fc.icustay_id = l2.icustay_id
      left join lab_d3_pivot l3 on fc.icustay_id = l3.icustay_id
)
select * from lab_variables;