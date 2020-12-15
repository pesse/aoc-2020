
-- Normalize the input
create table aoc_day11_normalized as
with
  base_data as (
    select
      rownum row_id,
      column_value line
    from table (
        aoc_file_loader.file_as_stringlist(
          aoc_file_loader.local_url('day_11_input.txt')
       )
    )
  ),
  cols as (
    select
      level col_id
    from dual
    connect by level <= (select length(line) from base_data where row_id = 1)
  ),
  column_data as (
    select
      base_data.row_id,
      cols.col_id,
      substr(line, cols.col_id, 1) seat
    from base_data
      cross join cols
  )
select * from column_data;

select count(distinct row_id), count(distinct col_id) from aoc_day11_normalized;

-- Part 1
with
  column_data as (
    select
      row_id,
      col_id,
      seat,
      case seat
        when '#' then 1
        else 0
      end occupied
    from aoc_day11_normalized
    --where row_id <= 10
  ),
  modeled_data as (
    select
      *
    from column_data
    model
    dimension by (
      0 generation,
      row_id,
      col_id
    )
    measures (
      seat,
      occupied,
      0 as sum_occupied,
      0 as nb_occupied,
      0 as changes,
      1 as sum_changes
    )
    ignore nav
    rules upsert all iterate(200) until (iteration_number > 1 and sum_changes[iteration_number, 1, 1] <= 0) (
      occupied[iteration_number, any, any] =
        case seat[iteration_number, cv(), cv()]
          when '#' then 1
          else 0
        end ,
      nb_occupied[iteration_number, any, any] =
        occupied[iteration_number, cv()-1, cv()-1]
        + occupied[iteration_number, cv()-1, cv()]
        + occupied[iteration_number, cv()-1, cv()+1]
        + occupied[iteration_number, cv(), cv()-1]
        + occupied[iteration_number, cv(), cv()+1]
        + occupied[iteration_number, cv()+1, cv()-1]
        + occupied[iteration_number, cv()+1, cv()]
        + occupied[iteration_number, cv()+1, cv()+1]
      ,
      seat[iteration_number+1, any, any] =
        case
          when seat[iteration_number, cv(), cv()] = '.' then
            '.'
          when seat[iteration_number, cv(), cv()] = 'L'
            and nb_occupied[iteration_number, cv(), cv()] = 0 then
            '#'
          when seat[iteration_number, cv(), cv()] = '#'
            and nb_occupied[iteration_number, cv(), cv()] >= 4 then
            'L'
          else seat[iteration_number, cv(), cv()]
        end,
      changes[iteration_number+1, any, any] =
        case when seat[iteration_number, cv(), cv()] != seat[iteration_number+1, cv(), cv()] then 1
        else 0 end,
      sum_changes[iteration_number+1,1,1] = sum(changes)[iteration_number+1, any, any]
    )
  ),
  display as (
    select
      generation,
      row_id,
      sum(changes) changes,
      sum(case seat when '#' then 1 else 0 end) occupied_seats
    from modeled_data
    group by generation, rollup(row_id)
  )
select
  *
from display
where row_id is null
order by generation desc
fetch first row only;


-- Part 1 in PL/SQL
declare
  l_occupied_seats_part_1 integer;
begin
  l_occupied_seats_part_1 :=
    aoc_day11_seating_system.part_1_occupied_seats(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_11_input.txt')
       )
    );
  dbms_output.put_line('Result: ' || l_occupied_seats_part_1);
end;
/

-- Part 2 in PL/SQL
declare
  l_occupied_seats_part_2 integer;
begin
  l_occupied_seats_part_2 :=
    aoc_day11_seating_system.part_2_occupied_seats(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_11_input.txt')
       )
    );
  dbms_output.put_line('Result: ' || l_occupied_seats_part_2);
end;
/