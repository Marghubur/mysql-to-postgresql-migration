CREATE OR REPLACE PROCEDURE public.sp_complaint_or_request_update_status(
  IN _complaintorrequestid integer,
  IN _executedbymanager bit,
  IN _executerid bigint,
  IN _executername varchar(100),
  IN _executeremail varchar(50),
  IN _managercomments varchar(500),
  IN _statusid integer,
  IN _attendanceid integer,
  IN _attendancestatus integer,
  IN _reviewername varchar(100),
  IN _userid bigint,
  IN _reviewerid bigint,
  IN _revieweremail varchar(100),
  IN _totalminutes integer
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
  if exists (select 1 from complaint_or_request where complaintorrequestid = _complaintorrequestid) then
 begin
 update complaint_or_request set 
 managercomments = _managercomments,
 currentstatus = _statusid,
 updatedon = timezone('utc', now()), 
 executedbymanager = _executedbymanager,
 executerid = _executerid,
 executername = _executername,
 executeremail = _executeremail
 where complaintorrequestid = _complaintorrequestid;
 end;
 end if;
 if exists (select 1 from daily_attendance where attendanceid = _attendanceid) then
 begin
 update daily_attendance set
 attendancestatus = _attendancestatus,
 reviewername = _reviewername,
 reviewerid = _reviewerid,
 revieweremail = _revieweremail,
 totalminutes = _totalminutes,
 updatedby = _userid,
 updatedon = timezone('utc', now())
 where attendanceid = _attendanceid;
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_complaint_or_request_update_status', 1::bit, 0::bit, _result);
END;
$$;
