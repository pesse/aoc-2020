
create table aoc_day5_input as
select column_value line from
table(
  aoc_file_loader.file_as_stringlist(
    aoc_file_loader.local_url('day_5_input.txt')
  )
);

-- Part 1
with
  seat_data as (
    select
      substr(line, 1, 7) seat_row,
      substr(line, 8, 3) seat_col,
      line orig
    from aoc_day5_input
  ),
  binary_data as (
    select
      translate(seat_row, 'FB', '01') b_seat_row,
      translate(seat_col, 'LR', '01') b_seat_col
      from seat_data
  ),
  decimal_data as (
    select
      substr(b_seat_row, 1, 1)*power(2,6)
        + substr(b_seat_row, 2, 1)*power(2,5)
        + substr(b_seat_row, 3, 1)*power(2,4)
        + substr(b_seat_row, 4, 1)*power(2,3)
        + substr(b_seat_row, 5, 1)*power(2,2)
        + substr(b_seat_row, 6, 1)*power(2,1)
        + substr(b_seat_row, 7, 1)
      dec_seat_row,
      substr(b_seat_col, 1, 1)*power(2,2)
        + substr(b_seat_col, 2, 1)*power(2,1)
        + substr(b_seat_col, 3, 1)
      dec_seat_col,
      b_seat_row,
      b_seat_col
      from binary_data
  ),
  data_with_id as (
    select
      dec_seat_row * 8 + dec_seat_col id,
      dec_seat_col,
      b_seat_row,
      b_seat_col
      from decimal_data
  )
select max(id)
from data_with_id;

-- Part 2
with
  seat_data as (
    select
      substr(line, 1, 7) seat_row,
      substr(line, 8, 3) seat_col,
      line orig
    from aoc_day5_input
  ),
  binary_data as (
    select
      translate(seat_row, 'FB', '01') b_seat_row,
      translate(seat_col, 'LR', '01') b_seat_col
      from seat_data
  ),
  decimal_data as (
    select
      substr(b_seat_row, 1, 1)*power(2,6)
        + substr(b_seat_row, 2, 1)*power(2,5)
        + substr(b_seat_row, 3, 1)*power(2,4)
        + substr(b_seat_row, 4, 1)*power(2,3)
        + substr(b_seat_row, 5, 1)*power(2,2)
        + substr(b_seat_row, 6, 1)*power(2,1)
        + substr(b_seat_row, 7, 1)
      dec_seat_row,
      substr(b_seat_col, 1, 1)*power(2,2)
        + substr(b_seat_col, 2, 1)*power(2,1)
        + substr(b_seat_col, 3, 1)
      dec_seat_col,
      b_seat_row,
      b_seat_col
      from binary_data
  ),
  data_with_id as (
    select
      dec_seat_row * 8 + dec_seat_col id,
      dec_seat_col,
      b_seat_row,
      b_seat_col
      from decimal_data
  ),
  id_analysis as (
    select
      id,
      id-lag(id) over (order by id) gap_prev,
      lead(id) over (order by id)-id gap_next
    from data_with_id
  )
select
  prev.id+1 my_id
from id_analysis prev, id_analysis next
where prev.gap_next > 1
  and next.gap_prev > 1
  and next.id - prev.id = 2;
