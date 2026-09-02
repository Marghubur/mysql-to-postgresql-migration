CREATE OR REPLACE FUNCTION public.sp_daily_attendance_config_data(
  IN _employeeid bigint
)
RETURNS SETOF "attendance_setting"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _attendancetype TEXT;
  _todate TEXT;
  _fromdate TEXT;
  _attendanceviewlimit bigint;
  _workingshiftid bigint;
BEGIN
  _attendancetype := false;
 _attendanceviewlimit := 0;
 select attendancetype, attendanceviewlimit into _attendancetype, _attendanceviewlimit
 from attendance_setting;
 _todate := timezone('utc', now());
 _fromdate := case _attendancetype
 when true
 then
 date_sub(date_sub(_todate, (weekday(_todate)) * interval '1 day'), (_attendanceviewlimit) * interval '1 week')
 else
 date_sub(_todate, (_attendanceviewlimit) * interval '1 day')
 end;
 _fromdate := date_sub(_fromdate, (1) * interval '1 day');
 RETURN QUERY select
 a.attendanceid,
 a.employeeid,
 a.employeename,
 a.employeeemail,
 a.reviewerid,
 a.reviewername,
 a.revieweremail,
 a.projectid,
 a.taskid,
 a.tasktype,
 a.logon,
 a.logoff,
 a.totalminutes,
 a.comments,
 a.attendancestatus,
 a.weekofyear,
 a.attendancedate,
 a.worktypeid,
 a.isonleave,
 a.leaveid,
 a.updatedon,
 case
 when a.attendancedate = c.calendardate
 and c.isholiday = true then true
 else false
 end
 isholiday,
 case
 when a.attendancedate = c.calendardate and c.isholiday = true then c.companycalendarid
 else 0
 end
 holidayid
 from daily_attendance a
 left join company_calendar c on a. attendancedate = c.calendardate
 where
 a.attendancedate between _fromdate and _todate
 and a.employeeid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from leave_request_notification where employeeid = _employeeid;
 _workingshiftid := 0;
 select workshiftid into _workingshiftid from employees where employeeuid = _employeeid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from work_shifts where workshiftid = _workingshiftid;
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from attendance_setting;
 if exists (select 1 from project_members_detail where employeeid = _employeeid and isactive = true) then
 begin
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from project p
 inner join project_members_detail pm on pm.projectid = p.projectid
 where pm.employeeid = _employeeid
 and pm.isactive = true;
 end;
 else
 begin
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from project where projectid = 1;
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_config_data', 1::bit, 0::bit, _result);
END;
$$;
