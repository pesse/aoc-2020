create or replace package body aoc_day11_seating_system as

  procedure print( i_array in out nocopy t_rows ) as
  begin
    for i in i_array.first..i_array.last loop
      for j in i_array(i).first..i_array(i).last loop
        dbms_output.put(i_array(i)(j));
      end loop;
      dbms_output.put_line('');
    end loop;
  end;

  function to_array( i_input sys.odcivarchar2list ) return t_rows as
    l_result t_rows := t_rows();
    l_numOfCols integer;
  begin
    l_numOfCols := length(i_input(1));

    l_result.extend(i_input.count);
    for i in i_input.first..i_input.last loop
      l_result(i) := t_cols();
      l_result(i).extend(l_numOfCols);
      for j in 1..l_numOfCols loop
        l_result(i)(j) := substr(i_input(i), j, 1);
      end loop;
    end loop;
    return l_result;
  end;

  function is_occupied( y integer, x integer, i_array in t_rows ) return integer as
  begin
    if y <= 0 or y > i_array.count or x <= 0 or x > i_array(y).count then
      return 0;
    end if;
    return case i_array(y)(x) when '#' then 1 else 0 end;
  end;

  function sees_occupied( y integer, x integer, ystep integer, xstep integer, i_array in t_rows ) return integer as
    l_nextY integer := y + ystep;
    l_nextX integer := x + xstep;
  begin
    if l_nextY <= 0 or l_nextY > i_array.count or l_nextX <= 0 or l_nextX > i_array(y).count then
      return 0;
    end if;
    return case i_array(l_nextY)(l_nextX)
      when '.' then sees_occupied(l_nextY, l_nextX, ystep, xstep, i_array)
      when '#' then 1
      else 0 end;
  end;

  function iterate_cell_part1( y integer, x integer, i_array in t_rows ) return char as
    l_neighbours integer;
  begin
    if i_array(y)(x) = '.' then
      return '.';
    end if;
    l_neighbours :=
        is_occupied(y-1, x-1, i_array)
      + is_occupied(y-1, x  , i_array)
      + is_occupied(y-1, x+1, i_array)
      + is_occupied(y  , x-1, i_array)
      + is_occupied(y  , x+1, i_array)
      + is_occupied(y+1, x-1, i_array)
      + is_occupied(y+1, x  , i_array)
      + is_occupied(y+1, x+1, i_array);

    if i_array(y)(x) = 'L' and l_neighbours = 0 then
      return '#';
    elsif i_array(y)(x) = '#' and l_neighbours >= 4 then
      return 'L';
    else
      return i_array(y)(x);
    end if;
  end;

  function iterate_array_part1( i_input in t_rows ) return t_rows as
    l_result t_rows := t_rows();
  begin
    l_result.extend(i_input.count);
    for i in i_input.first..i_input.last loop
      l_result(i) := t_cols();
      l_result(i).extend(i_input(i).count);
      for j in i_input(i).first..i_input(i).last loop
        l_result(i)(j) := iterate_cell_part1(i, j, i_input);
      end loop;
    end loop;
    return l_result;
  end;

  function iterate_cell_part2( y integer, x integer, i_array in t_rows ) return char as
    l_neighbours integer;
  begin
    if i_array(y)(x) = '.' then
      return '.';
    end if;
    l_neighbours :=
        sees_occupied(y, x, -1, -1, i_array)
      + sees_occupied(y, x, -1,  0, i_array)
      + sees_occupied(y, x, -1, +1, i_array)
      + sees_occupied(y, x,  0, -1, i_array)
      + sees_occupied(y, x,  0, +1, i_array)
      + sees_occupied(y, x, +1, -1, i_array)
      + sees_occupied(y, x, +1,  0, i_array)
      + sees_occupied(y, x, +1, +1, i_array);

    if i_array(y)(x) = 'L' and l_neighbours = 0 then
      return '#';
    elsif i_array(y)(x) = '#' and l_neighbours >= 5 then
      return 'L';
    else
      return i_array(y)(x);
    end if;
  end;

  function iterate_array_part2( i_input in t_rows ) return t_rows as
    l_result t_rows := t_rows();
  begin
    l_result.extend(i_input.count);
    for i in i_input.first..i_input.last loop
      l_result(i) := t_cols();
      l_result(i).extend(i_input(i).count);
      for j in i_input(i).first..i_input(i).last loop
        l_result(i)(j) := iterate_cell_part2(i, j, i_input);
      end loop;
    end loop;
    return l_result;
  end;

  function has_differences( i_array1 t_rows, i_array2 t_rows ) return boolean as
  begin
    if i_array1.count != i_array2.count then
      return true;
    end if;
    for i in i_array1.first..i_array1.last loop
      if i_array1(i).count != i_array2(i).count then
        return true;
      end if;
      for j in i_array1(i).first..i_array1(i).last loop
        if i_array1(i)(j) != i_array2(i)(j) then
          return true;
        end if;
      end loop;
    end loop;
    return false;
  end;

  function count_occupied_seats(i_array t_rows) return integer as
    l_result integer := 0;
  begin
    for i in i_array.first..i_array.last loop
      for j in i_array(i).first..i_array(i).last loop
        l_result := l_result + is_occupied(i, j, i_array);
      end loop;
    end loop;
    return l_result;
  end;

  function part_1_occupied_seats(
    i_input sys.odcivarchar2list,
    i_print_steps boolean default false ) return integer
  as
    l_previous_array t_rows;
    l_next_array t_rows;
    l_iteration integer := 0;
  begin
    l_previous_array := to_array(i_input);
    if i_print_steps then print(l_previous_array); end if;
    loop
      l_iteration := l_iteration+1;
      dbms_output.put_line('Iteration: '||l_iteration);

      l_next_array := iterate_array_part1(l_previous_array);
      if i_print_steps then print(l_next_array); end if;
      dbms_output.put_line('Occupied: '||count_occupied_seats(l_next_array));

      exit when not has_differences(l_previous_array, l_next_array)
        or l_iteration > 200;
      l_previous_array := l_next_array;
    end loop;

    return count_occupied_seats(l_next_array);
  end;

  function part_2_occupied_seats(
    i_input sys.odcivarchar2list,
    i_print_steps boolean default false ) return integer
  as
    l_previous_array t_rows;
    l_next_array t_rows;
    l_iteration integer := 0;
  begin
    l_previous_array := to_array(i_input);
    if i_print_steps then print(l_previous_array); end if;
    loop
      l_iteration := l_iteration+1;
      dbms_output.put_line('Iteration: '||l_iteration);

      l_next_array := iterate_array_part2(l_previous_array);
      if i_print_steps then print(l_next_array); end if;
      dbms_output.put_line('Occupied: '||count_occupied_seats(l_next_array));

      exit when not has_differences(l_previous_array, l_next_array)
        or l_iteration > 200;
      l_previous_array := l_next_array;
    end loop;

    return count_occupied_seats(l_next_array);
  end;
end;
/