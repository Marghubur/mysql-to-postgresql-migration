DROP FUNCTION IF EXISTS public.sp_employees_mappedclient_get_all_active();

CREATE OR REPLACE FUNCTION public.sp_employees_mappedclient_get_all_active()
 RETURNS SETOF employeemappedclients
 LANGUAGE plpgsql
AS $function$
DECLARE
    _sqlstate TEXT;
    _errorno TEXT;
    _errortext TEXT;
    _message TEXT;
    _result character varying; -- Matched to the logger OUT parameter
BEGIN
    -- FIXED: Removed the extra 'rowindex' column so it exactly matches the table
    -- FIXED: Changed 'isactive = 1' to 'isactive = true'
    RETURN QUERY 
    SELECT m.* 
    FROM employeemappedclients m
    WHERE isactive = true
    ORDER BY m.employeemappedclientsuid;
    
EXCEPTION WHEN OTHERS THEN
    _sqlstate := SQLSTATE;
    _errortext := SQLERRM;
    _errorno := SQLSTATE;
    _message := concat('ERROR ', _errorno, ' (', _sqlstate, '): ', _errortext);
    
    -- FIXED: Added ::varchar casts so the logger doesn't crash
    CALL sp_logexception(_message, ''::varchar, 'sp_employees_mappedclient_get_all_active'::varchar, 1, 0, _result);
END;
$function$;
