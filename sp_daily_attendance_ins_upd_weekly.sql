CREATE OR REPLACE PROCEDURE public.sp_daily_attendance_ins_upd_weekly(
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
  IN _isonleave bit,
  IN _leaveid integer,
  IN _createdby bigint,
  OUT _processingresult varchar(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  if not exists(select 1 from daily_attendance where attendanceid = _attendanceid) then
 begin
 _attendanceid := 0;
 select attendanceid into _attendanceid from daily_attendance order by attendanceid desc limit 1;
 _attendanceid := _attendanceid + 1;
 
 insert into daily_attendance values (
 _attendanceid,
 _employeeid,
 _employeename,
 _employeeemail,
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
 _createdby,
 now(),
 _createdby,
 null
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update daily_attendance set
 reviewerid = _reviewerid,
 reviewername = _reviewername,
 revieweremail = _revieweremail,
 projectid = _projectid,
 taskid = _taskid,
 tasktype = _tasktype,
 logon = _logon,
 logoff = _logoff,
 totalminutes = _totalminutes,
 comments = _comments,
 attendancestatus = _attendancestatus,
 weekofyear = _weekofyear,
 attendancedate = _attendancedate,
 worktypeid = _worktypeid,
 isonleave = _isonleave,
 leaveid = _leaveid,
 updatedby = _createdby,
 updatedon = timezone('utc', now())
 where attendanceid = _attendanceid;
 
 _processingresult := 'updated';
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_ins_upd_weekly', 1::bit, 0::bit, _result);
END;
$$;
