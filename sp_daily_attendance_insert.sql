CREATE OR REPLACE PROCEDURE public.sp_daily_attendance_insert(
  IN _attendanceid bigint,
  IN _employeeid bigint,
  IN _employeename varchar(100),
  IN _employeeemail varchar(100),
  IN _reviewerid bigint,
  IN _reviewername varchar(100),
  IN _revieweremail varchar(100),
  IN _projectid integer,
  IN _taskid integer,
  IN _tasktype integer,
  IN _logon varchar(10),
  IN _logoff varchar(10),
  IN _totalminutes integer,
  IN _comments jsonb,
  IN _attendancestatus integer,
  IN _weekofyear integer,
  IN _attendancedate timestamp,
  IN _worktypeid integer,
  IN _isonleave boolean,
  IN _leaveid integer,
  IN _adminid bigint,
  OUT _processingresult varchar(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _email TEXT;
BEGIN
  begin
 if not exists (select * from daily_attendance where employeeid = _employeeid and attendancedate =_attendancedate) then
 begin
 _attendanceid := 0;
 select attendanceid into _attendanceid from daily_attendance order by attendanceid desc limit 1;
 _attendanceid := _attendanceid + 1;
 _employeeid := 0;
 _employeename := '';
 _email := '';
 select employeeuid, concat(firstname, ' ', lastname) as fullname , email
 into _employeeid, _employeename, _email from employees 
 where email = _employeeemail or employeeuid = _employeeid;
 if (_employeeid > 0 and _employeename is not null) then
 begin
 insert into daily_attendance values (
 _attendanceid,
 _employeeid,
 _employeename,
 _email,
 _reviewerid,
 _reviewername,
 _revieweremail,
 _projectid,
 _taskid,
 _tasktype,
 _logon,
 _logoff,
 _totalminutes,
 _comments,
 _attendancestatus,
 _weekofyear,
 _attendancedate,
 _worktypeid,
 _isonleave,
 _leaveid,
 _adminid,
 now(),
 _adminid,
 null
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 _processingresult := 'employee not found';
 end;
 end if;
 end;
 end if;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_insert', 1::bit, 0::bit, _result);
END;
$$;
