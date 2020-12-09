-- Part 1
with
  config as (
    select
      25 as preamble_length,
      25 as search_range
    from dual
  ),
  base_data as (
    select
      rownum line,
      to_number(column_value) num
    from table (
        aoc_file_loader.file_as_stringlist(
          aoc_file_loader.local_url('day_9_input.txt')
       )
    )
  ),
  calc_cube as (
    select
      d1.line line_1,
      d1.num num_1,
      d2.line line_2,
      d2.num num_2,
      d1.num+d2.num sum
    from base_data d1
    cross join base_data d2
    cross join config
    where
      d1.line-d2.line between 1 and config.search_range
      or d1.line-d2.line between 1 and config.search_range
  ),
  valid_sequence( line, num, parents_found) as (
    select
      line,
      num,
      (select count(*) from calc_cube cube
        where
          cube.sum = cur.num
          and cube.line_2 between cur.line-config.search_range and cur.line-1
          and cube.line_1 between cur.line-config.search_range and cur.line-1
      )
    from base_data cur
      cross join config
    where line = config.preamble_length+1 -- First line after preamble
    union all
    select
      cur.line,
      cur.num,
      (select count(*) from calc_cube cube
        where
          cube.sum = cur.num
          and cube.line_2 between cur.line-config.search_range and cur.line-1
          and cube.line_1 between cur.line-config.search_range and cur.line-1
      )
    from base_data cur
      inner join valid_sequence prev on cur.line = prev.line+1
      cross join config
    where prev.parents_found > 0
  )
select
  line,
  num
from valid_sequence
where parents_found = 0
;

-- Part 2
with
  config as (
    select
      41682220 as invalid_num
    from dual
  ),
  base_data as (
    select
      rownum line,
      to_number(column_value) num
    from table (
        aoc_file_loader.file_as_stringlist(
          aoc_file_loader.local_url('day_9_input.txt')
       )
    )
  ),
  possible_input as (
    select
      line,
      num
    from base_data
      cross join config
    where
      line < (select line from base_data where num = config.invalid_num)
  ),
  walk (line, num, run_total, min_line, max_line, action, next_line) as (
    select
      line,
      num,
      num,
      line,
      line,
      'add',
      line+1
    from possible_input
    where line = 1
    union all
    select
      cur.line,
      cur.num,
      case when prev.run_total+cur.num > config.invalid_num then
        prev.run_total - (select num from possible_input where line = prev.min_line)
      else
        prev.run_total + cur.num
      end run_total,
      case when prev.run_total+cur.num > config.invalid_num then
        prev.min_line+1
      else
        prev.min_line
      end min_line,
      cur.line max_line,
      case when prev.run_total+cur.num > config.invalid_num then
        'rem'
      else
        'add'
      end action,
      case when prev.run_total+cur.num > config.invalid_num then
        cur.line
      else
        cur.line+1
      end next_line
    from possible_input cur, walk prev, config
    where cur.line = prev.next_line
      and prev.run_total != config.invalid_num
  ) --cycle line, run_total set is_loop to 'Y' default 'N'
select
  (select min(num) from possible_input where line between walk.min_line and walk.max_line) min_num,
  (select max(num) from possible_input where line between walk.min_line and walk.max_line) max_num,
  (select min(num)+max(num) from possible_input where line between walk.min_line and walk.max_line) sum_num
from walk, config
where run_total = config.invalid_num
;