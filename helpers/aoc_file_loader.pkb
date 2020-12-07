create or replace package body aoc_file_loader as

  function local_url( i_path varchar2 )
    return varchar2
  as
  begin
    return 'http://'||sys_context('USERENV','IP_ADDRESS')||'/'||nvl(i_path,'');
  end;

  function file_as_stringlist( i_url url )
    return sys.odcivarchar2list
  as
    l_result sys.odcivarchar2list := sys.odcivarchar2list();
    l_request   utl_http.req;
    l_response  utl_http.resp;
    l_value varchar2(1024);
  begin
    dbms_output.put_line('Requesting '||i_url);
    begin
      l_request := utl_http.begin_request(i_url);
      l_response := utl_http.get_response(l_request);
      loop
        utl_http.read_line(l_response, l_value, true);
        l_result.extend;
        l_result(l_result.last) := l_value;
      end loop;
    exception
      when utl_http.end_of_body then
        utl_http.end_response(l_response);
    end;
    return l_result;
  end;

end;
/