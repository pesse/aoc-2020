-- Part 1
with
  base_data as (
    select
      to_number(column_value) num
    from table (
        aoc_file_loader.file_as_stringlist(
          aoc_file_loader.local_url('day_10_input.txt')
       )
    )
  ),
  jolt_diffs as (
    select
      num,
      num - nvl(lag(num) over (order by num),0) jolt_diff
    from base_data
  ),
  sums as (
    select
      jolt_diff,
      count(*) count,
      sum(jolt_diff) sum
    from jolt_diffs
    group by (jolt_diff)
  )
select
  (select count from sums where jolt_diff = 1)
  * (select count+1 -- +1 for the device-adapter
    from sums where jolt_diff = 3) result
from dual;


-- Part 2
with
  base_data as (
    select
      to_number(column_value) num
    from table (
        aoc_file_loader.file_as_stringlist(
          aoc_file_loader.local_url('day_10_input.txt')
       )
    )
    union all select 0 from dual
  ),
  walk (num, multiplier, dist1, dist2, dist3) as (
    select
      num,
      1,
      (select count(*) from base_data where num = cur.num-1),
      (select count(*) from base_data where num = cur.num-2),
      (select count(*) from base_data where num = cur.num-3)
    from base_data cur
    where num = (select max(num) from base_data)
    union all
    select
      prev.num-1,
      prev.dist1,
      prev.dist2 + (
        prev.dist1 * (select count(*) from base_data where num = cur.num-1)),
      prev.dist3 + (
        prev.dist1 * (select count(*) from base_data where num = cur.num-2)),
      prev.dist1 * (select count(*) from base_data where num = cur.num-3)
    from walk prev
      left outer join base_data cur on prev.num-1 = cur.num
    where prev.num > 0
  )
select multiplier as result
from walk
order by num fetch first row only;
