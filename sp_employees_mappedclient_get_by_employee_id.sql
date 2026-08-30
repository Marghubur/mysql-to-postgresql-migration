DROP FUNCTION IF EXISTS public.sp_employees_mappedclient_get_by_employee_id(int8);

CREATE OR REPLACE FUNCTION public.sp_employees_mappedclient_get_by_employee_id(_employeeid bigint)
 RETURNS SETOF employeemappedclients
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- FIXED: Matched to the logger OUT parameter
BEGIN
    -- FIXED: Removed the extra 'rowindex' column
    -- FIXED: Changed 'isactive = 1' to 'isactive = true'
    RETURN QUERY 
    SELECT m.* 
    FROM employeemappedclients m
    WHERE isactive = true AND employeeuid = _employeeid
    ORDER BY m.employeemappedclientsuid;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(
        _message, 
        ''::varchar, 
        'sp_employees_mappedclient_get_by_employee_id'::varchar, 
        1, 
        0, 
        _result
    );
END;
$function$;
