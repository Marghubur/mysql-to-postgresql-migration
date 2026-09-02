CREATE OR REPLACE FUNCTION public.sp_company_getbyid(
  IN _companyid integer
)
RETURNS SETOF "company"
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
 
 RETURN QUERY select c.*, s.probationperiodindays, s.noticeperiodindays from company c
 left join bank_accounts b on c.companyid = b.companyid
 left join company_setting s on s.companyid = b.companyid
 where c.companyid = _companyid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_getbyid', 1::bit, 0::bit, _result);
END;
$$;
