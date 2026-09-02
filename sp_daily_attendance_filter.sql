CREATE OR REPLACE FUNCTION public.sp_daily_attendance_filter(
  IN _searchstring varchar(250),
  IN _sortby varchar(50),
  IN _pageindex integer,
  IN _pagesize integer,
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
  _selectquery TEXT;
  _totalemployees TEXT;
  _totalquery TEXT;
BEGIN
  begin
 begin
 if(_sortby is null or _sortby = '') then
 begin
 _sortby := ' a.AttendanceDate DESC ';
 end;
 end if;
 drop table if exists employee_attendance_page;
 create table if not exists employee_attendance_page  as (
 select employeeid
 from (
 select 
 e.employeeuid as employeeid,
 row_number() over (order by e.employeeuid) as rownum
 from employees e
 where (_employeeid = 0 or e.employeeuid = _employeeid)
 ) as numbered
 where rownum between ((_pageindex - 1) * _pagesize + 1) and (_pageindex * _pagesize)
 );
 _totalemployees := 0;
 _totalquery := concat(
 'SELECT COUNT(DISTINCT a.EmployeeId) 
  INTO @TotalEmployees
  FROM daily_attendance a
  INNER JOIN employee_attendance_page e
  ON e.EmployeeId = a.EmployeeId
  WHERE ', _searchstring
 );
 RETURN QUERY EXECUTE _totalquery;
 _selectquery := concat(
 'SELECT * FROM (
  SELECT 
  ROW_NUMBER() OVER (ORDER BY ', _sortby, ') AS RowIndex,
  a.AttendanceId,
  a.EmployeeId,
  a.EmployeeName,
  a.EmployeeEmail,
  a.ReviewerId,
  a.ReviewerName,
  a.ReviewerEmail,
  a.ProjectId,
  a.TaskId,
  a.TaskType,
  a.LogOn,
  a.LogOff,
  a.TotalMinutes,
  a.Comments,
  a.AttendanceStatus,
  a.WeekOfYear,
  a.AttendanceDate,
  a.WorkTypeId,
  a.IsOnLeave,
  a.LeaveId,
  a.UpdatedOn,
  CASE 
  WHEN a.AttendanceDate = c.CalendarDate AND c.IsHoliday = TRUE THEN TRUE
  ELSE FALSE
  END AS IsHoliday,
  CASE 
  WHEN a.AttendanceDate = c.CalendarDate AND c.IsHoliday = TRUE THEN c.CompanyCalendarId
  ELSE 0
  END AS HolidayId,
  ', _totalemployees, ' AS Total
  FROM daily_attendance a
  INNER JOIN employee_attendance_page e
  ON e.EmployeeId = a.EmployeeId
  LEFT JOIN company_calendar c
  ON a.AttendanceDate = c.CalendarDate
  WHERE ', _searchstring, '
  ) AS T'
 );
 RETURN QUERY EXECUTE _selectquery;RETURN QUERY select * from leave_request_notification l
 inner join employee_attendance_page e on e.employeeid = l.employeeid;
 drop table if exists employee_attendance_page;
 end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_filter', 1::bit, 0::bit, _result);
END;
$$;
