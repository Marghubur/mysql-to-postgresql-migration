CREATE OR REPLACE PROCEDURE public.sp_company_notification_insupd(
  IN _notificationid bigint,
  IN _topic varchar(100),
  IN _briefdetail varchar(250),
  IN _companyid integer,
  IN _departments jsonb,
  IN _completedetail text,
  IN _startdate timestamp,
  IN _enddate timestamp,
  IN _isgeneralannouncement bit,
  IN _announcementtype integer,
  IN _fileids jsonb,
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
BEGIN
  begin
 start transaction;
 begin
 if not exists (select * from company_notification where notificationid = _notificationid) then
 begin
 insert into company_notification values (
 default,
 _topic,
 _companyid,
 _briefdetail,
 _departments,
 _completedetail,
 _startdate,
 _enddate,
 _isgeneralannouncement,
 _announcementtype,
 _fileids,
 _adminid,
 null,
 timezone('utc', now()),
 null
 );
 _processingresult := 'inserted';
 end;
 else
 begin
 update company_notification set 
 companyid = _companyid,
 topic = _topic,
 briefdetail = _briefdetail,
 departments = _departments,
 completedetail = _completedetail,
 startdate = _startdate,
 enddate = _enddate,
 isgeneralannouncement = _isgeneralannouncement,
 announcementtype = _announcementtype,
 fileids = _fileids,
 updatedby = _adminid,
 updatedon = timezone('utc', now())
 where notificationid = _notificationid;
 _processingresult := 'updated';
 end;
 end if;
 end;
 commit;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_notification_insupd', 1::bit, 0::bit, _result);
END;
$$;
