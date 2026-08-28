-- DROP FUNCTION public.sp_email_templates_insupd(int4, varchar, varchar, int8);

CREATE OR REPLACE FUNCTION public.sp_email_templates_insupd(_emailtemplateid integer, _templatename character varying, _sampletemplateurl character varying, _createdby bigint)
 RETURNS character varying
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _processingresult character varying;
BEGIN
    _processingresult := '';

    IF NOT EXISTS (
        SELECT 1 FROM email_templates 
        WHERE emailtemplateid = _emailtemplateid
    ) THEN
        INSERT INTO email_templates (
            templatename,
            sampletemplateurl,
            createdon,
            createdby
        )
        VALUES (
            _templatename,
            _sampletemplateurl,
            timezone('utc', now()),
            _createdby
        );

        _processingresult := 'inserted';
    ELSE
        UPDATE email_templates SET
            templatename = _templatename,
            sampletemplateurl = _sampletemplateurl
        WHERE emailtemplateid = _emailtemplateid;

        _processingresult := 'updated';
    END IF;
    
    -- Return the result directly
    RETURN _processingresult;

EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    -- It is perfectly fine to CALL your logging procedure from inside a function
    CALL sp_logexception(_message, '', 'sp_email_templates_insupd', 1, 0, _result);
    RETURN 'error';
END;
$function$
;
