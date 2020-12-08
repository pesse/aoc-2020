-- Part 1
with
  base_data as (
    select
      rownum line_number,
      column_value line
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_8_input.txt')
      )
    )
  ),
  command_value as (
    select
      line_number,
      substr(line, 1, 3) command,
      to_number(substr(line, 4)) value
    from base_data
  ),
  run_program (line_number, command, next, accumulator, stack) as (
    select
      line_number,
      command,
      line_number+1,
      case when cmd.command = 'acc' then
        cmd.value
      else
        0
      end,
      ':'||line_number||':'
    from command_value cmd where line_number = 1
    union all
    select
      cmd.line_number,
      cmd.command,
      case when cmd.command = 'jmp' then
        cmd.line_number+cmd.value
      else
        cmd.line_number+1
      end,
      case when cmd.command = 'acc' then
        call.accumulator+cmd.value
      else
        call.accumulator
      end,
      call.stack||':'||cmd.line_number||':'
    from command_value cmd, run_program call
    where cmd.line_number = call.next
      and instr(call.stack, ':'||cmd.line_number||':') <= 0
  )
select
  accumulator
from run_program
order by stack desc
fetch first row only;
;

-- Part 2
with
  base_data as (
    select
      rownum line_number,
      column_value line
    from table(
      aoc_file_loader.file_as_stringlist(
        aoc_file_loader.local_url('day_8_input.txt')
      )
    )
  ),
  command_value as (
    select
      line_number,
      substr(line, 1, 3) command,
      to_number(substr(line, 4)) value
    from base_data
  ),
  variant_definition as (
    select
      rownum variant_id,
      line_number,
      command,
      case command
        when 'jmp' then
          'nop'
        when 'nop' then
          'jmp'
      end replacement_command,
      value
      from command_value
    where command in ('jmp','nop')
  ),
  program_variants as (
    select
      variant.variant_id,
      cmd.line_number,
      case when cmd.line_number = variant.line_number then
        variant.replacement_command
      else
        cmd.command
      end command,
      cmd.value
      from variant_definition variant
      cross join command_value cmd
  ),
  run_program (variant_id, line_number, command, next, accumulator, stack) as (
    select
      variant_id,
      line_number,
      command,
      line_number+1,
      case when cmd.command = 'acc' then
        cmd.value
      else
        0
      end,
      ':'||line_number||':'
    from program_variants cmd where line_number = 1
    union all
    select
      cmd.variant_id,
      cmd.line_number,
      cmd.command,
      case when cmd.command = 'jmp' then
        cmd.line_number+cmd.value
      else
        cmd.line_number+1
      end,
      case when cmd.command = 'acc' then
        call.accumulator+cmd.value
      else
        call.accumulator
      end,
      call.stack||':'||cmd.line_number||':'
    from program_variants cmd, run_program call
    where cmd.variant_id = call.variant_id
      and cmd.line_number = call.next
      and instr(call.stack, ':'||cmd.line_number||':') <= 0
  ),
  last_values as (
    select
      variant_id,
      max(next) last_value
    from run_program
    group by variant_id
  )
select
  accumulator,
  variant_definition.line_number,
  variant_definition.command,
  variant_definition.replacement_command
from run_program
  inner join variant_definition using (variant_id)
where variant_id = (
  select variant_id from last_values where last_value-1 = (
    select count(*) from base_data
  )
)
order by stack desc
fetch first row only;
