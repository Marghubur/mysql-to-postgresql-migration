CREATE OR REPLACE PROCEDURE public.sp_complaint_or_request_insupdate(
  IN _attendanceid integer,
  IN _attendancestatus integer,
  IN _totalminutes integer,
  IN _complaintorrequestid integer,
  IN _requesttypeid integer,
  IN _targetid integer,
  IN _targetoffset integer,
  IN _employeeid bigint,
  IN _employeename varchar(100),
  IN _email varchar(50),
  IN _mobile varchar(20),
  IN _managerid bigint,
  IN _managername varchar(100),
  IN _manageremail varchar(50),
  IN _managermobile varchar(20),
  IN _employeemessage text,
  IN _managercomments text,
  IN _currentstatus integer,
  IN _requestedon timestamp,
  IN _attendancedate timestamp,
  IN _leavefromdate timestamp,
  IN _leavetodate timestamp,
  IN _notify jsonb,
  IN _executedbymanager bit,
  IN _executerid bigint,
  IN _executername varchar(100),
  IN _executeremail varchar(50),
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
  _complaintorrequestid := 0;
 select complaintorrequestid into _complaintorrequestid from complaint_or_request 
 order by complaintorrequestid desc limit 1;
 _complaintorrequestid := _complaintorrequestid + 1; 
 if not exists (select 1 from complaint_or_request where complaintorrequestid = _complaintorrequestid) then
 begin
 insert into complaint_or_request values (
 _complaintorrequestid,
 _requesttypeid,
 _targetid,
 _targetoffset,
 _employeeid,
 _employeename,
 _email,
 _mobile,
 _managerid,
 _managername,
 _manageremail,
 _managermobile,
 _employeemessage,
 _managercomments,
 _currentstatus,
 _requestedon,
 _attendancedate,
 _leavefromdate,
 _leavetodate,
 _notify,
 _executedbymanager,
 _executerid,
 _executername,
 _executeremail,
 timezone('utc', now())
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update complaint_or_request set 
 managercomments = _managercomments,
 currentstatus = _currentstatus,
 updatedon = timezone('utc', now()),
 requestedon = _requestedon,
 employeemessage = _employeemessage,
 notify = _notify,
 executedbymanager = _executedbymanager,
 executerid = _executerid,
 executername = _executername,
 executeremail = _executeremail
 where complaintorrequestid = _complaintorrequestid;
 _processingresult := 'updated';
 end;
 end if;
 if exists (select 1 from daily_attendance where attendanceid = _attendanceid) then
 begin
 update attendance set
 attendancestatus = _attendancestatus,
 totalminutes = _totalminutes
 where attendanceid = _attendanceid;
 end;
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_complaint_or_request_insupdate', 1::bit, 0::bit, _result);
END;
$$;
