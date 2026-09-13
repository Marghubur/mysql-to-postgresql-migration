DROP PROCEDURE IF EXISTS public.sp_employee_email_mobile_duplicate_checked(character varying, character varying, jsonb);

CREATE OR REPLACE PROCEDURE public.sp_employee_email_mobile_duplicate_checked(
    _mobile character varying, 
    _email character varying,
    INOUT _response jsonb DEFAULT NULL
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errortext TEXT;
    _message TEXT;
    _dummy_result character varying;
BEGIN
    -- Perform both counts in a single table scan
    SELECT jsonb_build_object(
        'mobile_count', COUNT(*) FILTER (WHERE e.mobile = _mobile),
        'email_count',  COUNT(*) FILTER (WHERE e.email = _email)
    )
    INTO _response
    FROM employees e
    WHERE e.mobile = _mobile OR e.email = _email;

EXCEPTION WHEN OTHERS THEN
    _sqlstate  := SQLSTATE;
    _errortext := SQLERRM;
    _message   := concat('ERROR (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_email_mobile_duplicate_checked'::varchar, 1, 0, _dummy_result);
    
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
