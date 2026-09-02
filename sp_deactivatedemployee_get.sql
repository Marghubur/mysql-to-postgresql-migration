CREATE OR REPLACE FUNCTION public.sp_deactivatedemployee_get(
)
RETURNS SETOF "employeemappedclients"
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
 begin
 
 RETURN QUERY select e.employeeuid,
 e.firstname,
 e.lastname,
 e.mobile,
 e.email,
 ep.aadharno,
 ep.panno,
 ep.accountnumber,
 ep.bankname,
 ep.ifsccode,
 ep.domain,
 ep.specification,
 ep.exprienceinyear,
 false isactive,
 0 actualpackage,
 0 finalpackage,
 0 takehomebycandidate,
 (
 select 
 json_arrayagg(clientuid)
 from employeemappedclients 
 where employeeuid = e.employeeuid
 ) as clientjson
 from employee_archive e 
 inner join employeeprofessiondetail_archive ep on ep.employeeuid = e.employeeuid;
 
 end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_deactivatedemployee_get', 1::bit, 0::bit, _result);
END;
$$;
