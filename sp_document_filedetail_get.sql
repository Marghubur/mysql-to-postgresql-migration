CREATE OR REPLACE FUNCTION public.sp_document_filedetail_get(
  IN _ownerid bigint,
  IN _usertypeid bigint
)
RETURNS SETOF "userfiledetail"
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _operationstatus bigint;
BEGIN
  _operationstatus := '';
 begin
 
 begin
 RETURN QUERY select 
 u.fileid,
 u.fileownerid,
 u.filepath,
 u.parentfolder,
 u.filename,
 u.fileextension,
 u.usertypeid,
 u.createdby,
 u.updatedon
 from userfiledetail u
 where u.fileownerid = _ownerid and u.usertypeid = _usertypeid;
 end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_document_filedetail_get', 1::bit, 0::bit, _result);
END;
$$;
