/* As SYS - directory */
create or replace directory ext_tables as '/home/oracle/ext_tables';
grant read on directory ext_tables to sithdb;

/* As normal user - Load data */
drop table aoc_day4_ext_input;
create table aoc_day4_ext_input (
  raw_record varchar2(4000)
)
  organization external (
  type oracle_loader
  default directory ext_tables
  access parameters (
    records delimited by '\n\n'
    fields terminated by ','
    missing field values are null
    (
      raw_record char(4000)
    )
  )
  location ('day_4_input.txt')
  );

create table aoc_day4_input as
select * from aoc_day4_ext_input;

select * from aoc_day4_input;

-- Part 1
with
  fields as (
    select 'byr' name from dual union all
    select 'iyr'      from dual union all
    select 'eyr'      from dual union all
    select 'hgt'      from dual union all
    select 'hcl'      from dual union all
    select 'ecl'      from dual union all
    select 'pid'      from dual union all
    select 'cid'      from dual
  ),
  normalize_newline as (
    select
      rownum passport_id,
      replace(raw_record, chr(10), ' ') line
    from aoc_day4_input
  ),
  split_columns as (
    select
      passport_id,
      field.name key,
      substr(
        regexp_substr(line, field.name||':[^ ]+'),
        length(field.name)+2) value
    from normalize_newline, fields field
  ),
  pivot_data as (
    select
      *
    from split_columns
    pivot (
      max(value)
      for key in (
        'byr' as BYR,
        'iyr' as IYR,
        'eyr' as EYR,
        'hgt' as HGT,
        'hcl' as HCL,
        'ecl' as ECL,
        'pid' as PID,
        'cid' as CID
      )
    )
  )
select count(*)
from pivot_data
where byr is not null
  and iyr is not null
  and eyr is not null
  and hgt is not null
  and hcl is not null
  and ecl is not null
  and pid is not null
;

-- Part 2
with
  fields as (
    select 'byr' name from dual union all
    select 'iyr'      from dual union all
    select 'eyr'      from dual union all
    select 'hgt'      from dual union all
    select 'hcl'      from dual union all
    select 'ecl'      from dual union all
    select 'pid'      from dual union all
    select 'cid'      from dual
  ),
  normalize_newline as (
    select
      rownum passport_id,
      replace(raw_record, chr(10), ' ') line
    from aoc_day4_input
  ),
  split_columns as (
    select
      passport_id,
      field.name key,
      substr(
        regexp_substr(line, field.name||':[^ ]+'),
        length(field.name)+2) value
    from normalize_newline, fields field
  ),
  pivot_data as (
    select
      *
    from split_columns
    pivot (
      max(value)
      for key in (
        'byr' as BYR,
        'iyr' as IYR,
        'eyr' as EYR,
        'hgt' as HGT,
        'hcl' as HCL,
        'ecl' as ECL,
        'pid' as PID,
        'cid' as CID
      )
    )
  ),
  data_with_height as (
    select
      passport_id,
      byr,
      iyr,
      eyr,
      hgt,
      regexp_replace(hgt, '^([0-9]+)([cmin]{2})$', '\2') hgt_measure,
      regexp_replace(hgt, '^([0-9]+)([cmin]{2})$', '\1') hgt_value,
      hcl,
      ecl,
      pid,
      cid
    from pivot_data
  )
select count(*)
from data_with_height
where byr between 1920 and 2002
  and iyr between 2010 and 2020
  and eyr between 2020 and 2030
  and (
    (hgt_measure = 'cm' and hgt_value between 150 and 193)
    or (hgt_measure = 'in' and hgt_value between 59 and 76)
  )
  and regexp_like(hcl, '^#[a-f0-9]{6}$')
  and ecl in ('amb','blu','brn','gry','grn','hzl','oth')
  and regexp_like(pid, '^[0-9]{9}$')
;

