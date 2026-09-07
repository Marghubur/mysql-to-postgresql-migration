-- DROP FUNCTION public.sp_employee_email_mobile_duplicate_checked(varchar, varchar);

CREATE OR REPLACE FUNCTION public.sp_employee_email_mobile_duplicate_checked(_mobile character varying, _email character varying)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _mobilecount bigint;
    _emailcount bigint;
    _response jsonb;
BEGIN
    _emailcount := 0;
    _mobilecount := 0;
    
    SELECT count(e.employeeuid) INTO _emailcount 
    FROM employees e
    WHERE e.email = _email;
    
    SELECT count(e.employeeuid) INTO _mobilecount 
    FROM employees e
    WHERE e.mobile = _mobile;
    
    SELECT jsonb_build_object(
        'mobile_count', _mobilecount,
        'email_count', _emailcount
    ) INTO _response;

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_email_mobile_duplicate_checked'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$
;
