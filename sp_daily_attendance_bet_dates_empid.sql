CREATE OR REPLACE FUNCTION public.sp_daily_attendance_bet_dates_empid(
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
  _workshiftid bigint;
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
 left join company_calendar c on a.attendancedate = c.calendardate
 where attendancedate between _fromdate and _todate
 and employeeid = _employeeid;
 _workshiftid := 0;
 select workshiftid into _workshiftid from employees where employeeuid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from work_shifts where workshiftid = _workshiftid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from attendance_setting;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_bet_dates_empid', 1::bit, 0::bit, _result);
END;
$$;
