CREATE OR REPLACE PROCEDURE public.sp_document_filedetail_getbyid(
  IN _fileids varchar(20),
    INOUT _refcur refcursor DEFAULT 'cur_result'
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _selectquery TEXT;
BEGIN
  begin
 begin
 _selectquery := concat('
  Select 
  f.FileId FileId,
  f.FileOwnerId FileOwnerId,
  f.FileName FileName,
  f.FilePath FilePath,
  f.FileExtension FileExtension,
  f.ItemStatusId StatusId,
  f.UserTypeId UserTypeId,
  f.CreatedBy AdminId  
  from userfiledetail f where f.FileId in (', _fileids ,')
  ');
 
 OPEN _refcur FOR EXECUTE _selectquery;end;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_document_filedetail_getbyid', 1::bit, 0::bit, _result);
END;
$$;
