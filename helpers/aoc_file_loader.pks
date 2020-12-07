create or replace package aoc_file_loader as

  subtype url is varchar2(255) not null;

  function local_url( i_path varchar2 )
    return varchar2;

  function file_as_stringlist( i_url url )
    return sys.odcivarchar2list;

end;
/