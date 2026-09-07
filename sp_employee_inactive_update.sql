-- Drop both procedure and function variants to completely clear the routine kind conflict
DROP PROCEDURE IF EXISTS public.sp_employee_inactive_update(bigint);
DROP FUNCTION IF EXISTS public.sp_employee_inactive_update(bigint);

-- Recreate cleanly as a FUNCTION returning jsonb
CREATE OR REPLACE FUNCTION public.sp_employee_inactive_update(
    IN _employeeuid bigint
)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _processingresult character varying;
    _response jsonb;
BEGIN
    UPDATE employees 
    SET isactive = false 
    WHERE employeeuid = _employeeuid;
    
    _processingresult := 'In active';

    _response := jsonb_build_object(
        'status', _processingresult,
        'employeeuid', _employeeuid
    );

    RETURN _response;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_inactive_update'::varchar, 1, 0, _result);
    RETURN json_build_object('error', _message)::jsonb;
END;
$function$;
