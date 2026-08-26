-- DROP PROCEDURE public.sp_email_mapped_template_insupd(in int4, in int4, in varchar, in int4, in int8, out varchar);

CREATE OR REPLACE PROCEDURE public.sp_email_mapped_template_insupd(IN _emailtempmappingid integer, IN _companyid integer, IN _emailtemplatename character varying, IN _templateid integer, IN _adminid bigint, OUT _processingresult character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result TEXT;
    _mappedid bigint;
BEGIN
    BEGIN
        _mappedid := 0;
        
        IF NOT EXISTS (SELECT 1 FROM email_mapped_template WHERE emailtempmappingid = _emailtempmappingid) THEN
            -- FIXED: Safely get the max ID, defaulting to 0 if the table is empty
            _mappedid := COALESCE((SELECT MAX(emailtempmappingid) FROM email_mapped_template), 0);
            _mappedid := _mappedid + 1;
            
            INSERT INTO email_mapped_template VALUES(
                _mappedid,
                _companyid,
                _emailtemplatename,
                _templateid,
                _adminid,
                _adminid,
                timezone('utc', now()),
                null
            );
            
            _processingresult := 'inserted';
        ELSE
            UPDATE email_mapped_template SET 
                companyid = _companyid,
                emailtemplatename = _emailtemplatename,
                templateid = _templateid,
                updatedby = _adminid,
                updatedon = timezone('utc', now())
            WHERE emailtempmappingid = _emailtempmappingid;
            
            _processingresult := 'updated';
        END IF;
    END;
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- We output the error to your OUT parameter so you can see what failed
    _processingresult := 'failed: ' || _message; 
    
    -- COMMENTED OUT because sp_logexception is missing from your database
    -- CALL sp_logexception(_message, '', 'sp_email_mapped_template_insupd', 1, 0, _result);
END;
$procedure$
;
