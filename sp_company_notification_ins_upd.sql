CREATE OR REPLACE PROCEDURE public.sp_company_notification_ins_upd(
  IN _notificationid integer,
  IN _title varchar(250),
  
  IN _createdby bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result varchar(500);   -- match sp_logexception._processingresult type
BEGIN
  -- do NOT set _notificationid := 0 here

  IF NOT EXISTS (SELECT 1 FROM company_notification WHERE notificationid = _notificationid) THEN
    SELECT COALESCE(MAX(notificationid), 0) + 1 INTO _notificationid FROM company_notification;

    INSERT INTO company_notification(notificationid, title, subtitle, departments,
      notificationmessage, parsedcontentmessage, notificationtypeid, imageattachments,
      fileids, autodeleteenabled, lifespaninminutes, createdby, createdon)
    VALUES (_notificationid, _title, _subtitle, _departments, _notificationmessage,
      _parsedcontentmessage, _notificationtypeid, _imageattachments, _fileids,
      _autodeleteenabled, _lifespaninminutes, _createdby, now());
  ELSE
    UPDATE company_notification
    SET title = _title,
        subtitle = _subtitle,
        departments = _departments,
        notificationmessage = _notificationmessage,
        parsedcontentmessage = _parsedcontentmessage,
        notificationtypeid = _notificationtypeid,
        imageattachments = _imageattachments,
        fileids = _fileids,
        autodeleteenabled = _autodeleteenabled,
        lifespaninminutes = _lifespaninminutes,
        createdon = now()
    WHERE notificationid = _notificationid;
  END IF;

EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_notification_ins_upd', 1::bit, 0::bit, _result);
END;
$$;
