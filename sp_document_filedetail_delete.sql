CREATE OR REPLACE PROCEDURE public.sp_document_filedetail_delete(
  IN _fileids varchar(20),
  OUT _processingresult varchar(100)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _deletequery TEXT;
BEGIN
  begin
 _processingresult := '';
 start transaction;
 begin 
 _deletequery := concat('
  Delete from userfiledetail f where f.FileId in (', _fileids ,')
  ');
 
 EXECUTE _deletequery;_processingresult := 'Deleted successfully';
 end;
 commit;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_document_filedetail_delete', 1::bit, 0::bit, _result);
END;
$$;
