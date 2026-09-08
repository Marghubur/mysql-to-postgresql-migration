CREATE OR REPLACE FUNCTION public.sp_check_mobile_email_existence(
  IN _mobile varchar(20),
  IN _email varchar(100),
  IN _employeeid bigint
)
RETURNS SETOF "employees"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _employeecount bigint;
  _mobilecount bigint;
  _emailcount bigint;
BEGIN
  _emailcount := 0;
 _mobilecount := 0;
 _employeecount := 0;
 if exists (select 1 from employees e where e.employeeuid = _employeeid and e.isactive = true) then 
 begin
 _employeecount := 1;
 select count(e.employeeuid) into _emailcount from employees e
 where e.email = _email and e.employeeuid <> _employeeid;
 select count(e.employeeuid) into _mobilecount from employees e
 where e.mobile = _mobile and e.employeeuid <> _employeeid;
 end;
 else
 begin
 select count(e.employeeuid) into _employeecount from employees e
 where e.employeeuid = _employeeid;
 select count(e.employeeuid) into _emailcount from employees e
 where e.email = _email;
 select count(e.employeeuid) into _mobilecount from employees e
 where e.mobile = _mobile; 
 end; 
 end if;
 RETURN QUERY select _employeecount employeecount, _mobilecount mobilecount, _emailcount emailcount;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_check_mobile_email_existence', 1::bit, 0::bit, _result);
END;
$$;
