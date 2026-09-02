CREATE OR REPLACE FUNCTION public.sp_company_calendar_all_company(
  IN _companyid integer
)
RETURNS SETOF "company_calendar"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  RETURN QUERY select * from company_calendar
 where year = year(timezone('utc', now()))
 and companyid = _companyid;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_calendar_all_company', 1::bit, 0::bit, _result);
END;
$$;
