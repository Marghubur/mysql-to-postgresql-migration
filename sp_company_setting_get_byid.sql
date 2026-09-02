CREATE OR REPLACE FUNCTION public.sp_company_setting_get_byid(
  IN _companyid integer
)
RETURNS SETOF "company_setting"
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
 RETURN QUERY select c.* from company_setting c
 where c.companyid = _companyid or isprimary = 1;
 
 -- postgres query warning: Multiple result sets are not supported in functions. Commented out: 
select * from org_hierarchy
 where isdepartment = false;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_setting_get_byid', 1::bit, 0::bit, _result);
END;
$$;
