CREATE OR REPLACE PROCEDURE public.sp_company_files_insupd(
  IN _companyfileid integer,
  IN _companyid integer,
  IN _filename varchar(145),
  IN _filedescription varchar(500),
  IN _fileextension varchar(10),
  IN _filepath text,
  IN _filerole varchar(100),
  IN _adminid bigint,
  OUT _processingresult varchar(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
  _sqlstate TEXT;
  _errorno TEXT;
  _errortext TEXT;
  _message TEXT;
  _result TEXT;
  _fileid bigint;
BEGIN
  begin
 _fileid := 0;
 -- autocommit ignored
 -- sql_safe_updates ignored
 if not exists (select 1 from company_files where companyfileid = _companyfileid) then
 begin
 _fileid := 0;
 select companyfileid from company_files order by companyfileid desc limit 1 into _fileid ;
 _fileid := _fileid+1;
 insert into company_files values(
 _fileid,
 _companyid,
 _filename,
 _filedescription,
 _fileextension,
 _filepath,
 _filerole,
 _adminid,
 _adminid,
 timezone('utc', now()),
 null 
 );
 _processingresult := _fileid;
 end;
 else
 begin
 _fileid := _companyfileid;
 update company_files set 
 companyid = _companyid,
 filename = _filename,
 filedescription = _filedescription,
 fileextension = _fileextension,
 filepath = _filepath,
 filerole = _filerole,
 updatedby = _adminid,
 updatedon = timezone('utc', now())
 where companyfileid = _companyfileid;
 _processingresult := _fileid;
 end;
 end if; 
 -- sql_safe_updates ignored
 -- autocommit ignored
 end;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_company_files_insupd', 1::bit, 0::bit, _result);
END;
$$;
