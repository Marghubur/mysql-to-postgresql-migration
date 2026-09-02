CREATE OR REPLACE FUNCTION public.sp_document_filedetail_insupd(
  IN _insertfilejsondata jsonb
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
  i integer := 0;
  count integer := -1;
  _fileid bigint := -1;
  _fileownerid bigint := -1;
  _filename varchar(100);
  _filepath varchar(500);
  _parentfolder varchar(500);
  _fileextension varchar(100);
  _statusid bigint := -1;
  _usertypeid integer := -1;
  _adminid bigint := -1;
BEGIN
  begin
 if (_insertfilejsondata is not null) then
 begin
 _fileid := -1;
 count := count + json_length(_insertfilejsondata, '$');
 while (i <= count) loop
 begin
 _fileid := json_extract(_insertfilejsondata, concat( '$[', i, '].FileId'));
 _fileownerid := json_extract(_insertfilejsondata, concat( '$[', i, '].FileOwnerId'));
 _filename := json_unquote(json_extract(_insertfilejsondata, concat( '$[', i, '].FileName')));
 _filepath := json_unquote(json_extract(_insertfilejsondata, concat( '$[', i, '].FilePath')));
 _parentfolder := json_unquote(json_extract(_insertfilejsondata, concat( '$[', i, '].ParentFolder')));
 _fileextension := json_unquote(json_extract(_insertfilejsondata, concat( '$[', i, '].FileExtension')));
 _statusid := json_extract(_insertfilejsondata, concat( '$[', i, '].StatusId'));
 _usertypeid := json_extract(_insertfilejsondata, concat( '$[', i, '].UserTypeId'));
 _adminid := json_extract(_insertfilejsondata, concat( '$[', i, '].AdminId'));
 if not exists (select 1 from userfiledetail where fileid = _fileid) then
 begin
 insert into userfiledetail values(
 default, 
 _fileownerid,
 _filepath,
 _parentfolder,
 _filename,
 _fileextension,
 _statusid,
 _usertypeid,
 _adminid,
 null,
 timezone('utc', now()),
 null
 );
 end;
 else 
 begin
 update userfiledetail set
 filepath = _filepath,
 parentfolder = _parentfolder,
 filename = _filename,
 fileextension = _fileextension,
 itemstatusid = _statusid,
 usertypeid = _usertypeid,
 updatedby = _adminid,
 updatedon = timezone('utc', now())
 where fileid = _fileid;
 end;
 end if;
 i := i + 1;
 end;
 end loop;
 end; 
 end if;
 RETURN QUERY select * from userfiledetail where fileownerid = _fileownerid;
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_document_filedetail_insupd', 1::bit, 0::bit, _result);
END;
$$;
