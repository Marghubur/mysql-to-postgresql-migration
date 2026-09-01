CREATE OR REPLACE FUNCTION public.sp_company_notification_getby_id(
  IN _notificationid bigint
)
RETURNS SETOF "company_notification"
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
 RETURN QUERY select * from company_notification where notificationid = _notificationid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_notification_getby_id', 1::bit, 0::bit, _result);
END;
$$;
