CREATE OR REPLACE FUNCTION public.sp_current_seeion_by_emp_id(
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
BEGIN
  RETURN QUERY select 
 concat(e.firstname, ' ' , e.lastname) as fullname,
 e.employeeuid as userid,
 e.reportingmanagerid,
 e.email as emailid,
 e.mobile,
 concat(em.firstname, ' ' , em.lastname) as managername,
 em.email as manageremail,
 e.designationid,
 c.employeecodeprefix,
 c.employeecodelength,
 c.financialyear as financialstartyear,
 cm.organizationid,
 cm.companyname,
 c.companyid,
 c.timezonename as timezonename,
 l.accesslevelid as roleid
 from employees e
 join employees em on em.employeeuid = e.reportingmanagerid
 left join company_setting c on c.companyid = e.companyid
 left join company cm on cm.companyid = e.companyid
 left join employeelogin l on l.employeeid = e.employeeuid
 where e.employeeuid = _employeeid;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_current_seeion_by_emp_id', 1::bit, 0::bit, _result);
END;
$$;
