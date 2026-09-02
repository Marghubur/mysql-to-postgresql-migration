CREATE OR REPLACE FUNCTION public.sp_company_files_get_byids_json(
  IN _companyfileid jsonb
)
RETURNS SETOF "company_files"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
BEGIN
  RETURN QUERY select c.* from company_files c
 inner join (
 select *
 from
 json_table(
 _companyfileid,
 '$[*]'
 columns(
 col int path '$'
 )
 ) data
 ) t on c.companyfileid = t.col;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_files_get_byids_json', 1::bit, 0::bit, _result);
END;
$$;
