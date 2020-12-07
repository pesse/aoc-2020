begin
	dbms_network_acl_admin.append_host_ace(
		host => sys_context('USERENV','IP_ADDRESS'),
		lower_port => 80,
		upper_port => 80,
		ace => xs$ace_type(privilege_list => xs$name_list('http'),
						   principal_name => 'sithdb',
						   principal_type => xs_acl.ptype_db));
end;
/