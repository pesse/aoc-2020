-- Part 1
with
  answer_pos as (
    select column_value c
    from table(sys.odcivarchar2list(
      'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
      )
    )
  ),
  base_data as (
    select
      rownum answer_id,
      column_value answers,
      case when column_value is null then 1 else 0 end is_break
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_6_input.txt')
      )
    )
  ),
  grouped_data as (
    select
      answer_id,
      group_id,
      answers
    from (
      select
        answer_id,
        answers,
        is_break,
        sum(is_break) over (
          order by answer_id
          range between unbounded preceding
            and current row)
          group_id
      from base_data
    )
    where is_break = 0
  ),
  distinct_one_answer_per_row as (
    select distinct
      group_id,
      answer_pos.c answer
    from grouped_data
      cross join answer_pos
    where instr(answers, answer_pos.c) > 0
  ),
  distinct_answers as (
    select
      group_id,
      listagg(answer, '') within group (order by answer) distinct_answers
    from distinct_one_answer_per_row
    group by group_id
  ),
  answer_length as (
    select
      group_id,
      length(distinct_answers) answer_length
    from distinct_answers
  )
select
  sum(answer_length)
from answer_length
;

-- Part 2
with
  answer_pos as (
    select column_value c
    from table(sys.odcivarchar2list(
      'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
      )
    )
  ),
  base_data as (
    select
      rownum answer_id,
      column_value answers,
      case when column_value is null then 1 else 0 end is_break
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_6_input.txt')
      )
    )
  ),
  grouped_data as (
    select
      answer_id,
      group_id,
      answers
    from (
      select
        answer_id,
        answers,
        is_break,
        sum(is_break) over (
          order by answer_id
          range between unbounded preceding
            and current row)
          group_id
      from base_data
    )
    where is_break = 0
  ),
  distinct_one_answer_per_row as (
    select
      group_id,
      answer_pos.c answer,
      count(distinct answer_id) over (partition by group_id) group_answers,
      count(*) over (partition by group_id, answer_pos.c) this_pos_answered
    from grouped_data
      cross join answer_pos
    where instr(answers, answer_pos.c) > 0
  ),
  all_agreed_upon_answers as (
    select distinct
      group_id,
      answer
    from distinct_one_answer_per_row
    where group_answers = this_pos_answered
  ),
  distinct_answers as (
    select
      group_id,
      listagg(answer, '') within group (order by answer) distinct_answers
    from all_agreed_upon_answers
    group by group_id
  ),
  answer_length as (
    select
      group_id,
      length(distinct_answers) answer_length
    from distinct_answers
  )
select
  sum(answer_length)
from answer_length
;

