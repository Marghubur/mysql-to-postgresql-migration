CREATE OR REPLACE PROCEDURE public.sp_company_files_delete_by_id(
  IN _companyfileid integer
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
 
 delete from company_files where companyfileid = _companyfileid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_files_delete_by_id', 1::bit, 0::bit, _result);
END;
$$;
