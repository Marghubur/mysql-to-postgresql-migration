CREATE OR REPLACE FUNCTION public.sp_employee_assets_allocation_get_by_id(_employeeassetsallocationid bigint)
 RETURNS SETOF employee_assets_allocation
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Changed TEXT to character varying
BEGIN
    RETURN QUERY 
    SELECT * FROM employee_assets_allocation 
    WHERE employeeassetsallocationid = _employeeassetsallocationid;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employee_assets_allocation_get_by_id'::varchar, 1, 0, _result);
END;
$function$;
