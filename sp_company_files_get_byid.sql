CREATE OR REPLACE FUNCTION public.sp_company_files_get_byid(
  IN _companyid integer
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
  RETURN QUERY select 
 companyfileid fileid, 
 companyid,
 filename,
 filedescription,
 filepath,
 filerole,
 fileextension
 from company_files
 where companyid = _companyid;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_files_get_byid', 1::bit, 0::bit, _result);
END;
$$;
