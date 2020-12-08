-- Part 1
with
  base_data as (
    select
      column_value line
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_7_input.txt')
      )
    )
  ),
  bag_children as (
    select
      replace(
        regexp_replace(line, '^(.+) contain (.+)$', '\1'),
        'bags',
        'bag'
        ) bag,
      regexp_replace(line, '^(.+) contain (.+)$', '\2') children
    from base_data
  ),
  children_in_rows (bag, child, children) as (
    select
      bag,
      nvl(substr(children, 1, instr(children, ', ')-1), children),
      case when instr(children, ', ') > 0 then
        substr(children, instr(children, ', ')+2)
      else null end
    from bag_children
    union all
    select
      bag,
      nvl(substr(children, 1, instr(children, ', ')-1), children),
      case when instr(children, ', ') > 0 then
        substr(children, instr(children, ', ')+2)
      else null end
    from children_in_rows where children is not null
  ),
  bag_hierarchy( bag, child, hierarchy_level, path ) as (
    select
      bag,
      child,
      1,
      bag
    from children_in_rows
    where child like '%shiny gold bag%'
    union all
    select
      cur_bag.bag,
      cur_bag.child,
      parent_bag.hierarchy_level+1,
      cur_bag.bag || '/' || parent_bag.path
    from children_in_rows cur_bag
      inner join bag_hierarchy parent_bag on cur_bag.child like '%'||parent_bag.bag||'%'
  )
select count(distinct bag)
from bag_hierarchy
;

-- Part 2
with
  base_data as (
    select
      column_value line
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_7_input.txt')
      )
    )
  ),
  bag_children as (
    select
      replace(
        regexp_replace(line, '^(.+) contain (.+)$', '\1'),
        'bags',
        'bag'
        ) bag,
      regexp_replace(line, '^(.+) contain (.+)$', '\2') children
    from base_data
  ),
  children_in_rows (bag, child, children) as (
    select
      bag,
      nvl(substr(children, 1, instr(children, ', ')-1), children),
      case when instr(children, ', ') > 0 then
        substr(children, instr(children, ', ')+2)
      else null end
    from bag_children
    union all
    select
      bag,
      nvl(substr(children, 1, instr(children, ', ')-1), children),
      case when instr(children, ', ') > 0 then
        substr(children, instr(children, ', ')+2)
      else null end
    from children_in_rows where children is not null
  ),
  children_with_count as (
    select
      bag,
      to_number(
        replace(
          regexp_replace(child, '^([0-9]+) (.*)$', '\1'),
          'no other bags.',
          '0'
          )
        )child_count,
      regexp_replace(child, '^([0-9]+) (.*)$', '\2') child_name
    from children_in_rows
  ),
  bag_hierarchy( bag, child_name, child_count, cumulated_child_count, hierarchy_level, path ) as (
    select
      bag,
      child_name,
      child_count,
      child_count,
      1,
      bag
    from children_with_count
    where bag like '%shiny gold bag%'
    union all
    select
      cur_bag.bag,
      cur_bag.child_name,
      cur_bag.child_count,
      parent_bag.cumulated_child_count*cur_bag.child_count,
      parent_bag.hierarchy_level+1,
      parent_bag.path || '/' || cur_bag.bag
    from children_with_count cur_bag
      inner join bag_hierarchy parent_bag on parent_bag.child_name like '%'||cur_bag.bag||'%'
  )
select sum(cumulated_child_count)
from bag_hierarchy
;