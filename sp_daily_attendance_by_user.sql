CREATE OR REPLACE FUNCTION public.sp_daily_attendance_by_user(
  IN _fromdate timestamp,
  IN _todate timestamp,
  IN _employeeid bigint
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
BEGIN
  RETURN QUERY select
 attendanceid,
 employeeid,
 employeename,
 employeeemail,
 reviewerid,
 reviewername,
 revieweremail,
 projectid,
 taskid, 
 tasktype,
 logon,
 logoff,
 totalminutes,
 comments, 
 attendancestatus,
 weekofyear,
 attendancedate,
 worktypeid,
 isonleave,
 leaveid,
 a.updatedon,
 case 
 when a.attendancedate = c.calendardate 
 and c.isholiday = true then true
 else false
 end
 isholiday,
 case 
 when attendancedate = c.calendardate and c.isholiday = true then c.companycalendarid
 else 0
 end
 holidayid
 from daily_attendance a
 left join company_calendar c on attendancedate = calendardate
 where attendancedate between _fromdate and _todate
 and employeeid = _employeeid;
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from leave_request_notification
 where employeeid = _employeeid
 and requeststatusid = 9;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select e.*, c.attendancesubmissionlimit from employees e 
 left join company_setting c on c.companyid = e.companyid
 where e.employeeuid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from work_shifts w
 where w.workshiftid = (select workshiftid from employees where employeeuid = _employeeid);
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_by_user', 1::bit, 0::bit, _result);
END;
$$;
