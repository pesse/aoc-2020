create or replace package aoc_day11_seating_system as

  type t_cols is varray(100) of char(1);
  type t_rows is varray(100) of t_cols;

  function part_1_occupied_seats(
    i_input sys.odcivarchar2list,
    i_print_steps boolean default false ) return integer;

  function part_2_occupied_seats(
    i_input sys.odcivarchar2list,
    i_print_steps boolean default false ) return integer;

end;
/