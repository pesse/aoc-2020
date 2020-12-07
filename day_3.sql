-- Get Input
create table aoc_day3_input (
  line integer not null,
  pos integer not null,
  tree number(1,0) not null,
  primary key (line, pos)
);

create or replace package advent_of_code_day_3 as
  procedure load_input( i_url varchar2 );
end;
/

create or replace package body advent_of_code_day_3 as
  procedure load_input( i_url varchar2) as
    l_request   utl_http.req;
    l_response  utl_http.resp;
    l_value varchar2(1024);
    l_line integer := 1;
    l_tree number(1,0) := 0;
  begin
    execute immediate 'truncate table aoc_day3_input';
    begin
      l_request := utl_http.begin_request(i_url);
      l_response := utl_http.get_response(l_request);
      loop
        utl_http.read_line(l_response, l_value, true);
        for l_pos in 1..length(l_value) loop
            if substr(l_value, l_pos, 1) = '#' then
              l_tree := 1;
            else
              l_tree := 0;
            end if;
            insert into aoc_day3_input (line, pos, tree)
              values ( l_line, l_pos, l_tree);
          end loop;
        l_line := l_line+1;
      end loop;
    exception
      when utl_http.end_of_body then
        utl_http.end_response(l_response);
    end;
  end;

end;
/

call advent_of_code_day_3.load_input(aoc_file_loader.local_url('day_3_input.txt'));
commit;

select * from aoc_day3_input where line < 10 order by line, pos;

-- Part 1
with
  max_pos as (
    select max(pos) max_pos
      from aoc_day3_input
  ),
  step( line, pos, tree) as (
    select line, pos, tree
      from aoc_day3_input
      where line = 1 and pos = 1
    union all
    select cur.line, cur.pos, cur.tree
      from aoc_day3_input cur,
           step prev,
           max_pos mp
      where cur.line = prev.line+1
      and cur.pos =
          case when prev.pos+3 > mp.max_pos then
                 mod(prev.pos+3, mp.max_pos)
               else
                   prev.pos+3
            end
  )
select sum(tree) from step;

-- Part 2
with
  max_pos as (
    select max(pos) max_pos
      from aoc_day3_input
  ),
  slopes as (
    select 1 id, 1 right, 1 down from dual union all
    select 2   , 3      , 1      from dual union all
    select 3   , 5      , 1      from dual union all
    select 4   , 7      , 1      from dual union all
    select 5   , 1      , 2      from dual
  ),
  step( line, pos, tree, slope_id) as (
    select line, pos, tree, slopes.id slope_id
      from aoc_day3_input, slopes
      where line = 1 and pos = 1
    union all
    select cur.line, cur.pos, cur.tree, slope.id
      from aoc_day3_input cur,
        step prev,
        slopes slope,
        max_pos mp
      where
        slope.id = prev.slope_id
        and cur.line = prev.line+slope.down
        and cur.pos =
          case when prev.pos+slope.right > mp.max_pos then
            mod(prev.pos+slope.right, mp.max_pos)
          else
            prev.pos+slope.right
          end
  ),
  slope_results as (
    select
      slope_id, sum(tree) trees_hit
      from step
      group by slope_id
  )
select "1"*"2"*"3"*"4"*"5"
  from slope_results
  pivot (
    sum(trees_hit)
    for slope_id
    in (1, 2, 3, 4, 5)
  );
