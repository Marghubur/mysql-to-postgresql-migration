DROP PROCEDURE IF EXISTS public.sp_employee_inactive_update(bigint, jsonb);
DROP FUNCTION IF EXISTS public.sp_employee_inactive_update(bigint);

CREATE OR REPLACE PROCEDURE public.sp_employee_inactive_update(
    IN _employeeuid bigint,
    INOUT _response jsonb DEFAULT NULL
)
LANGUAGE plpgsql
AS $procedure$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying;
    _processingresult character varying;
BEGIN
    UPDATE employees 
    SET isactive = false 
    WHERE employeeuid = _employeeuid;
    
    _processingresult := 'In active';

    _response := jsonb_build_object(
        'status', _processingresult,
        'employeeuid', _employeeuid
    );
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_inactive_update'::varchar, 1, 0, _result);
    _response := jsonb_build_object('error', _message);
END;
$procedure$;
