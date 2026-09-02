CREATE OR REPLACE FUNCTION public.sp_daily_attendance_get(
  IN _employeeid bigint,
  IN _fromdate timestamp,
  IN _todate timestamp,
  IN _companyid integer
)
RETURNS SETOF "daily_attendance"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _dayoflastrundate bigint;
  _paycycledayofmonth bigint;
  _workshiftid bigint;
  _payrolldate TEXT;
  _daysinlastrundate bigint;
  _foryear bigint;
  _formonth bigint;
BEGIN
  RETURN QUERY select 
 a.*
 from daily_attendance a 
 where a.attendancedate between _fromdate and _todate
 and a.employeeid = _employeeid; 
 create table if not exists employeetemptable  as select e.*, c.attendancesubmissionlimit from employees e 
 left join company_setting c on c.companyid = e.companyid
 where e.employeeuid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from employeetemptable;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from company_calendar
 where companyid = _companyid
 and year = year(utc_date())
 and isholiday = true;
 _workshiftid := (select workshiftid from employeetemptable);
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from work_shifts
 where 
 case
 when _workshiftid > 0
 then workshiftid = _workshiftid
 else workshiftid = 1
 end;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from leave_request_notification 
 where employeeid = _employeeid
 and requeststatusid = (select itemstatusid from itemstatus where status = 'Approved');
 _paycycledayofmonth := 0;
 select paycycledayofmonth into _paycycledayofmonth from payroll_cycle_setting;
 _foryear := 0;
 _formonth := 0;
 select foryear, formonth into _foryear, _formonth from payroll_monthly_detail order by foryear desc, formonth desc limit 1;
 _payrolldate := str_to_date(concat(_foryear,'-',lpad(_formonth,2,'00'),'-',lpad(1,2,'00')), '%Y-%m-%d');
 _daysinlastrundate := day(last_day( _payrolldate));
 _dayoflastrundate := if(_paycycledayofmonth > _daysinlastrundate, _daysinlastrundate, _paycycledayofmonth);
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select str_to_date(concat(_foryear,'-',lpad(_formonth,2,'00'),'-',lpad(_dayoflastrundate,2,'00')), '%Y-%m-%d') as lastrunpayrolldate; 
 
 drop table if exists employeetemptable;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_get', 1::bit, 0::bit, _result);
END;
$$;
