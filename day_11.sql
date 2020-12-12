
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

-- Part 1: VERY slow with large input set :(
with
  column_data as (
    select
      row_id,
      col_id,
      seat
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
      0 as sum_occupied,
      0 as nb_occupied
    )
    ignore nav
    rules upsert all iterate(1) (
      sum_occupied[iteration_number, any, any] =
        sum(
          case seat
            when 'L' then 0
            when '#' then 1
            else null
          end
        )[
          generation = iteration_number,
          row_id between cv()-1 and cv()+1,
          col_id between cv()-1 and cv()+1
        ],
      nb_occupied[iteration_number, any, any] =
        sum_occupied[iteration_number, cv(), cv()]
        - case seat[iteration_number, cv(), cv()] when '#' then 1 else 0 end
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
        end
    )
  ),
  display as (
    select
      generation,
      row_id,
      listagg(seat) within group(order by col_id) seats,
      /*listagg(sum_occupied) within group ( order by col_id ) sum_occupied,
      listagg(nb_occupied) within group ( order by col_id ) nb_occupied,*/
      sum(case seat when '#' then 1 else 0 end) occupied_seats
    from modeled_data
    group by generation, rollup(row_id)
  )
select
  generation, row_id, col_id, seat
from modeled_data
--where row_id is null
;

drop table aoc_day11_gen_data;
create table aoc_day11_gen_data
(
  generation number(5, 0),
  row_id     number(4, 0),
  col_id     number(3, 0),
  seat       char(1),
  primary key (generation, row_id, col_id)
);

insert into aoc_day11_gen_data
  select
    0,
    row_id,
    col_id,
    seat
  from aoc_day11_normalized;

declare
  c_max_runs constant integer := 20;
  l_runs integer := 0;
  l_run_changes integer;
begin
  loop
    l_runs := l_runs+1;

    insert into aoc_day11_gen_data
    select * from (
    select
          generation,
          row_id,
          col_id,
          seat
        from aoc_day11_gen_data
        where generation = (select max(generation) from aoc_day11_gen_data)
        model
        dimension by (
          0 iteration,
          row_id,
          col_id
        )
        measures (
          generation,
          seat,
          0 as sum_occupied,
          0 as nb_occupied
        )
        ignore nav
        rules upsert all iterate(1) (
          sum_occupied[iteration_number, any, any] =
            sum(
              case seat
                when 'L' then 0
                when '#' then 1
                else null
              end
            )[
              iteration = iteration_number,
              row_id between cv()-1 and cv()+1,
              col_id between cv()-1 and cv()+1
            ],
          nb_occupied[iteration_number, any, any] =
            sum_occupied[iteration_number, cv(), cv()]
            - case seat[iteration_number, cv(), cv()] when '#' then 1 else 0 end
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
          generation[iteration_number+1, any, any] = generation[iteration_number, cv(), cv()]+1
        )
    ) modeled
    where generation not in (select generation from aoc_day11_gen_data);

    select count(*) into l_run_changes from (
      select row_id, col_id, seat from aoc_day11_gen_data where generation = (select max(generation)-1 from aoc_day11_gen_data)
      minus
      select row_id, col_id, seat from aoc_day11_gen_data where generation = (select max(generation) from aoc_day11_gen_data)
    );

    exit when l_run_changes = 0 or l_runs > c_max_runs;
  end loop;

  dbms_output.put_line('Last run changes: '||l_run_changes);
end;
/

commit;

select generation, sum(
              case seat
                when 'L' then 0
                when '#' then 1
                else null
              end
            ) from aoc_day11_gen_data group by generation order by 1 desc;

select count(*) from (
  select row_id, col_id, seat from aoc_day11_gen_data where generation = (select max(generation)-1 from aoc_day11_gen_data)
  minus
  select row_id, col_id, seat from aoc_day11_gen_data where generation = (select max(generation) from aoc_day11_gen_data)
);


select * from (
    select
          generation,
          iteration,
          row_id,
          col_id,
          seat
        from aoc_day11_gen_data
        where generation = (select max(generation) from aoc_day11_gen_data)
        model
        dimension by (
          0 iteration,
          row_id,
          col_id
        )
        measures (
          generation,
          seat,
          0 as sum_occupied,
          0 as nb_occupied
        )
        ignore nav
        rules upsert all iterate(1) (
          sum_occupied[iteration_number, any, any] =
            sum(
              case seat
                when 'L' then 0
                when '#' then 1
                else null
              end
            )[
              iteration = iteration_number,
              row_id between cv()-1 and cv()+1,
              col_id between cv()-1 and cv()+1
            ],
          nb_occupied[iteration_number, any, any] =
            sum_occupied[iteration_number, cv(), cv()]
            - case seat[iteration_number, cv(), cv()] when '#' then 1 else 0 end
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
          generation[iteration_number+1, any, any] = generation[iteration_number, cv(), cv()]+1
        )
    ) modeled
    --where generation not in (select generation from aoc_day11_gen_data)
    ;