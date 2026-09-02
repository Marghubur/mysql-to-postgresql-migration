CREATE OR REPLACE FUNCTION public.sp_email_mapped_template_getbyid(
  IN _emailtempmappingid integer
)
RETURNS SETOF "email_mapped_template"
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
 
 RETURN QUERY select * from email_mapped_template
 where emailtempmappingid = _emailtempmappingid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_email_mapped_template_getbyid', 1::bit, 0::bit, _result);
END;
$$;
