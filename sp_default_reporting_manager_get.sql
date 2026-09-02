CREATE OR REPLACE FUNCTION public.sp_default_reporting_manager_get(
)
RETURNS SETOF "default_reporting_manager"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  RETURN QUERY select * from default_reporting_manager;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_default_reporting_manager_get', 1::bit, 0::bit, _result);
END;
$$;
