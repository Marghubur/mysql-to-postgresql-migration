CREATE OR REPLACE PROCEDURE public.sp_email_link_config_insupd(
  IN _emailtlinkconfigurationid integer,
  IN _templatename varchar(145),
  IN _templateurl varchar(1024),
  IN _signaturetemplateurl varchar(145),
  IN _updatedby bigint,
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
BEGIN
  _processingresult := '';
 if not exists (
 select 1 from email_link_config
 where emailtlinkconfigurationid = _emailtlinkconfigurationid
 ) then
 insert into email_link_config
 (
 templatename,
 templateurl,
 signaturetemplateurl,
 updatedby,
 updatedon
 )
 values
 (
 _templatename,
 _templateurl,
 _signaturetemplateurl,
 _updatedby,
 timezone('utc', now())
 );
 _processingresult := 'inserted';
 else
 update email_link_config set
 templatename = _templatename,
 templateurl = _templateurl,
 signaturetemplateurl = _signaturetemplateurl,
 updatedby = _updatedby,
 updatedon = timezone('utc', now())
 where emailtlinkconfigurationid = _emailtlinkconfigurationid;
 _processingresult := 'updated';
 end if;
EXCEPTION WHEN OTHERS THEN
  _sqlstate := SQLSTATE;
  _errortext := SQLERRM;
  _errorno := SQLSTATE;
  _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
  CALL public.sp_logexception(_message, '', 'sp_email_link_config_insupd', 1::bit, 0::bit, _result);
END;
$$;
