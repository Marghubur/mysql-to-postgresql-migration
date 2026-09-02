CREATE OR REPLACE PROCEDURE public.sp_daily_attendance_ins_advance_by_empid(
  IN _fromdate timestamp,
  IN _todate timestamp,
  IN _attendancestatus integer,
  IN _employeeid bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _id bigint;
BEGIN
  _id := 0;
 select attendanceid into _id from daily_attendance order by attendanceid desc limit 1;
 insert into daily_attendance (
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
 createdby,
 createdon,
 updatedby,
 updatedon
 )
 select
 _id + row_number() over (),
 e.employeeuid,
 concat(e.firstname, ' ', e.lastname),
 e.email,
 0 as reviewerid,
 null,
 null,
 0 as projectid,
 0 as taskid,
 0 as tasktype,
 '00:00:00' as logon,
 '00:00:00' as logoff,
 480 as totalminutes,
 '[]' as comments,
 case
 when weekday(date_add(_fromdate, (seq - 0) * interval '1 day')) = 6
 then 3
 else _attendancestatus
 end as attendancestatus,
 weekofyear(date_add(_fromdate, (seq - 1) * interval '1 day')) as weekofyear,
 date_add(_fromdate, (seq - 1) * interval '1 day') as attendancedate,
 1,
 false,
 0,
 1 as createdby,
 now() as createdon,
 null as updatedby,
 null as updatedon
 from employees e,
 (select (t2.n * 100) + (t1.n * 10) + (t0.n) + 1 as seq
 from
 (select 0 as n union all select 1 union all select 2 union all select 3 union all select 4 union all
 select 5 union all select 6 union all select 7 union all select 8 union all select 9) t0,
 (select 0 as n union all select 1 union all select 2 union all select 3 union all select 4 union all
 select 5 union all select 6 union all select 7 union all select 8 union all select 9) t1,
 (select 0 as n union all select 1 union all select 2 union all select 3 union all select 4 union all
 select 5 union all select 6 union all select 7 union all select 8 union all select 9) t2
 ) numbers
 where
 e.employeeuid = _employeeid
 and date_add(_fromdate, (seq - 1) * interval '1 day') <= _todate
 and not exists (
 select 1 
 from daily_attendance da 
 where da.employeeid = _employeeid
 and da.attendancedate = date_add(_fromdate, (seq - 1) * interval '1 day')
 );
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_daily_attendance_ins_advance_by_empid', 1::bit, 0::bit, _result);
END;
$$;
