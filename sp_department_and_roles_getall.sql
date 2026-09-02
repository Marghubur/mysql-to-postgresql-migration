CREATE OR REPLACE FUNCTION public.sp_department_and_roles_getall(
  IN _companyid integer
)
RETURNS SETOF "org_hierarchy"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  begin
 
 RETURN QUERY select roleid as departmentid, rolename as departmentname from org_hierarchy
 where isdepartment = true;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from org_hierarchy
 where isdepartment = false;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from company_files where companyid = _companyid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_department_and_roles_getall', 1::bit, 0::bit, _result);
END;
$$;
