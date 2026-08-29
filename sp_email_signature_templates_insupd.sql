-- DROP PROCEDURE public.sp_email_signature_templates_insupd(in int4, in varchar, in varchar, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_email_signature_templates_insupd(IN _emailsignaturetemplateid integer, IN _templatename character varying, IN _signaturetemplateurl character varying, IN _createdby bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
BEGIN
    _processingresult := '';

 if not exists (
 select 1 from email_signature_templates
 where emailsignaturetemplateid = _emailsignaturetemplateid
 ) then
 insert into email_signature_templates
 (
 templatename,
 signaturetemplateurl,
 createdon,
 createdby
 )
 values
 (
 _templatename,
 _signaturetemplateurl,
 timezone('utc', now()),
 _createdby
 );

 _processingresult := 'inserted';
 else
 update email_signature_templates set
 templatename = _templatename,
 signaturetemplateurl = _signaturetemplateurl
 where emailsignaturetemplateid = _emailsignaturetemplateid;

 _processingresult := 'updated';
 end if;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    CALL sp_logexception(_message, '', 'sp_email_signature_templates_insupd', 1, 0, _result);
END;
$procedure$
;
