CREATE OR REPLACE FUNCTION public.sp_department_getall(
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
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_department_getall', 1::bit, 0::bit, _result);
END;
$$;
